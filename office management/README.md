Office Management — README

Overview

This project is a lightweight office-supplies ordering web app written in PHP + MySQL with a vanilla JavaScript front-end. It provides a product listing, variant support (color/size), a shopping cart, an order submission endpoint that deducts stock, and transaction logging for admin review.

Directory structure (key files)

- `Html/` — HTML pages (legacy). Primary UI lives in `phpFile/LP.php`.
- `Css/` — Stylesheets. `style.css`, `LandingPage.css`, `Login.css`.
- `JS/ladningPage.js` — Main front-end script. Renders products, options, cart, handles selection of sizes/colors, builds order payload, posts to `phpFile/submit_order.php`.
- `phpFile/config.php` — DB connection and global headers.
- `phpFile/get_products.php` — Returns products JSON for the frontend. Includes `variants` array for each product (joined from `product_variants` and `options`).
- `phpFile/submit_order.php` — Order submission endpoint. Performs DB transaction, writes order header, order items, deducts stock (variant-level if variant_id present), and logs inventory transactions.
- `phpFile/get_transactions.php` — Returns recent inventory transactions and items (for admin UI or troubleshooting).
- `phpFile/setup_database.php` — Helper script to create/validate core tables and FKs (run in dev to initialize schema).
- `phpFile/database.sql` — Example SQL / sample data.

Database schema (important tables)

Note: run `SHOW COLUMNS FROM <table>;` and `SELECT * FROM <table> LIMIT 5;` to confirm actual column names in your environment. The code expects the following column names by default:

- `products`
  - `product_id` (INT PRIMARY KEY AUTO_INCREMENT)
  - `name` VARCHAR
  - `image` VARCHAR
  - `category_id` INT
  - `quantity` INT (product-level stock)
  - `Date` TIMESTAMP

- `product_variants`
  - `variant_id` (INT PRIMARY KEY AUTO_INCREMENT)
  - `product_id` (INT) — FK to products
  - `color_option_id` (INT) — FK to `options.option_id` (or NULL)
  - `size_option_id` (INT) — FK to `options.option_id` (or NULL)
  - `stock` INT
  - `created_at` TIMESTAMP

- `options` and `option_types` & `product_options` — store option labels and mapping of available options per product (colors/sizes)

- `orders` (used by submit flow)
  - `order_id` INT PRIMARY KEY AUTO_INCREMENT
  - `employee_name` VARCHAR
  - `department` VARCHAR
  - `status` VARCHAR
  - `created_at` TIMESTAMP

- `order_items` (per-item rows in an order)
  - `id` INT PRIMARY KEY AUTO_INCREMENT
  - `order_id` INT
  - `product_id` INT
  - `variant_id` INT NULL
  - `quantity` INT

- Inventory log tables (recommended)
  - `inventory_transactions` (id, order_id, transaction_type, created_at)
  - `inventory_transaction_items` (transaction_id, product_id, variant_id, quantity_changed, stock_after, created_at)

SQL to create missing tables (run these in phpMyAdmin or MySQL CLI)

-- orders and order_items (if missing):

CREATE TABLE IF NOT EXISTS orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  employee_name VARCHAR(255) NOT NULL,
  department VARCHAR(100) DEFAULT '',
  status VARCHAR(50) DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  variant_id INT DEFAULT NULL,
  quantity INT NOT NULL,
  INDEX (order_id),
  INDEX (product_id),
  INDEX (variant_id),
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Inventory transaction logging tables:

CREATE TABLE IF NOT EXISTS inventory_transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NULL,
  transaction_type VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS inventory_transaction_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  transaction_id INT NOT NULL,
  product_id INT NOT NULL,
  variant_id INT DEFAULT NULL,
  quantity_changed INT NOT NULL,
  stock_after INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX (product_id),
  INDEX (variant_id),
  CONSTRAINT fk_invtrans_items_trans FOREIGN KEY (transaction_id) REFERENCES inventory_transactions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

How the flow works (quick)

1. Front-end loads `phpFile/get_products.php`.
   - This endpoint returns JSON shaped like: { products: [ { id, name, image, category_id, category_name, stock, variants: [ { variant_id, color_option_id, color, size_option_id, size, stock }, ... ] } ], categories: [...] }
   - The JS uses `product.variants` to build option buttons and `stock` to display total stock.

2. User picks options (size/color) and quantity and clicks Add to Cart.
   - The JS stores cart items with variant_id (when selected) and shows in the cart UI.

3. On Submit, the JS posts order JSON to `phpFile/submit_order.php`. Example payload:
   {
     employee_name: "Alice",
     department: "HR",
     items: [ { product_id: 12, variant_id: 34, quantity: 2 }, ... ],
     total_amount: 2
   }

4. `submit_order.php` (server) does a DB transaction:
   - Inserts an `orders` row.
   - Inserts `order_items` rows for each item.
   - If an item has `variant_id` the code locks that variant row, verifies stock, decrements `product_variants.stock`, and decrements `products.quantity` as fallback.
   - If item has no variant, it locks and decrements `products.quantity`.
   - Logs movements into `inventory_transactions` and `inventory_transaction_items`.
   - On any error (missing product/variant or insufficient stock) it rolls back and returns a JSON error.

How to test locally (XAMPP)

1. Start Apache & MySQL via XAMPP control panel.
2. Create the DB and tables (use phpMyAdmin or run SQL in `phpFile/database.sql` and the CREATE statements above for missing tables).
3. Load the site (for example: http://localhost/office%20management/phpFile/LP.php).
4. Open browser devtools (F12) -> Network & Console.
5. Try adding items to the cart and Submit. Check the network response for `submit_order.php` — it should return JSON {success:true, orderId:...} on success.
6. Confirm stock was deducted:
   SELECT * FROM product_variants WHERE product_id = <id>;
   SELECT * FROM products WHERE product_id = <id>;
7. Confirm inventory log:
   SELECT * FROM inventory_transactions ORDER BY created_at DESC LIMIT 10;
   SELECT * FROM inventory_transaction_items WHERE transaction_id = <id>;

Troubleshooting

- If you get a JS parse error (Unexpected token '<') for `submit_order.php` response, it usually means PHP emitted HTML (error page). Check `C:\xampp\apache\logs\error.log` and `C:\xampp\php\logs\php_error_log`.
- If submit fails with "Variant not found" or "Not enough stock" it means the DB row wasn't present or quantity insufficient — inspect `product_variants` rows.
- If `submit_order.php` complains about missing `orders` or `order_items` table, run the CREATE TABLE statements above.

Notes & next improvements

- The code currently logs human-readable `color` and `size` labels joined from `options.value`. If labels are missing, ensure `options` table contains the matching `option_id` values referenced by `product_variants.color_option_id` / `size_option_id`.
- The `Js/ladningPage.js` file contains debug console.log statements used during development. Remove them before going to production.
- Consider adding server-side authentication and input validation for production use.
- Consider using prepared migration scripts to create DB schema automatically instead of manual SQL.

If you want, I can also:
- Create a small admin HTML page that consumes `phpFile/get_transactions.php` and displays transactions.
- Add an endpoint to list all available option labels to the frontend to make the option rendering simpler.
- Clean up debug logs in `JS/ladningPage.js` and add a small unit test or manual test checklist.

---
If anything in this README doesn't match your live DB (column/table names differ), paste the outputs of:

SHOW TABLES;
SHOW COLUMNS FROM products;
SHOW COLUMNS FROM product_variants;

and I will adapt the README + server code to your exact schema.
