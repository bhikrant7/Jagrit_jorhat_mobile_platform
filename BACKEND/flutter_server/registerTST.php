<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php'; // Assumes $conn = new mysqli(...)

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Required fields
$requiredFields = [
  'firstName', 'lastName', 'phoneNumber',
  'address', 'gaonPanchayat', 'block', 'circleOffice'
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

// Assign values
$fname = $data['firstName'];
$lname = $data['lastName'];
$email = isset($data['email']) ? $data['email'] : '';
$phone = $data['phoneNumber'];
$address = $data['address'];
$gaon = $data['gaonPanchayat'];
$block = $data['block'];
$circle = $data['circleOffice'];

// Generate c_id: first 2 + last 4 digits of phone number
$first2 = substr($phone, 0, 2);
$last4 = substr($phone, -4);
$c_id = intval($first2 . $last4);  // e.g., 947098

// Check if c_id already exists
$checkStmt = $conn->prepare("SELECT c_id FROM users WHERE c_id = ?");
$checkStmt->bind_param("i", $c_id);
$checkStmt->execute();
$checkResult = $checkStmt->get_result();

if ($checkResult->num_rows > 0) {
  echo json_encode([
    "success" => false,
    "message" => "User already exists with c_id: $c_id"
  ]);
  $checkStmt->close();
  $conn->close();
  exit;
}
$checkStmt->close();

// Insert into database
$sql = "INSERT INTO users (
    c_id, f_name, l_name, email, phone, address,
    gaon_panchayat, block, circle_office,
    created_at, updated_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

$stmt = $conn->prepare($sql);

if (!$stmt) {
  echo json_encode([
    "success" => false,
    "message" => "Prepare failed: " . $conn->error
  ]);
  exit;
}

$stmt->bind_param("issssssss", $c_id, $fname, $lname, $email, $phone, $address, $gaon, $block, $circle);

if ($stmt->execute()) {
  echo json_encode([
    "success" => true,
    "message" => "Registration successful",
    "c_id" => $c_id
  ]);
} else {
  echo json_encode([
    "success" => false,
    "message" => "Registration failed: " . $stmt->error
  ]);
}

$stmt->close();
$conn->close();
?>



<!-- <?php 
// header("Content-Type: application/json");
// header("Access-Control-Allow-Origin: *");
// header("Access-Control-Allow-Headers: Content-Type");

// include 'db.php';

// // Read JSON input
// $data = json_decode(file_get_contents("php://input"), true);

// // Required fields
// $requiredFields = [
//   'firstName', 'lastName', 'phoneNumber',
//   'address', 'gaonPanchayat', 'block', 'circleOffice'
// ];

// // Check for missing fields
// foreach ($requiredFields as $field) {
//   if (empty($data[$field])) {
//     echo json_encode([
//       "success" => false,
//       "message" => "Missing field: $field"
//     ]);
//     exit;
//   }
// }

// // Assign values
// $c_id = $data['c_id']?? null;
// $fname   = $data['firstName'];
// $lname   = $data['lastName'];
// $email   = isset($data['email']) ? $data['email'] : '';
// $phone   = $data['phoneNumber'];
// $address = $data['address'];
// $gaon    = $data['gaonPanchayat'];
// $block   = $data['block'];
// $circle  = $data['circleOffice'];

// // Always explicitly set c_id as NULL (even if user tries to pass one)
// // $c_id = null;

// // Prepare SQL (manually inserting null for c_id)
// $sql = "INSERT INTO users (
//     c_id,f_name, l_name, email, phone, address,
//     gaon_panchayat, block, circle_office,
//     created_at, updated_at
// ) VALUES (?,?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())";

// $stmt = $conn->prepare($sql);

// if (!$stmt) {
//   echo json_encode([
//     "success" => false,
//     "message" => "Prepare failed: " . $conn->error
//   ]);
//   exit;
// }

// // c_id as null explicitly
// $stmt->bind_param("sssssssss",$c_id, $fname, $lname, $email, $phone, $address, $gaon, $block, $circle);

// if ($stmt->execute()) {
//   echo json_encode(["success" => true, "message" => "Registration successful"]);
// } else {
//   echo json_encode(["success" => false, "message" => "Registration failed: " . $stmt->error]);
// }


// $stmt->close();
// $conn->close();
?> -->
