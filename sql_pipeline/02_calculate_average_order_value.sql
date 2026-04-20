SELECT
  ROUND(SUM(ecommerce.purchase_revenue) / COUNT(DISTINCT ecommerce.transaction_id), 2) AS average_order_value
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND event_name = 'purchase'
  AND ecommerce.purchase_revenue IS NOT NULL;