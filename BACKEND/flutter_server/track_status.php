<?php
error_reporting(E_ALL);
ini_set('display_errors', 1); // show temporarily for debug

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

include 'db.php'; // check this file does not echo anything


$response = ["success" => false, "data" => [], "message" => ""];

// Validate input
if (!isset($_GET['a_id']) || empty($_GET['a_id'])) {
    $response["message"] = "Missing a_id";
    echo json_encode($response);
    exit;
}

$a_id = $_GET['a_id'];
$history = [];

// Check DB connection
if ($conn->connect_error) {
    $response["message"] = "Database connection failed: " . $conn->connect_error;
    echo json_encode($response);
    exit;
}

// Helper function
function fetchHistory($conn, $sql, $a_id) {
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        return ["error" => "Prepare failed: " . $conn->error];
    }
    $stmt->bind_param("s", $a_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $rows = [];
    while ($row = $result->fetch_assoc()) {
        $rows[] = $row;
    }
    $stmt->close();
    return $rows;
}

// 1. Forwarded
$history = array_merge($history, fetchHistory($conn, "
    SELECT fwd.remark, d.d_name AS department, fwd.created_at, 'forwarded' AS type
    FROM forwardapps fwd
    JOIN departments d ON fwd.d_id = d.d_id
    WHERE fwd.a_id = ?
", $a_id));

// 2. Reverted
$history = array_merge($history, fetchHistory($conn, "
    SELECT rvt.remark, d.d_name AS department, rvt.created_at, 'reverted' AS type
    FROM revertapps rvt
    JOIN departments d ON rvt.d_id = d.d_id
    WHERE rvt.a_id = ?
", $a_id));

// // 3. Subdepartment
// $history = array_merge($history, fetchHistory($conn, "
//     SELECT sub.remark, sd.d_name AS department, sub.created_at, 'subdepartment' AS type
//     FROM subforwardapps sub
//     JOIN subdepartments sd ON sub.sub_id = sd.sub_id
//     WHERE sub.a_id = ?
// ", $a_id));  // ✅ use sd.d_name if that's your column



// 3. Subdepartment
$history = array_merge($history, fetchHistory($conn, "
    SELECT sub.remark, sd.d_name AS department, sub.created_at, 'subdepartment' AS type
    FROM subforwardapps sub
    JOIN subdepartments sd ON sub.sub_id = sd.sub_id
    WHERE sub.a_id = ?
", $a_id));

// 4. Resolves
$history = array_merge($history, fetchHistory($conn, "
    SELECT rsv.remark, 
           COALESCE(d.d_name, sd.sd_name, asd.asd_name) AS department, 
           rsv.created_at, 
           'resolved' AS type
    FROM resolves rsv
    LEFT JOIN departments d ON rsv.d_id = d.d_id
    LEFT JOIN subdepartments sd ON rsv.sd_id = sd.sd_id
    LEFT JOIN assistantsubdepartments asd ON rsv.asd_id = asd.asd_id
    WHERE rsv.a_id = ?
", $a_id));


// Sort by created_at (newest first)
usort($history, function($a, $b) {
    return strtotime($b['created_at']) <=> strtotime($a['created_at']);
});

// Final response
$response["success"] = true;
$response["data"] = $history;
if (empty($history)) {
    $response["message"] = "No history found for a_id = $a_id";
}

echo json_encode($response);
$conn->close();
