# שלב ד – תכנות PL/pgSQL

בתיקייה זו נמצאים קבצי שלב ד׳ עבור מערכת ניהול טיולים מודרכים.
הקבצים כוללים הערות בעברית כדי שיהיה קל להסביר את הקוד בהגנה ובדוח.

## סדר הרצה ב־pgAdmin

מריצים לפי הסדר:

1. `00_AlterTable.sql`
2. `01_Function_AvailablePlaces.sql`
3. `02_Function_CustomerUnpaidCursor.sql`
4. `03_Procedure_CreateBooking.sql`
5. `04_Procedure_PayCustomerBookings.sql`
6. `05_Trigger_LogTourPriceUpdate.sql`
7. `06_Trigger_BookingTotalAndCapacity.sql`
8. `07_MainProgram1_CreateBooking.sql`
9. `08_MainProgram2_PayBookings.sql`
10. `09_Test_Triggers.sql` – בדיקות נוספות לטריגרים
11. `10_ProofQueriesForReport.sql` – שאילתות עזר לצילומי מסך בדוח

## הנחה חשובה במערכת

בטבלת `bookings`, העמודה `b_status` משמשת כסטטוס תשלום:

- `FALSE` = לא שולם
- `TRUE` = שולם

בנוסף, בטבלת `bookings` יש עמודה בשם `amount_pepole` עם שגיאת כתיב.
בקוד חייבים להשתמש בשם הזה בדיוק, כי זה שם העמודה האמיתי בבסיס הנתונים.

## פירוט התוכניות

### 1. `fn_available_places`

פונקציה שמקבלת מזהה מופע טיול (`t_i_id`) ומחזירה כמה מקומות פנויים נשארו.

אלמנטים תכנותיים:

- `SELECT INTO`
- Cursor implicit
- תנאי `IF`
- `COALESCE`
- `RETURN`
- `EXCEPTION`

### 2. `fn_customer_unpaid_bookings`

פונקציה שמקבלת מזהה לקוח ומחזירה `Ref Cursor` עם כל ההזמנות הלא משולמות שלו.

אלמנטים תכנותיים:

- החזרת `Ref Cursor`
- `OPEN cursor FOR SELECT`
- בדיקת קיום לקוח
- JOIN בין טבלאות
- `EXCEPTION`

### 3. `pr_create_booking`

פרוצדורה שיוצרת הזמנה חדשה רק אם יש מספיק מקומות פנויים בטיול.

אלמנטים תכנותיים:

- קריאה לפונקציה
- תנאי `IF`
- `INSERT`
- חישוב מחיר
- `RAISE NOTICE`
- `EXCEPTION`

### 4. `pr_pay_customer_bookings`

פרוצדורה שעוברת על כל ההזמנות הלא משולמות של לקוח, מסמנת אותן כשולמו,
ומוסיפה רשומות לטבלת `payment_log`.

אלמנטים תכנותיים:

- Cursor explicit
- `RECORD`
- `LOOP`
- `FETCH`
- `UPDATE`
- `INSERT`
- `EXCEPTION`

### 5. `trg_log_tour_price_update`

טריגר מסוג `AFTER UPDATE OF price` על טבלת `tour`.
כאשר מחיר של טיול משתנה, נשמרת רשומה בטבלת `tour_price_history`.

זה הטריגר שעונה על הדרישה של טריגר אחד לפחות בזמן `UPDATE`.

### 6. `trg_booking_total_and_capacity`

טריגר מסוג `BEFORE INSERT OR UPDATE` על טבלת `bookings`.
הוא מחשב אוטומטית את `total_price` ובודק שאין חריגה ממספר המשתתפים המקסימלי.

### 7. תוכנית ראשית 1

`07_MainProgram1_CreateBooking.sql`

מפעילה:

- פונקציה: `fn_available_places`
- פרוצדורה: `pr_create_booking`

### 8. תוכנית ראשית 2

`08_MainProgram2_PayBookings.sql`

מפעילה:

- פונקציה: `fn_customer_unpaid_bookings`
- פרוצדורה: `pr_pay_customer_bookings`

## מה לצלם לדוח

צריך להראות שכל תוכנית עבדה:

1. תוצאה של `fn_available_places`.
2. תוצאה של `FETCH ALL` מתוך ה־Ref Cursor.
3. הזמנה חדשה שנוצרה בטבלת `bookings`.
4. רשומות חדשות בטבלת `payment_log`.
5. רשומה חדשה בטבלת `tour_price_history` אחרי עדכון מחיר.
6. `total_price` מחושב בטבלת `bookings`.
7. הודעת חריגה מכוונת מהטריגר כאשר מנסים להכניס הזמנה עם יותר מדי משתתפים.
