use hypermarket;
select * from categories;
insert into categories values
(1,'Fresh Fruits'),
(2, 'Provisions'),
(3, 'Breakfast & Dairy'),
(4, 'Fresh Vegetables & Herbs'),
(5, 'Snacks & Beverages'),
(6, 'Instant Foods'),
(7, 'Chocolates & Desserts'),
(8, 'Personal Care'),
(9, 'Home Care'),
(11, 'Pet Foods');

DELETE FROM categories WHERE category_id = 10;

select * from categories ;