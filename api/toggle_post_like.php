<?php
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();
ob_start();

// Create tables if not exist
@$conn->query("CREATE TABLE IF NOT EXISTS post_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_post_like (post_id, user_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id)
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

try {
    // Check if like exists
    $checkSql = "SELECT id FROM post_likes WHERE post_id = ? AND user_id = ?";
    $checkStmt = @$conn->prepare($checkSql);
    if (!$checkStmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    $checkStmt->bind_param('ii', $postId, $userId);
    $checkStmt->execute();
    $result = $checkStmt->get_result();
    $likeExists = $result->fetch_assoc();
    $checkStmt->close();
    
    if ($likeExists) {
        // Unlike - delete the like
        $deleteSql = "DELETE FROM post_likes WHERE post_id = ? AND user_id = ?";
        $deleteStmt = @$conn->prepare($deleteSql);
        if (!$deleteStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $deleteStmt->bind_param('ii', $postId, $userId);
        @$deleteStmt->execute();
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $deleteStmt->close();
    } else {
        // Like - insert the like
        $insertSql = "INSERT INTO post_likes (post_id, user_id) VALUES (?, ?)";
        $insertStmt = @$conn->prepare($insertSql);
        if (!$insertStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $insertStmt->bind_param('ii', $postId, $userId);
        @$insertStmt->execute();
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $insertStmt->close();
    }
    
    // Get updated like count
    $countSql = "SELECT COUNT(*) as count FROM post_likes WHERE post_id = ?";
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
    $likeCount = (int)$countRow['count'];
    $countStmt->close();
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "is_liked" => !$likeExists,
        "likes_count" => $likeCount
    ]);
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;
?>
