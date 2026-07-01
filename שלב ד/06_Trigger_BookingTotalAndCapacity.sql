/*
================================================================================
קובץ: 06_Trigger_BookingTotalAndCapacity.sql
סוג תוכנית: טריגר 2
שם הטריגר: trg_booking_total_and_capacity

מה הטריגר עושה?
הטריגר רץ לפני INSERT או UPDATE בטבלת bookings.
הוא עושה שני דברים:

1. מחשב אוטומטית את total_price לפי:
   amount_pepole * price

2. בודק שלא מנסים להכניס הזמנה שחורגת ממספר המשתתפים המקסימלי של הטיול.

מתי הוא רץ?
BEFORE INSERT OR UPDATE OF amount_pepole, t_i_id ON bookings

אלמנטים חשובים:
- Trigger Function
- NEW
- IF
- SELECT INTO
- חריגה במקרה של כמות לא תקינה או חריגה ממספר משתתפים
- שינוי ערך NEW.total_price לפני השמירה בטבלה
================================================================================
*/

CREATE OR REPLACE FUNCTION trg_booking_total_and_capacity_func()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    -- מחיר לאדם אחד בטיול.
    v_price INTEGER;

    -- מספר המשתתפים המקסימלי בטיול.
    v_max_participants INTEGER;

    -- כמה אנשים כבר רשומים לאותו מופע טיול.
    v_already_booked INTEGER;
BEGIN
    -- בדיקה שכמות האנשים בהזמנה תקינה.
    IF NEW.amount_pepole IS NULL OR NEW.amount_pepole <= 0 THEN
        RAISE EXCEPTION 'Booking amount_pepole must be positive. Got: %', NEW.amount_pepole;
    END IF;

    -- שליפת מחיר ומספר משתתפים מקסימלי לפי מופע הטיול.
    SELECT
        t.price,
        t.max_participants
    INTO
        v_price,
        v_max_participants
    FROM tourinstance ti
    JOIN tour t ON t.t_name = ti.t_name
    WHERE ti.t_i_id = NEW.t_i_id;

    -- אם לא נמצא מופע טיול מתאים, נזרוק חריגה.
    IF v_price IS NULL THEN
        RAISE EXCEPTION 'Tour instance % does not exist or has no price', NEW.t_i_id;
    END IF;

    /*
    מחשבים כמה אנשים כבר רשומים לאותו מופע טיול.

    אם הפעולה היא INSERT, סופרים את כל ההזמנות הקיימות.
    אם הפעולה היא UPDATE, לא רוצים לספור את ההזמנה הנוכחית פעמיים,
    ולכן מוסיפים תנאי b.b_id <> NEW.b_id.
    */
    SELECT COALESCE(SUM(b.amount_pepole), 0)
    INTO v_already_booked
    FROM bookings b
    WHERE b.t_i_id = NEW.t_i_id
      AND (TG_OP = 'INSERT' OR b.b_id <> NEW.b_id);

    -- בדיקה שלא עוברים את מספר המשתתפים המקסימלי.
    IF v_already_booked + NEW.amount_pepole > v_max_participants THEN
        RAISE EXCEPTION
            'Cannot save booking %. Max participants: %, already booked: %, requested: %',
            NEW.b_id, v_max_participants, v_already_booked, NEW.amount_pepole;
    END IF;

    -- חישוב אוטומטי של המחיר הכולל לפני שהשורה נשמרת בטבלה.
    NEW.total_price := NEW.amount_pepole * v_price;

    -- מחזירים את NEW כדי שה־INSERT/UPDATE ימשיך עם הערך המחושב.
    RETURN NEW;
END;
$$;

-- אם הטריגר כבר קיים מהרצה קודמת, נמחק אותו.
DROP TRIGGER IF EXISTS trg_booking_total_and_capacity ON bookings;

-- יצירת הטריגר על טבלת bookings.
CREATE TRIGGER trg_booking_total_and_capacity
BEFORE INSERT OR UPDATE OF amount_pepole, t_i_id ON bookings
FOR EACH ROW
EXECUTE FUNCTION trg_booking_total_and_capacity_func();
