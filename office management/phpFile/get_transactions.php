<?php
require_once 'config.php';

function getTransactions() {
    global $conn;

    $sql = "SELECT t.id as transaction_id, t.order_id, t.transaction_type, t.created_at
            FROM inventory_transactions t
            ORDER BY t.created_at DESC";
    $res = $conn->query($sql);
    $transactions = array();
    if ($res && $res->num_rows > 0) {
        while ($row = $res->fetch_assoc()) {
            $tid = (int)$row['transaction_id'];
            $itemsSql = "SELECT iti.product_id, iti.variant_id, iti.quantity_changed, iti.stock_after,
                              p.name as product_name, pv.size as variant_size, pv.color as variant_color
                         FROM inventory_transaction_items iti
                         LEFT JOIN products p ON iti.product_id = p.product_id OR iti.product_id = p.id
                         LEFT JOIN product_variants pv ON iti.variant_id = pv.variant_id OR iti.variant_id = pv.id
                         WHERE iti.transaction_id = ?";
            $stmt = $conn->prepare($itemsSql);
            $stmt->bind_param('i', $tid);
            $stmt->execute();
            $itemsRes = $stmt->get_result();
            $items = array();
            if ($itemsRes) {
                while ($it = $itemsRes->fetch_assoc()) {
                    $items[] = $it;
                }
            }

            $transactions[] = array(
                'transaction_id' => $tid,
                'order_id' => $row['order_id'],
                'transaction_type' => $row['transaction_type'],
                'created_at' => $row['created_at'],
                'items' => $items
            );
        }
    }
    return $transactions;
}

$method = $_SERVER['REQUEST_METHOD'];
if ($method === 'GET') {
    header('Content-Type: application/json');
    echo json_encode(getTransactions());
} else {
    http_response_code(405);
    echo json_encode(array('message' => 'Method not allowed'));
}
