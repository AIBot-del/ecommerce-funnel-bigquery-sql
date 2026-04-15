--SQL PROJECT
--BY MATHEW KEMBOI
WITH base AS (
  SELECT
    *,
    MAX(DATE(event_date)) OVER () AS max_date
  FROM `sales-493322.sql_sales.TB1`
),
--DEFINING FUNNEL STAGES
--We count user_ids going through the funnel
funnel AS(
SELECT
  COUNT(DISTINCT IF(event_type = 'page_view', user_id, NULL))      AS stage_1_views,
  COUNT(DISTINCT IF(event_type = 'add_to_cart', user_id, NULL))    AS stage_2_cart,
  COUNT(DISTINCT IF(event_type = 'checkout_start', user_id, NULL)) AS stage_3_checkout,
  COUNT(DISTINCT IF(event_type = 'payment_info', user_id, NULL))   AS stage_4_payment,
  COUNT(DISTINCT IF(event_type = 'purchase', user_id, NULL))       AS stage_5_purchase
FROM base
WHERE DATE(event_date) >= DATE_SUB(max_date, INTERVAL 30 DAY)
)

--Calculating the conversion Rates
SELECT
  stage_1_views,
  stage_2_cart,
  ROUND(stage_2_cart * 100.0 / stage_1_views, 2) AS view_to_cart_rate,

  stage_3_checkout,
  ROUND(stage_3_checkout * 100.0 / stage_2_cart, 2) AS cart_to_checkout_rate,

  stage_4_payment,
  ROUND(stage_4_payment * 100.0 / stage_3_checkout, 2) AS checkout_to_payment_rate,

  stage_5_purchase,
  ROUND(stage_5_purchase * 100.0 / stage_4_payment, 2) AS payment_to_purchase_rate,

  ROUND(stage_5_purchase * 100.0 / stage_1_views, 2) AS overall_conversion_rate


FROM funnel;

--Analyzing marketing channel
--source of the traffic
--funnel by source
WITH base AS (
  SELECT
    *,
    MAX(DATE(event_date)) OVER () AS max_date
  FROM `sales-493322.sql_sales.TB1`
),

source_funnel AS (
  SELECT
    traffic_source,

    COUNT(DISTINCT IF(event_type = 'page_view', user_id, NULL))   AS views,
    COUNT(DISTINCT IF(event_type = 'add_to_cart', user_id, NULL)) AS cart,
    COUNT(DISTINCT IF(event_type = 'purchase', user_id, NULL))    AS purchases

  FROM base
  WHERE DATE(event_date) >= DATE_SUB(max_date, INTERVAL 30 DAY)
  GROUP BY traffic_source
)

SELECT *
FROM source_funnel
ORDER BY purchases DESC;

--Traffic source Conversions
WITH base AS (
  SELECT
    *,
    MAX(DATE(event_date)) OVER () AS max_date
  FROM `sales-493322.sql_sales.TB1`
),

source_funnel AS (
  SELECT
    traffic_source,

    COUNT(DISTINCT IF(event_type = 'page_view', user_id, NULL))   AS views,
    COUNT(DISTINCT IF(event_type = 'add_to_cart', user_id, NULL)) AS cart,
    COUNT(DISTINCT IF(event_type = 'purchase', user_id, NULL))    AS purchases

  FROM base
  WHERE DATE(event_date) >= DATE_SUB(max_date, INTERVAL 30 DAY)
  GROUP BY traffic_source
)

SELECT
  traffic_source,
  views,
  cart,
  purchases,

  ROUND(100 * cart / NULLIF(views, 0), 0) AS view_to_cart_rate,
  ROUND(100 * purchases / NULLIF(cart, 0), 0) AS cart_to_purchase_rate,
  ROUND(100 * purchases / NULLIF(views, 0), 0) AS view_to_purchase_rate

FROM source_funnel
ORDER BY view_to_purchase_rate DESC;

--time to convesion analysis
WITH base AS (
  SELECT *
  FROM `sales-493322.sql_sales.TB1`
),

max_date AS (
  SELECT MAX(DATE(event_date)) AS max_d
  FROM base
),

user_journey AS (
  SELECT
    user_id,
    MIN(IF(event_type = 'page_view', event_date, NULL)) AS view_time,
    MIN(IF(event_type = 'add_to_cart', event_date, NULL)) AS cart_time,
    MIN(IF(event_type = 'purchase', event_date, NULL)) AS purchase_time
  FROM base
  GROUP BY user_id
)

SELECT * FROM user_journey, max_date
WHERE DATE(view_time) >= DATE_SUB(max_d, INTERVAL 30 DAY);

WITH base AS (
  SELECT *
  FROM `sales-493322.sql_sales.TB1`
),

user_journey AS (
  SELECT
    user_id,
    MIN(IF(event_type = 'page_view', event_date, NULL)) AS view_time,
    MIN(IF(event_type = 'add_to_cart', event_date, NULL)) AS cart_time,
    MIN(IF(event_type = 'purchase', event_date, NULL)) AS purchase_time
  FROM base
  GROUP BY user_id
)

SELECT
  user_id,
  view_time,
  cart_time,
  purchase_time,

  TIMESTAMP_DIFF(cart_time, view_time, MINUTE) AS view_to_cart_mins,
  TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE) AS cart_to_purchase_mins,
  TIMESTAMP_DIFF(purchase_time, view_time, MINUTE) AS view_to_purchase_mins

FROM user_journey
WHERE view_time IS NOT NULL
  AND cart_time IS NOT NULL
  AND purchase_time IS NOT NULL;


WITH base AS (
  SELECT *
  FROM `sales-493322.sql_sales.TB1`
),

user_journey AS (
  SELECT
    user_id,

    ARRAY_AGG(IF(event_type = 'page_view', event_date, NULL) IGNORE NULLS ORDER BY event_date LIMIT 1)[OFFSET(0)] AS view_time,

    ARRAY_AGG(IF(event_type = 'add_to_cart', event_date, NULL) IGNORE NULLS ORDER BY event_date LIMIT 1)[OFFSET(0)] AS cart_time,

    ARRAY_AGG(IF(event_type = 'purchase', event_date, NULL) IGNORE NULLS ORDER BY event_date LIMIT 1)[OFFSET(0)] AS purchase_time

  FROM base
  GROUP BY user_id
)

SELECT
  COUNT(*) AS converted_users,

  AVG(TIMESTAMP_DIFF(cart_time, view_time, MINUTE)) AS avg_view_to_cart_minutes,
  AVG(TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE)) AS avg_cart_to_purchase_minutes,
  AVG(TIMESTAMP_DIFF(purchase_time, view_time, MINUTE)) AS avg_total_journey_minutes

FROM user_journey
WHERE view_time IS NOT NULL
  AND cart_time IS NOT NULL
  AND purchase_time IS NOT NULL;

--Revenue funnel Analysis

WITH funnel_revenue AS (

  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,

    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,

    SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue,

    COUNTIF(event_type = 'purchase') AS total_orders

  FROM `sales-493322.sql_sales.TB1`

)

SELECT
  total_visitors,
  total_buyers,
  total_orders,
  total_revenue,

  SAFE_DIVIDE(total_revenue, total_orders) AS avg_order_value,
  SAFE_DIVIDE(total_revenue, total_buyers) AS revenue_per_buyer,
  SAFE_DIVIDE(total_revenue, total_visitors) AS revenue_per_visitor

FROM funnel_revenue;

--END OF PROJECT