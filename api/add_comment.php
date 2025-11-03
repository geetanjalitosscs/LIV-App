<?php
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
require_once './encryption_helper.php';
ob_end_clean();
ob_start();

// Create tables if not exist
@$conn->query("CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
)");
if (ob_get_level() > 0) {
    ob_clean();
}

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['post_id']) || empty($input['user_id']) || empty($input['content'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Post ID, User ID, and content required"]);
    exit;
}

$postId = (int)$input['post_id'];
$userId = (int)$input['user_id'];
$content = trim($input['content']);

if (empty($content)) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Comment content cannot be empty"]);
    exit;
}

// Encrypt the content before storing
$encryptedContent = encrypt_data($content);
$encryptedContentEscaped = $conn->real_escape_string($encryptedContent);

try {
    $sql = "INSERT INTO comments (post_id, user_id, content) VALUES (?, ?, ?)";
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $stmt->bind_param('iis', $postId, $userId, $encryptedContentEscaped);
    
    if (@$stmt->execute()) {
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $commentId = $stmt->insert_id;
        
        // Fetch the created comment with user info
        $selectSql = "SELECT c.*, u.full_name, u.email 
                     FROM comments c 
                     JOIN users u ON c.user_id = u.id 
                     WHERE c.id = ?";
        $selectStmt = @$conn->prepare($selectSql);
        if (!$selectStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $selectStmt->bind_param('i', $commentId);
        $selectStmt->execute();
        $result = $selectStmt->get_result();
        $comment = $result->fetch_assoc();
        $selectStmt->close();
        
        // Decrypt the content before sending to client
        if (isset($comment['content'])) {
            $comment['content'] = decrypt_data($comment['content']);
        }
        
        ob_clean();
        echo json_encode([
            "success" => true,
            "comment" => $comment
        ]);
    } else {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Failed to add comment"]);
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
