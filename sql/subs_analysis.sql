-- EXPLORE
-- Understand distribution
SELECT COUNT(*), MIN(price_usd), MAX(price_usd), AVG(price_usd)
FROM daily_subs;

-- Count NULLS in daily_subs
SELECT COUNT(*) AS total_rows,
       COUNT(price_usd) AS non_null_values,
       COUNT(*) - COUNT(price_usd) AS null_values
FROM daily_subs;

-- Count NULLS in continent column
SELECT COUNT(*) AS total_rows,
       COUNT(continent) AS non_null_values,
       COUNT(*) - COUNT(continent) AS null_values
FROM daily_subs_country_rates;

-- Check for duplicates in key
SELECT user_id, COUNT(*)
FROM daily_subs
GROUP BY user_id
HAVING COUNT(*) > 1;

-- CLEAN
DELETE FROM daily_subs WHERE usd_price IS NULL;
-- Deletes 925

DELETE FROM daily_subs WHERE country_code IS NULL;
-- deletes 55

DELETE FROM daily_subs_country_rates WHERE continent IS NULL;
--deletes 24

UPDATE daily_subs
SET country_code = 'US'
WHERE currency = 'USD'
  AND (country_code IS NULL OR country_code = '');
  -- Update 291


-- CTE for aggregation
CREATE TABLE daily_subs_country_rates AS
WITH daily_subs_clean AS (
    SELECT 
    -- Add date columns and supplementary subscription name
        sub_start_ts::DATE AS sub_start_ts,
        DATE_TRUNC('week', sub_start_ts)::DATE AS sub_start_week,
        DATE_TRUNC('month', sub_start_ts)::DATE AS sub_start_month,
        DATE_TRUNC('quarter', sub_start_ts)::DATE AS sub_start_quarter,
        DATE_TRUNC('year', sub_start_ts)::DATE AS sub_start_year,
        user_id AS user, -- Assuming "user" is renamed to "user_id"
        plan,
        period,
        CONCAT(plan, ' ', period) AS full_sub_name,
        price AS local_price,
        price_usd,
        currency,
        country_code
    FROM daily_subs
),
daily_subs_clean_country AS (
    SELECT *
    FROM daily_subs_clean
    LEFT JOIN geo_lookup
    ON LOWER(daily_subs_clean.country_code) = LOWER(geo_lookup.country_iso)
), 
daily_subs_country_rates AS (
    SELECT 
        daily_subs_clean_country.*,
        CASE 
            WHEN daily_subs_clean_country.currency = 'USD' 
            THEN local_price 
            ELSE local_price * rate 
        END AS price_usd_calc
    FROM daily_subs_clean_country
    LEFT JOIN exchange_rates
    ON LOWER(daily_subs_clean_country.currency) = LOWER(exchange_rates.currency)
        AND daily_subs_clean_country.sub_start_month = exchange_rates.date)

SELECT * FROM daily_subs_country_rates;


-- Copy to .csv for later use
\copy daily_subs_country_rates TO '[HOME]/projects/saas_subscription_analysis/data/clean/zoom_subs.csv' CSV HEADER;
