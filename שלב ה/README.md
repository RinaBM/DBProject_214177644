# שלב ה' — יצירת ממשק גרפי לעבודה מול בסיס הנתונים

## תיאור כללי

בשלב זה נבנה ממשק גרפי למערכת SmartRoute — מערכת לניהול טיולים מודרכים.
הממשק מאפשר עבודה מול בסיס הנתונים PostgreSQL בצורה ידידותית, ללא צורך בהרצת פקודות SQL ידנית דרך pgAdmin.

האפליקציה מתבססת על המסכים שנבנו בשלב א' בעזרת Google AI Studio, אך הורחבה כך שתעמוד בדרישות של שלב ה':

- מסך כניסה ראשי למערכת.
- מסכי CRUD לטבלאות המרכזיות.
- הצגת שמות במקום מזהי ID במפתחות זרים.
- הפעלת שאילתות משלב ב'.
- הפעלת פונקציות ופרוצדורות משלב ד'.
- הצגת השפעה של פרוצדורות וטריגרים דרך טבלאות לוג.

## כלים וטכנולוגיות

בפרויקט השתמשנו בכלים הבאים:

- React — לבניית הממשק הגרפי בצד הלקוח.
- TypeScript — לכתיבת הקוד בצורה מסודרת וברורה.
- Node.js + Express — לבניית צד שרת ו־API.
- PostgreSQL — בסיס הנתונים של המערכת.
- pg — ספריית Node.js לחיבור ל־PostgreSQL.
- Vite — להרצת סביבת הפיתוח.
- Docker / pgAdmin — להרצת וניהול בסיס הנתונים.

## מבנה האפליקציה

האפליקציה כוללת צד לקוח וצד שרת באותו פרויקט.

צד הלקוח נמצא בתיקיית `src` וכולל את המסכים והרכיבים הגרפיים.
צד השרת נמצא בקובץ `server.ts` ומכיל את החיבור לבסיס הנתונים ואת כל נקודות ה־API.

מבנה מרכזי:

```text
שלב ה/
├── src/
│   ├── components/
│   │   ├── Layout.tsx
│   │   └── CrudManager.tsx
│   ├── pages/
│   │   ├── Dashboard.tsx
│   │   ├── RoutesManager.tsx
│   │   ├── SitesManager.tsx
│   │   ├── GuidesManager.tsx
│   │   ├── ToursManager.tsx
│   │   ├── TravelersManager.tsx
│   │   ├── BookingsManager.tsx
│   │   ├── RouteSitesManager.tsx
│   │   ├── AdvancedActions.tsx
│   │   └── SystemLogs.tsx
│   └── App.tsx
├── server.ts
├── package.json
├── .env.example
└── run-instructions.txt
```

## מסכי המערכת

במערכת קיימים המסכים הבאים:

1. Dashboard — מסך בית עם נתוני סיכום.
2. Routes — ניהול מסלולים / טיולים.
3. Sites — ניהול אתרים / תחנות.
4. Guides — ניהול מדריכים.
5. Tours — ניהול מופעי טיולים / טיולים מודרכים.
6. Travelers — ניהול מטיילים / לקוחות.
7. Bookings — ניהול הזמנות.
8. Route Sites — ניהול הקשר בין מסלול לאתר.
9. Advanced Actions — הפעלת שאילתות, פונקציות ופרוצדורות.
10. System Logs — צפייה בטבלאות לוג שנוצרות בעקבות פרוצדורות וטריגרים.

## פעולות CRUD

במסכי הניהול ניתן לבצע את ארבע פעולות CRUD:

- Create — הוספת רשומה חדשה.
- Read — שליפת נתונים והצגתם בטבלה.
- Update — עדכון רשומה קיימת.
- Delete — מחיקת רשומה קיימת.

בפעולת עדכון קיימות שתי אפשרויות:

1. לחיצה על כפתור העריכה בשורת הטבלה.
2. הכנסת ערך מפתח בשדה `Key for update`, לחיצה על `Load`, טעינת הנתונים לטופס ועדכון שלהם.

כך מתקיימת דרישת השלב שבזמן עדכון המשתמש ממלא מפתח והמערכת מביאה את יתר השדות.

## הצגת נתונים ידידותית למשתמש

בהתאם לדרישות השלב, הממשק לא מציג למשתמש מזהים מספריים כמידע המרכזי.
במקום להציג מפתח זר כמו `route_id`, `guide_id`, `user_id` או `t_i_id`, המערכת משתמשת ב־JOIN וב־lookups כדי להציג שמות ברורים.

לדוגמה:

- במסך Bookings מוצגים שם המטייל, שם הטיול ותאריך הטיול במקום מזהים בלבד.
- במסך Tours נבחרים מסלול ומדריך מתוך dropdown.
- במסך Route Sites נבחרים מסלול ואתר מתוך dropdown.

המזהים נשמרים מאחורי הקלעים לצורך עדכון ומחיקה, אך אינם מוצגים כמידע העיקרי למשתמש.

## התאמה לבסיס הנתונים לאחר האינטגרציה

האפליקציה יודעת לזהות את שמות הטבלאות והעמודות גם אם קיימות טבלאות בשם המקורי של הקבוצה וגם אם קיימות טבלאות מהמערכת שהתקבלה באינטגרציה.

לדוגמה, השרת יודע לעבוד עם שמות כגון:

- `route` או `tour`
- `site` או `station`
- `users` או `customer`
- `guidedtour` או `tourinstance`
- `booking` או `bookings`
- `routesite` או `tourstation`

בנוסף, ניתן להגדיר שמות טבלאות ידנית בקובץ `.env` במידת הצורך.

## שאילתות משלב ב'

במסך Advanced Actions ניתן להפעיל שתי שאילתות מתוך שלב ב':

1. Busiest Day — מציאת היום בשבוע שבו התקיימו הכי הרבה טיולים.
2. Guide Load — הצגת עומס מדריכים לפי מספר טיולים.

תוצאות השאילתות מוצגות בטבלה בתוך המסך.

## פונקציות ופרוצדורות משלב ד'

במסך Advanced Actions ניתן להפעיל את התוכניות שנכתבו בשלב ד':

### פונקציות

1. `fn_available_places`
   - מקבלת מזהה מופע טיול.
   - מחזירה כמה מקומות פנויים נשארו בטיול.

2. `fn_customer_unpaid_bookings`
   - מקבלת מזהה לקוח.
   - מחזירה את ההזמנות הלא משולמות של הלקוח.
   - הפונקציה מחזירה Ref Cursor, ולכן השרת פותח טרנזקציה ומבצע `FETCH ALL` כדי להציג את התוצאה במסך.

### פרוצדורות

1. `pr_create_booking`
   - יוצרת הזמנה חדשה אם קיימים מספיק מקומות פנויים.

2. `pr_pay_customer_bookings`
   - מסמנת את ההזמנות הלא משולמות של לקוח כשולמו.
   - מוסיפה רשומות לטבלת `payment_log`.

## הצגת השפעת פרוצדורות וטריגרים

נוסף מסך `System Logs` שמציג את טבלאות העזר משלב ד':

- `payment_log` — מציגה תשלומים שנוצרו על ידי הפרוצדורה `pr_pay_customer_bookings`.
- `tour_price_history` — מציגה היסטוריית שינויי מחיר שנוצרה על ידי הטריגר של עדכון מחיר טיול.

כך ניתן לראות במסך את ההשפעה בפועל של הפעלת פרוצדורות וטריגרים על בסיס הנתונים.

## הוראות הפעלה

1. יש לוודא ש־PostgreSQL פעיל ושבסיס הנתונים של הפרויקט נטען.
2. יש להיכנס לתיקיית שלב ה':

```bash
cd "שלב ה"
```

3. התקנת תלויות:

```bash
npm install
```

4. יצירת קובץ סביבה:

PowerShell:

```powershell
Copy-Item .env.example .env
```

CMD:

```cmd
copy .env.example .env
```

5. יש לעדכן את פרטי החיבור בקובץ `.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tripdb
DB_USER=postgres
DB_PASSWORD=your_password
```

6. הרצת האפליקציה:

```bash
npm run dev
```

7. פתיחת המערכת בדפדפן:

```text
http://localhost:3000
```

8. בדיקת חיבור למסד הנתונים:

```text
http://localhost:3000/api/health
```

9. בדיקת זיהוי הטבלאות והעמודות:

```text
http://localhost:3000/api/schema/status
```

## קבצים להגשה

בתיקיית שלב ה' נמצאים הקבצים הדרושים להגשה:

- קוד הממשק הגרפי.
- קוד צד השרת.
- קובץ הוראות הפעלה `run-instructions.txt`.
- קובץ README המשמש כדוח שלב ה'.
- תיקיית screenshots שבה יש לשים צילומי מסך של המערכת לאחר ההרצה.

## סיכום

בשלב זה המערכת הפכה מבסיס נתונים לאפליקציה גרפית מלאה.
הממשק מאפשר למשתמש לבצע פעולות ניהול בצורה נוחה, להריץ שאילתות מתקדמות, להפעיל תתי־תוכניות שנכתבו ב־PL/pgSQL, ולראות את ההשפעה שלהן על הנתונים בפועל.


## Running the graphical interface from Docker

In addition to the PostgreSQL and pgAdmin containers, Phase E includes a Docker configuration for the application server itself.
This creates a third container named `smartroute_app` and exposes the graphical interface on port 3000.

Commands:

```bash
Copy-Item .env.docker.example .env
docker compose up --build
```

Then open:

```text
http://localhost:3000
```

The application container connects to the existing PostgreSQL container through the host using `host.docker.internal`, because PostgreSQL is already exposed on port 5432.
This keeps the existing database and pgAdmin setup unchanged while adding the required graphical application server.

If the dashboard shows a database connection warning, it means the React/Node server is open correctly, but the database details in `.env` need to be fixed.
