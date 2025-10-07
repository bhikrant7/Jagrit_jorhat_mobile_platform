<?php
header("Content-Type: application/json");
include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);
$phone = $data['phone'];
$token = $data['token'];

// Validate token (optional but recommended)

$stmt = $conn->prepare("SELECT * FROM users WHERE phone = ?");
$stmt->bind_param("s", $phone);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if ($user) {
  echo json_encode(["success" => true, "user" => $user]);
} else {
  echo json_encode(["success" => false, "message" => "User not found"]);
}

$stmt->close();
$conn->close();
?>
