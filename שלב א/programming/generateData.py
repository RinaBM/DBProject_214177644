import random
import psycopg2
from faker import Faker
from datetime import timedelta

fake = Faker()

# =========================
# Database connection
# =========================
# אם את מריצה את הקובץ מהמחשב שלך, לרוב host צריך להיות localhost
# אם תריצי מתוך קונטיינר Docker, אז host יהיה db

conn = psycopg2.connect(
    host="localhost",
    port="5432",
    database="tripdb",
    user="RinaSH",
    password="RinaSH"
)

cur = conn.cursor()

# =========================
# Amounts
# =========================

NUM_USERS = 20000
NUM_BOOKINGS = 20000

NUM_GUIDES = 500
NUM_ROUTES = 500
NUM_SITES = 500
NUM_TOURS = 500
NUM_ROUTESITES = 500

# כדי לא להתנגש עם 20 הרשומות הידניות
START_ID = 1000

difficulty_levels = ["Easy", "Medium", "Hard"]
tour_statuses = ["Open", "Closed", "Cancelled"]
payment_statuses = ["Paid", "Unpaid", "Pending", "Cancelled"]

site_categories = [
    "Historical",
    "Nature",
    "Religious",
    "Culture",
    "Landmark",
    "Urban Nature"
]

languages_options = [
    "Hebrew, English",
    "Hebrew, French",
    "Hebrew, Spanish",
    "Hebrew, Arabic",
    "Hebrew, Italian",
    "Hebrew, German",
    "Hebrew, Russian"
]


# =========================
# Helper functions
# =========================

def insert_guides():
    print("Inserting guides...")

    for i in range(START_ID + 1, START_ID + NUM_GUIDES + 1):
        full_name = fake.name()
        phone = "052" + str(random.randint(1000000, 9999999))
        email = f"guide{i}@smartroute.com"
        languages = random.choice(languages_options)

        cur.execute("""
            INSERT INTO GUIDE (guide_id, full_name, phone, email, languages)
            VALUES (%s, %s, %s, %s, %s)
        """, (i, full_name, phone, email, languages))


def insert_routes():
    print("Inserting routes...")

    for i in range(START_ID + 1, START_ID + NUM_ROUTES + 1):
        route_name = f"{fake.city()} Travel Route"
        difficulty_level = random.choice(difficulty_levels)
        estimated_duration = random.randint(2, 12)
        distance = round(random.uniform(2.0, 30.0), 2)
        description = fake.sentence(nb_words=12)

        cur.execute("""
            INSERT INTO ROUTE
            (route_id, route_name, difficulty_level, estimated_duration, distance, description)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (i, route_name, difficulty_level, estimated_duration, distance, description))


def insert_sites():
    print("Inserting sites...")

    for i in range(START_ID + 1, START_ID + NUM_SITES + 1):
        site_name = f"{fake.city()} Site"[:100]
        country = fake.country()[:50]
        city = fake.city()[:50]
        category = random.choice(site_categories)[:50]
        description = fake.sentence(nb_words=12)[:500]

        cur.execute("""
            INSERT INTO SITE
            (site_id, site_name, country, city, category, description)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (i, site_name, country, city, category, description))


def insert_users():
    print("Inserting users...")

    for i in range(START_ID + 1, START_ID + NUM_USERS + 1):
        full_name = fake.name()
        email = f"user{i}@smartroute.com"
        phone = "050" + str(random.randint(1000000, 9999999))

        cur.execute("""
            INSERT INTO USERS (user_id, full_name, email, phone)
            VALUES (%s, %s, %s, %s)
        """, (i, full_name, email, phone))


def insert_guided_tours():
    print("Inserting guided tours...")

    for i in range(START_ID + 1, START_ID + NUM_TOURS + 1):
        start_date = fake.date_between(start_date="+10d", end_date="+365d")
        registration_deadline = start_date - timedelta(days=random.randint(1, 14))

        max_participants = random.randint(10, 50)
        price = round(random.uniform(50.0, 500.0), 2)
        status = random.choice(tour_statuses)

        route_id = random.randint(START_ID + 1, START_ID + NUM_ROUTES)
        guide_id = random.randint(START_ID + 1, START_ID + NUM_GUIDES)

        cur.execute("""
            INSERT INTO GUIDEDTOUR
            (guided_tour_id, start_date, registration_deadline, max_participants, price, status, route_id, guide_id)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            i,
            start_date,
            registration_deadline,
            max_participants,
            price,
            status,
            route_id,
            guide_id
        ))


def insert_route_sites():
    print("Inserting route sites...")

    used_pairs = set()
    used_route_orders = set()

    count = 0

    while count < NUM_ROUTESITES:
        route_id = random.randint(START_ID + 1, START_ID + NUM_ROUTES)
        site_id = random.randint(START_ID + 1, START_ID + NUM_SITES)
        visit_order = random.randint(1, 20)

        pair_key = (route_id, site_id)
        order_key = (route_id, visit_order)

        # בגלל:
        # PRIMARY KEY(route_id, site_id)
        # UNIQUE(route_id, visit_order)
        if pair_key in used_pairs or order_key in used_route_orders:
            continue

        used_pairs.add(pair_key)
        used_route_orders.add(order_key)

        cur.execute("""
            INSERT INTO ROUTESITE (route_id, site_id, visit_order)
            VALUES (%s, %s, %s)
        """, (route_id, site_id, visit_order))

        count += 1


def insert_bookings():
    print("Inserting bookings...")

    for i in range(START_ID + 1, START_ID + NUM_BOOKINGS + 1):
        user_id = random.randint(START_ID + 1, START_ID + NUM_USERS)
        guided_tour_id = random.randint(START_ID + 1, START_ID + NUM_TOURS)

        booking_date = fake.date_between(start_date="-180d", end_date="today")
        number_of_participants = random.randint(1, 5)
        payment_status = random.choice(payment_statuses)

        cur.execute("""
            INSERT INTO BOOKING
            (booking_id, booking_date, number_of_participants, payment_status, user_id, guided_tour_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (
            i,
            booking_date,
            number_of_participants,
            payment_status,
            user_id,
            guided_tour_id
        ))


def print_counts():
    print("\nFinal record counts:")

    tables = [
        "USERS",
        "GUIDE",
        "ROUTE",
        "SITE",
        "GUIDEDTOUR",
        "BOOKING",
        "ROUTESITE"
    ]

    for table in tables:
        cur.execute(f"SELECT COUNT(*) FROM {table}")
        count = cur.fetchone()[0]
        print(f"{table}: {count}")


# =========================
# Main
# =========================

try:
    insert_guides()
    insert_routes()
    insert_sites()
    insert_users()
    insert_guided_tours()
    insert_route_sites()
    insert_bookings()

    conn.commit()

    print_counts()
    print("\nData generation completed successfully!")

except Exception as e:
    conn.rollback()
    print("Error occurred:")
    print(e)

finally:
    cur.close()
    conn.close()