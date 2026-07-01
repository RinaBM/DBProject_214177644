/*
================================================================================
קובץ: 07_MainProgram1_CreateBooking.sql
סוג תוכנית: תוכנית ראשית 1

דרישת שלב ד׳:
כל תוכנית ראשית צריכה לזמן פונקציה אחת ופרוצדורה אחת.

מה התוכנית הזאת מפעילה?
1. פונקציה: fn_available_places
2. פרוצדורה: pr_create_booking

מה היא עושה בפועל?
- מוצאת מופע טיול שיש בו לפחות מקום פנוי אחד.
- מוצאת לקוח ראשון מהמערכת.
- מדפיסה כמה מקומות פנויים היו לפני ההזמנה.
- קוראת לפרוצדורה שיוצרת הזמנה חדשה.
- מדפיסה כמה מקומות פנויים נשארו אחרי ההזמנה.
- בסוף מציגה את ההזמנות האחרונות בטבלת bookings.

מה לצלם לדוח?
- את הודעות ה־NOTICE ב־Messages.
- את טבלת התוצאות של SELECT * FROM bookings בסוף.
================================================================================
*/

DO $$
DECLARE
    -- מזהה מופע טיול שנבחר אוטומטית.
    v_t_i_id INTEGER;

    -- מזהה לקוח שנבחר אוטומטית.
    v_c_id INTEGER;

    -- מספר מקומות פנויים לפני יצירת ההזמנה.
    v_before INTEGER;

    -- מספר מקומות פנויים אחרי יצירת ההזמנה.
    v_after INTEGER;
BEGIN
    -- מוצאים מופע טיול שיש בו לפחות מקום פנוי אחד.
    SELECT ti.t_i_id
    INTO v_t_i_id
    FROM tourinstance ti
    WHERE fn_available_places(ti.t_i_id) >= 1
    ORDER BY ti.t_i_id
    LIMIT 1;

    -- בוחרים לקוח ראשון מהמערכת.
    SELECT c.c_id
    INTO v_c_id
    FROM customer c
    ORDER BY c.c_id
    LIMIT 1;

    -- אם לא נמצא מופע טיול מתאים, התוכנית לא יכולה להמשיך.
    IF v_t_i_id IS NULL THEN
        RAISE EXCEPTION 'No tour instance with available places was found';
    END IF;

    -- אם אין לקוחות במערכת, התוכנית לא יכולה ליצור הזמנה.
    IF v_c_id IS NULL THEN
        RAISE EXCEPTION 'No customer was found';
    END IF;

    -- קריאה לפונקציה לפני ההזמנה.
    v_before := fn_available_places(v_t_i_id);
    RAISE NOTICE 'Available places before booking in tour instance %: %',
        v_t_i_id, v_before;

    -- קריאה לפרוצדורה שיוצרת הזמנה חדשה של אדם אחד.
    CALL pr_create_booking(v_t_i_id, v_c_id, 1, CURRENT_DATE);

    -- קריאה נוספת לפונקציה אחרי ההזמנה כדי לראות שהמספר ירד.
    v_after := fn_available_places(v_t_i_id);
    RAISE NOTICE 'Available places after booking in tour instance %: %',
        v_t_i_id, v_after;
END;
$$;

-- הצגת ההזמנות האחרונות כדי להוכיח שנוצרה הזמנה חדשה.
SELECT *
FROM bookings
ORDER BY b_id DESC
LIMIT 5;
