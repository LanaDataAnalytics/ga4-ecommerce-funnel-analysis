WITH CleanedData AS (
 
  SELECT
    event_name,
    device.category AS device_category,

    CONCAT(
      user_pseudo_id, 
      '-', 
      (SELECT CAST(value.int_value AS STRING) FROM UNNEST(event_params) WHERE key = 'ga_session_id')
    ) AS unique_session_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE

    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'

    AND event_name IN (
      'view_item', 'add_to_cart', 'begin_checkout', 
      'add_shipping_info', 'add_payment_info', 'purchase'
    )
   
    AND user_pseudo_id IS NOT NULL
),

FunnelSteps AS (

  SELECT
    CASE
      WHEN event_name = 'view_item' THEN 1
      WHEN event_name = 'add_to_cart' THEN 2
      WHEN event_name = 'begin_checkout' THEN 3
      WHEN event_name = 'add_shipping_info' THEN 4
      WHEN event_name = 'add_payment_info' THEN 5
      WHEN event_name = 'purchase' THEN 6
    END AS step_number,
    event_name,
    device_category,
  
    COUNT(DISTINCT unique_session_id) AS unique_sessions
  FROM
    CleanedData
  GROUP BY
    1, 2, 3
)

SELECT
  device_category,
  step_number,
  event_name,
  unique_sessions,

  ROUND(unique_sessions / LAG(unique_sessions) OVER(PARTITION BY device_category ORDER BY step_number) * 100, 2) AS step_conversion_pct
FROM
  FunnelSteps
ORDER BY
  device_category, 
  step_number;