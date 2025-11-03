<?php
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();
ob_start();

// Auto-create tables if not exists
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

$input = json_decode(file_get_contents('php://input'), true) ?: [];

if (empty($input['message_id']) || empty($input['user_id'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Message ID and User ID required"]);
    exit;
}

$messageId = (int)$input['message_id'];
$userId = (int)$input['user_id'];

try {
    // Check if like already exists
    $checkSql = "SELECT id FROM message_likes WHERE message_id = ? AND user_id = ?";
    $checkStmt = @$conn->prepare($checkSql);
    if (!$checkStmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    $checkStmt->bind_param('ii', $messageId, $userId);
    $checkStmt->execute();
    $result = $checkStmt->get_result();

    $isLiked = false;
    if ($result->num_rows > 0) {
        // Like exists, so unlike (delete)
        $deleteSql = "DELETE FROM message_likes WHERE message_id = ? AND user_id = ?";
        $deleteStmt = @$conn->prepare($deleteSql);
        if (!$deleteStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $deleteStmt->bind_param('ii', $messageId, $userId);
        @$deleteStmt->execute();
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $deleteStmt->close();
        $isLiked = false;
    } else {
        // Like does not exist, so like (insert)
        $insertSql = "INSERT INTO message_likes (message_id, user_id) VALUES (?, ?)";
        $insertStmt = @$conn->prepare($insertSql);
        if (!$insertStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $insertStmt->bind_param('ii', $messageId, $userId);
        @$insertStmt->execute();
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $insertStmt->close();
        $isLiked = true;
    }
    $checkStmt->close();

    // Get updated like count
    $countSql = "SELECT COUNT(id) as likes_count FROM message_likes WHERE message_id = ?";
    $countStmt = @$conn->prepare($countSql);
    if (!$countStmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    $countStmt->bind_param('i', $messageId);
    $countStmt->execute();
    $countResult = $countStmt->get_result();
    $likesCount = $countResult->fetch_assoc()['likes_count'];
    $countStmt->close();

    ob_clean();
    echo json_encode([
        "success" => true,
        "is_liked" => $isLiked,
        "likes_count" => (int)$likesCount
    ]);

} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;
?>
