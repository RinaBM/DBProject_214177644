/*
=========================================================
Phase 2 - Constraints.sql
SmartRoute - Guided Travel Routes Management System

This file includes 3 new constraints added using ALTER TABLE.
The constraints were not part of the original createTables.sql file.

For each constraint there is also an invalid INSERT/UPDATE example
that should fail and prove that the constraint works.
=========================================================
*/


/*
=========================================================
Constraint 1
User email must contain @

Table:
USERS

Purpose:
Every user email must contain the @ character.
This prevents invalid email values from being saved.
=========================================================
*/

ALTER TABLE USERS
ADD CONSTRAINT chk_users_email_contains_at
CHECK (email LIKE '%@%');

-- Test that should fail:
UPDATE USERS
SET email = 'invalid_email_without_at'
WHERE user_id = 1;

/*
=========================================================
Constraint 2
Guide phone must start with 05

Table:
GUIDE

Purpose:
Every guide phone number must start with '05'.
This constraint helps prevent invalid Israeli mobile phone numbers
from being saved in the system.
=========================================================
*/

ALTER TABLE GUIDE
ADD CONSTRAINT chk_guide_phone_starts_with_05
CHECK (phone LIKE '05%');

-- Test that should fail:
UPDATE GUIDE
SET phone = '031234567'
WHERE guide_id = 1;

ALTER TABLE GUIDE
ADD CONSTRAINT chk_guide_email_contains_at
CHECK (email LIKE '%@%');

-- Test that should fail:
UPDATE GUIDE
SET email = 'bad_guide_email'
WHERE guide_id = 1;



/*
=========================================================
Constraint 3
Route distance must be greater than zero

Table:
ROUTE

Purpose:
The original database allowed distance to be zero.
For a real travel route, the distance should be greater than zero.
This constraint prevents routes with distance 0.
=========================================================
*/

ALTER TABLE ROUTE
ADD CONSTRAINT chk_route_distance_greater_than_zero
CHECK (distance > 0);

-- Test that should fail:
UPDATE ROUTE
SET distance = 0
WHERE route_id = 1;