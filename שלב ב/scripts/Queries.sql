/*
=========================================================
Phase 2 - Queries.sql
SmartRoute - Guided Travel Routes Management System

The queries in this file are adapted to the GUI screens:
1. Dashboard
2. Routes
3. Sites
4. Tours
5. Travelers
6. Bookings

The file includes:
- 8 SELECT queries
- 4 SELECT queries written in two different ways
- 3 UPDATE queries
- 3 DELETE queries
=========================================================
*/

/*
=========================================================
SELECT Query 1
Dashboard summary

Screen:
Dashboard / Home

Purpose:
This query provides the main numbers shown in the dashboard cards:
total revenue, number of active routes, number of tours, and number of bookings.

The query joins several tables and uses aggregate functions.
=========================================================
*/

SELECT
    COALESCE(SUM(
        CASE
            WHEN b.payment_status = 'Paid'
            THEN b.number_of_participants * gt.price
            ELSE 0
        END
    ), 0) AS total_revenue,

    COUNT(DISTINCT CASE
        WHEN gt.status = 'Open' THEN r.route_id
    END) AS active_routes,

    COUNT(DISTINCT gt.guided_tour_id) AS total_tours,

    COUNT(DISTINCT b.booking_id) AS total_bookings

FROM ROUTE r
LEFT JOIN GUIDEDTOUR gt
    ON r.route_id = gt.route_id
LEFT JOIN BOOKING b
    ON gt.guided_tour_id = b.guided_tour_id;


/*
=========================================================
SELECT Query 2A
Monthly booking growth - using JOIN and GROUP BY

Screen:
Dashboard / Booking Growth Chart

Purpose:
This query shows the number of bookings, total participants,
and total revenue for each month and year.
It is used for a monthly growth chart in the dashboard.

This query uses:
- JOIN between BOOKING and GUIDEDTOUR
- EXTRACT to split the date into year and month
- GROUP BY
- ORDER BY
=========================================================
*/

SELECT
    EXTRACT(YEAR FROM b.booking_date) AS booking_year,
    EXTRACT(MONTH FROM b.booking_date) AS booking_month,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.number_of_participants) AS total_participants,
    SUM(
        CASE
            WHEN b.payment_status = 'Paid'
            THEN b.number_of_participants * gt.price
            ELSE 0
        END
    ) AS monthly_revenue
FROM BOOKING b
JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
GROUP BY
    EXTRACT(YEAR FROM b.booking_date),
    EXTRACT(MONTH FROM b.booking_date)
ORDER BY
    booking_year,
    booking_month;


/*
=========================================================
SELECT Query 2B
Monthly booking growth - using subquery

Screen:
Dashboard / Booking Growth Chart

Purpose:
Same result as Query 2A, but written using a subquery.
The inner query first calculates the year, month, participants,
and revenue for each booking. The outer query groups the results.

This version is useful for comparing efficiency with Query 2A.
=========================================================
*/

SELECT
    booking_year,
    booking_month,
    COUNT(booking_id) AS total_bookings,
    SUM(number_of_participants) AS total_participants,
    SUM(revenue_per_booking) AS monthly_revenue
FROM
(
    SELECT
        b.booking_id,
        EXTRACT(YEAR FROM b.booking_date) AS booking_year,
        EXTRACT(MONTH FROM b.booking_date) AS booking_month,
        b.number_of_participants,
        CASE
            WHEN b.payment_status = 'Paid'
            THEN b.number_of_participants * gt.price
            ELSE 0
        END AS revenue_per_booking
    FROM BOOKING b
    JOIN GUIDEDTOUR gt
        ON b.guided_tour_id = gt.guided_tour_id
) AS monthly_data
GROUP BY
    booking_year,
    booking_month
ORDER BY
    booking_year,
    booking_month;


/*
=========================================================
SELECT Query 3A
Routes list with statistics - using JOIN and GROUP BY

Screen:
Routes

Purpose:
This query displays the routes list for the Routes screen.
For each route, it shows the route details, number of sites in the route,
and number of guided tours connected to the route.

This query uses:
- LEFT JOIN
- GROUP BY
- COUNT DISTINCT
- ORDER BY
=========================================================
*/

SELECT
    r.route_id,
    r.route_name,
    r.difficulty_level,
    r.estimated_duration,
    r.distance,
    COUNT(DISTINCT rs.site_id) AS number_of_sites,
    COUNT(DISTINCT gt.guided_tour_id) AS number_of_tours
FROM ROUTE r
LEFT JOIN ROUTESITE rs
    ON r.route_id = rs.route_id
LEFT JOIN GUIDEDTOUR gt
    ON r.route_id = gt.route_id
GROUP BY
    r.route_id,
    r.route_name,
    r.difficulty_level,
    r.estimated_duration,
    r.distance
ORDER BY
    number_of_sites DESC,
    number_of_tours DESC;


/*
=========================================================
SELECT Query 3B
Routes list with statistics - using subqueries

Screen:
Routes

Purpose:
Same result as Query 3A, but written using correlated subqueries.
For each route, the query calculates the number of sites and tours
using separate subqueries.

This version is useful for comparing efficiency with Query 3A.
=========================================================
*/

SELECT
    r.route_id,
    r.route_name,
    r.difficulty_level,
    r.estimated_duration,
    r.distance,

    (
        SELECT COUNT(DISTINCT rs.site_id)
        FROM ROUTESITE rs
        WHERE rs.route_id = r.route_id
    ) AS number_of_sites,

    (
        SELECT COUNT(DISTINCT gt.guided_tour_id)
        FROM GUIDEDTOUR gt
        WHERE gt.route_id = r.route_id
    ) AS number_of_tours

FROM ROUTE r
ORDER BY
    number_of_sites DESC,
    number_of_tours DESC;


/*
=========================================================
SELECT Query 4A
Sites usage in routes - using JOIN and GROUP BY

Screen:
Sites

Purpose:
This query displays all sites and shows how many routes include each site.
It helps the manager understand which sites are used most often
in the travel routes.

This query uses:
- LEFT JOIN
- GROUP BY
- COUNT DISTINCT
- ORDER BY
=========================================================
*/

SELECT
    s.site_id,
    s.site_name,
    s.country,
    s.city,
    s.category,
    COUNT(DISTINCT rs.route_id) AS number_of_routes_using_site
FROM SITE s
LEFT JOIN ROUTESITE rs
    ON s.site_id = rs.site_id
GROUP BY
    s.site_id,
    s.site_name,
    s.country,
    s.city,
    s.category
ORDER BY
    number_of_routes_using_site DESC,
    s.country,
    s.city;


/*
=========================================================
SELECT Query 4B
Sites usage in routes - using subquery

Screen:
Sites

Purpose:
Same result as Query 4A, but written using a correlated subquery.
For each site, the query calculates how many routes include it.

This version is useful for comparing efficiency with Query 4A.
=========================================================
*/

SELECT
    s.site_id,
    s.site_name,
    s.country,
    s.city,
    s.category,

    (
        SELECT COUNT(DISTINCT rs.route_id)
        FROM ROUTESITE rs
        WHERE rs.site_id = s.site_id
    ) AS number_of_routes_using_site

FROM SITE s
ORDER BY
    number_of_routes_using_site DESC,
    s.country,
    s.city;


/*
=========================================================
SELECT Query 5A
Tours with availability - using JOIN and GROUP BY

Screen:
Tours

Purpose:
This query displays guided tours with route name, guide name,
tour date, status, price, maximum participants, registered participants,
and available places.

This query is useful for the Tours screen because it allows the manager
to see which tours still have available seats.

This query uses:
- JOIN
- LEFT JOIN
- GROUP BY
- SUM
- COALESCE
- ORDER BY
=========================================================
*/

SELECT
    gt.guided_tour_id,
    r.route_name,
    g.full_name AS guide_name,
    gt.start_date,
    EXTRACT(YEAR FROM gt.start_date) AS tour_year,
    EXTRACT(MONTH FROM gt.start_date) AS tour_month,
    EXTRACT(DAY FROM gt.start_date) AS tour_day,
    gt.status,
    gt.price,
    gt.max_participants,
    COALESCE(SUM(b.number_of_participants), 0) AS registered_participants,
    gt.max_participants - COALESCE(SUM(b.number_of_participants), 0) AS available_places
FROM GUIDEDTOUR gt
JOIN ROUTE r
    ON gt.route_id = r.route_id
JOIN GUIDE g
    ON gt.guide_id = g.guide_id
LEFT JOIN BOOKING b
    ON gt.guided_tour_id = b.guided_tour_id
GROUP BY
    gt.guided_tour_id,
    r.route_name,
    g.full_name,
    gt.start_date,
    gt.status,
    gt.price,
    gt.max_participants
ORDER BY
    gt.start_date,
    available_places;


/*
=========================================================
SELECT Query 5B
Tours with availability - using subquery

Screen:
Tours

Purpose:
Same result as Query 5A, but the number of registered participants
is calculated using a correlated subquery.

This version is useful for comparing efficiency with Query 5A.
=========================================================
*/

SELECT
    gt.guided_tour_id,
    r.route_name,
    g.full_name AS guide_name,
    gt.start_date,
    EXTRACT(YEAR FROM gt.start_date) AS tour_year,
    EXTRACT(MONTH FROM gt.start_date) AS tour_month,
    EXTRACT(DAY FROM gt.start_date) AS tour_day,
    gt.status,
    gt.price,
    gt.max_participants,

    COALESCE(
        (
            SELECT SUM(b.number_of_participants)
            FROM BOOKING b
            WHERE b.guided_tour_id = gt.guided_tour_id
        ), 0
    ) AS registered_participants,

    gt.max_participants - COALESCE(
        (
            SELECT SUM(b.number_of_participants)
            FROM BOOKING b
            WHERE b.guided_tour_id = gt.guided_tour_id
        ), 0
    ) AS available_places

FROM GUIDEDTOUR gt
JOIN ROUTE r
    ON gt.route_id = r.route_id
JOIN GUIDE g
    ON gt.guide_id = g.guide_id
ORDER BY
    gt.start_date,
    available_places;

/*
=========================================================
SELECT Query 6
Bookings management

Screen:
Bookings

Purpose:
This query displays full booking information for the Bookings screen.
For each booking, it shows the booking details, traveler information,
route name, and guided tour date.

This query uses:
- JOIN
- EXTRACT from date
- ORDER BY
=========================================================
*/

SELECT
    b.booking_id,
    b.booking_date,
    EXTRACT(YEAR FROM b.booking_date) AS booking_year,
    EXTRACT(MONTH FROM b.booking_date) AS booking_month,
    EXTRACT(DAY FROM b.booking_date) AS booking_day,
    u.full_name AS traveler_name,
    u.email,
    u.phone,
    r.route_name,
    gt.start_date AS tour_date,
    b.number_of_participants,
    b.payment_status
FROM BOOKING b
JOIN USERS u
    ON b.user_id = u.user_id
JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
JOIN ROUTE r
    ON gt.route_id = r.route_id
ORDER BY
    b.booking_date DESC,
    b.booking_id;



/*
=========================================================
SELECT Query 7
Travelers activity summary

Screen:
Travelers

Purpose:
This query displays the travelers list with activity information.
For each traveler, it shows the number of bookings, total participants,
last booking date, and total paid amount.

This query uses:
- LEFT JOIN
- GROUP BY
- COUNT
- SUM
- MAX
- ORDER BY
=========================================================
*/

SELECT
    u.user_id,
    u.full_name AS traveler_name,
    u.email,
    u.phone,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(SUM(b.number_of_participants), 0) AS total_participants,
    MAX(b.booking_date) AS last_booking_date,
    COALESCE(SUM(
        CASE
            WHEN b.payment_status = 'Paid'
            THEN b.number_of_participants * gt.price
            ELSE 0
        END
    ), 0) AS total_paid_amount
FROM USERS u
LEFT JOIN BOOKING b
    ON u.user_id = b.user_id
LEFT JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
GROUP BY
    u.user_id,
    u.full_name,
    u.email,
    u.phone
ORDER BY
    total_bookings DESC,
    total_paid_amount DESC;


/*
=========================================================
SELECT Query 8
Route details with ordered sites

Screen:
Routes / Route Details

Purpose:
This query displays the full details of each route together with
the sites included in the route, ordered by visit order.

This query is useful when the user clicks on a specific route
and wants to see the route plan.

This query uses:
- JOIN
- ORDER BY
- Data from ROUTE, ROUTESITE and SITE
=========================================================
*/

SELECT
    r.route_id,
    r.route_name,
    r.difficulty_level,
    r.estimated_duration,
    r.distance,
    rs.visit_order,
    s.site_id,
    s.site_name,
    s.country,
    s.city,
    s.category
FROM ROUTE r
JOIN ROUTESITE rs
    ON r.route_id = rs.route_id
JOIN SITE s
    ON rs.site_id = s.site_id
ORDER BY
    r.route_id,
    rs.visit_order;

/*
=========================================================
UPDATE Query 1
Reopen cancelled future tours

Screen:
Tours

Purpose:
This update changes the status of future tours from 'Cancelled' to 'Open'.
It is useful when the manager decides to reopen tours that were previously cancelled.

Before running the UPDATE, run the SELECT statement to show the current state.
After running the UPDATE, run the SELECT again to show the change.
=========================================================
*/

-- 1. Before update
SELECT
    guided_tour_id,
    start_date,
    status
FROM GUIDEDTOUR
WHERE status = 'Cancelled'
  AND start_date >= CURRENT_DATE
ORDER BY start_date
LIMIT 5;


-- 2. Update
UPDATE GUIDEDTOUR
SET status = 'Open'
WHERE guided_tour_id IN
(
    SELECT guided_tour_id
    FROM GUIDEDTOUR
    WHERE status = 'Cancelled'
      AND start_date >= CURRENT_DATE
    ORDER BY start_date
    LIMIT 5
);


-- 3. After update
SELECT
    guided_tour_id,
    start_date,
    status
FROM GUIDEDTOUR
WHERE status = 'Open'
  AND start_date >= CURRENT_DATE
ORDER BY start_date
LIMIT 10;


/*
=========================================================
UPDATE Query 2
Increase price for future hard routes tours

Screen:
Tours / Routes

Purpose:
This update increases the price by 10% for future guided tours
that belong to routes with difficulty level 'Hard'.

This is useful because hard routes may require more resources,
more preparation, or more experienced guides.

Before running the UPDATE, run the SELECT statement to show the current prices.
After running the UPDATE, run the SELECT again to show the updated prices.
=========================================================
*/

-- 1. Before update
SELECT
    gt.guided_tour_id,
    r.route_name,
    r.difficulty_level,
    gt.start_date,
    gt.price
FROM GUIDEDTOUR gt
JOIN ROUTE r
    ON gt.route_id = r.route_id
WHERE r.difficulty_level = 'Hard'
  AND gt.start_date >= CURRENT_DATE
ORDER BY gt.start_date
LIMIT 5;


-- 2. Update
UPDATE GUIDEDTOUR
SET price = price * 1.10
WHERE guided_tour_id IN
(
    SELECT gt.guided_tour_id
    FROM GUIDEDTOUR gt
    JOIN ROUTE r
        ON gt.route_id = r.route_id
    WHERE r.difficulty_level = 'Hard'
      AND gt.start_date >= CURRENT_DATE
    ORDER BY gt.start_date
    LIMIT 5
);


-- 3. After update
SELECT
    gt.guided_tour_id,
    r.route_name,
    r.difficulty_level,
    gt.start_date,
    gt.price
FROM GUIDEDTOUR gt
JOIN ROUTE r
    ON gt.route_id = r.route_id
WHERE r.difficulty_level = 'Hard'
  AND gt.start_date >= CURRENT_DATE
ORDER BY gt.start_date
LIMIT 5;


/*
=========================================================
UPDATE Query 3
Cancel old pending bookings

Screen:
Bookings

Purpose:
This update changes old bookings with payment status 'Pending'
to 'Cancelled'. It helps the manager clean bookings that were not paid
for a long time.

Before running the UPDATE, run the SELECT statement to show the current state.
After running the UPDATE, run the SELECT again to show the change.
=========================================================
*/

-- 1. Before update
SELECT
    b.booking_id,
    b.booking_date,
    b.payment_status,
    u.full_name AS traveler_name,
    r.route_name
FROM BOOKING b
JOIN USERS u
    ON b.user_id = u.user_id
JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
JOIN ROUTE r
    ON gt.route_id = r.route_id
WHERE b.payment_status = 'Pending'
ORDER BY b.booking_date
LIMIT 5;


-- 2. Update
UPDATE BOOKING
SET payment_status = 'Cancelled'
WHERE booking_id IN
(
    SELECT booking_id
    FROM BOOKING
    WHERE payment_status = 'Pending'
    ORDER BY booking_date
    LIMIT 5
);


-- 3. After update
SELECT
    b.booking_id,
    b.booking_date,
    b.payment_status,
    u.full_name AS traveler_name,
    r.route_name
FROM BOOKING b
JOIN USERS u
    ON b.user_id = u.user_id
JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
JOIN ROUTE r
    ON gt.route_id = r.route_id
WHERE b.payment_status = 'Cancelled'
ORDER BY b.booking_date
LIMIT 10;


/*
=========================================================
DELETE Query 1
Delete old cancelled bookings

Screen:
Bookings

Purpose:
This delete removes old cancelled bookings from the system.
It is useful for cleaning the bookings table from records that are no longer active.

Before running the DELETE, run the SELECT statement to show the records.
After running the DELETE, run the SELECT again to show that those records were removed.
=========================================================
*/

-- 1. Before delete
SELECT
    b.booking_id,
    b.booking_date,
    b.payment_status,
    u.full_name AS traveler_name,
    r.route_name
FROM BOOKING b
JOIN USERS u
    ON b.user_id = u.user_id
JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
JOIN ROUTE r
    ON gt.route_id = r.route_id
WHERE b.payment_status = 'Cancelled'
ORDER BY b.booking_date
LIMIT 5;


-- 2. Delete
DELETE FROM BOOKING
WHERE booking_id IN
(
    SELECT booking_id
    FROM BOOKING
    WHERE payment_status = 'Cancelled'
    ORDER BY booking_date
    LIMIT 5
);


-- 3. After delete
SELECT
    b.booking_id,
    b.booking_date,
    b.payment_status,
    u.full_name AS traveler_name,
    r.route_name
FROM BOOKING b
JOIN USERS u
    ON b.user_id = u.user_id
JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
JOIN ROUTE r
    ON gt.route_id = r.route_id
WHERE b.payment_status = 'Cancelled'
ORDER BY b.booking_date
LIMIT 10;

/*
=========================================================
DELETE Query 2
Delete unpaid bookings for cancelled tours

Screen:
Bookings / Tours

Purpose:
This delete removes unpaid bookings that belong to cancelled tours.
It is useful because if a tour was cancelled and the booking was not paid,
the booking is no longer relevant for the system.

This query uses:
- DELETE with subquery
- JOIN between BOOKING, GUIDEDTOUR, ROUTE and USERS
- Filtering by payment status and tour status
=========================================================
*/

-- 1. Before delete
SELECT
    b.booking_id,
    b.booking_date,
    b.payment_status,
    u.full_name AS traveler_name,
    r.route_name,
    gt.guided_tour_id,
    gt.status AS tour_status,
    gt.start_date
FROM BOOKING b
JOIN USERS u
    ON b.user_id = u.user_id
JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
JOIN ROUTE r
    ON gt.route_id = r.route_id
WHERE b.payment_status = 'Unpaid'
  AND gt.status = 'Cancelled'
ORDER BY b.booking_date
LIMIT 5;


-- 2. Delete
DELETE FROM BOOKING
WHERE booking_id IN
(
    SELECT b.booking_id
    FROM BOOKING b
    JOIN GUIDEDTOUR gt
        ON b.guided_tour_id = gt.guided_tour_id
    WHERE b.payment_status = 'Unpaid'
      AND gt.status = 'Cancelled'
    ORDER BY b.booking_date
    LIMIT 5
);


-- 3. After delete
SELECT
    b.booking_id,
    b.booking_date,
    b.payment_status,
    u.full_name AS traveler_name,
    r.route_name,
    gt.guided_tour_id,
    gt.status AS tour_status,
    gt.start_date
FROM BOOKING b
JOIN USERS u
    ON b.user_id = u.user_id
JOIN GUIDEDTOUR gt
    ON b.guided_tour_id = gt.guided_tour_id
JOIN ROUTE r
    ON gt.route_id = r.route_id
WHERE b.payment_status = 'Unpaid'
  AND gt.status = 'Cancelled'
ORDER BY b.booking_date
LIMIT 10;


/*
=========================================================
DELETE Query 3
Delete travelers without bookings

Screen:
Travelers

Purpose:
This delete removes travelers who do not have any bookings in the system.
It is useful for cleaning inactive traveler records from the Travelers screen.

The delete affects only users that are not connected to any booking.
=========================================================
*/

-- 1. Before delete
SELECT
    u.user_id,
    u.full_name,
    u.email,
    u.phone
FROM USERS u
LEFT JOIN BOOKING b
    ON u.user_id = b.user_id
WHERE b.booking_id IS NULL
ORDER BY u.user_id
LIMIT 5;


-- 2. Delete
DELETE FROM USERS
WHERE user_id IN
(
    SELECT u.user_id
    FROM USERS u
    LEFT JOIN BOOKING b
        ON u.user_id = b.user_id
    WHERE b.booking_id IS NULL
    ORDER BY u.user_id
    LIMIT 5
);


-- 3. After delete
SELECT
    u.user_id,
    u.full_name,
    u.email,
    u.phone
FROM USERS u
LEFT JOIN BOOKING b
    ON u.user_id = b.user_id
WHERE b.booking_id IS NULL
ORDER BY u.user_id
LIMIT 10;