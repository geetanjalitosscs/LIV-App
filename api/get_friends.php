<?php
// Prevent any output before JSON
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
ob_end_clean();
ob_start();

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['user_id'])) {
    echo json_encode(["success" => false, "error" => "User ID required"]);
    exit;
}

$userId = (int)$input['user_id'];

try {
    // Get all accepted friends for this user
    // A friend relationship exists when there's an accepted friend request
    // where either the user is the requester or the receiver
    $sql = "SELECT 
                CASE 
                    WHEN fr.requester_id = ? THEN fr.receiver_id
                    ELSE fr.requester_id
                END as friend_id,
                u.id as user_id,
                u.full_name,
                u.age,
                u.location,
                u.bio
            FROM friend_requests fr
            INNER JOIN users u ON (
                CASE 
                    WHEN fr.requester_id = ? THEN u.id = fr.receiver_id
                    ELSE u.id = fr.requester_id
                END
            )
            WHERE (fr.requester_id = ? OR fr.receiver_id = ?)
            AND fr.status = 'accepted'
            ORDER BY fr.updated_at DESC";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('iiii', $userId, $userId, $userId, $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $friends = [];
    while ($row = $result->fetch_assoc()) {
        $friends[] = [
            'user_id' => (int)$row['user_id'],
            'friend_id' => (int)$row['friend_id'],
            'full_name' => $row['full_name'],
            'age' => $row['age'] ? (int)$row['age'] : null,
            'location' => $row['location'],
            'bio' => $row['bio'],
        ];
    }
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "friends" => $friends
    ]);
    
    $stmt->close();
} catch (Exception $e) {
    ob_clean();
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage(),
        "friends" => []
    ]);
}

$conn->close();
exit;

