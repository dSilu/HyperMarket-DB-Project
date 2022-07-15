DROP DATABASE IF EXISTS HyperMarket;

CREATE DATABASE HyperMarket;


CREATE TABLE HyperMarket.stores
(
	store_id VARCHAR(5) PRIMARY KEY,
    store_name VARCHAR(101) NOT NULL,
    phone INT CHECK (LENGTH(phone)=14) NOT NULL,
    email VARCHAR(50) NOT NULL,
    street VARCHAR(101) NOT NULL,
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    pin INT CHECK (LENGTH(pin)=6)
);

CREATE TABLE HyperMarket.staffs
(
	staff_id VARCHAR(8) PRIMARY KEY,
    first_name VARCHAR(101) NOT NULL,
    last_name VARCHAR(101) NOT NULL,
    phone INT CHECK (LENGTH(phone)=6) NOT NULL,
    email VARCHAR(60) NOT NULL,
    store_id VARCHAR(5) NOT NULL,
    manager_id VARCHAR(8),
    FOREIGN KEY (store_id) REFERENCES HyperMarket.stores(store_id),
    FOREIGN KEY (manager_id) REFERENCES HyperMarket.staffs(staff_id)
);


CREATE TABLE HyperMarket.customers
(
	customer_id VARCHAR(14) PRIMARY KEY,
    first_name VARCHAR(101) NOT NULL,
    second_name VARCHAR(101) NOT NULL,
    phone INT CHECK (LENGTH(phone)=6) NOT NULL,
    email VARCHAR(70),
    street VARCHAR(101) NOT NULL,
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    pin INT CHECK (LENGTH(pin)=6) NOT NULL
);

CREATE TABLE HyperMarket.orders
(
	order_id VARCHAR(15) PRIMARY KEY,
    customer_id VARCHAR(14) NOT NULL,
    order_date DATE NOT NULL,
    store_id VARCHAR(5) NOT NULL,
    staff_id VARCHAR(8) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES HyperMarket.customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES HyperMarket.stores(store_id),
    FOREIGN KEY (staff_id) REFERENCES HyperMarket.staffs(staff_id)
);

CREATE TABLE HyperMarket.categories
(
	category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL
);


CREATE TABLE HyperMarket.brands
(
	brand_id INT AUTO_INCREMENT PRIMARY KEY,
    brand_name VARCHAR(255) NOT NULL
);

CREATE TABLE HyperMarket.products
(
	product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL,
    brand_id INT,
    mfg DATE,
    exp DATE,
    FOREIGN KEY (category_id) REFERENCES HyperMarket.categories(category_id),
    FOREIGN KEY (brand_id) REFERENCES HyperMarket.brands(brand_id)
);


CREATE TABLE HyperMarket.stocks
(
	store_id VARCHAR(5) NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    quantity FLOAT,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES HyperMarket.stores(store_id)
);


CREATE TABLE HyperMarket.cart
(
	item_id INT AUTO_INCREMENT,
	order_id VARCHAR(15) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    quantity FLOAT NOT NULL,
    list_price FLOAT NOT NULL,
    discount INT,
    PRIMARY KEY (item_id, order_id),
    FOREIGN KEY (order_id) REFERENCES HyperMarket.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES HyperMarket.products(product_id)
);