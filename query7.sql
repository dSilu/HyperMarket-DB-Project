
/*
Month on month Growth rate
*/
WITH monthly_active_users AS
(
	SELECT 
		MONTH(order_date) AS month,
		COUNT(DISTINCT customer_id) AS no_customers
	FROM HyperMarket.orders
    WHERE YEAR(order_date) = 2022
    GROUP BY 1
),
MoM AS
(
	SELECT 
		month, 
        no_customers, 
        GREATEST(LAG(no_customers) OVER (ORDER BY month ASC),1) AS last_mo
    FROM monthly_active_users
)
SELECT 
	month, 
    no_customers, ROUND((no_customers-last_mo)/last_mo,2) AS growth
FROM MoM
ORDER BY month;

