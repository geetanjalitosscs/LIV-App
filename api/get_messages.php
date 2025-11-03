<?php
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
require_once './encryption_helper.php';
ob_end_clean();
ob_start();

// Create tables if not exist
@$conn->query("CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    is_deleted_for_sender TINYINT(1) DEFAULT 0,
    is_deleted_for_receiver TINYINT(1) DEFAULT 0,
    edited_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sender (sender_id),
    INDEX idx_receiver (receiver_id),
    INDEX idx_created_at (created_at),
    INDEX idx_conversation (sender_id, receiver_id)
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
@$conn->query("CREATE TABLE IF NOT EXISTS message_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_message_like (message_id, user_id),
    FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)");
if (ob_get_level() > 0) {
    ob_clean();
}

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['user1_id']) || empty($input['user2_id'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Both user IDs required"]);
    exit;
}

$user1Id = (int)$input['user1_id'];
$user2Id = (int)$input['user2_id'];
$currentUserId = $user1Id; // The user making the request

try {
    // Get all messages between the two users with like counts and user's like status
    $sql = "SELECT m.*, 
                   u1.full_name as sender_name,
                   u2.full_name as receiver_name,
                   COALESCE(COUNT(DISTINCT ml.id), 0) as likes_count,
                   CASE WHEN ml2.id IS NOT NULL THEN 1 ELSE 0 END as is_liked_by_user
            FROM messages m
            JOIN users u1 ON m.sender_id = u1.id
            JOIN users u2 ON m.receiver_id = u2.id
            LEFT JOIN message_likes ml ON m.id = ml.message_id
            LEFT JOIN message_likes ml2 ON m.id = ml2.message_id AND ml2.user_id = ?
            WHERE ((m.sender_id = ? AND m.receiver_id = ?)
               OR (m.sender_id = ? AND m.receiver_id = ?))
               AND NOT (
                   (m.sender_id = ? AND m.is_deleted_for_sender = 1)
                   OR (m.receiver_id = ? AND m.is_deleted_for_receiver = 1)
               )
            GROUP BY m.id, m.sender_id, m.receiver_id, m.message, m.is_read, 
                     m.is_deleted_for_sender, m.is_deleted_for_receiver, m.edited_at,
                     m.created_at, u1.full_name, u2.full_name, ml2.id
            ORDER BY m.created_at ASC";
    
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $stmt->bind_param('iiiiiii', $currentUserId, $user1Id, $user2Id, $user2Id, $user1Id, $currentUserId, $currentUserId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $messages = [];
    while ($row = $result->fetch_assoc()) {
        // Decrypt the message before sending to client
        $decryptedMessage = decrypt_data($row['message']);
        
        $messages[] = [
            'id' => (int)$row['id'],
            'sender_id' => (int)$row['sender_id'],
            'receiver_id' => (int)$row['receiver_id'],
            'sender_name' => $row['sender_name'],
            'receiver_name' => $row['receiver_name'],
            'message' => $decryptedMessage,
            'is_read' => (bool)$row['is_read'],
            'edited_at' => $row['edited_at'],
            'created_at' => $row['created_at'],
            'likes_count' => (int)$row['likes_count'],
            'is_liked' => (bool)$row['is_liked_by_user'],
        ];
    }
    
    $stmt->close();
    
    // Mark messages as read for the receiver
    if (!empty($messages)) {
        $updateSql = "UPDATE messages 
                     SET is_read = 1 
                     WHERE receiver_id = ? AND sender_id = ? AND is_read = 0";
        $updateStmt = @$conn->prepare($updateSql);
        if ($updateStmt) {
            $updateStmt->bind_param('ii', $user1Id, $user2Id);
            @$updateStmt->execute();
            if (ob_get_level() > 0) {
                ob_clean();
            }
            $updateStmt->close();
        }
    }
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "messages" => $messages
    ]);
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;
?>
