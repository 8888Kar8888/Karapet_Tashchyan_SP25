
--TaskN(1,2)
--Choose your top-3 favorite movies and add them to the 'film' table (films with the title Film1, Film2, etc - will not be taken into account and grade will be reduced)
--Fill in rental rates with 4.99, 9.99 and 19.99 and rental durations with 1, 2 and 3 weeks respectively.

INSERT INTO public.film (
    title, description, release_year, language_id, original_language_id,
    rental_duration, rental_rate, length, rating, special_features, fulltext
)
SELECT * FROM (
    SELECT 
        'The Shawshank Redemption' AS title,
        'The Shawshank Redemption is a powerful tale of hope and resilience, following a wrongly imprisoned man who finds freedom through patience, friendship, and an unbreakable spirit.' AS description,
        1994 AS release_year,
        1 AS language_id,
        NULL::SMALLINT AS original_language_id,
        1 AS rental_duration,
        4.99 AS rental_rate,
        2.22 AS length,
        'R'::mpaa_rating AS rating,
        ARRAY[
            'Trailers',
            'Commentaries',
            'Deleted Scenes',
            'Behind the Scenes'
        ]::text[] AS special_features,
        '''friendship'':9 ''freedom'':7 ''hope'':4 ''imprison'':6 ''patienc'':8 ''power'':1 ''resili'':5 ''spirit'':11 ''tale'':2 ''unbreak'':10'::tsvector AS fulltext
) AS new_film
WHERE NOT EXISTS (
    SELECT 1 FROM film WHERE lower(title) = lower('The Shawshank Redemption')
)
RETURNING film_id, title;







INSERT INTO public.film (
    title, description, release_year, language_id, original_language_id,
    rental_duration, rental_rate, length, rating, special_features, fulltext
)
SELECT * FROM (
    SELECT 
        'The Godfather' AS title,
        'The Godfather is a gripping crime saga that follows the powerful Corleone mafia family, led by Vito Corleone, as his reluctant son Michael is drawn into the violent world of organized crime, ultimately transforming into a ruthless leader.' AS description,
        1972 AS release_year,
        1 AS language_id,
        NULL::SMALLINT AS original_language_id,
        2 AS rental_duration,
        9.99 AS rental_rate,
        2.55 AS length,
        'R'::mpaa_rating AS rating,
        ARRAY[
            'Trailers',
            'Commentaries',
            'Deleted Scenes',
            'Behind the Scenes',
            'Interviews',
            'Legacy & Impact',
            'Historical Context'
        ]::text[] AS special_features,
        '''family'':10 ''power'':9 ''loyalty'':8 ''betrayal'':7 ''crime'':6 ''mafia'':11 ''tradition'':5 ''revenge'':4 ''respect'':3 ''violence'':2 ''legacy'':1'::tsvector AS fulltext
) AS new_film
WHERE NOT EXISTS (
    SELECT 1 FROM film WHERE lower(title) = lower('The Godfather')
)
RETURNING film_id, title;






INSERT INTO public.film (
    title, description, release_year, language_id, original_language_id,
    rental_duration, rental_rate, length, rating, special_features, fulltext
)
SELECT * FROM (
    SELECT 
        'The Dark Knight' AS title,
        'The Dark Knight follows Batman as he battles the Joker, testing his morals and Gotham''s fate.' AS description,
        2008 AS release_year,
        1 AS language_id,
        NULL::SMALLINT AS original_language_id,
        3 AS rental_duration,
        19.99 AS rental_rate,
        2.32 AS length,
        'PG-13'::mpaa_rating AS rating,
        ARRAY[
            'Trailers',
            'Commentaries',
            'Deleted Scenes',
            'Behind the Scenes',
            'Interviews',
            'IMAX Scenes',
            'Visual Effects',
            'Stunt Choreography'
        ]::text[] AS special_features,
        '''chaos'':10 ''joker'':11 ''batman'':9 ''justice'':8 ''fear'':7 ''corruption'':6 ''anarchy'':5 ''sacrifice'':4 ''morality'':3 ''crime'':2 ''hero'':1'::tsvector AS fulltext
) AS new_film
WHERE NOT EXISTS (
    SELECT 1 FROM film WHERE lower(title) = lower('The Dark Knight')
)
RETURNING film_id, title;





--TaskN3
--Add the actors who play leading roles in your favorite movies to the 'actor' and 'film_actor' tables (6 or more actors in total).  Actors with the name Actor1, Actor2, etc - will not be taken into account and grade will be reduced.
INSERT INTO public.actor(first_name, last_name)
SELECT 'AL', 'PACINO'
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE upper(first_name) = 'AL' AND upper(last_name) = 'PACINO'
)
RETURNING actor_id, first_name, last_name;

INSERT INTO public.actor(first_name, last_name)
SELECT 'JAMES', 'CAAN'
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE upper(first_name) = 'JAMES' AND upper(last_name) = 'CAAN'
)
RETURNING actor_id, first_name, last_name;

INSERT INTO public.actor(first_name, last_name)
SELECT 'TIM', 'ROBBINS'
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE upper(first_name) = 'TIM' AND upper(last_name) = 'ROBBINS'
)
RETURNING actor_id, first_name, last_name;

INSERT INTO public.actor(first_name, last_name)
SELECT 'MORGAN', 'FREEMAN'
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE upper(first_name) = 'MORGAN' AND upper(last_name) = 'FREEMAN'
)
RETURNING actor_id, first_name, last_name;

INSERT INTO public.actor(first_name, last_name)
SELECT 'CHRISTIAN', 'BALE'
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE upper(first_name) = 'CHRISTIAN' AND upper(last_name) = 'BALE'
)
RETURNING actor_id, first_name, last_name;

INSERT INTO public.actor(first_name, last_name)
SELECT 'HEATH', 'LEDGER'
WHERE NOT EXISTS (
    SELECT 1 FROM public.actor WHERE upper(first_name) = 'HEATH' AND upper(last_name) = 'LEDGER'
)
RETURNING actor_id, first_name, last_name;




INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.actor a
JOIN public.film f ON lower(f.title) = 'the godfather'
WHERE lower(a.first_name) = 'al' AND lower(a.last_name) = 'pacino'
  AND NOT EXISTS (
    SELECT 1 FROM public.film_actor fa
    WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id
)
RETURNING actor_id, film_id;

INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.actor a
JOIN public.film f ON lower(f.title) = 'the godfather'
WHERE lower(a.first_name) = 'james' AND lower(a.last_name) = 'caan'
  AND NOT EXISTS (
    SELECT 1 FROM public.film_actor fa
    WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id
)
RETURNING actor_id, film_id;

INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.actor a
JOIN public.film f ON lower(f.title) = 'the shawshank redemption'
WHERE lower(a.first_name) = 'tim' AND lower(a.last_name) = 'robbins'
  AND NOT EXISTS (
    SELECT 1 FROM public.film_actor fa
    WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id
)
RETURNING actor_id, film_id;

INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.actor a
JOIN public.film f ON lower(f.title) = 'the shawshank redemption'
WHERE lower(a.first_name) = 'morgan' AND lower(a.last_name) = 'freeman'
  AND NOT EXISTS (
    SELECT 1 FROM public.film_actor fa
    WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id
)
RETURNING actor_id, film_id;

INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.actor a
JOIN public.film f ON lower(f.title) = 'the dark knight'
WHERE lower(a.first_name) = 'christian' AND lower(a.last_name) = 'bale'
  AND NOT EXISTS (
    SELECT 1 FROM public.film_actor fa
    WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id
)
RETURNING actor_id, film_id;

INSERT INTO public.film_actor (actor_id, film_id)
SELECT a.actor_id, f.film_id
FROM public.actor a
JOIN public.film f ON lower(f.title) = 'the dark knight'
WHERE lower(a.first_name) = 'heath' AND lower(a.last_name) = 'ledger'
  AND NOT EXISTS (
    SELECT 1 FROM public.film_actor fa
    WHERE fa.actor_id = a.actor_id AND fa.film_id = f.film_id
)
RETURNING actor_id, film_id;

--TaskN4
--Add your favorite movies to any store's inventory.
INSERT INTO public.inventory (film_id, store_id)
SELECT f.film_id, 1
FROM public.film f
WHERE lower(f.title) = 'the shawshank redemption'
  AND NOT EXISTS (
    SELECT 1 FROM public.inventory i
    WHERE i.film_id = f.film_id AND i.store_id = 1
)
RETURNING inventory_id, film_id, store_id;

INSERT INTO public.inventory (film_id, store_id)
SELECT f.film_id, 1
FROM public.film f
WHERE lower(f.title) = 'the godfather'
  AND NOT EXISTS (
    SELECT 1 FROM public.inventory i
    WHERE i.film_id = f.film_id AND i.store_id = 1
)
RETURNING inventory_id, film_id, store_id;

INSERT INTO public.inventory (film_id, store_id)
SELECT f.film_id, 1
FROM public.film f
WHERE lower(f.title) = 'the dark knight'
  AND NOT EXISTS (
    SELECT 1 FROM public.inventory i
    WHERE i.film_id = f.film_id AND i.store_id = 1
)
RETURNING inventory_id, film_id, store_id;

--TaskN5
--Alter any existing customer in the database with at least 43 rental and 43 payment records. Change their personal data to yours (first name, last name, address, etc.). You can use any existing address from the "address" table. Please do not perform any updates on the "address" table, as this can impact multiple records with the same address.

UPDATE public.customer
SET first_name = 'Karapet',
    last_name = 'Tashchyan',
    email = 'tashchyankar@gmail.com',
    address_id = 416
WHERE customer_id IN (
    SELECT customer_id
    FROM rental
    GROUP BY customer_id
    HAVING COUNT(rental_id) >= 43
    INTERSECT
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    HAVING COUNT(payment_id) >= 43
    LIMIT 1
)
RETURNING customer_id;


--TaskN6
--Remove any records related to you (as a customer) from all tables except 'Customer' and 'Inventory'
DELETE FROM rental
WHERE customer_id = (
    SELECT customer_id
    FROM customer
    WHERE lower(first_name) = 'karapet'
      AND lower(last_name) = 'tashchyan'
      AND lower(email) = 'tashchyankar@gmail.com'
      AND address_id = 416
    LIMIT 1
)
RETURNING rental_id;

DELETE FROM payment
WHERE customer_id = (
    SELECT customer_id
    FROM customer
    WHERE lower(first_name) = 'karapet'
      AND lower(last_name) = 'tashchyan'
      AND lower(email) = 'tashchyankar@gmail.com'
      AND address_id = 416
    LIMIT 1
)
RETURNING payment_id;


--TaskN7
--Rent you favorite movies from the store they are in and pay for them (add corresponding records to the database to represent this activity)
--(Note: to insert the payment_date into the table payment, you can create a new partition (see the scripts to install the training database ) or add records for the first half of 2017)

INSERT INTO rental(rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT TIMESTAMP '2017-02-15 16:45:21.914 +0400',
       i.inventory_id,
       c.customer_id,
       NULL,
       s.manager_staff_id
FROM inventory i
JOIN film f ON f.film_id = i.film_id
JOIN store s ON s.store_id = i.store_id
JOIN customer c ON 1=1
WHERE LOWER(f.title) = 'the shawshank redemption'
  AND LOWER(c.email) = 'tashchyankar@gmail.com'
  AND NOT EXISTS (
      SELECT 1
      FROM rental r
      WHERE r.inventory_id = i.inventory_id
        AND r.customer_id = c.customer_id
        AND r.rental_date = TIMESTAMP '2017-02-15 16:45:21.914 +0400'
  )
RETURNING rental_id, inventory_id, customer_id, rental_date;

INSERT INTO rental(rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT TIMESTAMP '2017-02-16 16:45:21.914 +0400',
       i.inventory_id,
       c.customer_id,
       NULL,
       s.manager_staff_id
FROM inventory i
JOIN film f ON f.film_id = i.film_id
JOIN store s ON s.store_id = i.store_id
JOIN customer c ON 1=1
WHERE LOWER(f.title) = 'the godfather'
  AND LOWER(c.email) = 'tashchyankar@gmail.com'
  AND NOT EXISTS (
      SELECT 1
      FROM rental r
      WHERE r.inventory_id = i.inventory_id
        AND r.customer_id = c.customer_id
        AND r.rental_date = TIMESTAMP '2017-02-16 16:45:21.914 +0400'
  )
RETURNING rental_id, inventory_id, customer_id, rental_date;

INSERT INTO rental(rental_date, inventory_id, customer_id, return_date, staff_id)
SELECT TIMESTAMP '2017-02-17 16:45:21.914 +0400',
       i.inventory_id,
       c.customer_id,
       NULL,
       s.manager_staff_id
FROM inventory i
JOIN film f ON f.film_id = i.film_id
JOIN store s ON s.store_id = i.store_id
JOIN customer c ON 1=1
WHERE LOWER(f.title) = 'the dark knight'
  AND LOWER(c.email) = 'tashchyankar@gmail.com'
  AND NOT EXISTS (
      SELECT 1
      FROM rental r
      WHERE r.inventory_id = i.inventory_id
        AND r.customer_id = c.customer_id
        AND r.rental_date = TIMESTAMP '2017-02-17 16:45:21.914 +0400'
  )
RETURNING rental_id, inventory_id, customer_id, rental_date;



INSERT INTO payment(customer_id, staff_id, rental_id, amount, payment_date)
SELECT r.customer_id, r.staff_id, r.rental_id, 6.99, TIMESTAMP '2017-02-16 17:45:50.914+04'
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE LOWER(f.title) = 'the shawshank redemption'
  AND r.customer_id = (
      SELECT customer_id FROM customer
      WHERE LOWER(first_name) = 'karapet'
        AND LOWER(last_name) = 'tashchyan'
        AND LOWER(email) = 'tashchyankar@gmail.com'
        AND address_id = 416
  )
  AND  not EXISTS (
      SELECT 1 FROM payment p
      WHERE p.rental_id = r.rental_id
        AND p.customer_id = r.customer_id
        AND p.payment_date = TIMESTAMP '2017-02-16 17:45:50.914+04'
  )
RETURNING payment_id;

)



INSERT INTO payment(customer_id, staff_id, rental_id, amount, payment_date)
SELECT r.customer_id, r.staff_id, r.rental_id, 5.99, TIMESTAMP '2017-02-17 16:45:21.914+04'
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE lower(f.title) = 'the godfather'
  AND r.customer_id = (
      SELECT customer_id FROM customer
      WHERE LOWER(first_name) = 'karapet'
        AND LOWER(last_name) = 'tashchyan'
        AND LOWER(email) = 'tashchyankar@gmail.com'
        AND address_id = 416
  )
  AND NOT EXISTS (
      SELECT 1 FROM payment p
      WHERE p.rental_id = r.rental_id
        AND p.customer_id = r.customer_id
        AND p.payment_date = TIMESTAMP '2017-02-17 16:45:21.914+04'
  )
RETURNING payment_id;




INSERT INTO payment(customer_id, staff_id, rental_id, amount, payment_date)
SELECT r.customer_id, r.staff_id, r.rental_id, 3.99, TIMESTAMP '2017-02-18 18:45:21.914+04'
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'the dark knight'
  AND r.customer_id = (
      SELECT customer_id FROM customer
      WHERE LOWER(first_name) = 'karapet'
        AND LOWER(last_name) = 'tashchyan'
        AND LOWER(email) = 'tashchyankar@gmail.com'
        AND address_id = 416
  )
  AND NOT EXISTS (
      SELECT 1 FROM payment p
      WHERE p.rental_id = r.rental_id
        AND p.customer_id = r.customer_id
        AND p.payment_date = TIMESTAMP '2017-02-18 18:45:21.914+04'
  )
RETURNING payment_id;

