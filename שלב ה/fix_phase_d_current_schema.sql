CREATE OR REPLACE FUNCTION fn_available_places(p_t_i_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    booking_tour_col TEXT;
    people_col TEXT;
    booked INTEGER := 0;
    max_places INTEGER := 30;
BEGIN
    SELECT column_name INTO booking_tour_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('guided_tour_id', 'guidedtour_id', 'tour_id', 't_i_id', 'tour_instance_id')
    LIMIT 1;

    IF booking_tour_col IS NULL THEN
        RAISE EXCEPTION 'Cannot find tour column in booking table';
    END IF;

    SELECT column_name INTO people_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('number_of_participants', 'participants_count', 'people_count', 'amount_pepole', 'amount_people', 'participants', 'pax')
    LIMIT 1;

    IF people_col IS NULL THEN
        EXECUTE format('SELECT COUNT(*) FROM booking WHERE %I = $1', booking_tour_col)
        INTO booked
        USING p_t_i_id;
    ELSE
        EXECUTE format('SELECT COALESCE(SUM(%I), 0) FROM booking WHERE %I = $1', people_col, booking_tour_col)
        INTO booked
        USING p_t_i_id;
    END IF;

    RETURN GREATEST(max_places - booked, 0);
END;
$$;

CREATE OR REPLACE FUNCTION fn_customer_unpaid_bookings(p_c_id INTEGER)
RETURNS REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    ref REFCURSOR := 'unpaid_bookings_cursor';
    customer_col TEXT;
    status_col TEXT;
BEGIN
    SELECT column_name INTO customer_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('user_id', 'customer_id', 'traveler_id', 'c_id')
    LIMIT 1;

    SELECT column_name INTO status_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('payment_status', 'status')
    LIMIT 1;

    IF customer_col IS NULL THEN
        RAISE EXCEPTION 'Cannot find traveler/customer column in booking table';
    END IF;

    IF status_col IS NULL THEN
        OPEN ref FOR EXECUTE format('SELECT * FROM booking WHERE %I = $1', customer_col)
        USING p_c_id;
    ELSE
        OPEN ref FOR EXECUTE format(
            'SELECT * FROM booking WHERE %I = $1 AND COALESCE(%I::text, '''') <> ''Paid''',
            customer_col,
            status_col
        )
        USING p_c_id;
    END IF;

    RETURN ref;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_create_booking(
    p_t_i_id INTEGER,
    p_c_id INTEGER,
    p_amount_pepole INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    id_col TEXT;
    tour_col TEXT;
    customer_col TEXT;
    people_col TEXT;
    status_col TEXT;
    date_col TEXT;
    available INTEGER;
    cols TEXT;
    vals TEXT;
BEGIN
    available := fn_available_places(p_t_i_id);

    IF available < p_amount_pepole THEN
        RAISE EXCEPTION 'Not enough available places. Available: %, requested: %', available, p_amount_pepole;
    END IF;

    SELECT column_name INTO id_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('booking_id', 'b_id', 'id')
    LIMIT 1;

    SELECT column_name INTO tour_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('guided_tour_id', 'guidedtour_id', 'tour_id', 't_i_id', 'tour_instance_id')
    LIMIT 1;

    SELECT column_name INTO customer_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('user_id', 'customer_id', 'traveler_id', 'c_id')
    LIMIT 1;

    SELECT column_name INTO people_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('number_of_participants', 'participants_count', 'people_count', 'amount_pepole', 'amount_people', 'participants', 'pax')
    LIMIT 1;

    SELECT column_name INTO status_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('payment_status', 'status')
    LIMIT 1;

    SELECT column_name INTO date_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('booking_date', 'created_at', 'date')
    LIMIT 1;

    IF id_col IS NULL OR tour_col IS NULL OR customer_col IS NULL THEN
        RAISE EXCEPTION 'Cannot create booking because required booking columns were not found';
    END IF;

    cols := format('%I, %I, %I', id_col, tour_col, customer_col);
    vals := format('(SELECT COALESCE(MAX(%I), 0) + 1 FROM booking), $1, $2', id_col);

    IF people_col IS NOT NULL THEN
        cols := cols || format(', %I', people_col);
        vals := vals || ', $3';
    END IF;

    IF status_col IS NOT NULL THEN
        cols := cols || format(', %I', status_col);
        vals := vals || ', ''Unpaid''';
    END IF;

    IF date_col IS NOT NULL THEN
        cols := cols || format(', %I', date_col);
        vals := vals || ', CURRENT_DATE';
    END IF;

    EXECUTE format('INSERT INTO booking (%s) VALUES (%s)', cols, vals)
    USING p_t_i_id, p_c_id, p_amount_pepole;
END;
$$;

CREATE OR REPLACE PROCEDURE pr_pay_customer_bookings(p_c_id INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    customer_col TEXT;
    status_col TEXT;
BEGIN
    SELECT column_name INTO customer_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('user_id', 'customer_id', 'traveler_id', 'c_id')
    LIMIT 1;

    SELECT column_name INTO status_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('payment_status', 'status')
    LIMIT 1;

    IF customer_col IS NULL OR status_col IS NULL THEN
        RAISE EXCEPTION 'Cannot find traveler/status columns in booking table';
    END IF;

    EXECUTE format(
        'UPDATE booking
         SET %I = ''Paid''
         WHERE %I = $1
           AND COALESCE(%I::text, '''') <> ''Paid''',
        status_col,
        customer_col,
        status_col
    )
    USING p_c_id;
END;
$$;
