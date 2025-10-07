<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php';

// Read the JSON body
$data = json_decode(file_get_contents("php://input"), true);

$phone = $data['phone'] ?? '';
$email = $data['email'] ?? '';

if (empty($phone) || empty($email)) {
  echo json_encode(["success" => false, "message" => "Phone number and email are required"]);
  exit;
}

// Check if user with given phone and email exists
$stmt = $conn->prepare("SELECT * FROM users WHERE phone = ? AND email = ?");
$stmt->bind_param("ss", $phone, $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
  $user = $result->fetch_assoc();

  echo json_encode([
    "success" => true,
    "message" => "User found",
    "user" => [
      "c_id" => $user['c_id'],
      "firstName" => $user['f_name'],
      "lastName" => $user['l_name'],
      "email" => $user['email'],
      "phone" => $user['phone'],
    ]
  ]);
} else {
  echo json_encode(["success" => false, "message" => "No matching user found"]);
}

$stmt->close();
$conn->close();
?>
