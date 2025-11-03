<?php
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();
ob_start();

// Add last_active_at column to users table if it doesn't exist
$checkCol = @$conn->query("SHOW COLUMNS FROM users LIKE 'last_active_at'");
if (!$checkCol || $checkCol->num_rows == 0) {
    @$conn->query("ALTER TABLE users ADD COLUMN last_active_at TIMESTAMP NULL DEFAULT NULL");
    if (ob_get_level() > 0) {
        ob_clean();
    }
}

$input = json_decode(file_get_contents('php://input'), true) ?: [];

if (empty($input['user_id'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "User ID required"]);
    exit;
}

$userId = (int)$input['user_id'];

try {
    $sql = "UPDATE users SET last_active_at = CURRENT_TIMESTAMP WHERE id = ?";
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $stmt->bind_param('i', $userId);
    @$stmt->execute();
    if (ob_get_level() > 0) {
        ob_clean();
    }
    
    $stmt->close();
    
    ob_clean();
    echo json_encode(["success" => true, "message" => "Activity updated"]);
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;

