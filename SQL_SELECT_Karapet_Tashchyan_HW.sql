--Task1.1
SELECT f.title
FROM film f
LEFT join
film_category fc on f.film_id =fc.film_id
LEFT JOIN category c on c.category_id = fc.category_id
WHERE c."name" = 'Animation' and (f.release_year between 2017 and 2019)  and f.rental_rate > 1
ORDER BY f.title asc;

--Task1.1 V2
WITH animation_films AS (
  SELECT f.title
  FROM film f
  JOIN film_category fc ON f.film_id = fc.film_id
  JOIN category c ON c.category_id = fc.category_id
  WHERE c.name = 'Animation'
    AND f.release_year BETWEEN 2017 AND 2019
    AND f.rental_rate > 1
)
SELECT * FROM animation_films
ORDER BY title;


--Task1.2
SELECT (a.address || ' ' || COALESCE(a.address2, '')) as payment_address, sum(p.amount) as revenue
FROM inventory i
LEFT JOIN rental r  on i.inventory_id = r.inventory_id
LEFT JOIN payment p on p.rental_id = r.rental_id 
LEFT JOIN customer c on c.customer_id = p.customer_id
LEFT JOIN address a on a.address_id = c.address_id
WHERE payment_date >= '2017-03-01'
GROUP BY (a.address || ' ' || COALESCE(a.address2, ''));

--Task1.3
SELECT a.first_name,a.last_name, count(f.film_id) as number_of_movies
FROM actor a 
LEFT JOIN film_actor fa on a.actor_id =fa.actor_id
LEFT JOIN film f on f.film_id = fa.film_id
WHERE f.release_year > 2015
GROUP BY a.first_name,a.last_name
ORDER BY count(f.film_id) desc
LIMIT 5;

--Task1.4
SELECT 
    f.release_year,
    COALESCE(drama.number_of_movies, 0) AS number_of_drama_movies,
    COALESCE(travel.number_of_movies, 0) AS number_of_travel_movies,
    COALESCE(documentary.number_of_movies, 0) AS number_of_documentary_movies
FROM film f
LEFT JOIN (
    SELECT f.release_year, COUNT(f.film_id) AS number_of_movies
    FROM film f
    LEFT JOIN film_category fc ON f.film_id = fc.film_id
    LEFT JOIN category c ON fc.category_id = c.category_id
    WHERE c."name" = 'Drama'
    GROUP BY f.release_year
) drama ON f.release_year = drama.release_year
LEFT JOIN (
    SELECT f.release_year, COUNT(f.film_id) AS number_of_movies
    FROM film f
    LEFT JOIN film_category fc ON f.film_id = fc.film_id
    LEFT JOIN category c ON fc.category_id = c.category_id
    WHERE c."name" = 'Travel'
    GROUP BY f.release_year
) travel ON f.release_year = travel.release_year
LEFT JOIN (
    SELECT f.release_year, COUNT(f.film_id) AS number_of_movies
    FROM film f
    LEFT JOIN film_category fc ON f.film_id = fc.film_id
    LEFT JOIN category c ON fc.category_id = c.category_id
    WHERE c."name" = 'Documentary'
    GROUP BY f.release_year
) documentary ON f.release_year = documentary.release_year
GROUP BY f.release_year, COALESCE(drama.number_of_movies, 0),COALESCE(travel.number_of_movies, 0), COALESCE(documentary.number_of_movies, 0)
ORDER BY f.release_year DESC;

--TASK N2
--Task2.1
WITH payment_2017 AS (
    SELECT p.payment_id, p.staff_id, p.amount, p.payment_date, i.store_id
    FROM payment p
    JOIN rental r ON p.rental_id = r.rental_id
    JOIN inventory i ON r.inventory_id = i.inventory_id
    WHERE p.payment_date BETWEEN '2017-01-01' AND '2017-12-31'
),
revenue_2017 AS (
    SELECT staff_id, SUM(amount) AS total_revenue
    FROM payment_2017
    GROUP BY staff_id
),
last_store AS (
    SELECT DISTINCT ON (staff_id)
        staff_id,
        store_id,
        payment_date
    FROM payment_2017
    ORDER BY staff_id, payment_date DESC
)
SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    ls.store_id,
    r.total_revenue
FROM revenue_2017 r
JOIN staff s ON r.staff_id = s.staff_id
JOIN last_store ls ON s.staff_id = ls.staff_id
ORDER BY r.total_revenue DESC
LIMIT 3;

--Task2.2

SELECT 
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS rental_count,
    f.rating,
    CASE f.rating
        WHEN 'G' THEN '0+'
        WHEN 'PG' THEN '10+'
        WHEN 'PG-13' THEN '13+'
        WHEN 'R' THEN '17+'
        WHEN 'NC-17' THEN '18+'
        ELSE 'Unknown'
    END AS expected_age
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.film_id, f.title, f.rating
ORDER BY rental_count DESC
LIMIT 5;

--Task3.1
SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    MAX(f.release_year) AS last_movie_year,
    EXTRACT(year from CURRENT_DATE) - MAX(f.release_year) AS years_inactive
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY years_inactive DESC;

--Task3.1 V2
WITH actor_films AS (
  SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    f.release_year,
    ROW_NUMBER() OVER (PARTITION BY a.actor_id ORDER BY f.release_year) AS rn
  FROM actor a
  JOIN film_actor fa ON a.actor_id = fa.actor_id
  JOIN film f ON fa.film_id = f.film_id
),
film_gaps AS (
  SELECT 
    af1.actor_id,
    af1.first_name,
    af1.last_name,
    af1.release_year AS current_year,
    af2.release_year AS prev_year,
    af1.release_year - af2.release_year AS gap
  FROM actor_films af1
  JOIN actor_films af2 
    ON af1.actor_id = af2.actor_id AND af1.rn = af2.rn + 1
)
SELECT 
  actor_id,
  first_name,
  last_name,
  MAX(gap) AS max_gap_between_movies
FROM film_gaps
GROUP BY actor_id, first_name, last_name
ORDER BY max_gap_between_movies DESC
LIMIT 10;










