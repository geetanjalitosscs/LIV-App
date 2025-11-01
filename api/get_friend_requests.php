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
    ob_clean();
    echo json_encode(["success" => false, "error" => "User ID required"]);
    exit;
}

$userId = (int)$input['user_id'];

try {
    // Get pending friend requests received by this user
    $sql = "SELECT 
                fr.id,
                fr.requester_id,
                fr.status,
                fr.created_at,
                u.id as user_id,
                u.full_name,
                u.age,
                u.location,
                u.bio
            FROM friend_requests fr
            INNER JOIN users u ON fr.requester_id = u.id
            WHERE fr.receiver_id = ? AND fr.status = 'pending'
            ORDER BY fr.created_at DESC";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('i', $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $requests = [];
    while ($row = $result->fetch_assoc()) {
        $requests[] = [
            'request_id' => (int)$row['id'],
            'user_id' => (int)$row['user_id'],
            'requester_id' => (int)$row['requester_id'],
            'full_name' => $row['full_name'],
            'age' => $row['age'] ? (int)$row['age'] : null,
            'location' => $row['location'],
            'bio' => $row['bio'],
            'status' => $row['status'],
            'created_at' => $row['created_at'],
        ];
    }
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "requests" => $requests
    ]);
    
    $stmt->close();
} catch (Exception $e) {
    ob_clean();
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage(),
        "requests" => []
    ]);
}

$conn->close();
exit;

