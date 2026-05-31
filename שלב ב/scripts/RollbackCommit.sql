/*
=========================================================
Phase 2 - RollbackCommit.sql
SmartRoute - Guided Travel Routes Management System

This file demonstrates transaction control using:
1. ROLLBACK - undoing an update
2. COMMIT - saving an update permanently

For each example we show the data before the update,
after the update, and after ROLLBACK / COMMIT.
=========================================================
*/

/*
=========================================================
ROLLBACK Example
Temporary price update for a guided tour

Purpose:
This example shows that after ROLLBACK, the database returns
to its previous state and the price change is canceled.
=========================================================
*/

BEGIN;

-- 1. Before update
SELECT
    guided_tour_id,
    start_date,
    price,
    status
FROM GUIDEDTOUR
WHERE guided_tour_id = 1;


-- 2. Update inside transaction
UPDATE GUIDEDTOUR
SET price = price + 100
WHERE guided_tour_id = 1;


-- 3. After update, before rollback
SELECT
    guided_tour_id,
    start_date,
    price,
    status
FROM GUIDEDTOUR
WHERE guided_tour_id = 1;


-- 4. Cancel the update
ROLLBACK;


-- 5. After rollback
SELECT
    guided_tour_id,
    start_date,
    price,
    status
FROM GUIDEDTOUR
WHERE guided_tour_id = 1;


/*
=========================================================
COMMIT Example
Payment status update for a booking

Purpose:
This example shows that after COMMIT, the database keeps the update
and the change becomes permanent.
=========================================================
*/

BEGIN;

-- 1. Before update
SELECT
    booking_id,
    booking_date,
    payment_status,
    number_of_participants
FROM BOOKING
WHERE booking_id = 4;


-- 2. Update inside transaction
UPDATE BOOKING
SET payment_status = 'Pending'
WHERE booking_id = 4
RETURNING
    booking_id,
    booking_date,
    payment_status,
    number_of_participants;


-- 3. Save the update permanently
COMMIT;


-- 4. After commit
SELECT
    booking_id,
    booking_date,
    payment_status,
    number_of_participants
FROM BOOKING
WHERE booking_id = 4;