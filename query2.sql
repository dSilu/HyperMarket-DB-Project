
/*
Best selling products:
Ther are two types of best selling products: 
i.e. price wise (sells wise), quantity wise

We are going to check top 3 products from each outlet
*/

-- Top selling products in 'Chennai and Bengaluru' quantity wise
SELECT 
    o.city, 
    p.product_name, 
    SUM(d.quantity) total_sold
FROM
    HyperMarket.details d
        JOIN
    HyperMarket.products p USING (product_id)
        JOIN
    HyperMarket.outlets o USING (outlet_id)
WHERE
    o.city IN ('Chennai' , 'Bengaluru')
GROUP BY 1 , 2
ORDER BY 3 DESC
LIMIT 10;

-- Top selling products in 'Chennai and Bengaluru' price wise
SELECT 
    o.city,
    p.product_name,
    ROUND(SUM(d.price * d.quantity), 2) price
FROM
    HyperMarket.details d
        JOIN
    HyperMarket.products p USING (product_id)
        JOIN
    HyperMarket.outlets o USING (outlet_id)
WHERE
    o.city IN ('Bengaluru' , 'Chennai')
GROUP BY 1 , 2
ORDER BY price DESC
LIMIT 10;

-- Top3 products from each outlet price wise
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


-- With Window function
WITH at_outlet AS 
# Find price of products and group the products based on city and product name
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
