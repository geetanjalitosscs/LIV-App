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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sender (sender_id),
    INDEX idx_receiver (receiver_id),
    INDEX idx_created_at (created_at),
    INDEX idx_conversation (sender_id, receiver_id)
)");
if (ob_get_level() > 0) {
    ob_clean();
}

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['user_id'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "User ID required"]);
    exit;
}

$userId = (int)$input['user_id'];

try {
    // Get all conversations for this user (people they've messaged or been messaged by)
    // Get the last message for each conversation
    $sql = "SELECT 
                CASE 
                    WHEN m.sender_id = ? THEN m.receiver_id
                    ELSE m.sender_id
                END as other_user_id,
                u.full_name as other_user_name,
                u.email as other_user_email,
                m.message as last_message,
                m.created_at as last_message_time,
                CASE 
                    WHEN m.sender_id = ? THEN 0
                    ELSE m.is_read
                END as is_read,
                COUNT(CASE WHEN m.sender_id != ? AND m.is_read = 0 THEN 1 END) as unread_count
            FROM messages m
            JOIN users u ON (
                CASE 
                    WHEN m.sender_id = ? THEN u.id = m.receiver_id
                    ELSE u.id = m.sender_id
                END
            )
            WHERE m.sender_id = ? OR m.receiver_id = ?
            GROUP BY other_user_id, u.full_name, u.email, m.id, m.message, m.created_at, m.is_read, m.sender_id
            ORDER BY m.created_at DESC";
    
    // First, get all unique conversations
    $allConvsSql = "SELECT DISTINCT
                        CASE 
                            WHEN sender_id = ? THEN receiver_id
                            ELSE sender_id
                        END as other_user_id
                    FROM messages
                    WHERE sender_id = ? OR receiver_id = ?";
    $allConvsStmt = @$conn->prepare($allConvsSql);
    if (!$allConvsStmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    $allConvsStmt->bind_param('iii', $userId, $userId, $userId);
    $allConvsStmt->execute();
    $allConvsResult = $allConvsStmt->get_result();
    
    $conversations = [];
    while ($convRow = $allConvsResult->fetch_assoc()) {
        $otherUserId = (int)$convRow['other_user_id'];
        
        // Get user info
        $userSql = "SELECT id, full_name, email FROM users WHERE id = ?";
        $userStmt = @$conn->prepare($userSql);
        $userStmt->bind_param('i', $otherUserId);
        $userStmt->execute();
        $userResult = $userStmt->get_result();
        $userRow = $userResult->fetch_assoc();
        $userStmt->close();
        
        if (!$userRow) continue;
        
        // Get last message sent BY the other user (not by current user)
        $lastMsgSql = "SELECT message, created_at 
                      FROM messages 
                      WHERE ((sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?))
                        AND sender_id = ?
                      ORDER BY created_at DESC 
                      LIMIT 1";
        $lastMsgStmt = @$conn->prepare($lastMsgSql);
        $lastMsgStmt->bind_param('iiiii', $otherUserId, $userId, $userId, $otherUserId, $otherUserId);
        $lastMsgStmt->execute();
        $lastMsgResult = $lastMsgStmt->get_result();
        $lastMsgRow = $lastMsgResult->fetch_assoc();
        $lastMsgStmt->close();
        
        // Count unread messages from other user
        $countSql = "SELECT COUNT(*) as unread_count 
                     FROM messages 
                     WHERE sender_id = ? AND receiver_id = ? AND is_read = 0";
        $countStmt = @$conn->prepare($countSql);
        $countStmt->bind_param('ii', $otherUserId, $userId);
        $countStmt->execute();
        $countResult = $countStmt->get_result();
        $countRow = $countResult->fetch_assoc();
        $unreadCount = (int)$countRow['unread_count'];
        $countStmt->close();
        
        // Decrypt the last message if it exists
        $decryptedLastMessage = '';
        if ($lastMsgRow && !empty($lastMsgRow['message'])) {
            $decryptedLastMessage = decrypt_data($lastMsgRow['message']);
        }
        
        $conversations[] = [
            'other_user_id' => $otherUserId,
            'other_user_name' => $userRow['full_name'],
            'other_user_email' => $userRow['email'],
            'last_message' => $decryptedLastMessage,
            'last_message_time' => $lastMsgRow ? $lastMsgRow['created_at'] : null,
            'unread_count' => $unreadCount,
        ];
    }
    $allConvsStmt->close();
    
    // Sort by last message time (if exists) or by most recent activity
    usort($conversations, function($a, $b) {
        $timeA = $a['last_message_time'] ?? '';
        $timeB = $b['last_message_time'] ?? '';
        if ($timeA && $timeB) {
            return strcmp($timeB, $timeA); // Descending order
        }
        return strcmp($timeB, $timeA);
    });
    
    // No need for the main $stmt anymore since we're done processing
    $stmt = null;
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "conversations" => $conversations
    ]);
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;
?>
