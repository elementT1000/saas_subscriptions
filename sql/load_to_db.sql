-- Using PostgreSQL 17
--1. SET UP TABLES
CREATE TABLE daily_subs (
    user_id INTEGER,
    plan TEXT,
    period TEXT,
    sub_start_ts DATE,
    sub_end_ts DATE,
    price NUMERIC,
    price_usd NUMERIC,
    currency TEXT,
    country_code TEXT
);


CREATE TABLE exchange_rates (
    rate NUMERIC,
    currency TEXT,
    date DATE
);

CREATE TABLE geo_lookup (
    continent TEXT,
    full_country_name TEXT,
    continent_iso TEXT,
    country_iso TEXT,
    region TEXT,
    region_detail TEXT
);

-- 2. LOAD FILES INTO TABLES
\copy exchange_rates FROM '[HOME]/projects/saas_subscription_analysis/data/raw/exchange_rates.csv' DELIMITER ',' CSV HEADER;
\copy geo_lookup FROM '[HOME]/projects/saas_subscription_analysis/data/raw/geo_lookup.csv' DELIMITER ',' CSV HEADER;
\copy daily_subs FROM '[HOME]/projects/saas_subscription_analysis/data/raw/daily_subs.csv' DELIMITER ',' CSV HEADER;


-- 3. CHECK
SELECT * FROM exchange_rates LIMIT 10;
SELECT * FROM geo_lookup LIMIT 10;
SELECT * FROM daily_subs LIMIT 10;
