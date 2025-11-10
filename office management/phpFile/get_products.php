<?php
require_once 'config.php';


function getCategories() {
    global $conn;
    $sql = "SELECT category_id, NAME FROM categories";
    $result = $conn->query($sql);
    $categories = array();
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $categories[] = array(
                'id' => $row['category_id'],
                'name' => $row['NAME']
            );
        }
    }
    return $categories;
}

function getProducts() {
    global $conn;

    $sql = "SELECT p.product_id, p.name, p.image, p.category_id, p.quantity
            FROM products p";
    $result = $conn->query($sql);

    $products = array();
    if ($result && $result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $productId = (int)$row['product_id'];

            // Fetch category name (if any)
            $catName = null;
            if (!empty($row['category_id'])) {
                $cstmt = $conn->prepare("SELECT NAME FROM categories WHERE category_id = ?");
                $cstmt->bind_param("i", $row['category_id']);
                $cstmt->execute();
                $cres = $cstmt->get_result();
                if ($cres && $cres->num_rows > 0) {
                    $crow = $cres->fetch_assoc();
                    $catName = $crow['NAME'];
                }
            }

            // Fetch variants for this product from product_variants
            // Join the options table to resolve option ids to readable values
            $vsql = "SELECT pv.variant_id, pv.color_option_id, pv.size_option_id, pv.stock,
                            oc.value as color_value, os.value as size_value
                     FROM product_variants pv
                     LEFT JOIN options oc ON pv.color_option_id = oc.option_id
                     LEFT JOIN options os ON pv.size_option_id = os.option_id
                     WHERE pv.product_id = ?";

            $vstmt = $conn->prepare($vsql);
            $vstmt->bind_param("i", $productId);
            $vstmt->execute();
            $vres = $vstmt->get_result();

            $variants = array();
            $totalStock = 0;
            if ($vres) {
                while ($vrow = $vres->fetch_assoc()) {
                    $variants[] = array(
                        'variant_id' => (int)$vrow['variant_id'],
                        'color_option_id' => $vrow['color_option_id'] !== null ? (int)$vrow['color_option_id'] : null,
                        'color' => $vrow['color_value'] !== null ? $vrow['color_value'] : null,
                        'size_option_id' => $vrow['size_option_id'] !== null ? (int)$vrow['size_option_id'] : null,
                        'size' => $vrow['size_value'] !== null ? $vrow['size_value'] : null,
                        'stock' => (int)$vrow['stock']
                    );
                    $totalStock += (int)$vrow['stock'];
                }
            }

            // As a fallback, if no variants exist, use the product.quantity column
            $displayStock = $totalStock > 0 ? $totalStock : (int)$row['quantity'];

            $products[] = array(
                'id' => $productId,
                'name' => $row['name'],
                'image' => $row['image'],
                'category_id' => $row['category_id'] !== null ? (int)$row['category_id'] : null,
                'category_name' => $catName,
                'stock' => $displayStock,
                'variants' => $variants
            );
        }
    }

    return $products;
}


$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $response = array(
            'products' => getProducts(),
            'categories' => getCategories()
        );
        echo json_encode($response);
        break;

    default:
        http_response_code(405);
        echo json_encode(array("message" => "Method not allowed"));
        break;
}
?>