# DBProject_214177644

# SmartRoute – Guided Travel Routes Management System

## Table of Contents

- [שלב א הקדמה](#introduction)
- [שלב ב - שאילתות ואילוצים](#phase-2)
- [שלב ג - אינטגרציה ומבטים](./שלב%20ג/README.md)
- [שלב ד' – תכנות PL/pgSQL](#phase-d)
- [שלב ה׳ - ממשק גרפי לעבודה מול בסיס הנתונים](#שלב-ה---ממשק-גרפי-לעבודה-מול-בסיס-הנתונים)
---
## שלב א הקדמה
## Introduction

SmartRoute is a database system designed for managing guided travel routes and organized tours.

The system allows travel companies and tour organizers to manage routes, tourist sites, guided tours, guides, travelers, and bookings in a structured and reliable way.

The database stores all main information required for planning and managing guided tours, while keeping the data organized, consistent, and easy to maintain.

---

## System Purpose

The system supports the following main actions:

* Creating and managing travel routes.
* Managing tourist sites and attractions.
* Connecting sites to routes.
* Scheduling guided tours according to existing routes.
* Assigning guides to guided tours.
* Managing travelers.
* Registering travelers to guided tours.
* Tracking bookings and payment status.

---

## Application Screens

The following screens were created using Google AI Studio as a visual prototype for the SmartRoute system.

Google AI Studio application link:

[SmartRoute App](https://aistudio.google.com/apps/664d5084-b6b3-46bc-a42e-04a17ecb6ce5?showAssistant=true&showPreview=true&fullscreenApplet=true)

### Dashboard

The dashboard displays a general overview of the system, including routes, bookings, and general statistics.

![Dashboard](./שלב%20א/screens/dashboard.png)

### Routes Management

This screen allows the manager to view and manage travel routes.

![Routes](./שלב%20א/screens/routes.png)

### Sites Management

This screen allows the manager to manage tourist sites and attractions.

![Sites](./שלב%20א/screens/sites.png)

### Travelers Management

This screen allows the manager to manage travelers in the system.

![Travelers](./שלב%20א/screens/travelers.png)

### Bookings Management

This screen allows the manager to view and manage tour registrations.

![Bookings](./שלב%20א/screens/bookings.png)

---

## ERD Diagram

The ERD describes the main entities in the SmartRoute system and the relationships between them.

Main entities:

* USERS
* GUIDE
* ROUTE
* SITE
* ROUTESITE
* GUIDEDTOUR
* BOOKING

Main relationships:

* A route can have many guided tours.
* A guide can lead many guided tours.
* A user can make many bookings.
* A guided tour can have many bookings.
* A route can include many sites.
* A site can appear in many routes.
* ROUTESITE represents the many-to-many relationship between ROUTE and SITE.

![ERD Diagram](./שלב%20א/diagrams/ERD.png)

---

## DSD Diagram

The DSD presents the final relational schema, including tables, primary keys, foreign keys, and relationships.

![DSD Diagram](./שלב%20א/diagrams/DSD.png)

---

## Database Design – 3NF

The database schema is normalized to at least Third Normal Form, 3NF.

The design separates the data into independent tables in order to reduce duplication and prevent update, insert, and delete anomalies.

Examples:

* Traveler information is stored only in the USERS table.
* Guide information is stored only in the GUIDE table.
* Route information is stored only in the ROUTE table.
* Site information is stored only in the SITE table.
* Booking information is stored only in the BOOKING table.
* The many-to-many relationship between ROUTE and SITE is implemented using the ROUTESITE table.

---

## SQL Scripts

The following SQL scripts are included in the repository:

| File                                           | Description                                                                         |
| ---------------------------------------------- | ----------------------------------------------------------------------------------- |
| [createTables.sql](./שלב%20א/createTables.sql) | Creates all database tables, including primary keys, foreign keys, and constraints. |
| [dropTables.sql](./שלב%20א/dropTables.sql)     | Drops all tables in the correct order.                                              |
| [insertTables.sql](./שלב%20א/insertTables.sql) | Inserts initial manual sample data.                                                 |
| [selectAll.sql](./שלב%20א/selectAll.sql)       | Selects all data from all tables.                                                   |

---

## Data Insertion Methods

The database was populated using three different data insertion methods.

---

### Method 1 – Python Data Generation

A Python script was used to generate and insert a large amount of data directly into the PostgreSQL database.

The script is stored in the `programming` folder:

[generateData.py](./שלב%20א/programming/generateData.py)

Final record counts after running the Python script:

| Table      | Number of Records |
| ---------- | ----------------: |
| USERS      |            20,020 |
| BOOKING    |            20,020 |
| GUIDE      |               520 |
| ROUTE      |               520 |
| SITE       |               520 |
| GUIDEDTOUR |               520 |
| ROUTESITE  |               521 |

This satisfies the requirement of at least 500 records in each table and at least 20,000 records in two tables.

Screenshot:

![Python Insert](./שלב%20א/screens/pyInsert.png)

---

### Method 2 – Mockaroo CSV Generation

Mockaroo was used as an external data generation tool.

A CSV file was generated for the GUIDE table.

The generated CSV file includes the following fields:

* guide_id
* full_name
* phone
* email
* languages

The file is stored in the `programming` folder:

[mockaroo_guides.csv](./שלב%20א/programming/mockaroo_guides.csv)

Screenshot:

![Mockaroo Insert](./שלב%20א/screens/mockarooInsert.png)

---

### Method 3 – Manual SQL Inserts

Manual SQL insert commands were written in the file `insertTables.sql`.

This file contains sample `INSERT` commands for the database tables.

File:

[insertTables.sql](./שלב%20א/insertTables.sql)

Screenshot:

![SQL Insert](./שלב%20א/screens/SQLInsert.png)

---

## Backup

Two backup methods were used for the database.

---

### Method 1 – SQL Backup using pg_dump

A logical SQL backup was created using the PostgreSQL `pg_dump` command.

The backup file is stored in the `backup` folder:

[backup_2026_05_27.sql](./שלב%20א/backup/backup_2026_05_27.sql)

This file is a readable SQL backup file.

Screenshot:

![SQL Backup](./שלב%20א/screens/SQLbackup.png)

---

### Method 2 – pgAdmin Custom Backup

A second backup was created using pgAdmin in custom backup format.

The backup file is stored in the `backup` folder:

[backup_pgadmin_2026_05_27.backup](./שלב%20א/backup/backup_pgadmin_2026_05_27.backup)

This file is a PostgreSQL custom backup file and is not meant to be read as plain text.

Screenshot:

![pgAdmin Backup](./שלב%20א/screens/pgBackup.png)

---

Both backup files were saved in the project repository under the `backup` folder.

---

## Technologies

* Database: PostgreSQL
* Database UI Tool: pgAdmin
* Containerization: Docker & Docker Compose
* Data Generation: Python, Mockaroo, CSV
* Development Environment: PyCharm / VS Code
* Frontend Prototype: React-based design created using Google AI Studio

---

## Running the Environment

To start the database environment, run:

```bash
docker compose up -d --build
```

To reset the database completely and recreate it from the initialization files:

```bash
docker compose down -v
docker compose up -d --build
```

After running the environment, pgAdmin is available at:

```text
http://localhost:8080
```


<a id="phase-2"></a>

## שלב ב - שאילתות ואילוצים

בשלב זה בוצע תשאול של בסיס הנתונים של מערכת SmartRoute.
השלב כולל שאילתות `SELECT`, שאילתות `UPDATE`, שאילתות `DELETE`, הוספת אילוצים, הוספת אינדקסים, ובדיקת `ROLLBACK` ו־`COMMIT`.

הקבצים שנוספו בשלב זה:

* `שלב ב/scripts/Queries.sql`
* `שלב ב/scripts/Constraints.sql`
* `שלב ב/scripts/Index.sql`
* `שלב ב/scripts/RollbackCommit.sql`
* `שלב ב/backup2`
* `שלב ב/screenshots`

---

# שאילתות SELECT

בשלב זה נכתבו 8 שאילתות `SELECT`.
ארבע מתוכן נכתבו בשתי צורות שונות, כדי להשוות בין יעילות של שאילתות שונות שמחזירות תוצאה דומה.

---

## SELECT 1 - Dashboard Summary

שאילתה זו מיועדת למסך הבית / Dashboard.
השאילתה מציגה סיכום כללי של המערכת: סך הכנסות, מספר מסלולים פעילים, מספר טיולים ומספר הזמנות.

השאילתה משתמשת בטבלאות:

* `ROUTE`
* `GUIDEDTOUR`
* `BOOKING`

צילום תוצאה:

![SELECT 1](./שלב%20ב/screenshots/SELECT1.png)

---

## SELECT 2A + SELECT 2B - Monthly Booking Growth

שאילתה זו מיועדת לגרף הצמיחה במסך Dashboard.
השאילתה מציגה לפי שנה וחודש: מספר הזמנות, מספר משתתפים והכנסה חודשית.

בשאילתה זו נעשה שימוש בפירוק תאריך באמצעות:

* `EXTRACT(YEAR FROM booking_date)`
* `EXTRACT(MONTH FROM booking_date)`

### SELECT 2A - שימוש ב־JOIN ו־GROUP BY

![SELECT 2A](./שלב%20ב/screenshots/SELECT2-1.png)

### SELECT 2B - שימוש בתת־שאילתה

![SELECT 2B](./שלב%20ב/screenshots/SELECT2-2.png)

### הסבר יעילות

בשאילתה 2A החישוב מתבצע ישירות באמצעות `JOIN` ו־`GROUP BY`.
בשאילתה 2B קודם נוצרת תת־שאילתה שמכינה את הנתונים, ורק לאחר מכן מתבצע הסיכום החודשי.

בדרך כלל, שימוש ישיר ב־`JOIN` ו־`GROUP BY` פשוט ויעיל יותר, אך PostgreSQL עשוי לבצע אופטימיזציה ולצמצם את ההבדלים בפועל.

---

## SELECT 3A + SELECT 3B - Routes Statistics

שאילתה זו מיועדת למסך Routes.
השאילתה מציגה לכל מסלול את פרטי המסלול, מספר האתרים במסלול ומספר הטיולים המודרכים המשויכים אליו.

השאילתה משתמשת בטבלאות:

* `ROUTE`
* `ROUTESITE`
* `GUIDEDTOUR`

### SELECT 3A - שימוש ב־JOIN ו־GROUP BY

![SELECT 3A](./שלב%20ב/screenshots/SELECT3-1.png)

### SELECT 3B - שימוש בתתי־שאילתות

![SELECT 3B](./שלב%20ב/screenshots/SELECT3-2.png)

### הסבר יעילות

בשאילתה 3A נעשה שימוש ב־`LEFT JOIN` וב־`GROUP BY`, ולכן הנתונים מחושבים בצורה מרוכזת.
בשאילתה 3B נעשה שימוש בתתי־שאילתות עבור כל מסלול בנפרד. דרך זו קריאה וברורה, אך עלולה להיות פחות יעילה כאשר יש הרבה מסלולים, משום שעבור כל שורה מתבצע חישוב נוסף.

---

## SELECT 4A + SELECT 4B - Sites Usage

שאילתה זו מיועדת למסך Sites.
השאילתה מציגה לכל אתר כמה מסלולים משתמשים בו.

השאילתה משתמשת בטבלאות:

* `SITE`
* `ROUTESITE`

### SELECT 4A - שימוש ב־JOIN ו־GROUP BY

![SELECT 4A](./שלב%20ב/screenshots/SELECT4-1.png)

### SELECT 4B - שימוש בתת־שאילתה

![SELECT 4B](./שלב%20ב/screenshots/SELECT4-2.png)

### הסבר יעילות

בשאילתה 4A בסיס הנתונים מבצע חיבור בין הטבלאות וסיכום מרוכז.
בשאילתה 4B מתבצעת ספירה עבור כל אתר בנפרד באמצעות תת־שאילתה. כאשר יש הרבה אתרים, דרך זו עשויה להיות איטית יותר.

---

## SELECT 5A + SELECT 5B - Tours Availability

שאילתה זו מיועדת למסך Tours.
השאילתה מציגה לכל טיול מודרך את שם המסלול, שם המדריך, תאריך הטיול, סטטוס, מחיר, מספר משתתפים מקסימלי, מספר משתתפים רשומים ומספר מקומות פנויים.

השאילתה משתמשת בטבלאות:

* `GUIDEDTOUR`
* `ROUTE`
* `GUIDE`
* `BOOKING`

בנוסף, השאילתה מפרקת את תאריך הטיול ליום, חודש ושנה.

### SELECT 5A - שימוש ב־JOIN ו־GROUP BY

![SELECT 5A](./שלב%20ב/screenshots/SELECT5-1.png)

### SELECT 5B - שימוש בתת־שאילתה

![SELECT 5B](./שלב%20ב/screenshots/SELECT5-2.png)

### הסבר יעילות

בשאילתה 5A מספר המשתתפים הרשומים מחושב באמצעות `JOIN` ו־`GROUP BY`.
בשאילתה 5B מספר המשתתפים מחושב באמצעות תת־שאילתה עבור כל טיול בנפרד.

בבדיקה שלנו היה ניתן לראות ששאילתה 5A יעילה יותר משאילתה 5B, משום שהיא מבצעת את הסיכום בצורה מרוכזת ולא מחשבת מחדש עבור כל שורה.

---

## SELECT 6 - Bookings Management

שאילתה זו מיועדת למסך Bookings.
השאילתה מציגה מידע מלא על ההזמנה: מספר הזמנה, תאריך הזמנה, שם המטייל, אימייל, טלפון, שם המסלול, תאריך הטיול, מספר משתתפים וסטטוס תשלום.

השאילתה משתמשת בטבלאות:

* `BOOKING`
* `USERS`
* `GUIDEDTOUR`
* `ROUTE`

צילום תוצאה:

![SELECT 6](./שלב%20ב/screenshots/SELECT6.png)

---

## SELECT 7 - Travelers Activity Summary

שאילתה זו מיועדת למסך Travelers.
השאילתה מציגה לכל מטייל את מספר ההזמנות שלו, סך המשתתפים שהזמין, תאריך ההזמנה האחרונה וסכום התשלומים הכולל.

השאילתה משתמשת בטבלאות:

* `USERS`
* `BOOKING`
* `GUIDEDTOUR`

צילום תוצאה:

![SELECT 7](./שלב%20ב/screenshots/SELECT7.png)

---

## SELECT 8 - Route Details

שאילתה זו מיועדת למסך פרטי מסלול.
השאילתה מציגה את המסלול ואת האתרים השייכים אליו לפי סדר הביקור.

השאילתה משתמשת בטבלאות:

* `ROUTE`
* `ROUTESITE`
* `SITE`

צילום תוצאה:

![SELECT 8](./שלב%20ב/screenshots/SELECT8.png)

---

# שאילתות UPDATE

בשלב זה נכתבו 3 שאילתות `UPDATE`.
עבור כל שאילתה מוצג מצב לפני העדכון, הרצת העדכון, ומצב לאחר העדכון.

---

## UPDATE 1 - פתיחה מחדש של טיולים עתידיים שבוטלו

שאילתה זו מעדכנת טיולים עתידיים שהיו בסטטוס `Cancelled` לסטטוס `Open`.

הצורך במערכת: מנהלת המערכת יכולה להחזיר טיולים שבוטלו לפעילות.

לפני העדכון:

![UPDATE 1 Before](./שלב%20ב/screenshots/Update1before.png)

הרצת העדכון:

![UPDATE 1 Run](./שלב%20ב/screenshots/Update1run.png)

אחרי העדכון:

![UPDATE 1 After](./שלב%20ב/screenshots/Update1after.png)

---

## UPDATE 2 - העלאת מחיר לטיולים במסלולים קשים

שאילתה זו מעלה מחיר של טיולים עתידיים במסלולים ברמת קושי `Hard` ב־10%.

הצורך במערכת: מסלולים קשים דורשים יותר הכנה, מדריכים מנוסים יותר ולעיתים משאבים נוספים.

לפני העדכון:

![UPDATE 2 Before](./שלב%20ב/screenshots/Update2before.png)

הרצת העדכון:

![UPDATE 2 Run](./שלב%20ב/screenshots/Update2run.png)

אחרי העדכון:

![UPDATE 2 After](./שלב%20ב/screenshots/Update2after.png)

---

## UPDATE 3 - ביטול הזמנות ישנות שממתינות לתשלום

שאילתה זו מעדכנת הזמנות ישנות בסטטוס `Pending` לסטטוס `Cancelled`.

הצורך במערכת: ניקוי הזמנות שלא שולמו ולא הושלמו בזמן.

לפני העדכון:

![UPDATE 3 Before](./שלב%20ב/screenshots/Update3before.png)

הרצת העדכון:

![UPDATE 3 Run](./שלב%20ב/screenshots/Update3run.png)

אחרי העדכון:

![UPDATE 3 After](./שלב%20ב/screenshots/Update3after.png)

---

# שאילתות DELETE

בשלב זה נכתבו 3 שאילתות `DELETE`.
עבור כל שאילתה מוצג מצב לפני המחיקה, הרצת המחיקה, ומצב לאחר המחיקה.

---

## DELETE 1 - מחיקת הזמנות מבוטלות

שאילתה זו מוחקת הזמנות שנמצאות בסטטוס `Cancelled`.

הצורך במערכת: ניקוי רשומות שאינן פעילות ואינן דרושות לניהול השוטף.

לפני המחיקה:

![DELETE 1 Before](./שלב%20ב/screenshots/Delete1before.png)

הרצת המחיקה:

![DELETE 1 Run](./שלב%20ב/screenshots/Delete1run.png)

אחרי המחיקה:

![DELETE 1 After](./שלב%20ב/screenshots/Delete1after.png)

---

## DELETE 2 - מחיקת הזמנות שלא שולמו עבור טיולים שבוטלו

שאילתה זו מוחקת הזמנות בסטטוס `Unpaid` ששייכות לטיולים שהסטטוס שלהם הוא `Cancelled`.

הצורך במערכת: אם הטיול בוטל וההזמנה לא שולמה, ההזמנה כבר אינה רלוונטית.

לפני המחיקה:

![DELETE 2 Before](./שלב%20ב/screenshots/Delete2before.png)

הרצת המחיקה:

![DELETE 2 Run](./שלב%20ב/screenshots/Delete2run.png)

אחרי המחיקה:

![DELETE 2 After](./שלב%20ב/screenshots/Delete2after.png)

---

## DELETE 3 - מחיקת מטיילים ללא הזמנות

שאילתה זו מוחקת משתמשים שאין להם אף הזמנה במערכת.

הצורך במערכת: ניקוי משתמשים לא פעילים ממסך Travelers.

לפני המחיקה:

![DELETE 3 Before](./שלב%20ב/screenshots/Delete3before.png)

הרצת המחיקה:

![DELETE 3 Run](./שלב%20ב/screenshots/Delete3run.png)

אחרי המחיקה:

![DELETE 3 After](./שלב%20ב/screenshots/Delete3after.png)

---

# אילוצים Constraints

בשלב זה נוספו 3 אילוצים חדשים באמצעות `ALTER TABLE`.
האילוצים נועדו לשמור על תקינות הנתונים ולמנוע הכנסת ערכים לא הגיוניים.

---

## Constraint 1 - אימייל משתמש חייב להכיל @

האילוץ נוסף לטבלת `USERS`.

האילוץ מוודא שכל אימייל של משתמש מכיל את התו `@`.

צילום בדיקה:

![Constraint 1](./שלב%20ב/screenshots/constraints1.png)

---

## Constraint 2 - טלפון מדריך חייב להתחיל ב־05

האילוץ נוסף לטבלת `GUIDE`.

האילוץ מוודא שמספר טלפון של מדריך מתחיל ב־`05`, בהתאם לפורמט של מספר נייד בישראל.

צילום בדיקה:

![Constraint 2](./שלב%20ב/screenshots/constraints2.png)

---

## Constraint 3 - מרחק מסלול חייב להיות גדול מ־0

האילוץ נוסף לטבלת `ROUTE`.

האילוץ מוודא שמרחק של מסלול יהיה גדול מ־0, משום שמסלול באורך 0 אינו הגיוני במערכת לניהול מסלולי טיול.

צילום בדיקה:

![Constraint 3](./שלב%20ב/screenshots/constraints3.png)

---

# אינדקסים Indexes

בשלב זה נוספו 3 אינדקסים.
לכל אינדקס בוצעה בדיקת זמן ריצה לפני ואחרי באמצעות `EXPLAIN ANALYZE`.

---

## Index 1 - אינדקס על סטטוס תשלום ותאריך הזמנה

האינדקס נוצר על:

```sql
BOOKING(payment_status, booking_date)
```

מטרת האינדקס היא לשפר שאילתות שמסננות הזמנות לפי סטטוס תשלום ותאריך הזמנה.
האינדקס מתאים למסכי Dashboard ו־Bookings.

לפני יצירת האינדקס:

![Index 1 Before](./שלב%20ב/screenshots/index1_before.png)

יצירת האינדקס:

![Index 1 Create](./שלב%20ב/screenshots/index1_create.png)

אחרי יצירת האינדקס:

![Index 1 After](./שלב%20ב/screenshots/index1_after.png)

### הסבר תוצאה

האינדקס מתאים לשאילתות שמחפשות הזמנות לפי סטטוס תשלום ובטווח תאריכים.
כאשר הטבלה גדולה יותר, האינדקס יכול לצמצם את כמות השורות שהמערכת צריכה לסרוק.

---

## Index 2 - אינדקס על תאריך הזמנה בסדר יורד

האינדקס נוצר על:

```sql
BOOKING(booking_date DESC)
```

מטרת האינדקס היא לשפר שאילתות שמציגות את ההזמנות האחרונות קודם.
האינדקס מתאים למסך Bookings ול־Dashboard.

לפני יצירת האינדקס:

![Index 2 Before](./שלב%20ב/screenshots/index2_before.png)

יצירת האינדקס:

![Index 2 Create](./שלב%20ב/screenshots/index2_create.png)

אחרי יצירת האינדקס:

![Index 2 After](./שלב%20ב/screenshots/index2_after.png)

### הסבר תוצאה

האינדקס מאפשר לבסיס הנתונים לגשת להזמנות לפי סדר תאריך יורד, ולכן יכול לעזור במיוחד בשאילתות שמציגות את ההזמנות האחרונות עם `ORDER BY booking_date DESC LIMIT`.

---

## Index 3 - אינדקס על סטטוס ותאריך התחלה של טיול

האינדקס נוצר על:

```sql
GUIDEDTOUR(status, start_date)
```

מטרת האינדקס היא לשפר שאילתות שמחפשות טיולים לפי סטטוס ולפי תאריך התחלה.
האינדקס מתאים למסך Tours ולחלק של Upcoming Tours במסך Dashboard.

לפני יצירת האינדקס:

![Index 3 Before](./שלב%20ב/screenshots/index3_before.png)

יצירת האינדקס:

![Index 3 Create](./שלב%20ב/screenshots/index3_create.png)

אחרי יצירת האינדקס:

![Index 3 After](./שלב%20ב/screenshots/index3_after.png)

### הסבר תוצאה

האינדקס מתאים לשאילתות שמציגות טיולים פתוחים ועתידיים.
במקום לסרוק את כל טבלת `GUIDEDTOUR`, בסיס הנתונים יכול להשתמש באינדקס לפי `status` ואז לפי `start_date`.

---

# ROLLBACK

בדוגמת ה־`ROLLBACK` בוצע עדכון זמני למחיר של טיול מודרך.
המחיר עודכן בתוך טרנזקציה, ולאחר מכן הופעלה פקודת `ROLLBACK`.

לאחר `ROLLBACK`, בסיס הנתונים חזר למצבו הקודם והמחיר המקורי נשמר.

לפני העדכון:

![Rollback Before](./שלב%20ב/screenshots/rollback_before.png)

הרצת העדכון:

![Rollback Update](./שלב%20ב/screenshots/rollback_update.png)

אחרי העדכון ולפני ROLLBACK:

![Rollback After Update](./שלב%20ב/screenshots/rollback_afterupdate.png)

אחרי ROLLBACK:

![Rollback After Rollback](./שלב%20ב/screenshots/rollback_afterrollback.png)

### הסבר

`ROLLBACK` מבטל שינויים שבוצעו בתוך טרנזקציה, כל עוד לא בוצע `COMMIT`.
בדוגמה זו המחיר חזר לערך המקורי לאחר הפעלת `ROLLBACK`.

---

# COMMIT

בדוגמת ה־`COMMIT` בוצע עדכון של סטטוס תשלום עבור הזמנה.
העדכון בוצע בתוך טרנזקציה, ולאחר מכן הופעלה פקודת `COMMIT`.

לאחר `COMMIT`, השינוי נשמר בבסיס הנתונים.

לפני העדכון:

![Commit Before](./שלב%20ב/screenshots/commit_before.png)

אחרי העדכון:

![Commit After Update](./שלב%20ב/screenshots/commit_afterapdate.png)

אחרי COMMIT:

![Commit After Commit](./שלב%20ב/screenshots/commit_aftercommmit.png)

### הסבר

`COMMIT` מאשר את השינויים שבוצעו בתוך טרנזקציה ושומר אותם לצמיתות בבסיס הנתונים.
בדוגמה זו סטטוס התשלום נשאר מעודכן גם לאחר סיום הטרנזקציה.

## גיבוי

[backup2.backup](./שלב%20ב/backup2.backup)

# סיכום שלב ב

בשלב זה בוצעו כל הדרישות:

* נכתבו 8 שאילתות `SELECT`
* 4 שאילתות `SELECT` נכתבו בשתי צורות שונות
* נכתבו 3 שאילתות `UPDATE`
* נכתבו 3 שאילתות `DELETE`
* נוספו 3 אילוצים חדשים
* נוספו 3 אינדקסים ונבדקו זמני ריצה לפני ואחרי
* הודגם שימוש ב־`ROLLBACK`
* הודגם שימוש ב־`COMMIT`
* כל השאילתות הותאמו למסכים של המערכת: Dashboard, Routes, Sites, Tours, Travelers, Bookings
השלב מדגים שימוש בשאילתות מורכבות, חיבורים בין טבלאות, סיכומים, תתי־שאילתות, שימוש בתאריכים, אילוצים, אינדקסים וניהול טרנזקציות.


<a id="phase-3"></a>
<a id="phase-3"></a>

# שלב ג - אינטגרציה ומבטים

## הקדמה

בשלב זה ביצענו אינטגרציה בין בסיס הנתונים המקורי שלנו, העוסק בניהול מסלולי טיול, לבין בסיס נתונים של אגף נוסף שקיבלנו מקבוצה אחרת.

מטרת האינטגרציה הייתה ליצור בסיס נתונים משולב אחד, תוך שמירה על הטבלאות הקיימות במערכת המקורית והרחבתן באמצעות פקודות `ALTER TABLE`, בהתאם להנחיות של שיטה א'.

---

## 1. אלגוריתם הינדוס לאחור – Reverse Engineering

כדי לייצר את ה־DSD וה־ERD של האגף שקיבלנו, פעלנו לפי האלגוריתם הבא:

1. **טעינת הגיבוי**
   קיבלנו קובץ גיבוי של בסיס הנתונים מהאגף השני וטענו אותו לתוך PostgreSQL.

2. **זיהוי טבלאות**
   סרקנו את הטבלאות שנוצרו מתוך הגיבוי וזיהינו את שמות הטבלאות, העמודות וטיפוסי הנתונים.

3. **זיהוי מפתחות ראשיים**
   בדקנו את אילוצי ה־Primary Key בכל טבלה, כדי להבין מה מזהה כל ישות.

4. **זיהוי מפתחות זרים**
   בדקנו את אילוצי ה־Foreign Key, כדי להבין את הקשרים בין הטבלאות.

5. **בניית DSD**
   מתוך הטבלאות, העמודות, המפתחות והקשרים בנינו תרשים DSD של האגף שהתקבל.

6. **בניית ERD**
   מתוך ה־DSD ביצענו הינדוס לאחור והמרנו את הסכמה הרלציונית לתרשים ERD קונספטואלי.

---

## 2. תרשימי האגף שהתקבל

### DSD של האגף החדש

![DSD של האגף החדש](./%D7%A9%D7%9C%D7%91%20%D7%92/diagrams/DSD.png)

### ERD של האגף החדש

![ERD של האגף החדש](./%D7%A9%D7%9C%D7%91%20%D7%92/diagrams/ERD.png)

---

## 3. החלטות אינטגרציה

בשלב האינטגרציה השווינו בין הישויות של המערכת המקורית שלנו לבין הישויות של האגף שהתקבל.

| המערכת המקורית שלנו | המערכת שהתקבלה | החלטת אינטגרציה                     |
| ------------------- | -------------- | ----------------------------------- |
| `USERS`             | `customer`     | איחוד לישות אחת של משתמשים/לקוחות   |
| `GUIDE`             | `guide`        | איחוד לישות אחת של מדריכים          |
| `ROUTE`             | `tour`         | איחוד לישות אחת של מסלולים/טיולים   |
| `SITE`              | `station`      | איחוד לישות אחת של אתרים/תחנות      |
| `GUIDEDTOUR`        | `tourinstance` | איחוד לישות אחת של סיור מודרך בפועל |
| `BOOKING`           | `bookings`     | איחוד לישות אחת של הזמנות           |
| `ROUTESITE`         | `tourstation`  | איחוד לטבלת קשר בין מסלול לאתר      |

מכיוון ששתי המערכות עוסקות באותו תחום תוכן — ניהול טיולים מודרכים — החלטנו לא ליצור טבלאות כפולות, אלא לאחד ישויות בעלות משמעות זהה.

שמות הטבלאות של המערכת המקורית נשמרו, ונוספו אליהן שדות מהמערכת שהתקבלה.

---

## 4. שדות שנוספו במסגרת האינטגרציה

| טבלה         | שדות שנוספו                           |
| ------------ | ------------------------------------- |
| `guide`      | `school`                              |
| `route`      | `route_type`, `area`, `accessibility` |
| `site`       | `address`                             |
| `guidedtour` | `start_time`, `end_time`              |
| `booking`    | `total_price`                         |
| `routesite`  | `visit_duration`                      |

השדות נוספו באמצעות פקודות `ALTER TABLE`, ללא יצירה מחדש של הטבלאות.

קובץ הפקודות המלא:
[Integrate.sql](./%D7%A9%D7%9C%D7%91%20%D7%92/Integrate.sql)

---

## 5. תרשימי המערכת המשולבת

### ERD משולב

![ERD משולב](./%D7%A9%D7%9C%D7%91%20%D7%92/diagrams/IntegratedERD.png)

### DSD לאחר אינטגרציה

![DSD לאחר אינטגרציה](./%D7%A9%D7%9C%D7%91%20%D7%92/diagrams/IntegratedDSD.png)

---

## 6. תהליך שילוב הנתונים

כדי למנוע התנגשויות בין שמות טבלאות, הנתונים שהתקבלו מהאגף השני נטענו תחילה לסכמה זמנית בשם `received`.

לאחר מכן בוצעה העברת נתונים מבוקרת מהסכמה הזמנית אל הטבלאות המשולבות במערכת המקורית.

במהלך ההעברה בוצעו התאמות כדי לשמור על אילוצי המערכת המקורית, לדוגמה:

* מספרי טלפון של מדריכים הומרו לפורמט שמתחיל ב־`05`.
* רמות קושי מספריות הומרו לערכים `Easy`, `Medium`, `Hard`.
* סטטוס סיור הומר לערך `Open`.
* סטטוס תשלום הומר לערכים `Paid` או `Pending`.
* ערכים מספריים מסוימים קיבלו ערכי ברירת מחדל כדי לעמוד באילוצי `CHECK`.

לאחר ההעברה בוצעו בדיקות תקינות:

* בדיקה שיש נתונים בכל הטבלאות.
* בדיקה שאין רשומות יתומות.
* בדיקה שהשאילתות משלב ב עדיין עובדות על בסיס הנתונים המשולב.

---

## 7. מבטים – Views

בשלב זה יצרנו שני מבטים, אחד עבור כל אגף מקורי.

קובץ המבטים המלא:
[Views.sql](./%D7%A9%D7%9C%D7%91%20%D7%92/Views.sql)

---

### מבט 1 – `original_tours_overview`

מבט זה מייצג את נקודת המבט של האגף המקורי שלנו.

הוא מציג מידע על סיורים מודרכים, מסלולים, מדריכים, מספר נרשמים, מקומות פנויים והכנסות מהזמנות ששולמו.

בדיקת נתונים מהמבט:

```sql
SELECT *
FROM original_tours_overview
LIMIT 10;
```

#### שאילתה 1.1 – סיורים פתוחים עם מקומות פנויים

שאילתה זו מציגה סיורים פתוחים שעדיין יש בהם מקומות פנויים.

```sql
SELECT
    guided_tour_id,
    route_name,
    guide_name,
    start_date,
    max_participants,
    registered_participants,
    available_places
FROM original_tours_overview
WHERE status = 'Open'
  AND available_places > 0
ORDER BY start_date
LIMIT 10;
```

#### שאילתה 1.2 – הכנסות לפי רמת קושי

שאילתה זו מסכמת את מספר הסיורים ואת סך ההכנסות לפי רמת הקושי של המסלול.

```sql
SELECT
    difficulty_level,
    COUNT(guided_tour_id) AS total_tours,
    SUM(paid_revenue) AS total_paid_revenue
FROM original_tours_overview
GROUP BY difficulty_level
ORDER BY total_paid_revenue DESC;
```

---

### מבט 2 – `received_department_view`

מבט זה מייצג את נקודת המבט של האגף שהתקבל.

הוא מציג מידע בסגנון המערכת שהתקבלה: לקוח, טיול, מופע טיול, מדריך, מספר משתתפים, סטטוס תשלום ומחיר כולל.

בדיקת נתונים מהמבט:

```sql
SELECT *
FROM received_department_view
LIMIT 10;
```

#### שאילתה 2.1 – הזמנות ששולמו

שאילתה זו מציגה הזמנות ששולמו, כולל שם הלקוח, שם הטיול, תאריך הטיול, מספר המשתתפים והמחיר הכולל.

```sql
SELECT
    booking_id,
    customer_name,
    tour_name,
    tour_date,
    number_of_participants,
    total_price
FROM received_department_view
WHERE payment_status = 'Paid'
ORDER BY tour_date DESC
LIMIT 10;
```

#### שאילתה 2.2 – הכנסות לפי בית ספר של מדריך

שאילתה זו מסכמת את מספר ההזמנות ואת סך ההכנסות לפי בית הספר של המדריך.

```sql
SELECT
    guide_school,
    COUNT(booking_id) AS total_bookings,
    COALESCE(SUM(total_price), 0) AS total_revenue
FROM received_department_view
WHERE guide_school IS NOT NULL
GROUP BY guide_school
ORDER BY total_revenue DESC
LIMIT 10;
```

---

## 8. קבצים להגשה

| קובץ                                                                                           | תיאור                             |
| ---------------------------------------------------------------------------------------------- | --------------------------------- |
| [`שלב ג/diagrams/DSD.png`](./%D7%A9%D7%9C%D7%91%20%D7%92/diagrams/DSD.png)                     | DSD של האגף שהתקבל                |
| [`שלב ג/diagrams/ERD.png`](./%D7%A9%D7%9C%D7%91%20%D7%92/diagrams/ERD.png)                     | ERD של האגף שהתקבל                |
| [`שלב ג/diagrams/IntegratedERD.png`](./%D7%A9%D7%9C%D7%91%20%D7%92/diagrams/IntegratedERD.png) | ERD משולב                         |
| [`שלב ג/diagrams/IntegratedDSD.png`](./%D7%A9%D7%9C%D7%91%20%D7%92/diagrams/IntegratedDSD.png) | DSD לאחר אינטגרציה                |
| [`שלב ג/Integrate.sql`](./%D7%A9%D7%9C%D7%91%20%D7%92/Integrate.sql)                           | פקודות שינוי, התאמה ושילוב נתונים |
| [`שלב ג/Views.sql`](./%D7%A9%D7%9C%D7%91%20%D7%92/Views.sql)                                   | יצירת המבטים והשאליתות עליהם      |
| `שלב ג/backup3.sql`                                                                            | גיבוי מעודכן לאחר שלב ג           |

---

## 9. סיכום

בשלב ג ביצענו תהליך אינטגרציה מלא בין שני בסיסי נתונים בתחום ניהול טיולים מודרכים.

תחילה ביצענו הינדוס לאחור לבסיס הנתונים שהתקבל, יצרנו עבורו DSD ו־ERD, ולאחר מכן בנינו ERD ו־DSD משולבים.

בהמשך שינינו את בסיס הנתונים המקורי באמצעות `ALTER TABLE`, העברנו את נתוני האגף שהתקבל אל הטבלאות המשולבות, בדקנו תקינות קשרים ויצרנו שני מבטים עם שאילתות משמעותיות על כל מבט.

## גיבוי
[`שלב ג/backup3.backup`](./%D7%A9%D7%9C%D7%91%20%D7%92/backup3.backup)
## להוסיף בתוכן העניינים הראשי

```md
- [שלב ד' – תכנות PL/pgSQL](#phase-d)
```

---

<a id="phase-d"></a>

## שלב ד' – תכנות PL/pgSQL

[⬆ חזרה לתוכן העניינים](#תוכן-עניינים)

בשלב זה הוספנו לבסיס הנתונים תוכניות PL/pgSQL מתקדמות.
המטרה הייתה להעביר חלק מהלוגיקה העסקית של מערכת ניהול הטיולים אל תוך בסיס הנתונים עצמו.

בשלב זה נכתבו:

* 2 פונקציות
* 2 פרוצדורות
* 2 טריגרים, כאשר לפחות אחד מהם מופעל בזמן `UPDATE`
* 2 תוכניות ראשיות, כאשר כל תוכנית ראשית מזמנת פונקציה אחת ופרוצדורה אחת
* קובץ `AlterTable.sql`
* קובץ בדיקות והוכחות

---

## מבנה הקבצים בשלב ד'

```text
phaseD/
│
├── 00_AlterTable.sql
├── 01_Function_AvailablePlaces.sql
├── 02_Function_CustomerUnpaidCursor.sql
├── 03_Procedure_CreateBooking.sql
├── 04_Procedure_PayCustomerBookings.sql
├── 05_Trigger_LogTourPriceUpdate.sql
├── 06_Trigger_BookingTotalAndCapacity.sql
├── 07_MainProgram1_CreateBooking.sql
├── 08_MainProgram2_PayBookings.sql
├── 09_Test_Triggers.sql
├── 10_ProofQueriesForReport.sql
├── README_PhaseD.md
├── backup4.backup
└── screenshots/
```

---

## 00_AlterTable.sql

קובץ זה מוסיף לבסיס הנתונים טבלאות עזר הדרושות לשלב ד'.

הטבלאות שנוספו הן:

* `tour_price_history` – טבלה לשמירת היסטוריית שינויי מחירים של טיולים.
* `payment_log` – טבלה לשמירת תיעוד של תשלומים שבוצעו עבור הזמנות.

טבלאות אלו מאפשרות להראות שהפרוצדורות והטריגרים לא רק מחשבים מידע, אלא גם מבצעים שינויים אמיתיים בבסיס הנתונים.

בצילום המסך ניתן לראות שהטבלאות נוצרו או שכבר היו קיימות, וההרצה הסתיימה בהצלחה.

![00\_AlterTable](שלב%20ד/screenshots/00_AlterTable_sql__helper_tables_created_or_already_exist.png)

---

## 01_Function_AvailablePlaces.sql

קובץ זה יוצר את הפונקציה:

```sql
fn_available_places(p_t_i_id INTEGER)
```

הפונקציה מקבלת מזהה של מופע טיול (`t_i_id`) ומחזירה את מספר המקומות הפנויים שנותרו באותו מופע.

הפונקציה מחשבת:

1. מהו מספר המשתתפים המקסימלי המותר בטיול.
2. כמה משתתפים כבר רשומים להזמנות קיימות.
3. כמה מקומות פנויים נשארו.

הפונקציה כוללת שימוש ב:

* משתנים
* `SELECT INTO`
* תנאי `IF`
* חישוב ערך מוחזר
* `RETURN`
* טיפול בחריגות `EXCEPTION`

בצילום המסך ניתן לראות שהפונקציה נוצרה בהצלחה.

![01\_Function\_AvailablePlaces](שלב%20ד/screenshots/01_Function_AvailablePlaces_sql__CREATE_FUNCTION.png)

---

## 02_Function_CustomerUnpaidCursor.sql

קובץ זה יוצר פונקציה המחזירה `Ref Cursor`.

הפונקציה מקבלת מזהה לקוח ומחזירה Cursor המכיל את כל ההזמנות של אותו לקוח שעדיין לא שולמו.

מטרת הפונקציה היא לאפשר שליפה מסודרת של הזמנות לא משולמות עבור לקוח מסוים, כדי שניתן יהיה בהמשך לטפל בהן בפרוצדורה.

הפונקציה כוללת שימוש ב:

* `REFCURSOR`
* בדיקת קיום לקוח
* תנאי `IF`
* פתיחת Cursor באמצעות `OPEN`
* טיפול בחריגות

בצילום המסך ניתן לראות שהפונקציה נוצרה בהצלחה.

![02\_Function\_CustomerUnpaidCursor](שלב%20ד/screenshots/02_Function_CustomerUnpaidCursor_sql__CREATE_FUNCTION.png)

---

## 03_Procedure_CreateBooking.sql

קובץ זה יוצר את הפרוצדורה:

```sql
pr_create_booking(...)
```

הפרוצדורה אחראית על יצירת הזמנה חדשה עבור לקוח למופע טיול מסוים.

לפני הכנסת ההזמנה לטבלת `bookings`, הפרוצדורה בודקת האם יש מספיק מקומות פנויים בטיול.
הבדיקה נעשית באמצעות קריאה לפונקציה `fn_available_places`.

אם יש מספיק מקומות פנויים — נוצרת הזמנה חדשה.
אם אין מספיק מקומות — נזרקת חריגה וההזמנה אינה נשמרת.

הפרוצדורה כוללת שימוש ב:

* קריאה לפונקציה
* משתנים
* תנאי `IF`
* פעולת `INSERT`
* יצירת מזהה חדש להזמנה
* `RAISE NOTICE`
* טיפול בחריגות

בצילום המסך ניתן לראות את יצירת התוכנית בבסיס הנתונים.

![03\_Procedure\_CreateBooking](שלב%20ד/screenshots/03_Procedure_CreateBooking_sql__OPEN_FILE_but_retake_needed_output_says_CREATE_FUNCTION.png)

---

## 04_Procedure_PayCustomerBookings.sql

קובץ זה יוצר את הפרוצדורה:

```sql
pr_pay_customer_bookings(p_c_id INTEGER)
```

הפרוצדורה מטפלת בתשלום עבור כל ההזמנות הלא משולמות של לקוח מסוים.

היא עוברת על ההזמנות הלא משולמות של הלקוח, מעדכנת אותן לסטטוס שולם, ומכניסה רשומה מתאימה לטבלת `payment_log`.

הפרוצדורה כוללת שימוש ב:

* Cursor מפורש
* `OPEN`
* `FETCH`
* `LOOP`
* `EXIT`
* `CLOSE`
* משתנה מסוג `RECORD`
* פעולת `UPDATE`
* פעולת `INSERT`
* טיפול בחריגות

בצילום המסך ניתן לראות שהפרוצדורה נוצרה בהצלחה.

![04\_Procedure\_PayCustomerBookings](שלב%20ד/screenshots/04_Procedure_PayCustomerBookings_sql__CREATE_PROCEDURE.png)

---

## 05_Trigger_LogTourPriceUpdate.sql

קובץ זה יוצר טריגר המופעל לאחר עדכון מחיר בטבלת `tour`.

כאשר מחיר של טיול משתנה, הטריגר שומר בטבלת `tour_price_history` את הנתונים הבאים:

* שם הטיול
* המחיר הישן
* המחיר החדש
* תאריך ושעת השינוי

טריגר זה מדגים שימוש בטריגר בזמן `UPDATE`, בהתאם לדרישת שלב ד'.

הטריגר כולל שימוש ב:

* `OLD`
* `NEW`
* פעולת `INSERT`
* בדיקה האם המחיר באמת השתנה
* החזרת `NEW`

בצילום המסך ניתן לראות את יצירת התוכנית בבסיס הנתונים.

![05\_Trigger\_LogTourPriceUpdate](שלב%20ד/screenshots/05_Trigger_LogTourPriceUpdate_sql__OPEN_FILE_but_retake_needed_output_says_CREATE_PROCEDURE.png)

---

## 06_Trigger_BookingTotalAndCapacity.sql

קובץ זה יוצר טריגר המופעל לפני הוספה או עדכון של הזמנה בטבלת `bookings`.

הטריגר מבצע שתי פעולות מרכזיות:

1. מחשב אוטומטית את `total_price` לפי מספר המשתתפים ומחיר הטיול.
2. בודק שאין חריגה ממספר המשתתפים המקסימלי בטיול.

אם מנסים להכניס הזמנה עם יותר משתתפים מהמותר, הטריגר זורק חריגה ומונע את הכנסת ההזמנה.

הטריגר כולל שימוש ב:

* `BEFORE INSERT OR UPDATE`
* `NEW`
* משתנים
* תנאי `IF`
* חישוב מחיר כולל
* `RAISE EXCEPTION`

בצילום המסך ניתן לראות שהטריגר נוצר בהצלחה.

![06\_Trigger\_BookingTotalAndCapacity](שלב%20ד/screenshots/06_Trigger_BookingTotalAndCapacity_sql__CREATE_TRIGGER.png)

---

## 07_MainProgram1_CreateBooking.sql

זוהי התוכנית הראשית הראשונה.

התוכנית מבצעת תהליך מלא של יצירת הזמנה חדשה:

1. בחירת מופע טיול שיש בו מקומות פנויים.
2. בחירת לקוח קיים מהמערכת.
3. קריאה לפונקציה `fn_available_places` כדי לבדוק כמה מקומות פנויים יש לפני ההזמנה.
4. קריאה לפרוצדורה `pr_create_booking` ליצירת הזמנה חדשה.
5. בדיקה חוזרת של מספר המקומות הפנויים לאחר יצירת ההזמנה.
6. הצגת ההזמנות האחרונות בטבלת `bookings`.

תוכנית זו מוכיחה שילוב בין פונקציה, פרוצדורה ושינוי בפועל בבסיס הנתונים.

בצילום המסך ניתן לראות שהתווספה הזמנה חדשה לטבלת `bookings`.

![07\_MainProgram1\_CreateBooking](שלב%20ד/screenshots/07_MainProgram1_CreateBooking_sql__proof_booking_created.png)

---

## 08_MainProgram2_PayBookings.sql

זוהי התוכנית הראשית השנייה.

התוכנית מבצעת טיפול בתשלומים של לקוח:

1. בחירת לקוח שיש לו הזמנות שלא שולמו.
2. קריאה לפונקציה `fn_customer_unpaid_bookings`, שמחזירה Cursor עם ההזמנות הלא משולמות.
3. קריאה לפרוצדורה `pr_pay_customer_bookings`, שמעדכנת את ההזמנות לסטטוס שולם.
4. הצגת רשומות מטבלת `payment_log`.
5. הצגת ההזמנות האחרונות מטבלת `bookings`.

תוכנית זו מוכיחה שימוש בפונקציה שמחזירה Cursor, בפרוצדורה עם Cursor מפורש, ובפעולת עדכון אמיתית בבסיס הנתונים.

בצילום המסך ניתן לראות את ההזמנות האחרונות ואת סטטוס התשלום שלהן לאחר הרצת התוכנית.

![08\_MainProgram2\_PayBookings](שלב%20ד/screenshots/08_MainProgram2_PayBookings_sql__proof_bookings_after_payment.png)

---

## 09_Test_Triggers.sql

קובץ זה משמש לבדיקת הטריגרים.

הקובץ כולל בדיקה שבה מנסים להכניס הזמנה עם מספר משתתפים גבוה מהמותר.
הטריגר מזהה שאין מספיק מקומות פנויים, מונע את הכנסת ההזמנה, ומציג הודעת חריגה מתאימה.

בדיקה זו מוכיחה שהטריגר לא רק נוצר, אלא גם פועל בפועל בזמן הכנסת נתונים לא תקינים.

בצילום המסך ניתן לראות את הודעת החריגה שהתקבלה מהטריגר:

```text
Expected trigger exception
```

![09\_Test\_Triggers](שלב%20ד/screenshots/09_Test_Triggers_sql__expected_trigger_exception.png)

---

## 10_ProofQueriesForReport.sql

קובץ זה כולל שאילתות עזר להצגת הוכחות בדוח.

השאילתות מציגות:

* הזמנות אחרונות
* מחירים כוללים שחושבו אוטומטית
* נתונים מטבלת `payment_log`
* נתונים מטבלת `tour_price_history`
* תוצאות שמראות שהתוכניות אכן השפיעו על בסיס הנתונים

בצילום המסך ניתן לראות הזמנות אחרונות ואת הערך `total_price`, שמוכיח שהמחיר הכולל חושב ונשמר.

![10\_ProofQueriesForReport](שלב%20ד/screenshots/10_ProofQueriesForReport_sql__proof_bookings_total_price.png)

---

## סדר הרצה מומלץ

יש להריץ את הקבצים לפי הסדר הבא:

```text
00_AlterTable.sql
01_Function_AvailablePlaces.sql
02_Function_CustomerUnpaidCursor.sql
03_Procedure_CreateBooking.sql
04_Procedure_PayCustomerBookings.sql
05_Trigger_LogTourPriceUpdate.sql
06_Trigger_BookingTotalAndCapacity.sql
07_MainProgram1_CreateBooking.sql
08_MainProgram2_PayBookings.sql
09_Test_Triggers.sql
10_ProofQueriesForReport.sql
```

---

## גיבוי

[backup4](./שלב%20ד/backup4)

---

## סיכום שלב ד'

בשלב זה בסיס הנתונים הורחב באמצעות תוכניות PL/pgSQL.
התוכניות מאפשרות לבצע בדיקות, חישובים ועדכונים ישירות בתוך בסיס הנתונים.

בפרט, השלב כולל:

* חישוב מקומות פנויים בטיול
* שליפת הזמנות לא משולמות באמצעות Cursor
* יצירת הזמנה חדשה לאחר בדיקת קיבולת
* עדכון הזמנות לסטטוס שולם
* תיעוד תשלומים
* שמירת היסטוריית שינויי מחירים
* בדיקת חריגות בעת הכנסת הזמנה עם יותר מדי משתתפים

צילומי המסך בתיקיית `screenshots` מוכיחים שהתוכניות רצות בהצלחה ומבצעות את הפעולות הנדרשות.


---
## שלב ה׳ - ממשק גרפי לעבודה מול בסיס הנתונים

בשלב זה נבנה ממשק גרפי למערכת **SmartRoute** לניהול טיולים מודרכים.  
הממשק מתחבר ל־PostgreSQL ומאפשר עבודה נוחה מול בסיס הנתונים דרך מסכים גרפיים.

### טכנולוגיות

- React + TypeScript
- Node.js + Express
- PostgreSQL
- Docker
- PL/pgSQL

### יכולות מרכזיות

- מסך בית עם Dashboard וקישורים לכל מסכי המערכת.
- ביצוע פעולות CRUD לטבלאות המרכזיות:
  - Routes
  - Sites
  - Guides
  - Tours
  - Travelers
  - Bookings
  - Route Sites
- הוספה, שליפה, עדכון ומחיקה של רשומות.
- עדכון רשומה דרך כפתור עריכה, כאשר הנתונים נטענים לטופס.
- הצגת שמות וערכים ידידותיים במקום מזהים מספריים בלבד.
- שימוש ב־Show More להצגת פרטים נוספים בלי להעמיס על הטבלה.
- מסך Advanced Actions להפעלת שאילתות משלב ב׳ ופונקציות/פרוצדורות משלב ד׳.
- הודעות הצלחה ושגיאה ברורות למשתמש.
- שמירה על אילוצי בסיס הנתונים, לדוגמה מניעת מחיקה של רשומה שמקושרת לרשומות אחרות.

### הוראות הפעלה

יש לוודא שקונטיינר PostgreSQL פעיל ושקובץ `.env` כולל את פרטי החיבור למסד הנתונים.

הרצת המערכת:

```bash
cd "שלב ה"
docker compose -p smartroute up --build
```

פתיחת המערכת בדפדפן:

```bash
http://localhost:3000
```

### קובץ גיבוי

קובץ הגיבוי של בסיס הנתונים לשלב ה׳:

[backup5.backup](./%D7%A9%D7%9C%D7%91%20%D7%94/backup/backup5.backup)

---

## צילומי מסך - שלב ה׳

### 1. Dashboard ראשי

מסך הבית מציג נתוני סיכום של המערכת: הכנסות, מסלולים, טיולים והזמנות.

![Dashboard](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/01_dashboard_top.png)

### 2. קישורים למסכי המערכת

במסך הבית קיימות קוביות ניווט לכל מסכי המערכת.

![Navigation Cards](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/02_dashboard_navigation_cards.png)

### 3. הוספת מסלול חדש

טופס הוספת מסלול חדש. המשתמש לא מזין ID, המערכת מטפלת בכך אוטומטית.

![Create Route Form](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/03_routes_create_form.png)

### 4. הצלחה לאחר הוספה

לאחר יצירת רשומה חדשה מוצגת הודעת הצלחה.

![Create Route Success](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/04_routes_create_success.png)

### 5. עדכון מסלול

בעת עדכון, נתוני הרשומה נטענים לטופס וניתן לשנות אותם.

![Update Route Form](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/05_routes_update_form.png)

### 6. חיפוש ועדכון

המערכת כוללת חיפוש לפי ערכים גלויים בטבלה והודעת הצלחה לאחר עדכון.

![Search And Update](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/06_routes_update_success_search.png)

### 7. אישור מחיקה

לפני מחיקה מוצגת הודעת אישור כדי למנוע מחיקה בטעות.

![Delete Confirmation](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/07_routes_delete_confirm.png)

### 8. מחיקה מוצלחת

לאחר מחיקה מוצגת הודעת הצלחה.

![Delete Success](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/08_routes_delete_success.png)

### 9. תוצאות חיפוש

החיפוש מסנן את הרשומות לפי הערכים שמופיעים למשתמש.

![Search Results](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/09_routes_search_results.png)

### 10. עדכון טיול עם רשימות נפתחות

במסך הטיולים ניתן לבחור מסלול ומדריך מתוך רשימות נפתחות, במקום להזין מזהים ידנית.

![Tours Dropdowns](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/10_tours_update_dropdowns.png)

### 11. מסך Bookings עם Show More

במסך ההזמנות מוצגים הנתונים המרכזיים, ופרטים נוספים נפתחים באמצעות Show More.

![Bookings Show More](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/11_bookings_show_more.png)

### 12. מסך Route Sites

מסך הקישור בין מסלולים לאתרים מציג שמות ידידותיים במקום מזהים בלבד.

![Route Sites](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/12_route_sites_table.png)

### 13. הרצת שאילתות משלב ב׳

מסך Advanced Actions מאפשר להריץ שאילתות משלב ב׳, כגון היום שבו היו הכי הרבה טיולים ועומס מדריכים.

![Advanced Queries](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/13_advanced_queries.png)

### 14. הרצת פונקציות משלב ד׳

המערכת מאפשרת להפעיל פונקציות PL/pgSQL מתוך הממשק הגרפי.

![Advanced Functions](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/14_advanced_functions.png)

### 15. הרצת פרוצדורות משלב ד׳

המערכת מאפשרת להפעיל פרוצדורות PL/pgSQL מתוך הממשק.

![Advanced Procedures](./%D7%A9%D7%9C%D7%91%20%D7%94/screenshots/15_advanced_procedures.png)

---

## סיכום שלב ה׳

בשלב זה נבנה ממשק גרפי מלא למערכת SmartRoute.  
הממשק מאפשר עבודה מול בסיס הנתונים בצורה ידידותית, כולל CRUD, חיפוש, עדכון, מחיקה, הצגת שמות במקום מזהים, והרצת שאילתות, פונקציות ופרוצדורות מתוך המסכים.

