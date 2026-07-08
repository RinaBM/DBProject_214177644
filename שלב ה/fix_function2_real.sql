DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT p.oid::regprocedure::text AS signature
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
          AND p.proname = 'fn_customer_unpaid_bookings'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS ' || r.signature || ' CASCADE';
    END LOOP;
END $$;

CREATE OR REPLACE FUNCTION public.fn_customer_unpaid_bookings(p_c_id INTEGER)
RETURNS TABLE (
    booking_id INTEGER,
    traveler_id INTEGER,
    guided_tour_id INTEGER,
    payment_status TEXT,
    participants INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    id_col TEXT;
    customer_col TEXT;
    tour_col TEXT;
    status_col TEXT;
    people_col TEXT;
    sql TEXT;
BEGIN
    SELECT column_name INTO id_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('booking_id', 'b_id', 'id')
    LIMIT 1;

    SELECT column_name INTO customer_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('user_id', 'customer_id', 'traveler_id', 'c_id')
    LIMIT 1;

    SELECT column_name INTO tour_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('guided_tour_id', 'guidedtour_id', 'tour_id', 't_i_id', 'tour_instance_id')
    LIMIT 1;

    SELECT column_name INTO status_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('payment_status', 'status')
    LIMIT 1;

    SELECT column_name INTO people_col
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'booking'
      AND column_name IN ('number_of_participants', 'participants_count', 'people_count', 'amount_pepole', 'amount_people', 'participants', 'pax')
    LIMIT 1;

    IF customer_col IS NULL THEN
        RAISE EXCEPTION 'Cannot find traveler/customer column in booking table';
    END IF;

    sql :=
        'SELECT ' ||
        CASE WHEN id_col IS NULL THEN 'NULL::integer' ELSE format('%I::integer', id_col) END || ' AS booking_id, ' ||
        format('%I::integer', customer_col) || ' AS traveler_id, ' ||
        CASE WHEN tour_col IS NULL THEN 'NULL::integer' ELSE format('%I::integer', tour_col) END || ' AS guided_tour_id, ' ||
        CASE WHEN status_col IS NULL THEN 'NULL::text' ELSE format('%I::text', status_col) END || ' AS payment_status, ' ||
        CASE WHEN people_col IS NULL THEN '1::integer' ELSE format('COALESCE(%I, 1)::integer', people_col) END || ' AS participants ' ||
        'FROM booking WHERE ' || format('%I = $1', customer_col);

    IF status_col IS NOT NULL THEN
        sql := sql || format(' AND COALESCE(%I::text, '''') <> ''Paid''', status_col);
    END IF;

    RETURN QUERY EXECUTE sql USING p_c_id;
END;
$$;
