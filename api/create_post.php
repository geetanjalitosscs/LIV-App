<?php
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();
ob_start();

// Create tables if not exist
@$conn->query("CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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

if (empty($input['user_id']) || empty($input['content'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "User ID and content required"]);
    exit;
}

$userId = (int)$input['user_id'];
$content = $conn->real_escape_string(trim($input['content']));

if (empty($content)) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Post content cannot be empty"]);
    exit;
}

try {
    $sql = "INSERT INTO posts (user_id, content) VALUES (?, ?)";
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $stmt->bind_param('is', $userId, $content);
    
    if (@$stmt->execute()) {
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $postId = $stmt->insert_id;
        
        // Fetch the created post with user info
        $selectSql = "SELECT p.*, u.full_name, u.email 
                     FROM posts p 
                     JOIN users u ON p.user_id = u.id 
                     WHERE p.id = ?";
        $selectStmt = @$conn->prepare($selectSql);
        if (!$selectStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $selectStmt->bind_param('i', $postId);
        $selectStmt->execute();
        $result = $selectStmt->get_result();
        $post = $result->fetch_assoc();
        $selectStmt->close();
        
        ob_clean();
        echo json_encode([
            "success" => true,
            "post" => $post
        ]);
    } else {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Failed to create post"]);
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
