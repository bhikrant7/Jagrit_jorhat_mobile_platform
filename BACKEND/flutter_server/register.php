<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

error_reporting(E_ALL);
ini_set('display_errors', 1);


include 'db.php';

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Required fields (excluding gaon/ward)
$requiredFields = [
  'firstName', 'lastName', 'phoneNumber',
  'address', 'block', 'circleOffice','address_type'
];

// Check for missing fields
foreach ($requiredFields as $field) {
  if (empty($data[$field])) {
    echo json_encode([
      "success" => false,
      "message" => "Missing field: $field"
    ]);
    exit;
  }
}

// Validate that at least one of gaonPanchayat OR ward exists
if (empty($data['gaonPanchayat']) && empty($data['ward'])) {
  echo json_encode([
    "success" => false,
    "message" => "Either gaonPanchayat or ward is required"
  ]);
  exit;
}

// Assign values
// $c_id    = $data['c_id'] ?? null;
$fname   = $data['firstName'];
$lname   = $data['lastName'];
$email   = isset($data['email']) ? $data['email'] : '';
$phone   = $data['phoneNumber'];
$address = $data['address'];
$gaon    = isset($data['gaonPanchayat']) ? $data['gaonPanchayat'] : null;
$addresstype = $data['address_type'];
$ward    = isset($data['ward']) ? $data['ward'] : null;
$block   = $data['block'];
$circle  = $data['circleOffice'];

// Prepare SQL without c_id if it is AUTO_INCREMENT
$sql = "INSERT INTO users (
    f_name, l_name, email, phone, address,address_type,
    gaon_panchayat, ward, block, circle_office,
    created_at, updated_at
) VALUES (?,?,?,?,?,?,?,?,?, NOW(), NOW())";

$stmt = $conn->prepare($sql);

if (!$stmt) {
  echo json_encode([
    "success" => false,
    "message" => "Prepare failed: " . $conn->error
  ]);
  exit;
}

$stmt->bind_param(
  "ssssssssss",
  $fname,
  $lname,
  $email,
  $phone,
  $address,
  $addresstype,
  $gaon,
  $ward,
  $block,
  $circle
);


if ($stmt->execute()) {
  echo json_encode(["success" => true, "message" => "Registration successful"]);
} else {
  echo json_encode(["success" => false, "message" => "Registration failed: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>

