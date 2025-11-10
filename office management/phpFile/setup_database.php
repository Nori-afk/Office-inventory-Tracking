<?php
require_once 'config.php';


try {
   
    $stmt = $conn->query("SHOW TABLES LIKE 'products'");
    $productsExists = $stmt->rowCount() > 0;

    if (!$productsExists) {
        $conn->exec("CREATE TABLE products (
            id INT PRIMARY KEY AUTO_INCREMENT,
            name VARCHAR(255) NOT NULL,
            category_id INT NOT NULL,
            image VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
        $productsPk = 'id';
    } else {
        // Detect primary key column name for products
        $pkStmt = $conn->query("SHOW KEYS FROM products WHERE Key_name = 'PRIMARY'");
        $pkRow = $pkStmt->fetch(PDO::FETCH_ASSOC);
        if ($pkRow && !empty($pkRow['Column_name'])) {
            $productsPk = $pkRow['Column_name'];
        } else {
          
            $colStmt = $conn->query("SHOW COLUMNS FROM products LIKE 'id'");
            if ($colStmt->rowCount() === 0) {
      
                $conn->exec("ALTER TABLE products ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST");
                $productsPk = 'id';
            } else {
                // `id` exists but not primary, make it primary
                $conn->exec("ALTER TABLE products ADD PRIMARY KEY (id)");
                $productsPk = 'id';
            }
        }
    }

   
    $conn->exec("CREATE TABLE IF NOT EXISTS product_variants (
        id INT PRIMARY KEY AUTO_INCREMENT,
        product_id INT NOT NULL,
        size VARCHAR(50),
        color VARCHAR(50),
        stock INT NOT NULL DEFAULT 0,
        UNIQUE KEY unique_variant (product_id, size, color)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

  
    try {
        $conn->exec("ALTER TABLE product_variants DROP FOREIGN KEY product_variants_ibfk_1");
    } catch (Exception $e) {
        // ignore if it doesn't exist
    }

    // Add FK referencing products(<detected pk column>)
    $fkName = 'fk_product_variants_product';
    // Drop FK if exists with different name
    try { $conn->exec("ALTER TABLE product_variants DROP FOREIGN KEY $fkName"); } catch (Exception $e) { }
    $conn->exec("ALTER TABLE product_variants ADD CONSTRAINT $fkName FOREIGN KEY (product_id) REFERENCES products($productsPk) ON DELETE CASCADE ON UPDATE CASCADE");

    // Create orders table if missing
    $conn->exec("CREATE TABLE IF NOT EXISTS orders (
        id INT PRIMARY KEY AUTO_INCREMENT,
        employee_name VARCHAR(255) NOT NULL,
        department VARCHAR(100) NOT NULL,
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

    // Create order_items table if missing
    $conn->exec("CREATE TABLE IF NOT EXISTS order_items (
        id INT PRIMARY KEY AUTO_INCREMENT,
        order_id INT NOT NULL,
        product_id INT NOT NULL,
        variant_id INT NOT NULL,
        quantity INT NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

    // Ensure foreign keys for order_items
    try { $conn->exec("ALTER TABLE order_items DROP FOREIGN KEY order_items_ibfk_1"); } catch (Exception $e) { }
    try { $conn->exec("ALTER TABLE order_items DROP FOREIGN KEY order_items_ibfk_2"); } catch (Exception $e) { }
    try { $conn->exec("ALTER TABLE order_items DROP FOREIGN KEY order_items_ibfk_3"); } catch (Exception $e) { }

    // Add proper foreign keys
    $conn->exec("ALTER TABLE order_items ADD CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE");
    // product_id should reference products using detected pk
    try { $conn->exec("ALTER TABLE order_items ADD CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products($productsPk) ON DELETE CASCADE ON UPDATE CASCADE"); } catch (Exception $e) { }
    try { $conn->exec("ALTER TABLE order_items ADD CONSTRAINT fk_order_items_variant FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE ON UPDATE CASCADE"); } catch (Exception $e) { }

    echo "Database tables created/validated successfully";

} catch(PDOException $e) {
    echo "Error creating tables: " . $e->getMessage();
}
?>