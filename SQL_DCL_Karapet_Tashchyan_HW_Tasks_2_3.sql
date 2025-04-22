--TaskN2
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'rentaluser'
    ) THEN
        CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
    END IF;
END$$;

GRANT CONNECT ON DATABASE dvdrental TO rentaluser;

GRANT SELECT ON customer TO rentaluser;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_roles WHERE rolname = 'rental'
    ) THEN
        CREATE ROLE rental;
    END IF;
END$$;

GRANT INSERT, SELECT, UPDATE ON rental TO rental;

GRANT rental TO rentaluser;

ALTER ROLE rentaluser INHERIT;

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


REVOKE INSERT ON rental FROM rental;

create role client_mary_smith;

select * 
from customer c
left join rental r on c.customer_id = r.customer_id
left join payment p on p.customer_id = c.customer_id
limit 1;


--TaskN3 option1 
ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

ALTER TABLE rental FORCE ROW LEVEL SECURITY;
ALTER TABLE payment FORCE ROW LEVEL SECURITY;

GRANT SELECT ON customer TO client_mary_smith;


create policy  rental_policy_for_mary_smith
on rental
for select
to client_mary_smith
using(customer_id in 
(select customer_id
from customer 
where lower(first_name)='mary' and lower(last_name)='smith'
))

create policy payment_policy_for_mary_smith
on payment
for select 
to client_mary_smith
using(customer_id in 
(
select customer_id
from customer
where lower(first_name)='mary' and lower(last_name)='smith'
))

GRANT SELECT ON rental TO client_mary_smith;
GRANT SELECT ON payment TO client_mary_smith;

set role client_mary_smith

select * from rental;
select * from payment;





--TaskN3 option2 for not granting also select on customer table
ALTER TABLE rental FORCE ROW LEVEL SECURITY;
ALTER TABLE payment FORCE ROW LEVEL SECURITY;


create policy  rental_policy_for_mary_smith
on rental
for select
to client_mary_smith
using(customer_id =1)

create policy payment_policy_for_mary_smith
on payment
for select 
to client_mary_smith
using(customer_id =1)

GRANT SELECT ON rental TO client_mary_smith;
GRANT SELECT ON payment TO client_mary_smith;

set role client_mary_smith

select * from rental;
select * from payment;