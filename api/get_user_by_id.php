<?php
header('Content-Type: application/json');
require_once './config_db.php';

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['user_id'])) {
    echo json_encode(["success" => false, "error" => "User ID required"]); exit;
}

$userId = (int)$input['user_id'];

$sql = "SELECT id, full_name, email, phone, gender, age, location, bio, created_at FROM users WHERE id=? LIMIT 1";
$stmt = $conn->prepare($sql);
$stmt->bind_param('i', $userId);
$stmt->execute();
$res = $stmt->get_result();

if ($user = $res->fetch_assoc()) {
    echo json_encode(["success" => true, "user" => $user]);
} else {
    echo json_encode(["success" => false, "error" => "User not found"]);
}
$stmt->close();
$conn->close();
?>

