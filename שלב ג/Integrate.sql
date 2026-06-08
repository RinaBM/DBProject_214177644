-- ============================================================
-- Integrate.sql
-- Phase 3 - Integration
-- Guided Tour Management System
--
-- Purpose:
-- 1. Add new attributes from the received Guided Tours system.
-- 2. Use a temporary schema named received to hold the received system data.
-- 3. Migrate the received data into the integrated public schema.
-- 4. Validate the integrated database.
--
-- Important:
-- This script assumes that the received group's backup was already loaded
-- into a temporary schema named received, containing:
-- received.customer, received.guide, received.tour, received.station,
-- received.tourinstance, received.tourstation, received.bookings
-- ============================================================

SET search_path TO public;

-- ============================================================
-- Part 1: Add new columns to the existing tables
-- ============================================================

ALTER TABLE public.guide
ADD COLUMN IF NOT EXISTS school VARCHAR(100);

ALTER TABLE public.route
ADD COLUMN IF NOT EXISTS route_type VARCHAR(30),
ADD COLUMN IF NOT EXISTS area VARCHAR(100),
ADD COLUMN IF NOT EXISTS accessibility INT;

ALTER TABLE public.site
ADD COLUMN IF NOT EXISTS address VARCHAR(150);

ALTER TABLE public.guidedtour
ADD COLUMN IF NOT EXISTS start_time TIME,
ADD COLUMN IF NOT EXISTS end_time TIME;

ALTER TABLE public.booking
ADD COLUMN IF NOT EXISTS total_price NUMERIC(10,2);

ALTER TABLE public.routesite
ADD COLUMN IF NOT EXISTS visit_duration DOUBLE PRECISION;


-- ============================================================
-- Part 2: Verify that the new columns were added
-- ============================================================

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND column_name IN (
      'school',
      'route_type',
      'area',
      'accessibility',
      'address',
      'start_time',
      'end_time',
      'total_price',
      'visit_duration'
  )
ORDER BY table_name, column_name;


-- ============================================================
-- Part 3: Check received data before migration
-- ============================================================

SELECT 'customer -> users' AS migration_part, COUNT(*) AS rows_to_insert
FROM received.customer
UNION ALL
SELECT 'guide -> guide', COUNT(*)
FROM received.guide
UNION ALL
SELECT 'tour -> route', COUNT(*)
FROM received.tour
UNION ALL
SELECT 'station -> site', COUNT(*)
FROM received.station
UNION ALL
SELECT 'tourinstance -> guidedtour', COUNT(*)
FROM received.tourinstance
UNION ALL
SELECT 'tourstation -> routesite', COUNT(*)
FROM received.tourstation
UNION ALL
SELECT 'bookings -> booking', COUNT(*)
FROM received.bookings;


-- ============================================================
-- Part 4: Check that the received data has no broken references
-- ============================================================

SELECT 'missing_customers' AS check_name, COUNT(*) AS missing_count
FROM received.bookings b
LEFT JOIN received.customer c ON b.c_id = c.c_id
WHERE c.c_id IS NULL
UNION ALL
SELECT 'missing_tourinstances', COUNT(*)
FROM received.bookings b
LEFT JOIN received.tourinstance ti ON b.t_i_id = ti.t_i_id
WHERE ti.t_i_id IS NULL
UNION ALL
SELECT 'missing_guides', COUNT(*)
FROM received.tourinstance ti
LEFT JOIN received.guide g ON ti.g_id = g.g_id
WHERE g.g_id IS NULL
UNION ALL
SELECT 'missing_tours', COUNT(*)
FROM received.tourinstance ti
LEFT JOIN received.tour t ON ti.t_name = t.t_name
WHERE t.t_name IS NULL
UNION ALL
SELECT 'missing_stations', COUNT(*)
FROM received.tourstation ts
LEFT JOIN received.station s ON ts.s_name = s.s_name
WHERE s.s_name IS NULL
UNION ALL
SELECT 'missing_tours_in_tourstation', COUNT(*)
FROM received.tourstation ts
LEFT JOIN received.tour t ON ts.t_name = t.t_name
WHERE t.t_name IS NULL;


-- ============================================================
-- Part 5: Migrate received data into the integrated public schema
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- Clean old temporary mapping tables if they exist
-- ------------------------------------------------------------

DROP TABLE IF EXISTS map_customer;
DROP TABLE IF EXISTS map_guide;
DROP TABLE IF EXISTS map_route;
DROP TABLE IF EXISTS map_site;
DROP TABLE IF EXISTS map_guidedtour;
DROP TABLE IF EXISTS map_booking;

-- ------------------------------------------------------------
-- Mapping tables
-- These temporary tables map IDs from the received system
-- to new IDs in our integrated system.
-- ------------------------------------------------------------

CREATE TEMP TABLE map_customer AS
SELECT 
    c_id AS old_c_id,
    c_id + COALESCE((SELECT MAX(user_id) FROM public.users), 0) AS new_user_id
FROM received.customer;

CREATE TEMP TABLE map_guide AS
SELECT 
    g_id AS old_g_id,
    g_id + COALESCE((SELECT MAX(guide_id) FROM public.guide), 0) AS new_guide_id
FROM received.guide;

CREATE TEMP TABLE map_route AS
SELECT
    t_name AS old_t_name,
    ROW_NUMBER() OVER (ORDER BY t_name)
      + COALESCE((SELECT MAX(route_id) FROM public.route), 0) AS new_route_id
FROM received.tour;

CREATE TEMP TABLE map_site AS
SELECT
    s_name AS old_s_name,
    ROW_NUMBER() OVER (ORDER BY s_name)
      + COALESCE((SELECT MAX(site_id) FROM public.site), 0) AS new_site_id
FROM received.station;

CREATE TEMP TABLE map_guidedtour AS
SELECT
    t_i_id AS old_t_i_id,
    t_i_id + COALESCE((SELECT MAX(guided_tour_id) FROM public.guidedtour), 0) AS new_guided_tour_id
FROM received.tourinstance;

CREATE TEMP TABLE map_booking AS
SELECT
    b_id AS old_b_id,
    b_id + COALESCE((SELECT MAX(booking_id) FROM public.booking), 0) AS new_booking_id
FROM received.bookings;


-- ------------------------------------------------------------
-- customer -> users
-- ------------------------------------------------------------

INSERT INTO public.users (
    user_id,
    full_name,
    email,
    phone
)
SELECT
    mc.new_user_id,
    c.c_first_name || ' ' || c.c_last_name AS full_name,
    c.c_email,
    c.c_phone
FROM received.customer c
JOIN map_customer mc ON c.c_id = mc.old_c_id
ON CONFLICT DO NOTHING;


-- ------------------------------------------------------------
-- guide -> guide
-- Phone numbers are converted to match the original system CHECK constraint:
-- phone must start with 05.
-- ------------------------------------------------------------

INSERT INTO public.guide (
    guide_id,
    full_name,
    phone,
    email,
    languages,
    school
)
SELECT
    mg.new_guide_id,
    g.g_first_name || ' ' || g.g_last_name AS full_name,
    '05' || RIGHT(REGEXP_REPLACE(g.g_phone, '\D', '', 'g'), 8) AS phone,
    g.g_email,
    'Not specified' AS languages,
    g.school
FROM received.guide g
JOIN map_guide mg ON g.g_id = mg.old_g_id
ON CONFLICT DO NOTHING;


-- ------------------------------------------------------------
-- tour -> route
-- difficulty_level is converted from numeric values to:
-- Easy / Medium / Hard.
-- distance receives a default positive value because of the CHECK constraint.
-- ------------------------------------------------------------

INSERT INTO public.route (
    route_id,
    route_name,
    difficulty_level,
    estimated_duration,
    distance,
    description,
    route_type,
    area,
    accessibility
)
SELECT
    mr.new_route_id,
    t.t_name AS route_name,
    CASE
        WHEN t.t_level <= 2 THEN 'Easy'
        WHEN t.t_level = 3 THEN 'Medium'
        ELSE 'Hard'
    END AS difficulty_level,
    t.t_duration AS estimated_duration,
    1 AS distance,
    'Imported from received Guided Tours system' AS description,
    t.t_type AS route_type,
    t.area,
    t.accessibility
FROM received.tour t
JOIN map_route mr ON t.t_name = mr.old_t_name
ON CONFLICT DO NOTHING;


-- ------------------------------------------------------------
-- station -> site
-- ------------------------------------------------------------

INSERT INTO public.site (
    site_id,
    site_name,
    country,
    city,
    category,
    description,
    address
)
SELECT
    ms.new_site_id,
    s.s_name AS site_name,
    'Israel' AS country,
    'Not specified' AS city,
    'Station' AS category,
    s.descrip AS description,
    s.s_address AS address
FROM received.station s
JOIN map_site ms ON s.s_name = ms.old_s_name
ON CONFLICT DO NOTHING;


-- ------------------------------------------------------------
-- tourinstance -> guidedtour
-- status is converted to 'Open' to match the original system CHECK constraint.
-- ------------------------------------------------------------

INSERT INTO public.guidedtour (
    guided_tour_id,
    start_date,
    max_participants,
    price,
    status,
    registration_deadline,
    start_time,
    end_time,
    route_id,
    guide_id
)
SELECT
    mgt.new_guided_tour_id,
    ti.t_date AS start_date,
    t.max_participants,
    t.price,
    'Open' AS status,
    (ti.t_date - INTERVAL '7 days')::DATE AS registration_deadline,
    ti.start_time,
    ti.end_time,
    mr.new_route_id,
    mg.new_guide_id
FROM received.tourinstance ti
JOIN received.tour t ON ti.t_name = t.t_name
JOIN map_guidedtour mgt ON ti.t_i_id = mgt.old_t_i_id
JOIN map_route mr ON ti.t_name = mr.old_t_name
JOIN map_guide mg ON ti.g_id = mg.old_g_id
ON CONFLICT DO NOTHING;


-- ------------------------------------------------------------
-- tourstation -> routesite
-- visit_order is forced to be at least 1.
-- ------------------------------------------------------------

INSERT INTO public.routesite (
    route_id,
    site_id,
    visit_order,
    visit_duration
)
SELECT
    mr.new_route_id,
    ms.new_site_id,
    GREATEST(ts.t_index, 1) AS visit_order,
    ts.s_during AS visit_duration
FROM received.tourstation ts
JOIN map_route mr ON ts.t_name = mr.old_t_name
JOIN map_site ms ON ts.s_name = ms.old_s_name
ON CONFLICT DO NOTHING;


-- ------------------------------------------------------------
-- bookings -> booking
-- payment_status is converted to Paid / Pending.
-- number_of_participants is forced to be at least 1.
-- ------------------------------------------------------------

INSERT INTO public.booking (
    booking_id,
    booking_date,
    number_of_participants,
    payment_status,
    total_price,
    user_id,
    guided_tour_id
)
SELECT
    mb.new_booking_id,
    b.b_date AS booking_date,
    GREATEST(b.amount_pepole, 1) AS number_of_participants,
    CASE 
        WHEN b.b_status = TRUE THEN 'Paid'
        ELSE 'Pending'
    END AS payment_status,
    b.total_price,
    mc.new_user_id,
    mgt.new_guided_tour_id
FROM received.bookings b
JOIN map_booking mb ON b.b_id = mb.old_b_id
JOIN map_customer mc ON b.c_id = mc.old_c_id
JOIN map_guidedtour mgt ON b.t_i_id = mgt.old_t_i_id
ON CONFLICT DO NOTHING;

COMMIT;


-- ============================================================
-- Part 6: Validate integrated data
-- ============================================================

-- Check row counts in the integrated tables
SELECT 'users' AS table_name, COUNT(*) AS rows_count FROM public.users
UNION ALL
SELECT 'guide', COUNT(*) FROM public.guide
UNION ALL
SELECT 'route', COUNT(*) FROM public.route
UNION ALL
SELECT 'site', COUNT(*) FROM public.site
UNION ALL
SELECT 'guidedtour', COUNT(*) FROM public.guidedtour
UNION ALL
SELECT 'routesite', COUNT(*) FROM public.routesite
UNION ALL
SELECT 'booking', COUNT(*) FROM public.booking;


-- Check that there are no orphan records after integration
SELECT 'booking_without_user' AS check_name, COUNT(*) AS missing_count
FROM public.booking b
LEFT JOIN public.users u ON b.user_id = u.user_id
WHERE u.user_id IS NULL
UNION ALL
SELECT 'booking_without_guidedtour', COUNT(*)
FROM public.booking b
LEFT JOIN public.guidedtour gt ON b.guided_tour_id = gt.guided_tour_id
WHERE gt.guided_tour_id IS NULL
UNION ALL
SELECT 'guidedtour_without_route', COUNT(*)
FROM public.guidedtour gt
LEFT JOIN public.route r ON gt.route_id = r.route_id
WHERE r.route_id IS NULL
UNION ALL
SELECT 'guidedtour_without_guide', COUNT(*)
FROM public.guidedtour gt
LEFT JOIN public.guide g ON gt.guide_id = g.guide_id
WHERE g.guide_id IS NULL
UNION ALL
SELECT 'routesite_without_route', COUNT(*)
FROM public.routesite rs
LEFT JOIN public.route r ON rs.route_id = r.route_id
WHERE r.route_id IS NULL
UNION ALL
SELECT 'routesite_without_site', COUNT(*)
FROM public.routesite rs
LEFT JOIN public.site s ON rs.site_id = s.site_id
WHERE s.site_id IS NULL;


-- ============================================================
-- Optional final cleanup
-- Run this only after validating that all data was migrated correctly
-- and before creating backup3.sql, if you want a clean final backup.
-- ============================================================

-- DROP SCHEMA received CASCADE;
