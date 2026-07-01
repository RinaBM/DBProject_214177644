/*
================================================================================
קובץ: 05_Trigger_LogTourPriceUpdate.sql
סוג תוכנית: טריגר 1
שם הטריגר: trg_log_tour_price_update

מה הטריגר עושה?
כאשר מעדכנים מחיר של טיול בטבלת tour, הטריגר שומר את המחיר הישן
והמחיר החדש בטבלת tour_price_history.

זה הטריגר שעונה על הדרישה:
"לפחות טריגר אחד בזמן UPDATE".

מתי הוא רץ?
AFTER UPDATE OF price ON tour
כלומר אחרי עדכון של העמודה price בטבלת tour.

אלמנטים חשובים:
- Trigger Function
- OLD ו־NEW
- INSERT לטבלת היסטוריה
- RAISE NOTICE
================================================================================
*/

-- זו פונקציית הטריגר. היא לא נקראת ישירות על ידינו, אלא רק על ידי הטריגר.
CREATE OR REPLACE FUNCTION trg_log_tour_price_update_func()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    /*
    OLD.price הוא המחיר לפני העדכון.
    NEW.price הוא המחיר אחרי העדכון.

    IS DISTINCT FROM בטוח יותר מ־<> כי הוא יודע להתמודד גם עם NULL.
    */
    IF OLD.price IS DISTINCT FROM NEW.price THEN
        -- שמירת שינוי המחיר בטבלת ההיסטוריה.
        INSERT INTO tour_price_history (t_name, old_price, new_price)
        VALUES (OLD.t_name, OLD.price, NEW.price);

        -- הודעה שתופיע ב־Messages ותשמש כהוכחה שהטריגר הופעל.
        RAISE NOTICE 'Price of tour % changed from % to %',
            OLD.t_name, OLD.price, NEW.price;
    END IF;

    -- בטריגר AFTER UPDATE מחזירים NEW כדי לאפשר לעדכון להסתיים תקין.
    RETURN NEW;
END;
$$;

-- אם הטריגר כבר קיים מהרצה קודמת, נמחק אותו כדי לא לקבל שגיאה.
DROP TRIGGER IF EXISTS trg_log_tour_price_update ON tour;

-- יצירת הטריגר עצמו.
CREATE TRIGGER trg_log_tour_price_update
AFTER UPDATE OF price ON tour
FOR EACH ROW
EXECUTE FUNCTION trg_log_tour_price_update_func();
