<?php
$host = "localhost";
$username = "root";
$password = "";
$database = "flutter_db"; 
$port = 3307; 


$conn = new mysqli($host, $username, $password, $database, $port);

// Check connection
if ($conn->connect_error) {
  die(json_encode([
    "success" => false,
    "message" => "Database connection failed: " . $conn->connect_error,
  ]));
}
?>
