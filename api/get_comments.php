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

if (empty($input['post_id'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Post ID required"]);
    exit;
}

$postId = (int)$input['post_id'];

try {
    $sql = "SELECT c.*, u.full_name, u.email 
            FROM comments c
            JOIN users u ON c.user_id = u.id
            WHERE c.post_id = ?
            ORDER BY c.created_at ASC";
    
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $stmt->bind_param('i', $postId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $comments = [];
    while ($row = $result->fetch_assoc()) {
        // Decrypt the content before sending to client
        $decryptedContent = decrypt_data($row['content']);
        
        $comments[] = [
            'id' => (int)$row['id'],
            'post_id' => (int)$row['post_id'],
            'user_id' => (int)$row['user_id'],
            'user_name' => $row['full_name'],
            'user_email' => $row['email'],
            'content' => $decryptedContent,
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
        ];
    }
    
    $stmt->close();
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "comments" => $comments
    ]);
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;
?>
