CREATE TABLE USERS
(
    user_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,

    PRIMARY KEY (user_id),
    UNIQUE (email)
);

CREATE TABLE GUIDE
(
    guide_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    languages VARCHAR(200) NOT NULL,

    PRIMARY KEY (guide_id),
    UNIQUE (email)
);

CREATE TABLE ROUTE
(
    route_id INT NOT NULL,
    route_name VARCHAR(100) NOT NULL,
    difficulty_level VARCHAR(50) NOT NULL,
    estimated_duration INT NOT NULL,
    distance NUMERIC(6,2) NOT NULL,
    description VARCHAR(500),

    PRIMARY KEY (route_id),

    CHECK (estimated_duration > 0),
    CHECK (distance >= 0),
    CHECK (difficulty_level IN ('Easy', 'Medium', 'Hard'))
);

CREATE TABLE SITE
(
    site_id INT NOT NULL,
    site_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description VARCHAR(500),

    PRIMARY KEY (site_id)
);

CREATE TABLE GUIDEDTOUR
(
    guided_tour_id INT NOT NULL,
    start_date DATE NOT NULL,
    registration_deadline DATE NOT NULL,
    max_participants INT NOT NULL,
    price NUMERIC(8,2) NOT NULL,
    status VARCHAR(30) NOT NULL,
    route_id INT NOT NULL,
    guide_id INT NOT NULL,

    PRIMARY KEY (guided_tour_id),

    FOREIGN KEY (route_id)
        REFERENCES ROUTE(route_id),

    FOREIGN KEY (guide_id)
        REFERENCES GUIDE(guide_id),

    CHECK (registration_deadline <= start_date),
    CHECK (max_participants > 0),
    CHECK (price >= 0),
    CHECK (status IN ('Open', 'Closed', 'Cancelled'))
);

CREATE TABLE BOOKING
(
    booking_id INT NOT NULL,
    booking_date DATE NOT NULL,
    number_of_participants INT NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    user_id INT NOT NULL,
    guided_tour_id INT NOT NULL,

    PRIMARY KEY (booking_id),

    FOREIGN KEY (user_id)
        REFERENCES USERS(user_id),

    FOREIGN KEY (guided_tour_id)
        REFERENCES GUIDEDTOUR(guided_tour_id),

    CHECK (number_of_participants > 0),
    CHECK (payment_status IN ('Paid', 'Unpaid', 'Pending', 'Cancelled'))
);

CREATE TABLE ROUTESITE
(
    route_id INT NOT NULL,
    site_id INT NOT NULL,
    visit_order INT NOT NULL,

    PRIMARY KEY (route_id, site_id),

    FOREIGN KEY (route_id)
        REFERENCES ROUTE(route_id),

    FOREIGN KEY (site_id)
        REFERENCES SITE(site_id),

    CHECK (visit_order > 0),

    UNIQUE (route_id, visit_order)
);

commit;