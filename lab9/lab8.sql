-- Exercise 2.1

CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    result INT;
BEGIN
    SELECT end_date-start_date INTO result
    FROM rentals
    WHERE rental_id=p_rental_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT rental_days(2);
SELECT rental_days(11);
SELECT rental_days(19);
SELECT rental_days(999);

-- Rental 19 returns NULL because end_date is NULL.
-- Rental 999 returns NULL because no matching row exists.
-- The reasons are different.


-- Exercise 2.2

CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
BEGIN
    RETURN COUNT(*)
    FROM rentals
    WHERE member_id=p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1);
SELECT member_rental_count(5);
SELECT member_rental_count(6);
SELECT member_rental_count(99);

-- COUNT(*) returns 0 when no rows match the condition.
-- It does not distinguish a nonexistent member
-- from a member without rentals.


-- Exercise 2.3

CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    result VARCHAR;
BEGIN
    SELECT city INTO result
    FROM stations
    WHERE station_id=p_station_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30);
SELECT station_city(77);


-- Exercise 2.4

SELECT rental_id,member_id,
       rental_days(rental_id) AS duration
FROM rentals
WHERE rental_days(rental_id)>4
ORDER BY duration DESC;


-- Exercise 3.1

CREATE OR REPLACE FUNCTION fee_with_discount(
    p_fee NUMERIC,
    p_percent NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee*(1-p_percent/100),2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00,15);


-- Exercise 3.2

CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
)
AS $$
BEGIN
    SELECT COUNT(*)::INT,
           COALESCE(SUM(fee),0),
           MAX(start_date)
    INTO rental_cnt,total_fee,last_start
    FROM rentals
    WHERE member_id=p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
SELECT * FROM member_stats(6);

-- The first call returns one composite value.
-- The second call returns three separate columns.
-- SELECT * FROM is more convenient for joins and filtering.
-- Member 6 returns 0, 0, NULL.


-- Exercise 3.3

CREATE OR REPLACE FUNCTION apply_late_fee(
    INOUT p_fee NUMERIC
)
AS $$
BEGIN
    p_fee:=p_fee+5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee)
FROM rentals
WHERE rental_id=1;

-- INOUT is both an input and an output parameter.
-- Its final value is returned automatically.


-- Exercise 3.4

CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
)
AS $$
BEGIN
    SELECT SUM(p_fees[i]),
           ROUND(AVG(p_fees[i]),2),
           MAX(p_fees[i])
    INTO total,average,largest
    FROM generate_subscripts(p_fees,1) g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50,35.00,18.50,31.50);

-- SELECT * FROM fee_summary();

SELECT * FROM fee_summary(VARIADIC ARRAY[]::NUMERIC[]);

-- Calling fee_summary() without arguments fails
-- because the function has no matching zero-argument signature.
-- An explicitly passed empty array returns NULL aggregates.
-- VARIADIC must be the last input parameter because
-- it collects all remaining input arguments.
-- OUT parameters may follow it.


-- Exercise 3.5

-- a) IN: the id is an input value.
-- b) INOUT: the balance is received and returned updated.
-- c) VARIADIC: the number of station ids is unknown.
-- d) OUT: multiple statistics are returned together.


-- Exercise 4.1

CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE(SUM(fee),0)
    FROM rentals
    WHERE member_id=p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1);
SELECT total_fees(6);


-- Exercise 4.2

CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE(SUM(fee),0)
    FROM rentals
    WHERE member_id=p_member_id
    AND start_date>=p_from_date;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1,DATE '2024-01-01');
SELECT total_fees(1,DATE '2025-01-01');

SELECT proname,
       pg_get_function_identity_arguments(oid)
FROM pg_proc
WHERE proname='total_fees';


-- Exercise 4.3

CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE(SUM(fee),0)
    FROM rentals
    WHERE member_id=p_member_id
    AND start_date>=p_from_date;
END;
$$ LANGUAGE plpgsql;

-- SELECT total_fees(1);

-- Expected error:
-- ERROR: function total_fees(integer) is not unique
-- HINT: Could not choose a best candidate function.
-- You might need to add explicit type casts.
-- Both overloaded functions accept one integer argument.


-- Exercise 4.4

DROP FUNCTION total_fees(INT);

SELECT total_fees(1);

-- The two-parameter function uses its default date
-- and returns 50.00.
-- Dropping the two-parameter version instead
-- would return 98.50 from the original function.


-- Exercise 4.5

CREATE OR REPLACE FUNCTION total_fees(p_name VARCHAR)
RETURNS NUMERIC AS $$
BEGIN
    RETURN COALESCE(SUM(r.fee),0)
    FROM rentals r
    JOIN members m ON r.member_id=m.member_id
    WHERE m.full_name=p_name;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova');
SELECT total_fees(1);

-- The functions have different input types.
-- The VARCHAR version returns all fees: 98.50.
-- The INT version uses the default date: 50.00.


-- Exercise 5.1

CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE(
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id,model,daily_rate
    FROM bikes
    WHERE model ILIKE p_pattern
    ORDER BY bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');

-- SELECT without FROM returns composite values
-- in a single column.
-- SELECT * FROM returns three separate columns.


-- Exercise 5.2

CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE(
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration INT,
    fee NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id,b.model,s.station_name,
           r.end_date-r.start_date,r.fee
    FROM rentals r
    JOIN bikes b ON r.bike_id=b.bike_id
    LEFT JOIN stations s ON b.station_id=s.station_id
    WHERE r.member_id=p_member_id
    ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);


-- Exercise 5.3

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(
    bike_id INT,
    model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id,model
    FROM bikes
    WHERE station_id=p_station_id;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM bike_list(10);

-- Expected error:
-- ERROR: column reference "bike_id" is ambiguous
-- DETAIL: It could refer to either a PL/pgSQL variable
-- or a table column.
-- The output parameters have the same names as table columns.
-- The SQL statement is analyzed when it is first executed.


-- Fix 1

DROP FUNCTION bike_list(INT);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(
    found_id INT,
    found_model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id,model
    FROM bikes
    WHERE station_id=p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);


-- Fix 2

DROP FUNCTION bike_list(INT);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE(
    bike_id INT,
    model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id,b.model
    FROM bikes b
    WHERE b.station_id=p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);


-- Exercise 5.4

CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE(
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name,
           COUNT(b.bike_id),
           s.capacity-COUNT(b.bike_id)
    FROM stations s
    LEFT JOIN bikes b ON s.station_id=b.station_id
    WHERE s.city=p_city
    GROUP BY s.station_id,s.station_name,s.capacity;
END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM station_board('Almaty');

-- Expected error:
-- ERROR: structure of query does not match function result type
-- DETAIL: Returned type bigint does not match expected
-- type integer in column 2.
-- COUNT returns BIGINT, but the declared output is INT.


CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE(
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name,
           COUNT(b.bike_id)::INT,
           s.capacity-COUNT(b.bike_id)::INT
    FROM stations s
    LEFT JOIN bikes b ON s.station_id=b.station_id
    WHERE s.city=p_city
    GROUP BY s.station_id,s.station_name,s.capacity;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');
SELECT * FROM station_board('Astana');


-- Exercise 6.1

DO $$
<<rental_report>>
DECLARE
    total_rentals INT:=0;
BEGIN
    SELECT COUNT(*) INTO total_rentals
    FROM rentals;

    RAISE NOTICE 'The rentals table holds % rows.',
                 total_rentals;
END rental_report;
$$;

-- If the END label does not match the opening label,
-- PostgreSQL raises a syntax error.


-- Exercise 6.2

DO $$
<<rental_report>>
DECLARE
    total_rentals INT:=0;
    fee_total NUMERIC;
BEGIN
    SELECT COUNT(*) INTO total_rentals
    FROM rentals;

    RAISE NOTICE 'The rentals table holds % rows.',
                 total_rentals;

    SELECT SUM(fee) INTO fee_total
    FROM rentals;

    RAISE NOTICE 'Outer before: %',fee_total;

    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT SUM(fee) INTO fee_total
        FROM rentals
        WHERE start_date>=DATE '2025-01-01';

        RAISE NOTICE 'Inner: %',fee_total;
        RAISE NOTICE 'Outer inside: %',rental_report.fee_total;
    END;

    RAISE NOTICE 'Outer after: %',fee_total;
END rental_report;
$$;

-- Outer before: 621.50
-- Inner: 369.00
-- Outer inside: 621.50
-- Outer after: 621.50
-- The inner variable hides the outer variable.
-- Changing the inner variable does not change the outer one.


-- Exercise 6.3

/*
DO $$
BEGIN
    DECLARE
        local_fee NUMERIC:=100;
    BEGIN
        RAISE NOTICE 'First: %',local_fee;
    END;

    BEGIN
        RAISE NOTICE 'Second: %',local_fee;
    END;
END;
$$;
*/

-- Expected error:
-- ERROR: column "local_fee" does not exist
-- The variable is only visible inside the first subblock.


DO $$
DECLARE
    local_fee NUMERIC:=100;
BEGIN
    BEGIN
        RAISE NOTICE 'First: %',local_fee;
    END;

    BEGIN
        RAISE NOTICE 'Second: %',local_fee;
    END;
END;
$$;

-- Both subblocks can access the outer variable.


-- Exercise 6.4

CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
)
AS $$
BEGIN
    SELECT COALESCE(SUM(fee),0)
    INTO before_total
    FROM rentals
    WHERE start_date<p_from_date;

    SELECT COALESCE(SUM(fee),0)
    INTO after_total
    FROM rentals
    WHERE start_date>=p_from_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_split(DATE '2025-01-01');

SELECT before_total+after_total AS calculated_total,
       (SELECT SUM(fee) FROM rentals) AS actual_total
FROM fee_split(DATE '2025-01-01');


-- Exercise 7.1

CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
)
AS $$
DECLARE
    station_capacity INT;
BEGIN
    SELECT capacity INTO station_capacity
    FROM stations
    WHERE station_id=p_station_id;

    SELECT COUNT(*) INTO bikes_parked
    FROM bikes
    WHERE station_id=p_station_id;

    capacity_pct:=ROUND(
        bikes_parked*100.0/NULLIF(station_capacity,0),1
    );
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id,s.station_name,l.*
FROM stations s,LATERAL station_load(s.station_id) l;

-- Station 50 returns NULL for capacity_pct.
-- Occupancy percentage is undefined when capacity is zero.
-- NULLIF prevents division by zero.


-- Exercise 7.2

CREATE OR REPLACE FUNCTION top_members(
    p_limit INT DEFAULT 3
)
RETURNS TABLE(
    member_name VARCHAR,
    rental_count INT,
    total_spent NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee),0)
    FROM members m
    LEFT JOIN rentals r ON m.member_id=r.member_id
    GROUP BY m.member_id,m.full_name
    ORDER BY COALESCE(SUM(r.fee),0) DESC,m.member_id
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);

-- Aisha has 5 rentals, while Daniyar has 4.
-- Daniyar ranks higher because he spent 138.00,
-- while Aisha spent 98.50.
-- Ranking is based on total spending, not rental count.


-- Exercise 7.3

CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE(
    member_name VARCHAR,
    bike_model VARCHAR,
    days INT,
    amount_owed NUMERIC,
    status VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,b.model,
           COALESCE(r.end_date,CURRENT_DATE)-r.start_date,
           ROUND(
               (COALESCE(r.end_date,CURRENT_DATE)-r.start_date)
               *b.daily_rate,2
           ),
           CASE
               WHEN r.end_date IS NULL THEN 'OPEN'
               ELSE 'CLOSED'
           END::VARCHAR
    FROM rentals r
    JOIN members m ON r.member_id=m.member_id
    JOIN bikes b ON r.bike_id=b.bike_id
    WHERE r.rental_id=p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);

-- Rental 11: 8 days * 9.25 = 74.00.
-- It matches the stored fee.
-- Rental 19 depends on CURRENT_DATE.
-- The amount increases as the rental continues.
-- A function depending on CURRENT_DATE cannot be IMMUTABLE.


-- Exercise 7.4

CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    OUT member_count INT,
    OUT rental_count INT,
    OUT total_revenue NUMERIC
)
AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee),0)
    INTO member_count,rental_count,total_revenue
    FROM members m
    LEFT JOIN rentals r ON m.member_id=r.member_id
    WHERE m.city=p_city;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    p_from_date DATE,
    OUT member_count INT,
    OUT rental_count INT,
    OUT total_revenue NUMERIC
)
AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id)::INT,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee),0)
    INTO member_count,rental_count,total_revenue
    FROM members m
    LEFT JOIN rentals r ON m.member_id=r.member_id
    AND r.start_date>=p_from_date
    WHERE m.city=p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty',DATE '2025-01-01');

SELECT COUNT(DISTINCT m.member_id)
FROM members m
LEFT JOIN rentals r ON m.member_id=r.member_id
WHERE m.city='Almaty'
AND r.start_date>=DATE '2025-01-01';

-- The date condition belongs in the ON clause.
-- ON preserves members without matching rentals.
-- WHERE removes members without matching rentals.
-- Almaty: ON returns 3 members, WHERE returns 2.


-- Lab Questions

-- 1.
-- A function name is its identifier.
-- A signature includes its name and input parameter types.
-- PostgreSQL needs the signature to identify
-- a specific overloaded function.

-- 2.
-- Dollar quoting allows single quotes inside
-- the function body without escaping them.

CREATE OR REPLACE FUNCTION quote_example()
RETURNS TEXT AS $$
BEGIN
    RETURN 'It''s a beautiful day';
END;
$$ LANGUAGE plpgsql;

SELECT quote_example();

-- 3.
-- OUT parameters are useful for returning multiple
-- values in one record.
-- RETURNS TABLE is useful for returning multiple rows
-- with named columns.

-- 4.
-- VARIADIC collects all remaining input arguments.
-- If a function had VARIADIC nums INT[] followed by
-- another input parameter, the trailing arguments
-- could not simply all belong to the array.
-- PostgreSQL requires VARIADIC to be the last input parameter.

-- 5.
-- RETURN returns a scalar value or ends the function.
-- RETURN QUERY appends query results to a set of rows.

-- 6.
-- DEFAULT parameters allow functions to be called
-- with fewer arguments, which may create ambiguity.
-- Avoid overlapping signatures with default parameters.

-- 7.
-- A variable declared in a subblock is no longer
-- accessible after the subblock ends.
-- Use outer_block.variable_name to access
-- a shadowed outer variable.

-- 8.
-- Advantage: fewer network round trips.
-- Disadvantage: harder debugging and database portability.

-- 9.
-- Trusted languages restrict access to external resources.
-- Ordinary users with the required privileges can
-- create functions using trusted languages.
-- Only superusers can create functions in untrusted languages.

-- 10.
-- Changing input argument types creates a new signature
-- instead of replacing the original function.
-- Both versions may remain and cause unexpected
-- overload resolution or ambiguity.


