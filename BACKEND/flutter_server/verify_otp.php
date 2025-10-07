<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php'; // This should define $conn (MySQLi)

// Random 32-char token
function generateRandomToken($length = 32) {
    return bin2hex(random_bytes($length / 2));
}

$data = json_decode(file_get_contents('php://input'), true);
$phone = $data['phone'] ?? '';
$otp = $data['otp'] ?? '';

if (empty($phone) || empty($otp)) {
    echo json_encode(["success" => false, "message" => "Phone number and OTP are required"]);
    exit;
}

try {
    // 1. Get OTP & check expiry
    $stmt = $conn->prepare("SELECT otp, expires_at FROM otps WHERE phone = ? ORDER BY id DESC LIMIT 1");
    $stmt->bind_param("s", $phone);
    $stmt->execute();
    $result = $stmt->get_result();
    $otpRow = $result->fetch_assoc();
    $stmt->close();

    if (!$otpRow || $otpRow['otp'] !== $otp || strtotime($otpRow['expires_at']) < time()) {
        echo json_encode(["success" => false, "message" => "Invalid or expired OTP"]);
        exit;
    }

    // 2. Update user as verified
    $token = generateRandomToken();
    $stmt = $conn->prepare("UPDATE users SET email_verified_at = NOW(), remember_token = ?, updated_at = NOW() WHERE phone = ?");
    $stmt->bind_param("ss", $token, $phone);
    $stmt->execute();
    $stmt->close();

    // 3. Delete the OTP (optional cleanup)
    $stmt = $conn->prepare("DELETE FROM otps WHERE phone = ?");
    $stmt->bind_param("s", $phone);
    $stmt->execute();
    $stmt->close();

    // 4. Get updated user info
    $stmt = $conn->prepare("SELECT * FROM users WHERE phone = ? LIMIT 1");
    $stmt->bind_param("s", $phone);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();
    $stmt->close();

    echo json_encode([
        "success" => true,
        "message" => "OTP verified successfully",
        "token" => $token,
        "user" => $user
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => "Server error", "error" => $e->getMessage()]);
}
