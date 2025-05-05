--TaskN1
SELECT
    ch.channel_desc AS channel,
    cu.cust_last_name || ', ' || cu.cust_first_name AS customer_name,
    TO_CHAR(cs.total_sales, 'FM999999999.00') AS total_sales,
    TO_CHAR((cs.total_sales / totals.channel_total) * 100, 'FM999990.0000') || '%' AS sales_percentage
FROM (
    SELECT
        s.channel_id,
        s.cust_id,
        SUM(s.amount_sold) AS total_sales,
        RANK() OVER (PARTITION BY s.channel_id ORDER BY SUM(s.amount_sold) DESC) AS rnk
    FROM sh.sales s
    GROUP BY s.channel_id, s.cust_id
) cs
JOIN (
    SELECT
        channel_id,
        SUM(amount_sold) AS channel_total
    FROM sh.sales
    GROUP BY channel_id
) totals ON cs.channel_id = totals.channel_id
JOIN sh.customers cu ON cs.cust_id = cu.cust_id
JOIN sh.channels ch ON cs.channel_id = ch.channel_id
WHERE cs.rnk <= 5
ORDER BY ch.channel_desc, cs.total_sales DESC;


--TaskN2
SELECT 
    product_name,
    q1_sales,
    q2_sales,
    q3_sales,
    q4_sales,
    ROUND((q1_sales + q2_sales + q3_sales + q4_sales), 2) AS YEAR_SUM
FROM (
    SELECT 
        p.prod_name AS product_name,
        ROUND(SUM(s.amount_sold) FILTER (
            WHERE EXTRACT(quarter FROM t.time_id) = 1), 2) AS q1_sales,
        ROUND(SUM(s.amount_sold) FILTER (
            WHERE EXTRACT(quarter FROM t.time_id) = 2), 2) AS q2_sales,
        ROUND(SUM(s.amount_sold) FILTER (
            WHERE EXTRACT(quarter FROM t.time_id) = 3), 2) AS q3_sales,
        ROUND(SUM(s.amount_sold) FILTER (
            WHERE EXTRACT(quarter FROM t.time_id) = 4), 2) AS q4_sales,
        SUM(SUM(s.amount_sold)) OVER (
            PARTITION BY p.prod_name) AS total_sales
    FROM 
        sh.sales s
        LEFT JOIN sh.products p ON s.prod_id = p.prod_id
        LEFT JOIN sh.customers cu ON s.cust_id = cu.cust_id
        LEFT JOIN sh.countries co ON cu.country_id = co.country_id
        LEFT JOIN sh.times t ON s.time_id = t.time_id
    WHERE 
        LOWER(co.country_subregion) = 'asia'
        AND EXTRACT(year FROM t.time_id) = 2001
        AND LOWER(p.prod_category) = 'photo'
    GROUP BY 
        p.prod_name
) AS quarterly_data
ORDER BY 
    YEAR_SUM DESC;

--TaskN3

WITH yearly_sales AS (
    SELECT 
        c.cust_id,
        c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
        ch.channel_desc,
        t.calendar_year,
        SUM(s.amount_sold) AS total_sales
    FROM 
        sh.sales s
        JOIN sh.customers c ON s.cust_id = c.cust_id
        JOIN sh.channels ch ON s.channel_id = ch.channel_id
        JOIN sh.times t ON s.time_id = t.time_id
    WHERE 
        t.calendar_year IN (1998, 1999, 2001)
    GROUP BY 
        c.cust_id, c.cust_first_name, c.cust_last_name, 
        ch.channel_desc, t.calendar_year
),

channel_rankings AS (
    SELECT 
        *,
        RANK() OVER (
            PARTITION BY channel_desc, calendar_year 
            ORDER BY total_sales DESC
        ) AS channel_rank
    FROM yearly_sales
)

SELECT 
    customer_name,
    channel_desc AS sales_channel,
    calendar_year AS sales_year,
    ROUND(total_sales, 2) AS channel_sales,
    channel_rank AS sales_rank
FROM 
    channel_rankings
WHERE 
    channel_rank <= 300
ORDER BY 
    sales_channel,
    sales_year,
    sales_rank;

--TaskN4
SELECT 
    TO_CHAR(t.time_id, 'Month') AS month,
    p.prod_category,
    ROUND(SUM(CASE WHEN UPPER(co.country_subregion) LIKE '%AMERICA%' THEN s.amount_sold ELSE 0 END), 2) AS americas_sales,
    ROUND(SUM(CASE WHEN UPPER(co.country_subregion) LIKE '%EUROPE%' THEN s.amount_sold ELSE 0 END), 2) AS europe_sales
    FROM 
    sh.sales s
    JOIN sh.products p ON s.prod_id = p.prod_id
    JOIN sh.customers c ON s.cust_id = c.cust_id
    JOIN sh.countries co ON c.country_id = co.country_id
    JOIN sh.times t ON s.time_id = t.time_id
WHERE 
    t.time_id BETWEEN TO_DATE('2000-01-01', 'YYYY-MM-DD') AND TO_DATE('2000-03-31', 'YYYY-MM-DD')
    AND (UPPER(co.country_subregion) LIKE '%EUROPE%' OR UPPER(co.country_subregion) LIKE '%AMERICA%')
GROUP BY 
    TO_CHAR(t.time_id, 'Month'),
    p.prod_category,
    EXTRACT(MONTH FROM t.time_id)
ORDER BY 
    EXTRACT(MONTH FROM t.time_id),
    p.prod_category;