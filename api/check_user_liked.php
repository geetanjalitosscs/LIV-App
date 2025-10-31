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

if (empty($input['user_id']) || empty($input['liked_user_ids'])) {
    echo json_encode(["success" => false, "error" => "User ID and Liked User IDs required"]); exit;
}

$userId = (int)$input['user_id'];
$likedUserIds = is_array($input['liked_user_ids']) ? $input['liked_user_ids'] : [$input['liked_user_ids']];
$likedUserIds = array_map('intval', $likedUserIds);

// Prepare placeholders for IN clause
$placeholders = implode(',', array_fill(0, count($likedUserIds), '?'));
$types = 'i' . str_repeat('i', count($likedUserIds)); // First 'i' for user_id, then for liked_user_ids

try {
    $sql = "SELECT liked_user_id FROM likes WHERE user_id = ? AND liked_user_id IN ($placeholders)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param($types, $userId, ...$likedUserIds);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $likedUsers = [];
    while ($row = $result->fetch_assoc()) {
        $likedUsers[] = (int)$row['liked_user_id'];
    }
    
    echo json_encode([
        "success" => true,
        "liked_user_ids" => $likedUsers
    ]);
    
    $stmt->close();
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage(),
        "liked_user_ids" => []
    ]);
}

$conn->close();
