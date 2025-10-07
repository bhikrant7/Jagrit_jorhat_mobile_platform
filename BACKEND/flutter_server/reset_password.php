<!-- <?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php';

// Read incoming JSON body
$data = json_decode(file_get_contents("php://input"), true);

$phone = $data['phone'] ?? '';
$newPassword = $data['newPassword'] ?? '';

if (empty($phone) || empty($newPassword)) {
  echo json_encode([
    "success" => false,
    "message" => "Phone number and new password are required"
  ]);
  exit;
}

// Check if user exists
$stmt = $conn->prepare("SELECT * FROM users WHERE phone = ?");
$stmt->bind_param("s", $phone);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
  echo json_encode([
    "success" => false,
    "message" => "User with this phone number not found"
  ]);
  $stmt->close();
  $conn->close();
  exit;
}

// Hash the new password
$hashedPassword = password_hash($newPassword, PASSWORD_BCRYPT);

// Update the password
$updateStmt = $conn->prepare("UPDATE users SET password = ? WHERE phone = ?");
$updateStmt->bind_param("ss", $hashedPassword, $phone);

if ($updateStmt->execute()) {
  echo json_encode([
    "success" => true,
    "message" => "Password updated successfully"
  ]);
} else {
  echo json_encode([
    "success" => false,
    "message" => "Failed to update password"
  ]);
}

$updateStmt->close();
$stmt->close();
$conn->close();
?> -->
