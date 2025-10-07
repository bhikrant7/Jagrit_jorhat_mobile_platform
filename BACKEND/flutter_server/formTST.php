<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Methods, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST");

include 'db.php';

// Ensure POST method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
    exit;
}

// Collect fields
$c_id = $_POST['c_id'] ?? null;
$issue = $_POST['issue'] ?? null;
$description = $_POST['description'] ?? null;
$ref_numb = $_POST['ref_numb'] ?? null;

// Validate required fields
if (empty($c_id) || empty($issue) || empty($description)) {
    echo json_encode(["success" => false, "message" => "Missing required fields"]);
    exit;
}

$img_url = null;

// ✅ Handle file upload only if media exists
if (isset($_FILES['media']) && $_FILES['media']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = "uploads/tmp/";
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    $maxFileSize = 5 * 1024 * 1024; // 5MB

    $originalName = basename($_FILES['media']['name']);
    $fileSize = $_FILES['media']['size'];
    $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));

    // ✅ Validate extension
    if (!in_array($extension, $allowedExtensions)) {
        echo json_encode(["success" => false, "message" => "Invalid file type. Allowed: jpg, jpeg, png, pdf"]);
        exit;
    }

    // ✅ Validate file size
    if ($fileSize > $maxFileSize) {
        echo json_encode(["success" => false, "message" => "File exceeds 5MB limit."]);
        exit;
    }

    $newFileName = uniqid("file_") . "." . $extension;
    $targetPath = $uploadDir . $newFileName;

    // ✅ Move file
    if (move_uploaded_file($_FILES['media']['tmp_name'], $targetPath)) {
        $serverUrl = "https://jagritjorhat.assam.gov.in/jagrit/flutter_server/";
        $img_url = $serverUrl . $targetPath;

        // ✅ Ensure file exists on server before DB insert
        if (!file_exists($targetPath)) {
            echo json_encode(["success" => false, "message" => "Image upload failed (file missing after move)."]);
            exit;
        }
    } else {
        error_log("Upload failed. Error code: " . $_FILES['media']['error']);
        echo json_encode(["success" => false, "message" => "File move failed"]);
        exit;
    }
} elseif (isset($_FILES['media'])) {
    error_log("Upload error: " . $_FILES['media']['error']);
    echo json_encode(["success" => false, "message" => "Media upload error: " . $_FILES['media']['error']]);
    exit;
}

// ✅ Insert only if either no file or valid file is uploaded
$stmt = $conn->prepare("
    INSERT INTO applications 
    (c_id, issue, description, ref_numb, img_url, created_at, updated_at) 
    VALUES (?, ?, ?, ?, ?, NOW(), NOW())
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
