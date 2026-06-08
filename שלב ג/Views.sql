-- ============================================================
-- Views.sql
-- Phase 3 - Views for the integrated database
-- Guided Tour Management System
--
-- This file includes:
-- 1. Two views:
--    - original_tours_overview: original department perspective
--    - received_department_view: received department perspective
-- 2. SELECT * queries for each view
-- 3. Two meaningful queries for each view
-- ============================================================

SET search_path TO public;


-- ============================================================
-- View 1: Original department perspective
-- Shows guided tours with route, guide, bookings and revenue.
-- ============================================================

CREATE OR REPLACE VIEW original_tours_overview AS
SELECT
    gt.guided_tour_id,
    r.route_id,
    r.route_name,
    r.difficulty_level,
    r.area,
    r.route_type,
    g.guide_id,
    g.full_name AS guide_name,
    gt.start_date,
    gt.start_time,
    gt.end_time,
    gt.status,
    gt.max_participants,
    COALESCE(SUM(b.number_of_participants), 0) AS registered_participants,
    gt.max_participants - COALESCE(SUM(b.number_of_participants), 0) AS available_places,
    gt.price,
    COALESCE(SUM(
        CASE
            WHEN b.payment_status = 'Paid'
            THEN b.total_price
            ELSE 0
        END
    ), 0) AS paid_revenue
FROM public.guidedtour gt
JOIN public.route r
    ON gt.route_id = r.route_id
JOIN public.guide g
    ON gt.guide_id = g.guide_id
LEFT JOIN public.booking b
    ON gt.guided_tour_id = b.guided_tour_id
GROUP BY
    gt.guided_tour_id,
    r.route_id,
    r.route_name,
    r.difficulty_level,
    r.area,
    r.route_type,
    g.guide_id,
    g.full_name,
    gt.start_date,
    gt.start_time,
    gt.end_time,
    gt.status,
    gt.max_participants,
    gt.price;


-- ============================================================
-- View 2: Received department perspective
-- Presents integrated data using customer / tour / guide style,
-- similar to the terminology of the received system.
-- ============================================================

CREATE OR REPLACE VIEW received_department_view AS
SELECT
    b.booking_id,
    u.user_id AS customer_id,
    u.full_name AS customer_name,
    u.email AS customer_email,
    u.phone AS customer_phone,
    r.route_name AS tour_name,
    r.route_type AS tour_type,
    r.area,
    gt.guided_tour_id AS tour_instance_id,
    gt.start_date AS tour_date,
    gt.start_time,
    gt.end_time,
    g.full_name AS guide_name,
    g.school AS guide_school,
    b.number_of_participants,
    b.payment_status,
    b.total_price
FROM public.booking b
JOIN public.users u
    ON b.user_id = u.user_id
JOIN public.guidedtour gt
    ON b.guided_tour_id = gt.guided_tour_id
JOIN public.route r
    ON gt.route_id = r.route_id
JOIN public.guide g
    ON gt.guide_id = g.guide_id;


-- ============================================================
-- SELECT * from each view
-- These queries are used for the report screenshots.
-- ============================================================

SELECT *
FROM original_tours_overview
LIMIT 10;

SELECT *
FROM received_department_view
LIMIT 10;


-- ============================================================
-- Queries on View 1: original_tours_overview
-- ============================================================

-- Query 1.1:
-- Open guided tours that still have available places.
SELECT
    guided_tour_id,
    route_name,
    guide_name,
    start_date,
    max_participants,
    registered_participants,
    available_places
FROM original_tours_overview
WHERE status = 'Open'
  AND available_places > 0
ORDER BY start_date
LIMIT 10;


-- Query 1.2:
-- Total number of tours and paid revenue by difficulty level.
SELECT
    difficulty_level,
    COUNT(guided_tour_id) AS total_tours,
    SUM(paid_revenue) AS total_paid_revenue
FROM original_tours_overview
GROUP BY difficulty_level
ORDER BY total_paid_revenue DESC;


-- ============================================================
-- Queries on View 2: received_department_view
-- ============================================================

-- Query 2.1:
-- Paid bookings from the received department perspective.
SELECT
    booking_id,
    customer_name,
    tour_name,
    tour_date,
    number_of_participants,
    total_price
FROM received_department_view
WHERE payment_status = 'Paid'
ORDER BY tour_date DESC
LIMIT 10;


-- Query 2.2:
-- Number of bookings and total revenue by guide school.
-- Rows with NULL guide_school are filtered out because school was added
-- from the received department and does not exist for all original records.
SELECT
    guide_school,
    COUNT(booking_id) AS total_bookings,
    COALESCE(SUM(total_price), 0) AS total_revenue
FROM received_department_view
WHERE guide_school IS NOT NULL
GROUP BY guide_school
ORDER BY total_revenue DESC
LIMIT 10;
