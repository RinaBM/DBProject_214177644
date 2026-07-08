DROP FUNCTION IF EXISTS fn_customer_unpaid_bookings(integer);

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
        OPEN ref FOR EXECUTE format(
            'SELECT * FROM booking WHERE %I = $1',
            customer_col
        )
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
