/*
================================================================================
קובץ: 01_Function_AvailablePlaces.sql
סוג תוכנית: פונקציה 1
שם הפונקציה: fn_available_places

מה הפונקציה עושה?
הפונקציה מקבלת מזהה של מופע טיול, כלומר t_i_id מתוך tourinstance,
ומחזירה כמה מקומות פנויים נשארו בטיול הזה.

הרעיון:
1. מוצאים מה מספר המשתתפים המקסימלי בטיול מתוך טבלת tour.
2. מחשבים כמה אנשים כבר נרשמו לאותו מופע טיול מתוך bookings.
3. מחזירים: מקסימום משתתפים פחות מספר האנשים שכבר נרשמו.

אלמנטים תכנותיים שיש כאן:
- משתנים DECLARE
- SELECT INTO, שזה Cursor implicit
- IF
- SUM + COALESCE
- RETURN
- EXCEPTION
================================================================================
*/

CREATE OR REPLACE FUNCTION fn_available_places(p_t_i_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    -- מספר המשתתפים המקסימלי שמותר בטיול.
    v_max_participants INTEGER;

    -- כמה אנשים כבר נרשמו בפועל למופע הטיול הזה.
    v_booked_places INTEGER;

    -- מספר המקומות הפנויים שנחזיר בסוף.
    v_available_places INTEGER;
BEGIN
    /*
    כאן אנחנו משתמשים ב־SELECT INTO.
    זה נחשב Cursor implicit, כי PostgreSQL מריץ שאילתה ומכניס את התוצאה למשתנה.

    tourinstance מכילה מופע ספציפי של טיול בתאריך ושעה.
    tour מכילה את פרטי הטיול עצמו, כולל max_participants.
    הקישור ביניהן הוא לפי t_name.
    */
    SELECT t.max_participants
    INTO v_max_participants
    FROM tourinstance ti
    JOIN tour t ON t.t_name = ti.t_name
    WHERE ti.t_i_id = p_t_i_id;

    -- אם לא מצאנו טיול כזה, אין מה לחשב ולכן נזרוק חריגה.
    IF v_max_participants IS NULL THEN
        RAISE EXCEPTION 'Tour instance % does not exist', p_t_i_id;
    END IF;

    /*
    מחשבים כמה אנשים כבר הזמינו מקום בטיול הזה.
    amount_pepole היא כמות האנשים בהזמנה.
    יש בשם העמודה שגיאת כתיב במערכת, ולכן חייבים לכתוב amount_pepole בדיוק כך.

    COALESCE חשוב כי אם אין עדיין הזמנות, SUM מחזיר NULL.
    במקרה כזה נרצה להתייחס לזה כ־0.
    */
    SELECT COALESCE(SUM(b.amount_pepole), 0)
    INTO v_booked_places
    FROM bookings b
    WHERE b.t_i_id = p_t_i_id;

    -- חישוב המקומות הפנויים.
    v_available_places := v_max_participants - v_booked_places;

    -- הגנה: אם מסיבה כלשהי יצא מספר שלילי, נחזיר 0 ולא מספר שלילי.
    IF v_available_places < 0 THEN
        RETURN 0;
    END IF;

    -- החזרת התוצאה למי שקרא לפונקציה.
    RETURN v_available_places;

EXCEPTION
    -- אם קרתה שגיאה כלשהי, נחזיר הודעת שגיאה ברורה יותר.
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in fn_available_places for tour instance %: %',
            p_t_i_id, SQLERRM;
END;
$$;
