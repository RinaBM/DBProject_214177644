/*
=========================================================
Phase 2 - Index.sql
SmartRoute - Guided Travel Routes Management System

This file includes 3 indexes.
For each index, we run EXPLAIN ANALYZE before and after creating the index
in order to compare query execution time.

Important:
In small tables, PostgreSQL may still choose a sequential scan.
This is normal because scanning a small table can be cheaper than using an index.
=========================================================
*/

/*
=========================================================
Index 1
Index on BOOKING(payment_status, booking_date)

Purpose:
This index improves queries that filter bookings by payment status
and booking date.

It is useful for:
- Dashboard revenue reports
- Bookings screen filtering
- Monthly payment reports

The query checks paid bookings in a specific date range.
=========================================================
*/

-- Before creating the index
EXPLAIN ANALYZE
SELECT
    booking_id,
    booking_date,
    payment_status,
    number_of_participants
FROM BOOKING
WHERE payment_status = 'Paid'
  AND booking_date BETWEEN DATE '2026-01-01' AND DATE '2026-03-31'
ORDER BY booking_date;


-- Create index
CREATE INDEX idx_booking_payment_status_date
ON BOOKING(payment_status, booking_date);


-- After creating the index
EXPLAIN ANALYZE
SELECT
    booking_id,
    booking_date,
    payment_status,
    number_of_participants
FROM BOOKING
WHERE payment_status = 'Paid'
  AND booking_date BETWEEN DATE '2026-01-01' AND DATE '2026-03-31'
ORDER BY booking_date;


/*
=========================================================
Index 2
Index on BOOKING(booking_date DESC)

Purpose:
This index improves queries that sort bookings by booking date,
especially when the system needs to show the latest bookings first.

It is useful for:
- Bookings screen
- Dashboard recent bookings area

The query checks the latest 20 bookings.
=========================================================
*/

-- Before creating the index
EXPLAIN ANALYZE
SELECT
    booking_id,
    booking_date,
    payment_status,
    number_of_participants
FROM BOOKING
ORDER BY booking_date DESC
LIMIT 20;


-- Create index
CREATE INDEX idx_booking_date_desc
ON BOOKING(booking_date DESC);


-- After creating the index
EXPLAIN ANALYZE
SELECT
    booking_id,
    booking_date,
    payment_status,
    number_of_participants
FROM BOOKING
ORDER BY booking_date DESC
LIMIT 20;

/*
=========================================================
Index 3
Index on GUIDEDTOUR(status, start_date)

Purpose:
This index improves queries that filter guided tours by status
and start date.

It is useful for:
- Tours screen
- Dashboard upcoming tours section

The query checks open future tours ordered by start date.
=========================================================
*/

-- Before creating the index
EXPLAIN ANALYZE
SELECT
    guided_tour_id,
    route_id,
    guide_id,
    start_date,
    status,
    price,
    max_participants
FROM GUIDEDTOUR
WHERE status = 'Open'
  AND start_date >= CURRENT_DATE
ORDER BY start_date
LIMIT 20;


-- Create index
CREATE INDEX idx_guidedtour_status_start_date
ON GUIDEDTOUR(status, start_date);


-- After creating the index
EXPLAIN ANALYZE
SELECT
    guided_tour_id,
    route_id,
    guide_id,
    start_date,
    status,
    price,
    max_participants
FROM GUIDEDTOUR
WHERE status = 'Open'
  AND start_date >= CURRENT_DATE
ORDER BY start_date
LIMIT 20;