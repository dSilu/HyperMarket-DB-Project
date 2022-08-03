# Clustering customers

-- customer segment view
CREATE VIEW HyperMarket.customer_segment AS 
(	SELECT c.customer_id,
		ROUND(SUM(d.price * d.quantity),2) monthly_shopping,
		CASE
			WHEN SUM(d.price * d.quantity) > 50000 THEN 'Platinum'
			WHEN SUM(d.price * d.quantity) > 20000 THEN 'Gold'
			WHEN SUM(d.price * d.quantity) > 10000 THEN 'Silver'
			ELSE 'Casual'
		END 'customer_category'
	FROM HyperMarket.details d
	RIGHT JOIN HyperMarket.customers c 
	ON d.customer_id = c.customer_id
    WHERE MONTH(d.order_date) = (
								SELECT 
									MAX(MONTH(order_date)) 
                                FROM 
									HyperMarket.details)
	GROUP BY c.customer_id 
);

SELECT * FROM HyperMarket.customer_segment;

-- DROP VIEW HyperMarket.customer_segment;

-- Create a procedure to check of any month in any year
DELIMITER $$
CREATE PROCEDURE HyperMarket.customer_segments (IN relevant_year INT)
DETERMINISTIC NO SQL
BEGIN
	SELECT c.customer_id,
		ROUND(SUM(d.price * d.quantity),2) monthly_shopping,
		CASE
			WHEN SUM(d.price * d.quantity) > 50000 THEN 'Platinum'
			WHEN SUM(d.price * d.quantity) > 20000 THEN 'Gold'
			WHEN SUM(d.price * d.quantity) > 10000 THEN 'Silver'
			ELSE 'Casual'
		END 'customer_category'
	FROM HyperMarket.details d
	RIGHT JOIN HyperMarket.customers c 
	ON d.customer_id = c.customer_id
	WHERE MONTH(d.order_date) = (SELECT 
									MAX(MONTH(order_date)) 
								FROM HyperMarket.orders 
                                WHERE 
									YEAR(order_date)=relevant_year)
	GROUP BY c.customer_id ;
END$$
DELIMITER ;



