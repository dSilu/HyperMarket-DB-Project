/* BASIC QUERIES*/

-- 1. Check tables
SHOW tables FROM HyperMarket;

-- 2. Total number of records in each table
SELECT 
    TABLE_NAME, TABLE_ROWS
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA = 'HyperMarket';

/*
To find details about a product or a order we have to join 3 to 4 tables to get the desired outputs.
This becomes time consuming when it comes to a busy day. To elevate this issue we can save the data of a complex join
to a view table. Which we can use any day any time in a local machine. 

Views are handy because 
i. Similar to table but does not use physical memory.
ii. Simplifies complex queries like joins
iii. Access control.
iv. Ease of creation and management.alter
v. Works like a deep copy of tables.alter

For this reasons we will create a view with all the necessary fields in it, which will reduce the cost of complex joins every time we try to find something.
*/

-- 3. Create details view
CREATE VIEW HyperMarket.details AS
    SELECT 
        od.outlet_id,
        ot.city,
        od.order_id,
        od.order_date,
        od.customer_id,
        c1.product_id,
        c1.quantity,
        b.brand_id,
        p.category_id,
        p.price
    FROM
        HyperMarket.outlets ot
            INNER JOIN
        HyperMarket.orders od ON ot.outlet_id = od.outlet_id
            INNER JOIN
        HyperMarket.cart c1 ON od.order_id = c1.order_id
            INNER JOIN
        HyperMarket.products p ON c1.product_id = p.product_id
            INNER JOIN
        HyperMarket.brands b ON p.brand_id = b.brand_id
            INNER JOIN
        HyperMarket.categories c2 ON p.category_id = c2.category_id;

-- call details view
SELECT 
    *
FROM
    HyperMarket.details;

-- We can drop the view as
# DROP VIEW HyperMarket.details;


/*Use the details view for further analysis*/

-- 4. As the added dataset is a dummy dataset, there are some order_ids with no orders. Let's find out
SELECT 
    COUNT(*)
FROM
    (SELECT 
        o.order_id, d.customer_id
    FROM
        HyperMarket.orders o
    LEFT JOIN HyperMarket.details d ON o.order_id = d.order_id
    WHERE
        d.customer_id IS NULL) T;

-- 5. Find out expired products
SELECT 
    product_id, 
    product_name, 
    mfg, exp 		# Using * is slower 
FROM
    HyperMarket.products
WHERE
    exp < DATE(NOW());
    
-- Stored procedure
DELIMITER $$
CREATE PROCEDURE HyperMarket.find_expired_products(IN check_date DATE)
DETERMINISTIC NO SQL READS SQL DATA
BEGIN
	SELECT 
		product_id,
        product_name,
        mfg,
        exp 
	FROM 
		HyperMarket.products
	WHERE
		exp < check_date;
END $$

CALL HyperMarket.find_expired_products('2022-10-01');


-- 6. Number of sells at each outlet
SELECT outlet_id, COUNT(outlet_id) as num_sells
FROM HyperMarket.details
GROUP BY outlet_id
ORDER BY num_sells DESC;

/*
Best selling products:
Ther are two types of best selling products: 
i.e. price wise (sells wise), quantity wise

We are going to check top 3 products from each outlet
*/
SELECT city from HyperMarket.outlets where outlet_id = 'ST02';

-- 7.a. Best selling products: Top3 products from each outlet price wise
WITH Chennai_outlet AS 
	(SELECT 
		d.product_id, 
        p.product_name, 
        ROUND(sum(d.price * d.quantity),2) AS price 
	FROM HyperMarket.details d 
    JOIN HyperMarket.products p 
		USING (product_id) 
	WHERE d.outlet_id = 'ST01' 
    GROUP BY 1 
    ORDER BY 3 DESC 
    LIMIT 3),
Hyderabad_outlet AS 
	(SELECT 
		d.product_id, 
        p.product_name, 
        ROUND(sum(d.price * d.quantity),2) AS price 
	FROM HyperMarket.details d 
    JOIN HyperMarket.products p 
		USING (product_id) 
    WHERE d.outlet_id = 'ST02' 
    GROUP BY 1 
    ORDER BY 3 DESC 
    LIMIT 3),
Bengaluru_outlet AS 
	(SELECT 
		d.product_id, 
        p.product_name, 
        ROUND(sum(d.price * d.quantity),2) AS price 
	FROM HyperMarket.details d 
    JOIN HyperMarket.products p 
		USING (product_id) 
	WHERE d.outlet_id = 'ST03' 
    GROUP BY 1 
    ORDER BY 3 DESC 
    LIMIT 3),
Pune_outlet AS 
	(SELECT 
		d.product_id, 
        p.product_name, 
        ROUND(sum(d.price * d.quantity),2) AS price 
	FROM HyperMarket.details d 
    JOIN HyperMarket.products p 
		USING (product_id) 
	WHERE d.outlet_id = 'ST04' 
    GROUP BY 1 
    ORDER BY 3 DESC 
    LIMIT 3)
SELECT * FROM Chennai_outlet
UNION
SELECT * FROM Hyderabad_outlet
UNION
SELECT * FROM Bengaluru_outlet
UNION
SELECT * FROM Pune_outlet;

-- The above query is too long to write, we can use window function

-- OR
WITH product_price AS  # Find price for each product of each order
(
	SELECT 
		order_id, 
        product_name, 
        quantity * price AS price 
	FROM 
		HyperMarket.details
	JOIN HyperMarket.products 
		USING (product_id)
),
at_outlet AS # Find price of products and roup the products based on city and product name
(
	SELECT 
		o.city, 
        p.product_name, 
        SUM(d.quantity * d.price) as total
	FROM 
		HyperMarket.details d
		JOIN HyperMarket.outlets o 
			USING (outlet_id)
		JOIN HyperMarket.products p 
			USING (product_id)
	GROUP BY 1,2
),
product_ranking AS  # Rank the products and find top 3 products of each city.
(	SELECT 
		city, 
		product_name, 
		total, 
		RANK() OVER (PARTITION BY city ORDER BY total DESC) rn
	FROM at_outlet
)
SELECT 
	city, 
	product_name AS product, 
    ROUND(total,2) AS total_sales
FROM product_ranking
WHERE rn <= 3;

-- Top selling products in 'Chennai and Bengaluru'
SELECT o.city, p.product_name, SUM(d.quantity) total_sold
FROM HyperMarket.details d
JOIN HyperMarket.products p USING (product_id)
JOIN HyperMarket.outlets o USING (outlet_id)
WHERE o.city in ('Chennai', 'Bengaluru')
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

-- Make a bill of every product with customer name
SELECT 
    d.customer_id,
    CONCAT_WS(' ', c.first_name, c.last_name) AS name,
    d.order_id,
    ROUND(SUM(d.quantity * d.price), 2) order_price,
    d.order_date,
    c.phone
FROM
    HyperMarket.details d
        JOIN
    HyperMarket.customers c ON c.customer_id = d.customer_id
GROUP BY d.order_id;


/*
Least Selling products in Hyderabad and Pune
*/
SELECT o.city, p.product_name, SUM(d.price * d.quantity) price
FROM HyperMarket.details d
JOIN HyperMarket.products p USING (product_id)
JOIN HyperMarket.outlets o USING (outlet_id)
WHERE o.city in ('Hyderabad','Pune')
GROUP BY 1,2
ORDER BY price ASC
LIMIT 10;

-- Quantity wise
SELECT o.city, p.product_name, SUM(d.quantity) total_sold
FROM HyperMarket.details d
JOIN HyperMarket.products p USING (product_id)
JOIN HyperMarket.outlets o USING (outlet_id)
WHERE o.city in ('Hyderabad', 'Pune')
GROUP BY 1,2
ORDER BY 3 ASC
LIMIT 10;

SELECT 
    c1.category_name,
    ROUND(SUM(c2.quantity * p.price), 2) AS total_price
FROM
    HyperMarket.categories c1
        RIGHT JOIN
    HyperMarket.products p ON c1.category_id = p.category_id
        RIGHT JOIN
    HyperMarket.cart c2 ON p.product_id = c2.product_id
GROUP BY c1.category_id
ORDER BY total_price DESC
LIMIT 3;



-- But we can't relay on limit as two categories can have same selling price for a month
WITH top_categories AS (
	SELECT 
		c1.category_name, 
		ROUND(SUM(c2.quantity * p.price),2) AS total_price
	FROM HyperMarket.categories c1
	RIGHT JOIN HyperMarket.products p 
		ON c1.category_id = p.category_id
	RIGHT JOIN HyperMarket.cart c2 
		ON p.product_id = c2.product_id
	GROUP BY c1.category_id)
SELECT 
	t1.category_name, 
    t1.total_price
FROM top_categories t1
JOIN (
	SELECT DISTINCT total_price 
    FROM top_categories LIMIT 3) t2
ON t1.total_price = t2.total_price
ORDER BY t1.total_price DESC;

DESCRIBE HyperMarket.outlets;

DROP FUNCTION HyperMarket.year_sell;
-- Check tables
SHOW tables FROM HyperMarket;

-- Total number of records in each table
SELECT TABLE_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'HyperMarket';
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

SELECT 
    MONTH(order_date) month_2022,
    ROUND(SUM(quantity * price), 2) sells
FROM
    HyperMarket.details
WHERE
    outlet_id = 'ST01'
        AND YEAR(order_date) = 2022
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date) ASC;

-- DROP Procedure HyperMarket.monthwise_sells;
-- With stored procedure
DELIMITER $$
CREATE PROCEDURE HyperMarket.monthwise_sells(IN outlet VARCHAR(5), IN check_year INT, OUT month INT,  OUT total_sells DECIMAL(10,2))
DETERMINISTIC NO SQL
BEGIN
	SELECT T.month, T.total_sells
    FROM (SELECT
		Month(order_date) month, 
		ROUND(SUM(quantity * price),2) AS total_sells
	FROM HyperMarket.details
    WHERE
		outlet_id = outlet AND year(order_date) = check_year
	GROUP BY month(order_date)
    ORDER BY month(order_date) ASC) T;
END$$
DELIMITER ;

CALL HyperMarket.monthwise_sells('ST02', 2022, @month, @sells);

SELECT 
    outlet_id, city, ROUND(SUM(price * quantity), 2) total_sells
FROM
    HyperMarket.details
GROUP BY outlet_id
ORDER BY total_sells DESC
LIMIT 1;

SELECT 
    outlet_id, city, COUNT(customer_id) num_customers
FROM
    HyperMarket.details
WHERE
    outlet_id IS NOT NULL
GROUP BY outlet_id
ORDER BY num_customers DESC;

-- Checking duplicates in details view
SELECT 
    COUNT(*)
FROM
    HyperMarket.details;
SELECT 
    COUNT(DISTINCT customer_id)
FROM
    HyperMarket.details;
SELECT 
    customer_id, COUNT(customer_id) num_visits
FROM
    HyperMarket.orders
GROUP BY customer_id
ORDER BY num_visits DESC;

DESCRIBE HyperMarket.orders;
SELECT 
    t1.customer_id,
    t1.order_date,
    t1.outlet_id f1,
    t2.customer_id,
    t2.order_date,
    t2.outlet_id f2
FROM
    HyperMarket.orders t1
        JOIN
    HyperMarket.orders t2 ON t1.customer_id = t2.customer_id
WHERE
    t1.outlet_id != t2.outlet_id
        AND t1.order_date = t2.order_date;


# Clustering customers
DELIMITER $$
CREATE PROCEDURE HyperMarket.customer_segments (IN relevant_year INT)
DETERMINISTIC NO SQL
BEGIN
	SELECT c.customer_id,
		ROUND(SUM(d.price * d.quantity),2) monthly_shopping,
		CASE
			WHEN SUM(d.price * d.quantity) > 50000 THEN 'Prime'
			WHEN SUM(d.price * d.quantity) > 20000 THEN 'Gold'
			WHEN SUM(d.price * d.quantity) > 10000 THEN 'Silver'
			ELSE 'Casual'
		END 'customer_category'
	FROM HyperMarket.details d
	RIGHT JOIN HyperMarket.customers c 
	ON d.customer_id = c.customer_id
	WHERE MONTH(d.order_date) = (SELECT MAX(MONTH(order_date)) FROM HyperMarket.orders WHERE YEAR(order_date)=relevant_year)
	GROUP BY c.customer_id ;
END$$
DELIMITER ;



SELECT * FROM HyperMarket.customers ORDER BY first_name DESC LIMIT 10;

DESC HyperMarket.orders;
# total price of an order in cart
describe HyperMarket.outlets;
describe HyperMarket.orders;

DROP PROCEDURE HyperMarket.cart_price;

-- Calculate cart price
DELIMITER $$
CREATE PROCEDURE HyperMarket.cart_price(IN current_cart VARCHAR(15))
DETERMINISTIC
BEGIN

	SELECT
		d.outlet_id OutletNo,
		c.customer_id CustomerId, 
        CONCAT(c.first_name, ' ', c.last_name) CustomerName, 
        d.order_id OrderId,
        d.order_date,
        ROUND(SUM(d.quantity * d.price),2) AS 'Total Amount',
        CASE
			WHEN SUM(d.quantity * d.price) > 35000 THEN '25%'
            WHEN SUM(d.quantity * d.price) > 15000 THEN '20%'
            WHEN SUM(d.quantity * d.price) > 10000 THEN '15%'
            WHEN SUM(d.quantity * d.price) > 5000 THEN '12%'
            WHEN SUM(d.quantity * d.price) > 2000 THEN '8%'
            WHEN SUM(d.quantity * d.price) > 1000 THEN '5%'
            ELSE '--'
		END AS `Discount`,
        CASE
			WHEN SUM(d.quantity * d.price) > 35000 THEN ROUND(SUM(d.quantity * d.price) - (SUM(d.quantity * d.price) * 25/100),2)
            WHEN SUM(d.quantity * d.price) > 15000 THEN ROUND(SUM(d.quantity * d.price) - (SUM(d.quantity * d.price) * 20/100),2)
            WHEN SUM(d.quantity * d.price) > 10000 THEN ROUND(SUM(d.quantity * d.price) - (SUM(d.quantity * d.price) * 15/100),2)
            WHEN SUM(d.quantity * d.price) > 5000 THEN ROUND(SUM(d.quantity * d.price) - (SUM(d.quantity * d.price) * 12/100),2)
            WHEN SUM(d.quantity * d.price) > 2000 THEN ROUND(SUM(d.quantity * d.price) - (SUM(d.quantity * d.price) * 8/100),2)
            WHEN SUM(d.quantity * d.price) > 1000 THEN ROUND(SUM(d.quantity * d.price) - (SUM(d.quantity * d.price) * 5/100),2)
			ELSE ROUND(SUM(d.quantity * d.price),2)
		END AS 'Payble Amount',
        c.city,
        c.phone
    FROM HyperMarket.details d
    JOIN HyperMarket.customers c 
    ON d.customer_id = c.customer_id
    WHERE d.order_id = current_cart
    GROUP BY d.order_id;
    
END $$
DELIMITER ;

call HyperMarket.cart_price('tx-2997');

SELECT order_id FROM HyperMarket.details ORDER BY order_id DESC;


-- Which day of the week, customers tend to go shopping?
SELECT DAYOFWEEK(order_date) AS day_of_week,
	COUNT(order_id) AS sales
FROM HyperMarket.orders
GROUP BY 1
ORDER BY sales DESC;




-- MOM customer growth?
/*
Month on month growth formula = 
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
SELECT month, no_customers, ROUND((no_customers-last_mo)/last_mo,2) AS growth
FROM MoM
ORDER BY month;

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


SELECT customer_id, order_id, order_date FROM HyperMarket.details;