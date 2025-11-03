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

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

// Consider users online if they were active in the last 5 minutes (300 seconds)
$onlineThreshold = 300; // 5 minutes in seconds

try {
    $sql = "SELECT id, 
                   CASE 
                       WHEN last_active_at IS NULL THEN 0
                       WHEN TIMESTAMPDIFF(SECOND, last_active_at, NOW()) <= ? THEN 1
                       ELSE 0
                   END as is_online
            FROM users";
    
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $stmt->bind_param('i', $onlineThreshold);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $onlineUsers = [];
    while ($row = $result->fetch_assoc()) {
        $onlineUsers[(int)$row['id']] = (bool)$row['is_online'];
    }
    
    $stmt->close();
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "online_users" => $onlineUsers
    ]);
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;

