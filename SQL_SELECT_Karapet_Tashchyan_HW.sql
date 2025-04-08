
--Task1.1
SELECT f.title
FROM public.film f
LEFT join
public.film_category fc on f.film_id =fc.film_id
LEFT join 
public.category c on c.category_id = fc.category_id
WHERE lower(c."name") = 'animation' and (f.release_year between 2017 and 2019)  and f.rental_rate > 1
ORDER BY f.title asc;

--Task1.1 V2
WITH animation_films AS (
  SELECT f.title
  FROM public.film f
  JOIN public.film_category fc ON f.film_id = fc.film_id
  JOIN public.category c ON c.category_id = fc.category_id
  WHERE lower(c.name) = 'animation'
    AND f.release_year BETWEEN 2017 AND 2019
    AND f.rental_rate > 1
)
SELECT * FROM animation_films
ORDER BY title;


--Task1.2
SELECT (a.address || ' ' || COALESCE(a.address2, '')) as payment_address, sum(p.amount) as revenue
FROM public.inventory i
LEFT JOIN public.rental r  on i.inventory_id = r.inventory_id
LEFT JOIN public.payment p on p.rental_id = r.rental_id 
LEFT JOIN public.customer c on c.customer_id = p.customer_id
LEFT JOIN public.address a on a.address_id = c.address_id
WHERE payment_date >= '2017-03-01'
GROUP BY (a.address || ' ' || COALESCE(a.address2, ''));



--Task1.3 
WITH top5_actors AS (
    SELECT 
        a.first_name, 
        a.last_name, 
        COUNT(f.film_id) AS number_of_movies
    FROM public.actor a
    LEFT JOIN public.film_actor fa ON a.actor_id = fa.actor_id
    LEFT JOIN public.film f ON f.film_id = fa.film_id
    WHERE f.release_year > 2015
    GROUP BY a.first_name, a.last_name
    ORDER BY number_of_movies DESC
    LIMIT 5
)
SELECT 
    a.first_name, 
    a.last_name, 
    COUNT(f.film_id) AS number_of_movies
FROM public.actor a
LEFT JOIN public.film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN public.film f ON f.film_id = fa.film_id
WHERE f.release_year > 2015
GROUP BY a.first_name, a.last_name
HAVING COUNT(f.film_id) BETWEEN 
    (SELECT MIN(number_of_movies) FROM top5_actors) AND 
    (SELECT MAX(number_of_movies) FROM top5_actors)
ORDER BY number_of_movies DESC;




--Task1.4
SELECT 
    f.release_year,
    COUNT(CASE WHEN LOWER(c.name) = 'drama' THEN 1 END) AS number_of_drama_movies,
    COUNT(CASE WHEN LOWER(c.name) = 'travel' THEN 1 END) AS number_of_travel_movies,
    COUNT(CASE WHEN LOWER(c.name) = 'documentary' THEN 1 END) AS number_of_documentary_movies
FROM film f
LEFT JOIN film_category fc ON f.film_id = fc.film_id
LEFT JOIN category c ON fc.category_id = c.category_id
GROUP BY f.release_year
ORDER BY f.release_year DESC;


--TASK N2
--Task2.1
WITH payment_2017 AS (
    SELECT p.payment_id, p.staff_id, p.amount, p.payment_date, i.store_id
    FROM public.payment p
    JOIN public.rental r ON p.rental_id = r.rental_id
    JOIN public.inventory i ON r.inventory_id = i.inventory_id
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
JOIN public.staff s ON r.staff_id = s.staff_id
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
FROM public.rental r
JOIN public.inventory i ON r.inventory_id = i.inventory_id
JOIN public.film f ON i.film_id = f.film_id
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
FROM public.actor a
JOIN public.film_actor fa ON a.actor_id = fa.actor_id
JOIN public.film f ON fa.film_id = f.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY years_inactive DESC;

--Task3.1 V2
WITH actor_films AS (
  SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    f.release_year
  FROM public.actor a
  JOIN public.film_actor fa ON a.actor_id = fa.actor_id
  JOIN public.film f ON fa.film_id = f.film_id
),
film_gaps AS (
  SELECT 
    af1.actor_id,
    af1.first_name,
    af1.last_name,
    af1.release_year AS current_year,
    MAX(af2.release_year) AS prev_year,  -- Find the most recent previous film
    af1.release_year - MAX(af2.release_year) AS gap
  FROM actor_films af1
  LEFT JOIN actor_films af2 
    ON af1.actor_id = af2.actor_id 
    AND af1.release_year > af2.release_year  -- Ensure it's an earlier movie
  GROUP BY af1.actor_id, af1.first_name, af1.last_name, af1.release_year
)
SELECT 
  actor_id,
  first_name,
  last_name,
  MAX(gap) AS max_gap_between_movies
FROM film_gaps
WHERE gap IS NOT NULL  -- Exclude actors with only one movie
GROUP BY actor_id, first_name, last_name
ORDER BY max_gap_between_movies DESC
LIMIT 10;










