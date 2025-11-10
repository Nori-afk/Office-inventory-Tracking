<?php
require_once 'config.php';
// Always return JSON from this endpoint
header('Content-Type: application/json; charset=utf-8');

// Don't send raw PHP warnings/notices as HTML — convert them to exceptions so we return JSON errors
ini_set('display_errors', '0');
set_error_handler(function($severity, $message, $file, $line) {
    // Convert warnings/notices to ErrorException so they can be caught and returned as JSON
    throw new ErrorException($message, 0, $severity, $file, $line);
});

// Shutdown handler to catch fatal errors and return JSON instead of HTML
register_shutdown_function(function() {
    $err = error_get_last();
    if ($err !== null) {
        http_response_code(500);
        header('Content-Type: application/json; charset=utf-8');
        $resp = array('success' => false, 'message' => 'Server error', 'details' => $err['message']);
        // Try to output JSON even if some output has been sent
        echo json_encode($resp);
        exit;
    }
});

function sendJson($data, $status = 200) {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data);
    exit;
}

// Handle order submission
function submitOrder($orderData) {
    global $conn;
    
    // Start transaction
    $conn->begin_transaction();
    
    try {

        // Prepare order header insertion
        // Your DB's `orders` table stores employee_name and department (see setup_database.php),
        // so map frontend fields accordingly.
        $employeeName = isset($orderData['employee_name']) ? $orderData['employee_name'] : (isset($orderData['customerName']) ? $orderData['customerName'] : 'Guest');
        $department = isset($orderData['department']) ? $orderData['department'] : '';

        $sql = "INSERT INTO orders (employee_name, department, status, created_at) VALUES (?, ?, 'pending', NOW())";
        $stmt = $conn->prepare($sql);
        if ($stmt === false) {
            throw new Exception('Failed to prepare orders insert: ' . $conn->error);
        }
        $stmt->bind_param("ss", $employeeName, $department);
        $stmt->execute();

        $orderId = $conn->insert_id;

        // Create an inventory transaction record to log stock deductions
        $tSql = "INSERT INTO inventory_transactions (order_id, transaction_type, created_at) VALUES (?, 'sale', NOW())";
        $tStmt = $conn->prepare($tSql);
        $tStmt->bind_param("i", $orderId);
        $tStmt->execute();
        $transactionId = $conn->insert_id;

        // Insert order items and update stock (supports product_variants)
        // Use `order_items` table (created by setup_database.php) which stores variant_id
        $detailSql = "INSERT INTO order_items (order_id, product_id, variant_id, quantity) VALUES (?, ?, ?, ?)";
        $detailStmt = $conn->prepare($detailSql);
        if ($detailStmt === false) {
            throw new Exception('Failed to prepare order_items insert: ' . $conn->error);
        }

        $invItemSql = "INSERT INTO inventory_transaction_items (transaction_id, product_id, variant_id, quantity_changed, stock_after) VALUES (?, ?, ?, ?, ?)";
        $invItemStmt = $conn->prepare($invItemSql);

        foreach ($orderData['items'] as $item) {
            $productId = isset($item['product_id']) ? $item['product_id'] : (isset($item['productId']) ? $item['productId'] : null);
            $quantity = isset($item['quantity']) ? (int)$item['quantity'] : 0;
            $variantId = isset($item['variant_id']) ? $item['variant_id'] : null;

            // Insert order item (include variant if present)
            $variantIdInt = $variantId ? (int)$variantId : 0;
            $detailStmt->bind_param("iiii", $orderId, $productId, $variantIdInt, $quantity);
            $detailStmt->execute();

            // If variant provided, reduce variant stock; otherwise reduce product stock
            if ($variantId) {
                // Check current variant stock
                $check = $conn->prepare("SELECT stock, product_id FROM product_variants WHERE variant_id = ? FOR UPDATE");
                $check->bind_param('i', $variantId);
                $check->execute();
                $cres = $check->get_result();
                if (!$cres || $cres->num_rows === 0) {
                    throw new Exception("Variant not found: " . $variantId);
                }
                $vrow = $cres->fetch_assoc();
                $currentStock = (int)$vrow['stock'];
                $parentProductId = (int)$vrow['product_id'];

                if ($currentStock < $quantity) {
                    throw new Exception("Not enough stock for variant " . $variantId);
                }

                // Decrement variant stock
                $upd = $conn->prepare("UPDATE product_variants SET stock = stock - ? WHERE variant_id = ?");
                $upd->bind_param('ii', $quantity, $variantId);
                $upd->execute();

                // Also decrement parent product total quantity if column exists
                $updP = $conn->prepare("UPDATE products SET quantity = GREATEST(quantity - ?, 0) WHERE product_id = ?");
                $updP->bind_param('ii', $quantity, $parentProductId);
                $updP->execute();

                // Get new stock after update
                $after = $conn->query("SELECT stock FROM product_variants WHERE variant_id = " . (int)$variantId)->fetch_assoc();
                $afterStock = isset($after['stock']) ? (int)$after['stock'] : 0;

                // Log inventory transaction item
                $qtyChanged = -$quantity;
                $vId = (int)$variantId;
                $invItemStmt->bind_param('iiiii', $transactionId, $productId, $vId, $qtyChanged, $afterStock);
                $invItemStmt->execute();

            } else {
                // No variant: operate on products table
                $check = $conn->prepare("SELECT quantity FROM products WHERE product_id = ? FOR UPDATE");
                $check->bind_param('i', $productId);
                $check->execute();
                $cres = $check->get_result();
                if (!$cres || $cres->num_rows === 0) {
                    throw new Exception("Product not found: " . $productId);
                }
                $prow = $cres->fetch_assoc();
                $currentStock = (int)$prow['quantity'];

                if ($currentStock < $quantity) {
                    throw new Exception("Not enough stock for product " . $productId);
                }

                // Decrement product stock
                $upd = $conn->prepare("UPDATE products SET quantity = quantity - ? WHERE product_id = ?");
                $upd->bind_param('ii', $quantity, $productId);
                $upd->execute();

                // Get new product stock
                $after = $conn->query("SELECT quantity as stock FROM products WHERE product_id = " . (int)$productId)->fetch_assoc();
                $afterStock = isset($after['stock']) ? (int)$after['stock'] : 0;

                // Log inventory transaction item (variant_id NULL)
                $qtyChanged = -$quantity;
                $vId = 0;
                $invItemStmt->bind_param('iiiii', $transactionId, $productId, $vId, $qtyChanged, $afterStock);
                $invItemStmt->execute();
            }
        }

        // Commit transaction
        $conn->commit();
        return array("success" => true, "orderId" => $orderId);
        
    } catch (Exception $e) {
        // Rollback transaction on error
        $conn->rollback();
        return array("success" => false, "message" => $e->getMessage());
    }
}

// Handle the request
$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'POST':
        try {
            $data = json_decode(file_get_contents("php://input"), true);
            if (!$data) {
                sendJson(array('success' => false, 'message' => 'Invalid request data'), 400);
            }
            $result = submitOrder($data);
            sendJson($result, 200);
        } catch (Exception $e) {
            // Ensure we return JSON on any exception
            sendJson(array('success' => false, 'message' => $e->getMessage()), 500);
        }
        break;
    
    default:
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed"));
        break;
}
?>