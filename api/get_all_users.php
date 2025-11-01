<?php
// Prevent any output before JSON
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
// Clean any output from config_db.php
ob_end_clean();
ob_start();

$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

// Get current user ID to exclude from results
$currentUserId = isset($input['current_user_id']) ? (int)$input['current_user_id'] : null;

try {
    // Build query - exclude current user if provided
    if ($currentUserId !== null && $currentUserId > 0) {
        $sql = "SELECT id, full_name, email, phone, gender, age, location, bio, created_at FROM users WHERE id != ? ORDER BY created_at DESC";
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $stmt->bind_param('i', $currentUserId);
    } else {
        $sql = "SELECT id, full_name, email, phone, gender, age, location, bio, created_at FROM users ORDER BY created_at DESC";
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
    }

    if (!$stmt->execute()) {
        throw new Exception("Execute failed: " . $stmt->error);
    }
    
    $result = $stmt->get_result();
    
    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "users" => $users,
        "count" => count($users)
    ]);
    
    $stmt->close();
} catch (Exception $e) {
    ob_clean();
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage(),
        "users" => [],
        "count" => 0
    ]);
}

$conn->close();
exit;

