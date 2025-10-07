<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Methods, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST");

include 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
    exit;
}

// Explicitly ignore a_id even if sent from frontend
unset($_POST['a_id']); // This ensures a_id is not mistakenly used

// Collect fields
$c_id = $_POST['c_id'] ?? null;
$issue = $_POST['issue'] ?? null;
$description = $_POST['description'] ?? null;
$ref_numb = $_POST['ref_numb'] ?? null;

if (empty($c_id) || empty($issue) || empty($description)) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit;
}

$img_url = null;

// ✅ Handle file upload if exists
if (isset($_FILES['media']) && $_FILES['media']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = "uploads/tmp/";
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    $maxFileSize = 5 * 1024 * 1024;

    $originalName = basename($_FILES['media']['name']);
    $fileSize = $_FILES['media']['size'];
    $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

    if (!in_array($extension, $allowedExtensions)) {
        echo json_encode(["success" => false, "message" => "Invalid file type. Allowed: jpg, jpeg, png, pdf"]);
        exit;
    }

    if ($fileSize > $maxFileSize) {
        echo json_encode(["success" => false, "message" => "File exceeds 5MB limit."]);
        exit;
    }

    $newFileName = uniqid("file_") . "." . $extension;
    $targetPath = $uploadDir . $newFileName;

    if (move_uploaded_file($_FILES['media']['tmp_name'], $targetPath)) {
        $serverUrl = "https://jagritjorhat.assam.gov.in/jagrit/flutter_server/";
        $img_url = $serverUrl . $targetPath;
    } else {
        echo json_encode(["success" => false, "message" => "File move failed"]);
        exit;
    }
} elseif (isset($_FILES['media'])) {
    echo json_encode(["success" => false, "message" => "Media upload error: " . $_FILES['media']['error']]);
    exit;
}

// ✅ Insert into DB — a_id is auto-incremented (implicitly NULL)
$stmt = $conn->prepare("
    INSERT INTO applications 
    (a_id, c_id, issue, description, ref_numb, img_url, created_at, updated_at) 
    VALUES (NULL, ?, ?, ?, ?, ?, NOW(), NOW())
");

$stmt->bind_param("issss", $c_id, $issue, $description, $ref_numb, $img_url);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Application submitted successfully",
        "a_id" => $stmt->insert_id,
        "img_url" => $img_url
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Submission failed: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
