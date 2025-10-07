<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php';

// Read the JSON body
$data = json_decode(file_get_contents("php://input"), true);

$phone = $data['phoneNumber'] ?? '';
// $password = $data['password'] ?? '';

if (empty($phone)) {
  echo json_encode(["success" => false, "message" => "Phone number is required"]);
  exit;
}

// Check user by phone
$stmt = $conn->prepare("SELECT * FROM users WHERE phone = ?");
$stmt->bind_param("s", $phone);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
  $user = $result->fetch_assoc();

  if ($data['phoneNumber'] === $user['phone']) {
    echo json_encode([
      "success" => true,
      "message" => "User available",
      "user" => [
        "c_id" => $user['c_id'],
        "firstName" => $user['f_name'],
        "lastName" => $user['l_name'],
        "email" => $user['email'],
        "phone" => $user['phone'],
        "address" => $user['address'],
        "gaonPanchayat" => $user['gaon_panchayat'],
        "block" => $user['block'],
        "circleOffice" => $user['circle_office'],
        // "district" => $user['district'],
        // "state" => $user['state'],
        "emailVerifiedAt" => $user['email_verified_at'],
        "remember_token" => $user['remember_token'],
        // "otp" => $user['otp'],
        // "otp_valid" => $user['otp_valid'],
        "createdAt" => $user['created_at'],
        "updatedAt" => $user['updated_at'],
      ]
    ]);
  } else {
    echo json_encode(["success" => false, "message" => "Invalid phone number"]);
  }
} else {
  echo json_encode(["success" => false, "message" => "User not found"]);
}

$stmt->close();
$conn->close();
?>
