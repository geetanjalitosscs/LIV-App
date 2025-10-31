<?php
$host = 'localhost';
$user = 'root';
$pass = '';
$dbname = 'liv';

$conn = new mysqli($host, $user, $pass, $dbname);
if ($conn->connect_error) {
    die(json_encode(["success" => false, "error" => "Connection failed: " . $conn->connect_error]));
}
// Use $conn in your scripts
?>
