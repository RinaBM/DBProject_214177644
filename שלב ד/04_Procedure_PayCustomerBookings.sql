/*
================================================================================
קובץ: 04_Procedure_PayCustomerBookings.sql
סוג תוכנית: פרוצדורה 2
שם הפרוצדורה: pr_pay_customer_bookings

מה הפרוצדורה עושה?
הפרוצדורה מקבלת מזהה לקוח, עוברת על כל ההזמנות הלא משולמות שלו,
מסמנת אותן כשולמו, ומוסיפה רשומה לטבלת payment_log.

זו אחת התוכניות החשובות לשלב ד׳ כי יש בה הרבה אלמנטים תכנותיים:
- Cursor explicit
- RECORD
- LOOP
- FETCH
- UPDATE
- INSERT
- IF
- RAISE NOTICE
- EXCEPTION

הנחה במערכת:
b_status = FALSE  => לא שולם
b_status = TRUE   => שולם
================================================================================
*/

CREATE OR REPLACE PROCEDURE pr_pay_customer_bookings(p_c_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    /*
    זה Cursor explicit.
    בניגוד ל־SELECT INTO שהוא Cursor implicit, כאן אנחנו מגדירים Cursor בעצמנו,
    פותחים אותו עם OPEN, קוראים ממנו שורה־שורה עם FETCH, וסוגרים עם CLOSE.

    ה־Cursor מחזיר את כל ההזמנות הלא משולמות של הלקוח.
    */
    cur_unpaid_bookings CURSOR FOR
        SELECT
            b.b_id,
            COALESCE(b.total_price, b.amount_pepole * t.price) AS amount_to_pay
        FROM bookings b
        JOIN tourinstance ti ON ti.t_i_id = b.t_i_id
        JOIN tour t ON t.t_name = ti.t_name
        WHERE b.c_id = p_c_id
          AND b.b_status = FALSE
        ORDER BY b.b_id;

    -- RECORD הוא משתנה שיכול להחזיק שורה שלמה מה־Cursor.
    rec_booking RECORD;

    -- האם הלקוח קיים במערכת.
    v_customer_exists BOOLEAN;

    -- מונה כמה הזמנות שילמנו.
    v_counter INTEGER := 0;

    -- סכום כולל של התשלומים שבוצעו.
    v_total_paid NUMERIC := 0;
BEGIN
    -- קודם בודקים שהלקוח קיים.
    SELECT EXISTS (
        SELECT 1
        FROM customer c
        WHERE c.c_id = p_c_id
    )
    INTO v_customer_exists;

    IF NOT v_customer_exists THEN
        RAISE EXCEPTION 'Customer % does not exist', p_c_id;
    END IF;

    -- פותחים את ה־Cursor.
    OPEN cur_unpaid_bookings;

    -- לולאה שעוברת על כל ההזמנות הלא משולמות.
    LOOP
        -- שולפים שורה אחת מה־Cursor לתוך rec_booking.
        FETCH cur_unpaid_bookings INTO rec_booking;

        -- אם אין עוד שורות, יוצאים מהלולאה.
        EXIT WHEN NOT FOUND;

        -- מעדכנים את ההזמנה להיות משולמת.
        UPDATE bookings
        SET b_status = TRUE,
            total_price = rec_booking.amount_to_pay
        WHERE b_id = rec_booking.b_id;

        -- מוסיפים רשומה ליומן התשלומים כדי להוכיח שהתבצע תשלום.
        INSERT INTO payment_log (c_id, b_id, amount, note)
        VALUES (p_c_id, rec_booking.b_id, rec_booking.amount_to_pay, 'Paid by pr_pay_customer_bookings');

        -- מעדכנים מונה וסכום כולל.
        v_counter := v_counter + 1;
        v_total_paid := v_total_paid + rec_booking.amount_to_pay;
    END LOOP;

    -- סוגרים את ה־Cursor.
    CLOSE cur_unpaid_bookings;

    -- מדפיסים הודעה למשתמש לפי התוצאה.
    IF v_counter = 0 THEN
        RAISE NOTICE 'Customer % has no unpaid bookings', p_c_id;
    ELSE
        RAISE NOTICE 'Customer % paid % bookings. Total paid: %',
            p_c_id, v_counter, v_total_paid;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in pr_pay_customer_bookings for customer %: %',
            p_c_id, SQLERRM;
END;
$$;
