/*==============================================================
  OLIST E-COMMERCE ANALYSIS
  FILE: 01_Database_Setup.sql
  PURPOSE: Database constraints and structural setup.

  NOTE:
  - Run these statements only after the data has been imported
    and the required NULL/duplicate checks have passed.
  - If a constraint already exists, do not run it again.
==============================================================*/

/*==============================================================
  1. PRIMARY KEYS
==============================================================*/

-- Orders: one row per order.
ALTER TABLE orders
ALTER COLUMN order_id NVARCHAR(50) NOT NULL;

ALTER TABLE orders
ADD PRIMARY KEY (order_id);

-- Sellers: one row per seller.
ALTER TABLE sellers
ALTER COLUMN seller_id NVARCHAR(50) NOT NULL;

ALTER TABLE sellers
ADD PRIMARY KEY (seller_id);

/*==============================================================
  2. FOREIGN KEYS
==============================================================*/

-- Orders -> Customers
ALTER TABLE orders
ADD FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

-- Order Items -> Orders
ALTER TABLE order_items
ALTER COLUMN order_id NVARCHAR(50) NOT NULL;

ALTER TABLE order_items
ADD FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- Order Items -> Products
ALTER TABLE order_items
ALTER COLUMN product_id NVARCHAR(50) NOT NULL;

ALTER TABLE order_items
ADD FOREIGN KEY (product_id)
REFERENCES products(product_id);

-- Order Items -> Sellers
ALTER TABLE order_items
ALTER COLUMN seller_id NVARCHAR(50) NOT NULL;

ALTER TABLE order_items
ADD FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id);

-- Payments -> Orders
ALTER TABLE order_payments
ADD FOREIGN KEY (order_id)
REFERENCES orders(order_id);

-- Reviews -> Orders
ALTER TABLE order_reviews
ADD FOREIGN KEY (order_id)
REFERENCES orders(order_id);
