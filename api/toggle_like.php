<?php
// Prevent any output before JSON
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();

// Create likes table if not exists
$conn->query("CREATE TABLE IF NOT EXISTS likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    liked_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_like (user_id, liked_user_id),
    INDEX idx_liked_user (liked_user_id)
)");

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['user_id']) || empty($input['liked_user_id'])) {
    echo json_encode(["success" => false, "error" => "User ID and Liked User ID required"]); exit;
}

$userId = (int)$input['user_id'];
$likedUserId = (int)$input['liked_user_id'];

// Prevent users from liking themselves
if ($userId === $likedUserId) {
    echo json_encode(["success" => false, "error" => "Cannot like yourself"]); exit;
}

try {
    // Check if like already exists
    $checkSql = "SELECT id FROM likes WHERE user_id = ? AND liked_user_id = ? LIMIT 1";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param('ii', $userId, $likedUserId);
    $checkStmt->execute();
    $checkResult = $checkStmt->get_result();
    
    if ($checkResult->num_rows > 0) {
        // Unlike - remove the like
        $deleteSql = "DELETE FROM likes WHERE user_id = ? AND liked_user_id = ?";
        $deleteStmt = $conn->prepare($deleteSql);
        $deleteStmt->bind_param('ii', $userId, $likedUserId);
        $deleteStmt->execute();
        $deleteStmt->close();
        
        // Get updated like count
        $countSql = "SELECT COUNT(*) as count FROM likes WHERE liked_user_id = ?";
        $countStmt = $conn->prepare($countSql);
        $countStmt->bind_param('i', $likedUserId);
        $countStmt->execute();
        $countResult = $countStmt->get_result();
        $countRow = $countResult->fetch_assoc();
        $likeCount = (int)$countRow['count'];
        $countStmt->close();
        
        echo json_encode([
            "success" => true,
            "liked" => false,
            "like_count" => $likeCount,
            "message" => "Like removed"
        ]);
    } else {
        // Like - add the like
        $insertSql = "INSERT INTO likes (user_id, liked_user_id) VALUES (?, ?)";
        $insertStmt = $conn->prepare($insertSql);
        $insertStmt->bind_param('ii', $userId, $likedUserId);
        $insertStmt->execute();
        $insertStmt->close();
        
        // Get updated like count
        $countSql = "SELECT COUNT(*) as count FROM likes WHERE liked_user_id = ?";
        $countStmt = $conn->prepare($countSql);
        $countStmt->bind_param('i', $likedUserId);
        $countStmt->execute();
        $countResult = $countStmt->get_result();
        $countRow = $countResult->fetch_assoc();
        $likeCount = (int)$countRow['count'];
        $countStmt->close();
        
        echo json_encode([
            "success" => true,
            "liked" => true,
            "like_count" => $likeCount,
            "message" => "User liked successfully"
        ]);
    }
    
    $checkStmt->close();
} catch (Exception $e) {
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}

$conn->close();
