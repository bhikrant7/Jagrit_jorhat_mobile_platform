<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");


require_once 'db.php';

require_once 'vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable(__DIR__);
$dotenv->load();



$smsApiUrl    = $_ENV['SMS_API_URL'] ?? '';
$smsAgency    = $_ENV['SMS_AGENCY'] ?? '';
$smsPassword  = $_ENV['SMS_PASSWORD'] ?? '';
$smsDistrict  = $_ENV['SMS_DISTRICT'] ?? '';
$smsAppId     = $_ENV['SMS_APP_ID'] ?? '';
$smsSenderId  = $_ENV['SMS_SENDER_ID'] ?? '';
$smsTeId      = $_ENV['SMS_TE_ID'] ?? '';


$data = json_decode(file_get_contents('php://input'), true);
$phone = trim($data['phone'] ?? '');

if (empty($phone) || !preg_match('/^[6789]\d{9}$/', $phone)) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid phone number",
    ]);
    exit;
}

$otp = str_pad(rand(100000, 999999), 6, '0', STR_PAD_LEFT);
$expiresAt = date('Y-m-d H:i:s', strtotime('+5 minutes'));

// Insert or update OTP in database
$sql = "INSERT INTO otps (phone, otp, expires_at, created_at, updated_at)
        VALUES (?, ?, ?, NOW(), NOW())
        ON DUPLICATE KEY UPDATE
            otp = VALUES(otp),
            expires_at = VALUES(expires_at),
            updated_at = NOW()";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "Prepare statement failed: " . $conn->error,
    ]);
    exit;
}

$stmt->bind_param('sss', $phone, $otp, $expiresAt);

if (!$stmt->execute()) {
    echo json_encode([
        "success" => false,
        "message" => "Database error: " . $stmt->error,
    ]);
    $stmt->close();
    exit;
}

$stmt->close();

//////////////////////////////////////////
// SEND SMS using your SMS Provider
//////////////////////////////////////////

// Create message
$message = "Your Login OTP for Jagrit Jorhat website is {$otp}.";

// Build URL with query params
$params = http_build_query([
    'agency'     => $smsAgency,
    'password'   => $smsPassword,
    'district'   => $smsDistrict,
    'app_id'     => $smsAppId,
    'sender_id'  => $smsSenderId,
    'unicode'    => 'false',
    'to'         => $phone,
    'te_id'      => $smsTeId,
    'msg'        => $message
]);

$url = $smsApiUrl . '?' . $params;

// Send SMS using cURL (recommended)
error_log("SMS URL: $url");


$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10); 
curl_setopt($ch, CURLOPT_FAILONERROR, true); 

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

if ($response === false) {
    echo json_encode([
        "success" => false,
        "message" => "Failed to send OTP",
        "curl_error" => $error,
        "http_code" => $httpCode,
        "url" => $url
    ]);
    exit;
}

echo json_encode([
    "success" => true,
    "message" => "OTP sent successfully",
    "sms_response" => $response 
]);
