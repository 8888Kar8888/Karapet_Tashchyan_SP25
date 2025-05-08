--  Subtask 2.1: Create user 'rentaluser' with password and grant only CONNECT permission
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'rentaluser'
    ) THEN
        CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
    END IF;
END$$;

-- Allow the user to connect to the dvdrental database
GRANT CONNECT ON DATABASE dvdrental TO rentaluser;

--  Subtask 2.2: Grant SELECT access on the 'customer' table to 'rentaluser'
GRANT SELECT ON customer TO rentaluser;

--  Subtask 2.3: Create a role group 'rental' and add 'rentaluser' to it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'rental'
    ) THEN
        CREATE ROLE rental;
    END IF;
END$$;

-- Grant INSERT, SELECT, and UPDATE on 'rental' table to 'rental' role
GRANT INSERT, SELECT, UPDATE ON rental TO rental;

-- Add 'rentaluser' to the 'rental' group role
GRANT rental TO rentaluser;

-- Ensure 'rentaluser' inherits privileges from the 'rental' group
ALTER ROLE rentaluser INHERIT;

--  Subtask 2.4: Insert a row into 'rental' table using 'rentaluser' permissions
-- Insert only if this row doesn't already exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM rental 
        WHERE rental_date = '2025-04-21 10:00:00+04'
          AND inventory_id = 4573 
          AND customer_id = 2 
          AND staff_id = 1
    ) THEN
        INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
        VALUES ('2025-04-21 10:00:00+04', 4573, 2, 1);
    END IF;
END$$;

--  Subtask 2.5: Update an existing rental row
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM rental WHERE rental_id = 16000
    ) THEN
        UPDATE rental
        SET rental_date = '2025-04-21 11:00:00+04'
        WHERE rental_id = 16000;
    END IF;
END$$;

--  Subtask 2.6: Revoke INSERT permission from 'rental' role
REVOKE INSERT ON rental FROM rental;

-- ❌ Now, if 'rentaluser' tries to insert, it should be denied

--  Subtask 2.7: Create a personalized role for a customer with rental & payment history
-- For example, for customer Mary Smith
-- NOTE: Adjust the name if needed to match your data
CREATE ROLE client_mary_smith;

-- Optional verification (not required by task, but helps validate customer existence)
SELECT * 
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON p.customer_id = c.customer_id
WHERE LOWER(first_name) = 'mary' AND LOWER(last_name) = 'smith'
LIMIT 1;



-- Enable RLS on rental and payment tables
ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

-- Force RLS even for superusers
ALTER TABLE rental FORCE ROW LEVEL SECURITY;
ALTER TABLE payment FORCE ROW LEVEL SECURITY;

-- Create RLS policy for 'rental' table to restrict access to Mary Smith’s rows
CREATE POLICY rental_policy_for_mary_smith
ON rental
FOR SELECT
TO client_mary_smith
USING (
    customer_id IN (
        SELECT customer_id
        FROM customer
        WHERE LOWER(first_name) = 'mary' AND LOWER(last_name) = 'smith'
    )
);

-- Create RLS policy for 'payment' table to restrict access to Mary Smith’s rows
CREATE POLICY payment_policy_for_mary_smith
ON payment
FOR SELECT
TO client_mary_smith
USING (
    customer_id IN (
        SELECT customer_id
        FROM customer
        WHERE LOWER(first_name) = 'mary' AND LOWER(last_name) = 'smith'
    )
);

-- Grant access to the appropriate tables
GRANT SELECT ON rental TO client_mary_smith;
GRANT SELECT ON payment TO client_mary_smith;

-- ✅ Test access (assuming you're logged in as superuser, use SET ROLE)
SET ROLE client_mary_smith;

-- These queries should return only Mary Smith's data
SELECT * FROM rental;
SELECT * FROM payment;





-- If you know Mary Smith's customer_id (e.g., 1), you can simplify the policy

-- Replace '1' with actual customer_id
CREATE POLICY rental_policy_for_mary_smith
ON rental
FOR SELECT
TO client_mary_smith
USING (customer_id = 1);

CREATE POLICY payment_policy_for_mary_smith
ON payment
FOR SELECT
TO client_mary_smith
USING (customer_id = 1);

-- Grant select on both tables
GRANT SELECT ON rental TO client_mary_smith;
GRANT SELECT ON payment TO client_mary_smith;

-- Test access as Mary Smith's role
SET ROLE client_mary_smith;

SELECT * FROM rental;
SELECT * FROM payment;
