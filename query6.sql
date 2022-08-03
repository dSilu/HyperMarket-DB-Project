/*
Total sells in outlets
*/

-- Total number of sells in each outlet till date
SELECT 
    city, COUNT(outlet_id) num_sells
FROM
    HyperMarket.details d
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM HyperMarket.details;


-- Total price of sells in each outlet till date
SELECT 
	o.city, 
    o.outlet_id, 
    Round(SUM(d.quantity * d.price),2) AS amount
FROM 
	HyperMarket.details d
	JOIN 
	HyperMarket.outlets o USING (outlet_id)
GROUP BY 2
ORDER BY 3 DESC;


# Total sales in a year in an outlet
DELIMITER $$
CREATE FUNCTION HyperMarket.year_sell(outlet VARCHAR(05), check_year INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC NO SQL READS SQL DATA
BEGIN
	DECLARE sells DECIMAL(10,2);
    
    SELECT sum(quantity * price) INTO sells
    FROM HyperMarket.details
    WHERE outlet_id = outlet AND year(order_date) = check_year;
    
    RETURN sells;
END$$
DELIMITER ;

SELECT HyperMarket.year_sell('ST01', 2022) AS 'sells in Chennai, 2022';

DESC HyperMarket.outlets;

-- Month wise sells
DELIMITER $$
CREATE PROCEDURE HyperMarket.month_wise_sells(IN outlet_id VARCHAR(5), IN check_year INT)
DETERMINISTIC
BEGIN
	SELECT 
		MONTH(order_date) month,
		ROUND(SUM(quantity * price), 2) sells
	FROM
		HyperMarket.details
	WHERE
		outlet_id = outlet_id
			AND YEAR(order_date) = check_year
	GROUP BY 1
	ORDER BY 1 ASC;
END$$
DELIMITER ;

CALL HyperMarket.month_wise_sells('ST01', 2022);

DROP procedure HyperMarket.month_wise_sells;


-- Which day of the week, customers tend to go shopping?
SELECT 
	DAYNAME(order_date) AS day_of_week,
	COUNT(order_id) AS sales
FROM HyperMarket.orders
GROUP BY 1
ORDER BY sales DESC;

