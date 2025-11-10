-- Create database
CREATE DATABASE IF NOT EXISTS office_supplies;
USE office_supplies;

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    stock INT NOT NULL,
    colors JSON,
    sizes JSON,
    image VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255) NOT NULL,
    order_date DATETIME NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL
);

-- Create order_details table
CREATE TABLE IF NOT EXISTS order_details (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert sample products
INSERT INTO products (name, category, stock, colors, sizes, image, price) VALUES
('Ballpoint Pens (Pack of 50)', 'Writing Supplies', 150, '["Blue", "Black", "Red"]', NULL, '/ballpoint-pens-pack.jpg', 12.99),
('A4 Notebook', 'Notebooks', 200, '["White", "Cream"]', '["Small", "Medium", "Large"]', '/a4-notebook.jpg', 5.99),
('LED Desk Lamp', 'Lighting', 45, '["Silver", "Black"]', '["10 inch", "12 inch", "14 inch"]', '/led-desk-lamp.png', 29.99),
('Paper Clips (Box of 100)', 'Fasteners', 320, '["Silver"]', NULL, '/paper-clips-box.jpg', 3.99),
('Sticky Notes (Colorful)', 'Office Supplies', 280, '["Yellow", "Pink", "Green", "Blue"]', '["3x3 inch", "3x5 inch"]', '/colorful-sticky-notes.png', 6.99);