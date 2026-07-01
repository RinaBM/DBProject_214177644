/*
================================================================================
קובץ: 03_Procedure_CreateBooking.sql
סוג תוכנית: פרוצדורה 1
שם הפרוצדורה: pr_create_booking

מה הפרוצדורה עושה?
הפרוצדורה יוצרת הזמנה חדשה לטיול, אבל רק אם יש מספיק מקומות פנויים.

מה היא מקבלת?
- p_t_i_id: מזהה מופע טיול
- p_c_id: מזהה לקוח
- p_amount_pepole: כמות אנשים להזמנה
- p_b_date: תאריך ההזמנה. ברירת מחדל: היום

מה היא עושה בפועל?
1. בודקת שכמות האנשים חיובית.
2. בודקת שהלקוח קיים.
3. קוראת לפונקציה fn_available_places כדי לדעת כמה מקומות פנויים יש.
4. אם אין מספיק מקום - זורקת חריגה.
5. מחשבת מחיר כולל.
6. יוצרת הזמנה חדשה בטבלת bookings.

אלמנטים תכנותיים שיש כאן:
- קריאה לפונקציה מתוך פרוצדורה
- IF
- INSERT
- חישוב
- RAISE NOTICE
- EXCEPTION
================================================================================
*/

CREATE OR REPLACE PROCEDURE pr_create_booking(
    p_t_i_id INTEGER,
    p_c_id INTEGER,
    p_amount_pepole INTEGER,
    p_b_date DATE DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- כמה מקומות פנויים יש במופע הטיול.
    v_available_places INTEGER;

    -- מחיר לאדם אחד בטיול.
    v_price INTEGER;

    -- מזהה חדש להזמנה החדשה.
    v_new_b_id INTEGER;

    -- האם הלקוח קיים.
    v_customer_exists BOOLEAN;
BEGIN
    -- בדיקת תקינות: אי אפשר ליצור הזמנה עם 0 אנשים או מספר שלילי.
    IF p_amount_pepole IS NULL OR p_amount_pepole <= 0 THEN
        RAISE EXCEPTION 'Amount of people must be positive. Got: %', p_amount_pepole;
    END IF;

    -- בדיקה שהלקוח באמת קיים בטבלת customer.
    SELECT EXISTS (
        SELECT 1
        FROM customer c
        WHERE c.c_id = p_c_id
    )
    INTO v_customer_exists;

    IF NOT v_customer_exists THEN
        RAISE EXCEPTION 'Customer % does not exist', p_c_id;
    END IF;

    -- קריאה לפונקציה הראשונה: בודקים כמה מקומות פנויים נשארו.
    v_available_places := fn_available_places(p_t_i_id);

    -- אם מספר המקומות הפנויים קטן מכמות האנשים המבוקשת, לא נאפשר הזמנה.
    IF v_available_places < p_amount_pepole THEN
        RAISE EXCEPTION
            'Not enough available places in tour instance %. Requested %, available %',
            p_t_i_id, p_amount_pepole, v_available_places;
    END IF;

    -- מוצאים את מחיר הטיול לפי מופע הטיול.
    SELECT t.price
    INTO v_price
    FROM tourinstance ti
    JOIN tour t ON t.t_name = ti.t_name
    WHERE ti.t_i_id = p_t_i_id;

    IF v_price IS NULL THEN
        RAISE EXCEPTION 'Could not find price for tour instance %', p_t_i_id;
    END IF;

    /*
    יצירת מזהה חדש להזמנה.
    בגלל שבטבלה b_id הוא integer רגיל ולא SERIAL לפי המבנה שקיבלנו,
    אנחנו מייצרים id חדש לפי MAX + 1.
    */
    SELECT COALESCE(MAX(b_id), 0) + 1
    INTO v_new_b_id
    FROM bookings;

    -- הכנסת ההזמנה החדשה לטבלת bookings.
    INSERT INTO bookings (
        b_id,
        amount_pepole,
        b_date,
        b_status,
        t_i_id,
        c_id,
        total_price
    )
    VALUES (
        v_new_b_id,
        p_amount_pepole,
        p_b_date,
        FALSE,                         -- FALSE אומר שההזמנה עדיין לא שולמה
        p_t_i_id,
        p_c_id,
        p_amount_pepole * v_price       -- מחיר כולל = כמות אנשים * מחיר לאדם
    );

    -- הודעה שתופיע ב־Messages של pgAdmin ותשמש כהוכחה להרצה.
    RAISE NOTICE 'Booking % was created successfully. Customer %, tour instance %, people %, total price %',
        v_new_b_id, p_c_id, p_t_i_id, p_amount_pepole, p_amount_pepole * v_price;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in pr_create_booking: %', SQLERRM;
END;
$$;
