<?php
// Prevent any output before JSON
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['user_ids'])) {
    echo json_encode(["success" => false, "error" => "User IDs required"]); exit;
}

$userIds = is_array($input['user_ids']) ? $input['user_ids'] : [$input['user_ids']];
$userIds = array_map('intval', $userIds);

// Prepare placeholders for IN clause
$placeholders = implode(',', array_fill(0, count($userIds), '?'));
$types = str_repeat('i', count($userIds));

try {
    $sql = "SELECT liked_user_id, COUNT(*) as count FROM likes WHERE liked_user_id IN ($placeholders) GROUP BY liked_user_id";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, ...$userIds);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $likes = [];
    while ($row = $result->fetch_assoc()) {
        $likes[(int)$row['liked_user_id']] = (int)$row['count'];
    }
    
    // Ensure all requested user IDs are in the response (with 0 likes if not found)
    $likesCount = [];
    foreach ($userIds as $userId) {
        $likesCount[$userId] = $likes[$userId] ?? 0;
    }
    
    echo json_encode([
        "success" => true,
        "likes" => $likesCount
    ]);
    
    $stmt->close();
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage(),
        "likes" => []
    ]);
}

$conn->close();
