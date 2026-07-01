/*
================================================================================
קובץ: 10_ProofQueriesForReport.sql
מטרה: שאילתות הוכחה לדוח שלב ד׳.

הקובץ הזה נועד לעזור לך לצלם הוכחות לדוח.
הוא לא מחליף את קבצי התוכניות, אלא רק מרכז בדיקות נוחות.

סדר מומלץ:
1. להריץ קודם את הקבצים 00 עד 06.
2. להריץ את הקובץ 07 ולצלם.
3. להריץ את הקובץ 08 ולצלם.
4. להריץ מכאן שאילתות לפי הצורך.
================================================================================
*/

-- הוכחה לפונקציה fn_available_places:
-- מציגים 5 מופעי טיול וכמה מקומות פנויים נשארו בכל אחד.
SELECT
    ti.t_i_id,
    ti.t_name,
    fn_available_places(ti.t_i_id) AS available_places
FROM tourinstance ti
ORDER BY ti.t_i_id
LIMIT 5;

-- הוכחה לטבלת bookings אחרי יצירת הזמנה:
SELECT *
FROM bookings
ORDER BY b_id DESC
LIMIT 5;

-- הוכחה ל־payment_log אחרי תשלום הזמנות:
SELECT *
FROM payment_log
ORDER BY payment_id DESC
LIMIT 10;

-- הוכחה לטריגר UPDATE של שינוי מחיר:
SELECT *
FROM tour_price_history
ORDER BY history_id DESC
LIMIT 10;

-- הוכחה ש־total_price מחושב בהזמנות:
SELECT b_id, amount_pepole, t_i_id, total_price, b_status
FROM bookings
ORDER BY b_id DESC
LIMIT 10;
