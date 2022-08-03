

/*
Low Stock alert Mechanism
*/

-- VIEW to calculate low stock
CREATE VIEW HyperMarket.stock_info AS
(
	SELECT
		outlet_id,
        product_id,
        quantity,
        CASE
			WHEN quantity <115 THEN 'Low Stock'
            ELSE 'Stocks Sufficient'
            END AS stock_status
	FROM HyperMarket.stocks);

SELECT * FROM HyperMarket.stock_info;
DROP VIEW HyperMarket.stock_info;


DELIMITER $$
CREATE PROCEDURE HyperMarket.low_stock_info() 
BEGIN 
	SELECT 
		outlet_id, 
        COUNT(product_id) num_products
        # will calculate low total number of products
	FROM HyperMarket.stock_info
    WHERE 
		LOWER(stock_status) = 'low stock'
    GROUP BY 1; 
END$$ 
DELIMITER ;

CALL HyperMarket.low_stock_info();

DROP PROCEDURE HyperMarket.low_stock_info;

