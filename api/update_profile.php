<?php
header('Content-Type: application/json');
require_once './config_db.php';

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

// User ID is required
if (empty($input['user_id'])) {
    echo json_encode(["success" => false, "error" => "User ID required"]); exit;
}

$userId = (int)$input['user_id'];

// Validate user exists
$checkUser = $conn->query("SELECT id FROM users WHERE id=$userId LIMIT 1");
if (!$checkUser || $checkUser->num_rows == 0) {
    echo json_encode(["success" => false, "error" => "User not found"]); exit;
}

// Build update query based on provided fields
$updates = [];
$allowedFields = ['full_name', 'phone', 'gender', 'age', 'location'];

foreach ($allowedFields as $field) {
    if (isset($input[$field])) {
        if ($field == 'age') {
            $value = (int)$input[$field];
        } else {
            $value = $conn->real_escape_string(trim($input[$field]));
        }
        $updates[] = "$field = '$value'";
    }
}

if (empty($updates)) {
    echo json_encode(["success" => false, "error" => "No fields to update"]); exit;
}

// Update user profile
$sql = "UPDATE users SET " . implode(', ', $updates) . " WHERE id=$userId";
if ($conn->query($sql)) {
    // Fetch updated user data
    $getUser = $conn->query("SELECT id, full_name, email, phone, gender, age, location, created_at FROM users WHERE id=$userId LIMIT 1");
    $user = $getUser->fetch_assoc();
    echo json_encode(["success" => true, "user" => $user]);
} else {
    echo json_encode(["success" => false, "error" => "Update failed: " . $conn->error]);
}
$conn->close();
?>

