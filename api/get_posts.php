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

@$conn->query("CREATE TABLE IF NOT EXISTS post_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_post_like (post_id, user_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id)
)");

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

$currentUserId = isset($input['current_user_id']) ? (int)$input['current_user_id'] : null;

try {
    // Get all posts with user info, like counts, comment counts, and if current user liked each post
    $sql = "SELECT 
                p.id,
                p.user_id,
                p.content,
                p.created_at,
                p.updated_at,
                u.full_name,
                u.email,
                COALESCE(COUNT(DISTINCT pl.id), 0) as likes_count,
                COALESCE(COUNT(DISTINCT c.id), 0) as comments_count,
                CASE WHEN pl2.id IS NOT NULL THEN 1 ELSE 0 END as is_liked
            FROM posts p
            JOIN users u ON p.user_id = u.id
            LEFT JOIN post_likes pl ON p.id = pl.post_id
            LEFT JOIN comments c ON p.id = c.post_id
            LEFT JOIN post_likes pl2 ON p.id = pl2.post_id AND pl2.user_id = ?
            GROUP BY p.id, p.user_id, p.content, p.created_at, p.updated_at, u.full_name, u.email, pl2.id
            ORDER BY p.created_at DESC";
    
    $stmt = @$conn->prepare($sql);
    if (!$stmt) {
        ob_clean();
        echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
        exit;
    }
    
    // If no current user, use 0 which won't match any likes
    $checkUserId = $currentUserId ?? 0;
    $stmt->bind_param('i', $checkUserId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $posts = [];
    while ($row = $result->fetch_assoc()) {
        $posts[] = [
            'id' => (int)$row['id'],
            'user_id' => (int)$row['user_id'],
            'user_name' => $row['full_name'],
            'user_email' => $row['email'],
            'content' => $row['content'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
            'likes_count' => (int)$row['likes_count'],
            'comments_count' => (int)$row['comments_count'],
            'is_liked' => (bool)$row['is_liked'],
        ];
    }
    
    $stmt->close();
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "posts" => $posts
    ]);
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;
?>
