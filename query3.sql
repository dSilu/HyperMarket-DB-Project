
/*
Least Selling products in Hyderabad and Pune price wise
*/
SELECT 
    o.city, 
    p.product_name, 
    SUM(d.price * d.quantity) price
FROM
    HyperMarket.details d
        JOIN
    HyperMarket.products p USING (product_id)
        JOIN
    HyperMarket.outlets o USING (outlet_id)
WHERE
    o.city IN ('Hyderabad' , 'Pune')
GROUP BY 1 , 2
ORDER BY price ASC
LIMIT 10;

-- Quantity wise
SELECT 
	o.city, 
    p.product_name, 
    SUM(d.quantity) total_sold # sum because to sum quantity not count
FROM 
	HyperMarket.details d
	JOIN 
    HyperMarket.products p USING (product_id)
	JOIN 
    HyperMarket.outlets o USING (outlet_id)
WHERE 
	o.city in ('Hyderabad', 'Pune')
GROUP BY 1,2
ORDER BY 3 ASC
LIMIT 10;

-- IF we go with limit we will miss a lot of data. 
-- So we will go with a sub query and CTE
WITH least_selling_products AS
(
SELECT 
	o.city, 
    p.product_name, 
    SUM(d.quantity) total_sold
FROM HyperMarket.details d
	JOIN 
    HyperMarket.products p USING (product_id)
	JOIN 
    HyperMarket.outlets o USING (outlet_id)
WHERE 
	o.city in ('Hyderabad', 'Pune')
GROUP BY 1,2
ORDER BY 3 ASC)
SELECT * 
FROM 
	least_selling_products 
WHERE total_sold = (
					SELECT 
						MIN(total_sold) 
                    FROM 
						least_selling_products);
                        