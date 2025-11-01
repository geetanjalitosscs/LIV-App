<?php
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();
ob_start();

// Create tables if not exist
@$conn->query("CREATE TABLE IF NOT EXISTS shares (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    shared_with_user_id INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    INDEX idx_shared_with (shared_with_user_id)
)");
if (ob_get_level() > 0) {
    ob_clean();
}

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['post_id']) || empty($input['user_id'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Post ID and User ID required"]);
    exit;
}

$postId = (int)$input['post_id'];
$userId = (int)$input['user_id'];
$sharedWithUserId = isset($input['shared_with_user_id']) ? (int)$input['shared_with_user_id'] : null;

try {
    $sql = "INSERT INTO shares (post_id, user_id, shared_with_user_id) VALUES (?, ?, ?)";
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    $stmt->bind_param('iii', $postId, $userId, $sharedWithUserId);
    
    if (@$stmt->execute()) {
        if (ob_get_level() > 0) {
            ob_clean();
        }
        
        // Get share count for the post
        $countSql = "SELECT COUNT(*) as count FROM shares WHERE post_id = ?";
        $countStmt = @$conn->prepare($countSql);
        if (!$countStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $countStmt->bind_param('i', $postId);
        $countStmt->execute();
        $countResult = $countStmt->get_result();
        $countRow = $countResult->fetch_assoc();
        $shareCount = (int)$countRow['count'];
        $countStmt->close();
        
        ob_clean();
        echo json_encode([
            "success" => true,
            "message" => "Post shared successfully",
            "shares_count" => $shareCount
        ]);
    } else {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Failed to share post"]);
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
