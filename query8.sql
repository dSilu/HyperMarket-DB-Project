-- customer retention rate
WITH monthly_customer_count AS 
(
	SELECT 
		DISTINCT MONTH(order_date) as order_month,
		customer_id
    FROM HyperMarket.orders
)
SELECT
	P.order_month,
	COUNT(DISTINCT T.customer_id)/GREATEST(COUNT(DISTINCT P.customer_id),1) retention
FROM monthly_customer_count P -- previous month
LEFT JOIN monthly_customer_count T -- This month
	ON P.customer_id = T.customer_id
	AND P.order_month = (T.order_month - INTERVAL 1 month)
GROUP BY 1;