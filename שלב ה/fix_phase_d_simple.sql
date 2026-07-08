CREATE OR REPLACE FUNCTION fn_available_places(p_t_i_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    max_places INTEGER := 30;
    booked_places INTEGER := 0;
BEGIN
    SELECT COALESCE(SUM(
        CASE
            WHEN EXISTS (
                SELECT 1 FROM information_schema.columns
                WHERE table_name = 'booking'
                AND column_name = 'number_of_participants'
            )
            THEN number_of_participants
            ELSE 1
        END
    ), 0)
    INTO booked_places
    FROM booking
    WHERE tour_id = p_t_i_id;

    RETURN GREATEST(max_places - booked_places, 0);
EXCEPTION
    WHEN undefined_column THEN
        SELECT COUNT(*)
        INTO booked_places
        FROM booking
        WHERE tour_id = p_t_i_id;

        RETURN GREATEST(max_places - booked_places, 0);
END;
$$;

CREATE OR REPLACE PROCEDURE pr_pay_customer_bookings(p_c_id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE booking
    SET payment_status = 'Paid'
    WHERE user_id = p_c_id
      AND payment_status <> 'Paid';
END;
$$;
