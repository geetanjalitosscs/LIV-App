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

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['sender_id']) || empty($input['receiver_id']) || empty($input['message'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Sender ID, Receiver ID, and message required"]);
    exit;
}

$senderId = (int)$input['sender_id'];
$receiverId = (int)$input['receiver_id'];
$message = trim($input['message']);

if (empty($message)) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Message cannot be empty"]);
    exit;
}

if ($senderId === $receiverId) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Cannot send message to yourself"]);
    exit;
}

// Encrypt the message before storing
$encryptedMessage = encrypt_data($message);
$encryptedMessageEscaped = $conn->real_escape_string($encryptedMessage);

try {
    $sql = "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)";
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $stmt->bind_param('iis', $senderId, $receiverId, $encryptedMessageEscaped);
    
    if (@$stmt->execute()) {
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $messageId = $stmt->insert_id;
        
        // Fetch the created message with sender info
        $selectSql = "SELECT m.*, u.full_name as sender_name 
                     FROM messages m 
                     JOIN users u ON m.sender_id = u.id 
                     WHERE m.id = ?";
        $selectStmt = @$conn->prepare($selectSql);
        if (!$selectStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $selectStmt->bind_param('i', $messageId);
        $selectStmt->execute();
        $result = $selectStmt->get_result();
        $messageData = $result->fetch_assoc();
        $selectStmt->close();
        
        // Decrypt the message before sending to client
        if (isset($messageData['message'])) {
            $messageData['message'] = decrypt_data($messageData['message']);
        }
        
        ob_clean();
        echo json_encode([
            "success" => true,
            "message" => $messageData
        ]);
    } else {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Failed to send message"]);
    }
    
    $stmt->close();
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;
?>
