USE retail_business_intelligence;

-- INDEXES FOR PERFORMANCE OPTIMIZATION 

-- Orders
CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_orders_purchase_date
ON orders(order_purchase_timestamp);

-- Order Items
CREATE INDEX idx_orderitems_product
ON order_items(product_id);

CREATE INDEX idx_ordertimes_seller
ON order_items(seller_id);

-- Payments 
CREATE INDEX idx_payments_type
ON payments(payment_type);

-- Reviews
CREATE INDEX idx_reviews_score
ON reviews(review_score);

-- Customers
CREATE INDEX idx_customers_state
ON customers(customer_state);

-- Sellers
CREATE INDEX idx_sellers_state
ON sellers(seller_state);

-- Products
CREATE INDEX idx_products_category
ON products(product_category_name);

-- Geolocation
CREATE INDEX idx_geo_state
ON geolocation(geolocation_state);

CREATE INDEX idx_geo_city
ON geolocation(geolocation_city);


