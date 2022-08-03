/*
Basic Queries
*/
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
            LEFT JOIN
        HyperMarket.orders od ON ot.outlet_id = od.outlet_id
            LEFT JOIN
        HyperMarket.cart c1 ON od.order_id = c1.order_id
            RIGHT JOIN
        HyperMarket.products p ON c1.product_id = p.product_id
            LEFT JOIN
        HyperMarket.brands b ON p.brand_id = b.brand_id
            LEFT JOIN
        HyperMarket.categories c2 ON p.category_id = c2.category_id;

-- call details view
SELECT 
    *
FROM
    HyperMarket.details;

-- We can drop the view as
DROP VIEW HyperMarket.details;
