<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php';

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

// Required fields (excluding email, but gaon/ward rule applies)
$requiredFields = [
  'c_id', 'firstName', 'lastName', 'phoneNumber',
  'address', 'block', 'circleOffice'
];

// Check required
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

if (empty($data['gaonPanchayat'])){
    $address_type= 'urban';
}else{
    $address_type= 'rural';
}

// Assign values
$c_id    = $data['c_id'];  // required
$fname   = $data['firstName'];
$lname   = $data['lastName'];
$email   = isset($data['email']) ? $data['email'] : '';
$phone   = $data['phoneNumber'];
$address = $data['address'];
$gaon    = isset($data['gaonPanchayat']) ? $data['gaonPanchayat'] : null;
$ward    = isset($data['ward']) ? $data['ward'] : null;
$block   = $data['block'];
$circle  = $data['circleOffice'];

// Prepare UPDATE SQL
$sql = "UPDATE users SET 
          f_name = ?, 
          l_name = ?, 
          email = ?, 
          phone = ?, 
          address = ?, 
          address_type = ?,
          gaon_panchayat = ?, 
          ward = ?, 
          block = ?, 
          circle_office = ?, 
          updated_at = NOW()
        WHERE c_id = ?";

$stmt = $conn->prepare($sql);

if (!$stmt) {
  echo json_encode([
    "success" => false,
    "message" => "Prepare failed: " . $conn->error
  ]);
  exit;
}

// Bind params (all strings)
$stmt->bind_param(
  "sssssssssss",
  $fname,
  $lname,
  $email,
  $phone,
  $address,
  $address_type,
  $gaon,
  $ward,
  $block,
  $circle,
  $c_id
);

if ($stmt->execute()) {
  if ($stmt->affected_rows > 0) {
    echo json_encode(["success" => true, "message" => "User updated successfully"]);
  } else {
    echo json_encode(["success" => false, "message" => "No changes or user not found"]);
  }
} else {
  echo json_encode([
    "success" => false,
    "message" => "Update failed: " . $stmt->error
  ]);
}

$stmt->close();
$conn->close();
?>
