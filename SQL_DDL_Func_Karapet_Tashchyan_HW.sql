--TaskN1

DROP VIEW sales_revenue_by_category_qtr
CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT c.name AS category,
       sum(p.amount) AS total_sales_revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name,
         extract(YEAR
                 FROM p.payment_date),
         extract(QUARTER
                 FROM p.payment_date)
HAVING sum(p.amount) > 0
ORDER BY extract(YEAR
                 FROM p.payment_date),
         extract(QUARTER
                 FROM p.payment_date),
         c.name;

--TaskN2

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(cur_quart_year text) RETURNS TABLE (category text, total_sales_revenue numeric(5, 2)) AS $$
declare cur_year int;
declare cur_quarter int;

begin
	cur_year := cast(substring(cur_quart_year from 1 for 4) as int);
	cur_quarter := cast(substring(cur_quart_year from 7 for 1) as int);

	return query SELECT
    c.name AS category,

    SUM(p.amount) AS total_sales_revenue
FROM
    payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
where EXTRACT(year from payment_date) = cur_year and extract(quarter from payment_date)=cur_quarter
GROUP BY
    c.name
HAVING
    SUM(p.amount) > 0;
end;
$$ LANGUAGE PLPGSQL;


SELECT DISTINCT rating
FROM film
ORDER BY rating DESC --TaskN3

CREATE SCHEMA IF NOT EXISTS core;

--drop function core.most_popular_films_by_countries
 --select * from get_sales_revenue_by_category_qtr('2017-Q2')



--TaskN3
CREATE OR REPLACE FUNCTION core.most_popular_films_by_countries(countries TEXT[]) RETURNS TABLE ("Country" TEXT, "Film" TEXT, "Rating" mpaa_rating,
                                                                                                                              "Language" character(20),
                                                                                                                                         "Length" SMALLINT, "Release Year" INTEGER) AS $$
BEGIN
    RETURN QUERY
    WITH film_data AS (
        SELECT
            co.country AS country,
            f.title AS film,
            f.rating AS rating,
            l.name AS language,
            f.length AS length,
            f.release_year AS release_year,
            RANK() OVER (PARTITION BY co.country ORDER BY f.rating DESC) AS rank
        FROM film f
        JOIN language l ON f.language_id = l.language_id
        JOIN inventory i ON f.film_id = i.film_id
        JOIN rental r ON i.inventory_id = r.inventory_id
        JOIN customer cu ON r.customer_id = cu.customer_id
        JOIN address a ON cu.address_id = a.address_id
        JOIN city ci ON a.city_id = ci.city_id
        JOIN country co ON ci.country_id = co.country_id
        WHERE co.country = ANY(countries)
    )
    SELECT
        country AS "Country",
        film AS "Film",
        rating AS "Rating",
        language AS "Language",
        length AS "Length",
        release_year AS "Release Year"
    FROM film_data
    WHERE rank = 1;
END;
$$ LANGUAGE PLPGSQL;

--TaskN4

CREATE OR REPLACE FUNCTION core.films_in_stock_by_title(pattern TEXT) RETURNS TABLE ("Row_num" BIGINT, "From title" TEXT, "Language" character(20),
                                                                                                                                     "Customer name" TEXT, "Rental date" timestamptz) AS $$
BEGIN
    RETURN QUERY
    WITH available_films AS (
        SELECT
            f.title,
            l.name AS language,
            c.first_name || ' ' || c.last_name AS customer_name,
            r.rental_date
        FROM film f
        JOIN language l ON f.language_id = l.language_id
        JOIN inventory i ON f.film_id = i.film_id
        LEFT JOIN rental r ON i.inventory_id = r.inventory_id AND r.return_date IS NULL
        LEFT JOIN customer c ON r.customer_id = c.customer_id
        WHERE f.title ILIKE pattern
        AND r.rental_id IS NULL
    )
    SELECT
        ROW_NUMBER() OVER () AS "Row_num",
        title AS "From title",
        language AS "Language",
        customer_name AS "Customer name",
        rental_date AS "Rental date"
    FROM available_films;

    IF NOT FOUND THEN
        RAISE NOTICE 'No movies found in stock matching the title pattern: %', pattern;
    END IF;
END;
$$ LANGUAGE PLPGSQL;

--select * from core.films_in_stock_by_title('%love%')
 --TaskN5

CREATE OR REPLACE FUNCTION new_movie(film_name TEXT, ry INTEGER DEFAULT extract(YEAR
                                                                                FROM CURRENT_DATE), lang TEXT DEFAULT 'Klingon', rental_rate NUMERIC DEFAULT 4.99, rental_duration INTEGER DEFAULT 3, replacement_cost NUMERIC DEFAULT 19.99) RETURNS void AS $$
DECLARE
    lang_id INT;
BEGIN
    -- Check if film_name is null or empty
    IF film_name IS NULL OR LENGTH(TRIM(film_name)) = 0 THEN
        RAISE EXCEPTION 'Film name cannot be null or empty.';
    END IF;

    -- Check if language exists and get its ID
    SELECT language_id INTO lang_id
    FROM language
    WHERE name = lang;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Language "%" not found in the language table.', lang;
    END IF;

    -- Check if the film already exists (case-insensitive)
    IF EXISTS (SELECT 1 FROM film WHERE LOWER(title) = LOWER(film_name)) THEN
        RAISE NOTICE 'Film "%" already exists. Skipping insert.', film_name;
    ELSE
        -- Insert new film with dynamic values
        INSERT INTO film (
            title, rental_rate, rental_duration, replacement_cost,
            release_year, language_id
        )
        VALUES (
            film_name, rental_rate, rental_duration, replacement_cost,
            ry, lang_id
        );
        RAISE NOTICE 'Film "%" successfully inserted.', film_name;
    END IF;
END;
$$ LANGUAGE PLPGSQL;


SELECT new_movie('Inception', 2010, 'English');









