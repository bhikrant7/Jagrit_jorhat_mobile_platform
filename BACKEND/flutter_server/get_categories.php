<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

include 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(["success" => false, "message" => "Invalid request method. Use GET."]);
    exit;
}

$sql = "SELECT cc_id, tag FROM commoncases ORDER BY tag ASC";
$result = $conn->query($sql);

$categories = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // Ensure tag is properly encoded for JSON
        $row['tag'] = mb_convert_encoding($row['tag'], 'UTF-8', 'UTF-8');
        $categories[] = $row;
    }
}

echo json_encode(["success" => true, "data" => $categories]);

$conn->close();
?>