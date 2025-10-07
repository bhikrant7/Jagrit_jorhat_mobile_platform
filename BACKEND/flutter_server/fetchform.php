<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php';

// Check for c_id in GET params
if (!isset($_GET['c_id']) || empty($_GET['c_id'])) {
    echo json_encode(["success" => false, "message" => "Missing c_id"]);
    exit;
}

$c_id = intval($_GET['c_id']);

// Fetch submissions from database
$stmt = $conn->prepare("SELECT a_id, issue, description, ref_numb, img_url, created_at FROM applications WHERE c_id = ? ORDER BY created_at DESC");
$stmt->bind_param("i", $c_id);
$stmt->execute();

$result = $stmt->get_result();
$submissions = [];

while ($row = $result->fetch_assoc()) {
    // No need to modify $row['img_url'] if already full URL
    $submissions[] = $row;
}



echo json_encode([
    "success" => true,
    "data" => $submissions
]);

$stmt->close();
$conn->close();
?>
