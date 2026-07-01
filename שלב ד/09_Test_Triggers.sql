/*
================================================================================
קובץ: 09_Test_Triggers.sql
סוג תוכנית: קובץ בדיקות לטריגרים

הקובץ הזה לא חובה לפי הדרישה המקורית, אבל הוא מאוד עוזר להוכחות בדוח.

מה הוא בודק?
1. את טריגר UPDATE על מחיר בטבלת tour.
2. את טריגר bookings שמחשב total_price ובודק כמות משתתפים.
3. חריגה מכוונת כדי להראות שהטריגר באמת מונע הזמנה לא תקינה.

מה לצלם לדוח?
- את tour_price_history אחרי עדכון מחיר.
- את bookings עם total_price מלא.
- את הודעת ה־NOTICE של החריגה הצפויה.
================================================================================
*/

/*
בדיקה 1: טריגר מחיר.
מעדכנים מחיר של טיול אחד ב־1.
הטריגר אמור להוסיף רשומה לטבלת tour_price_history.
*/
UPDATE tour
SET price = price + 1
WHERE t_name = (
    SELECT t_name
    FROM tour
    ORDER BY t_name
    LIMIT 1
);

-- הוכחה שהטריגר רץ: אמורה להופיע רשומה חדשה עם old_price ו־new_price.
SELECT *
FROM tour_price_history
ORDER BY history_id DESC
LIMIT 5;

/*
בדיקה 2: טריגר bookings.
אם הרצת את MainProgram1, נוצרה הזמנה.
הטריגר אמור לדאוג ש־total_price יהיה מחושב.
*/
SELECT b.b_id, b.amount_pepole, b.t_i_id, b.total_price
FROM bookings b
ORDER BY b.b_id DESC
LIMIT 5;

/*
בדיקה 3: חריגה מכוונת.
כאן מנסים ליצור הזמנה עם כמות אנשים לא הגיונית.
הטריגר אמור לזרוק חריגה כי זה עובר את max_participants.

שמנו את זה בתוך DO עם EXCEPTION כדי שהמערכת לא תיעצר,
אלא תדפיס הודעת NOTICE שאפשר לצלם לדוח.
*/
DO $$
BEGIN
    INSERT INTO bookings (
        b_id,
        amount_pepole,
        b_date,
        b_status,
        t_i_id,
        c_id
    )
    VALUES (
        (SELECT COALESCE(MAX(b_id), 0) + 1 FROM bookings),
        999999,
        CURRENT_DATE,
        FALSE,
        (SELECT t_i_id FROM tourinstance ORDER BY t_i_id LIMIT 1),
        (SELECT c_id FROM customer ORDER BY c_id LIMIT 1)
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Expected trigger exception: %', SQLERRM;
END;
$$;
