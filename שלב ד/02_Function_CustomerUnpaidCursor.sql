/*
================================================================================
קובץ: 02_Function_CustomerUnpaidCursor.sql
סוג תוכנית: פונקציה 2
שם הפונקציה: fn_customer_unpaid_bookings

מה הפונקציה עושה?
הפונקציה מקבלת מזהה לקוח ומחזירה Ref Cursor עם כל ההזמנות הלא משולמות שלו.

הנחה במערכת:
b_status = FALSE  => ההזמנה עדיין לא שולמה
b_status = TRUE   => ההזמנה שולמה

למה זה טוב לשלב ד׳?
כי הדרישה ביקשה, אם אפשר, להחזיר Ref Cursor. כאן אנחנו מחזירים Cursor
שאפשר אחר כך לקרוא ממנו בעזרת FETCH ALL.

אלמנטים תכנותיים שיש כאן:
- בדיקת קיום לקוח
- IF
- החזרת REFCURSOR
- OPEN cursor FOR SELECT
- JOIN בין כמה טבלאות
- EXCEPTION
================================================================================
*/

CREATE OR REPLACE FUNCTION fn_customer_unpaid_bookings(
    p_c_id INTEGER,
    p_cursor_name REFCURSOR DEFAULT 'customer_unpaid_cursor'
)
RETURNS REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    -- משתנה בוליאני שבודק האם הלקוח קיים במערכת.
    v_customer_exists BOOLEAN;
BEGIN
    -- בודקים אם יש לקוח עם המזהה שקיבלנו.
    SELECT EXISTS (
        SELECT 1
        FROM customer c
        WHERE c.c_id = p_c_id
    )
    INTO v_customer_exists;

    -- אם הלקוח לא קיים, נזרוק חריגה.
    IF NOT v_customer_exists THEN
        RAISE EXCEPTION 'Customer % does not exist', p_c_id;
    END IF;

    /*
    פותחים Ref Cursor.
    כלומר, במקום להחזיר מספר אחד, הפונקציה מחזירה "מצביע" לתוצאה של שאילתה.
    אחר כך בתוכנית הראשית נוכל לעשות FETCH ALL FROM customer_unpaid_cursor.
    */
    OPEN p_cursor_name FOR
        SELECT
            b.b_id,                                      -- מזהה הזמנה
            b.c_id,                                      -- מזהה לקוח
            c.c_first_name || ' ' || c.c_last_name AS customer_name, -- שם מלא של לקוח
            b.t_i_id,                                    -- מזהה מופע טיול
            ti.t_date,                                   -- תאריך הטיול
            ti.start_time,                               -- שעת התחלה
            ti.end_time,                                 -- שעת סיום
            ti.t_name,                                   -- שם הטיול
            b.amount_pepole,                             -- כמות אנשים בהזמנה
            COALESCE(b.total_price, b.amount_pepole * t.price) AS amount_to_pay
                                                          -- אם total_price ריק, מחשבים לפי כמות אנשים כפול מחיר
        FROM bookings b
        JOIN customer c ON c.c_id = b.c_id
        JOIN tourinstance ti ON ti.t_i_id = b.t_i_id
        JOIN tour t ON t.t_name = ti.t_name
        WHERE b.c_id = p_c_id
          AND b.b_status = FALSE                         -- רק הזמנות שלא שולמו
        ORDER BY ti.t_date, b.b_id;

    -- מחזירים את שם ה־Cursor שנפתח.
    RETURN p_cursor_name;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in fn_customer_unpaid_bookings for customer %: %',
            p_c_id, SQLERRM;
END;
$$;
