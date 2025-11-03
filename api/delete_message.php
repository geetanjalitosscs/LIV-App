<?php
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();
ob_start();

// Auto-create messages table if not exists
@$conn->query("CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    is_deleted_for_sender TINYINT(1) DEFAULT 0,
    is_deleted_for_receiver TINYINT(1) DEFAULT 0,
    edited_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)");
if (ob_get_level() > 0) {
    ob_clean();
}

// Add new columns to existing table if they don't exist
$checkCol = @$conn->query("SHOW COLUMNS FROM messages LIKE 'is_deleted_for_sender'");
if (!$checkCol || $checkCol->num_rows == 0) {
    @$conn->query("ALTER TABLE messages ADD COLUMN is_deleted_for_sender TINYINT(1) DEFAULT 0");
    if (ob_get_level() > 0) {
        ob_clean();
    }
}
$checkCol = @$conn->query("SHOW COLUMNS FROM messages LIKE 'is_deleted_for_receiver'");
if (!$checkCol || $checkCol->num_rows == 0) {
    @$conn->query("ALTER TABLE messages ADD COLUMN is_deleted_for_receiver TINYINT(1) DEFAULT 0");
    if (ob_get_level() > 0) {
        ob_clean();
    }
}
$checkCol = @$conn->query("SHOW COLUMNS FROM messages LIKE 'edited_at'");
if (!$checkCol || $checkCol->num_rows == 0) {
    @$conn->query("ALTER TABLE messages ADD COLUMN edited_at TIMESTAMP NULL DEFAULT NULL");
    if (ob_get_level() > 0) {
        ob_clean();
    }
}

$input = json_decode(file_get_contents('php://input'), true) ?: [];

if (empty($input['message_id']) || empty($input['user_id'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Message ID and User ID required"]);
    exit;
}

$messageId = (int)$input['message_id'];
$userId = (int)$input['user_id'];

try {
    // Get message details
    $checkSql = "SELECT sender_id, receiver_id FROM messages WHERE id = ?";
    $checkStmt = @$conn->prepare($checkSql);
    if (!$checkStmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    $checkStmt->bind_param('i', $messageId);
    $checkStmt->execute();
    $result = $checkStmt->get_result();
    
    if ($result->num_rows === 0) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Message not found"]);
        exit;
    }
    
    $message = $result->fetch_assoc();
    $senderId = (int)$message['sender_id'];
    $receiverId = (int)$message['receiver_id'];
    $checkStmt->close();
    
    $isSender = ($userId === $senderId);
    $isReceiver = ($userId === $receiverId);
    
    if (!$isSender && !$isReceiver) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "You don't have permission to delete this message"]);
        exit;
    }
    
    // Update deletion flags
    if ($isSender) {
        // If sender deletes: delete for both sender and receiver
        $updateSql = "UPDATE messages SET is_deleted_for_sender = 1, is_deleted_for_receiver = 1 WHERE id = ?";
    } else {
        // If receiver deletes: only delete for receiver
        $updateSql = "UPDATE messages SET is_deleted_for_receiver = 1 WHERE id = ?";
    }
    
    $updateStmt = @$conn->prepare($updateSql);
    if (!$updateStmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $updateStmt->bind_param('i', $messageId);
    
    if (@$updateStmt->execute()) {
        if (ob_get_level() > 0) {
            ob_clean();
        }
        ob_clean();
        echo json_encode([
            "success" => true,
            "message" => "Message deleted successfully"
        ]);
    } else {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Failed to delete message"]);
    }
    
    $updateStmt->close();
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;
?>
