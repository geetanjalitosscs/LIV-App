<?php
header('Content-Type: application/json');
require_once './config_db.php';

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['email']) || empty($input['password'])) {
    echo json_encode(["success" => false, "error" => "Email and password required"]); exit;
}

$email = strtolower($conn->real_escape_string(trim($input['email'])));
$password = $input['password'];

$sql = "SELECT id, full_name, email, phone, password, gender, age, created_at FROM users WHERE email=? LIMIT 1";
$stmt = $conn->prepare($sql);
$stmt->bind_param('s', $email);
$stmt->execute();
$res = $stmt->get_result();

if ($user = $res->fetch_assoc()) {
    if (password_verify($password, $user['password'])) {
        unset($user['password']);
        echo json_encode(["success" => true, "user" => $user]);
    } else {
        echo json_encode(["success" => false, "error" => "Invalid password"]);
    }
} else {
    echo json_encode(["success" => false, "error" => "User not found"]);
}
$stmt->close();
$conn->close();
