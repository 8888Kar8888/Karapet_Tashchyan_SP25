--TaskN1
-- Comprehensive solution for multi-year regional channel analysis
WITH sales_data AS (
    -- First CTE: Aggregate sales by region, year, and channel
    -- Clever use of CASE to group subregions into continents
    SELECT 
        CASE 
            WHEN lower(co.country_subregion) IN ('northern america', 'southern america') THEN 'Americas'
            WHEN lower(co.country_subregion) = 'asia' THEN 'Asia'
            WHEN lower(co.country_subregion) IN ('eastern europe', 'western europe') THEN 'Europe'
        END AS country_region,
        t.calendar_year,
        ch.channel_desc,
        SUM(s.amount_sold) AS amount_sold
    FROM 
        sh.sales s
        JOIN sh.customers c ON s.cust_id = c.cust_id
        JOIN sh.countries co ON c.country_id = co.country_id
        JOIN sh.times t ON s.time_id = t.time_id
        JOIN sh.channels ch ON s.channel_id = ch.channel_id
    WHERE 
        t.calendar_year BETWEEN 1999 AND 2001
        AND co.country_subregion IN (
            'Northern America', 'Southern America', 'Asia',
            'Eastern Europe', 'Western Europe'
        )
    GROUP BY 
        CASE 
            WHEN lower(co.country_subregion) IN ('northern america', 'southern america') THEN 'Americas'
            WHEN lower(co.country_subregion) = 'asia' THEN 'Asia'
            WHEN lower(co.country_subregion) IN ('eastern europe', 'western europe') THEN 'Europe'
        END,
        t.calendar_year,
        ch.channel_desc
),

-- Second CTE: Calculate total sales per region per year
-- Provides denominator for percentage calculations
region_year_totals AS (
    SELECT 
        country_region,
        calendar_year,
        SUM(amount_sold) AS region_year_total
    FROM 
        sales_data
    GROUP BY 
        country_region,
        calendar_year
),

-- Third CTE: Calculate channel percentages and previous year values
-- Uses LAG window function to get prior year percentages
channel_percentages AS (
    SELECT 
        sd.country_region,
        sd.calendar_year,
        sd.channel_desc,
        sd.amount_sold,
        (sd.amount_sold / NULLIF(ryt.region_year_total, 0)) * 100 AS pct_by_channels,
        LAG((sd.amount_sold / NULLIF(ryt.region_year_total, 0)) * 100, 1) OVER (
            PARTITION BY sd.country_region, sd.channel_desc 
            ORDER BY sd.calendar_year
        ) AS prev_year_pct
    FROM 
        sales_data sd
        JOIN region_year_totals ryt ON sd.country_region = ryt.country_region
                                   AND sd.calendar_year = ryt.calendar_year
)

-- Final output with formatted results
SELECT 
    country_region,
    calendar_year,
    channel_desc,
    TO_CHAR(amount_sold, 'FM9,999,999,999.00') AS amount_sold,
    TO_CHAR(pct_by_channels, 'FM990.0000') || '%' AS "% BY CHANNELS",
    CASE 
        WHEN prev_year_pct IS NULL THEN 'N/A' 
        ELSE TO_CHAR(prev_year_pct, 'FM990.0000') || '%' 
    END AS "% PREVIOUS PERIOD",
    CASE 
        WHEN prev_year_pct IS NULL THEN 'N/A' 
        WHEN pct_by_channels - prev_year_pct >= 0 THEN '+' || TO_CHAR(pct_by_channels - prev_year_pct, 'FM990.0000') || '%'
        ELSE TO_CHAR(pct_by_channels - prev_year_pct, 'FM990.0000') || '%' 
    END AS "% DIFF"
FROM 
    channel_percentages
ORDER BY 
    country_region ASC,
    calendar_year ASC,
    channel_desc ASC;




--TaskN2
-- Solution for weekly sales analysis with advanced window functions
WITH week_dates AS (
    -- First CTE: Filter dates for weeks 49-51 of 1999
    SELECT 
        time_id,
        day_name,
        calendar_week_number,
        calendar_year
    FROM 
        sh.times
    WHERE 
        calendar_year = 1999
        AND calendar_week_number IN (49, 50, 51)
),

daily_sales AS (
    -- Second CTE: Aggregate daily sales for the selected weeks
    SELECT 
        w.time_id,
        w.day_name,
        w.calendar_week_number,
        w.calendar_year,
        SUM(s.amount_sold) AS daily_amount
    FROM 
        sh.sales s
        JOIN week_dates w ON s.time_id = w.time_id
    GROUP BY 
        w.time_id,
        w.day_name,
        w.calendar_week_number,
        w.calendar_year
)

-- Main query with cumulative sums and conditional centered averages
SELECT 
    TO_CHAR(time_id, 'YYYY-MM-DD') AS date,
    day_name,
    calendar_week_number,
    ROUND(daily_amount, 2) AS daily_amount,
    -- Cumulative sum partitioned by week
    ROUND(SUM(daily_amount) OVER (
        PARTITION BY calendar_week_number
        ORDER BY time_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS cum_sum,
    
    -- Conditional centered average based on day of week
    -- Special handling for Monday and Friday
    CASE 
        WHEN day_name = 'Monday' THEN 
            -- Monday average includes weekend + Mon/Tue
            ROUND(AVG(daily_amount) OVER (
                PARTITION BY calendar_week_number
                ORDER BY time_id
                ROWS BETWEEN 2 PRECEDING AND 1 FOLLOWING
            ), 2)
        WHEN day_name = 'Friday' THEN 
            -- Friday average includes Thu/Fri + weekend
            ROUND(AVG(daily_amount) OVER (
                PARTITION BY calendar_week_number
                ORDER BY time_id
                ROWS BETWEEN 1 PRECEDING AND 2 FOLLOWING
            ), 2)
        ELSE 
            -- Standard centered average for midweek days
            ROUND(AVG(daily_amount) OVER (
                PARTITION BY calendar_week_number
                ORDER BY time_id
                ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
            ), 2)
    END AS centered_3_day_avg
FROM 
    daily_sales
ORDER BY 
    time_id;
    
    
    
    
-- Task 3.1: 7-day moving average using ROWS
-- Ideal when you need a fixed number of rows in the window
SELECT 
    time_id,
    amount_sold,
    AVG(amount_sold) OVER (
        ORDER BY time_id
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day
FROM sh.sales
WHERE time_id BETWEEN DATE '1999-12-01' AND DATE '1999-12-31'
ORDER BY time_id;

-- Task 3.2: Price range comparison using RANGE
-- Perfect for value-based windows (±100 units in this case)
SELECT 
    prod_id,
    amount_sold,
    COUNT(*) OVER (
        ORDER BY amount_sold
        RANGE BETWEEN 100 PRECEDING AND 100 FOLLOWING
    ) AS similar_priced_products,
    AVG(amount_sold) OVER (
        ORDER BY amount_sold
        RANGE BETWEEN 100 PRECEDING AND 100 FOLLOWING
    ) AS avg_in_price_range
FROM sh.sales
WHERE time_id = DATE '1999-12-15'
ORDER BY amount_sold;
    
-- Task 3.3: Tiered analysis using GROUPS
-- First create price tiers in a CTE
WITH products_with_tiers AS (
    SELECT 
        prod_id,
        amount_sold,
        -- Divide products into 5 equal-sized price tiers
        NTILE(5) OVER (ORDER BY amount_sold) AS price_tier
    FROM sh.sales
    WHERE time_id BETWEEN DATE '1999-12-01' AND DATE '1999-12-07'
)

-- Then perform group-based analysis
SELECT 
    prod_id,
    amount_sold,
    price_tier,
    -- Rank within each price tier
    RANK() OVER (
        PARTITION BY price_tier
        ORDER BY amount_sold
    ) AS rank_in_tier,
    -- Average of current group plus adjacent groups
    AVG(amount_sold) OVER (
        PARTITION BY price_tier
        ORDER BY amount_sold
        GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS avg_of_peer_group
FROM products_with_tiers
ORDER BY price_tier, amount_sold;
    







--Why ROWS was chosen:

--We need a fixed count of 7 rows (current row + 6 preceding) regardless of the time intervals between them
--ROWS is perfect when you want to include an exact number of preceding/following rows in your calculation
--This ensures we always average exactly 7 data points, creating a consistent moving window
--Particularly useful when data points are evenly spaced (e.g., daily sales data)
    


--Why RANGE was chosen:

--We want to compare products within a specific value range (±100 price units)
--RANGE looks at the actual values in the ORDER BY column rather than row positions
--Automatically includes all rows where the amount_sold is within 100 units in either direction
--More meaningful than ROWS when analyzing value-based neighborhoods

    

--Why GROUPS was chosen:

--We've already created discrete categories (price tiers) using NTILE(5)
--GROUPS allows us to work with these logical groupings rather than fixed rows or value ranges
--Perfect for analyzing "the current group plus one group above and below" in the tier structure
--Maintains the categorical boundaries we intentionally created