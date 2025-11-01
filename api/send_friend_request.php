<?php
// Prevent any output before JSON
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
// Clean any output from config_db.php
ob_end_clean();
ob_start();

// Create friend_requests table if not exists (suppress warnings)
@$conn->query("CREATE TABLE IF NOT EXISTS friend_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    requester_id INT NOT NULL,
    receiver_id INT NOT NULL,
    status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_request (requester_id, receiver_id),
    INDEX idx_requester (requester_id),
    INDEX idx_receiver (receiver_id),
    INDEX idx_status (status),
    FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
// Clean any output from CREATE TABLE query
if (ob_get_level() > 0) {
    ob_clean();
}

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['requester_id']) || empty($input['receiver_id'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Requester ID and Receiver ID required"]);
    exit;
}

$requesterId = (int)$input['requester_id'];
$receiverId = (int)$input['receiver_id'];

// Prevent users from sending friend request to themselves
if ($requesterId === $receiverId) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Cannot send friend request to yourself"]);
    exit;
}

try {
    // Check if request already exists
    $checkSql = "SELECT id, status FROM friend_requests WHERE requester_id = ? AND receiver_id = ? LIMIT 1";
    $checkStmt = $conn->prepare($checkSql);
    $checkStmt->bind_param('ii', $requesterId, $receiverId);
    $checkStmt->execute();
    $checkResult = $checkStmt->get_result();
    
    if ($checkResult->num_rows > 0) {
        $existing = $checkResult->fetch_assoc();
        $status = $existing['status'];
        $checkStmt->close();
        
        if ($status === 'pending') {
            ob_clean();
            echo json_encode([
                "success" => false,
                "error" => "Friend request already sent and pending"
            ]);
            exit;
        } elseif ($status === 'accepted') {
            ob_clean();
            echo json_encode([
                "success" => false,
                "error" => "Already friends with this user"
            ]);
            exit;
        }
        // If status is 'rejected' (shouldn't happen as rejected requests are deleted),
        // or any other status, we'll continue to insert a new request
    }
    $checkStmt->close();
    
    // Check if reverse request exists (receiver sending to requester)
    // Only check for pending or accepted (rejected requests are deleted)
    $reverseSql = "SELECT id, status FROM friend_requests WHERE requester_id = ? AND receiver_id = ? AND status IN ('pending', 'accepted') LIMIT 1";
    $reverseStmt = $conn->prepare($reverseSql);
    $reverseStmt->bind_param('ii', $receiverId, $requesterId);
    $reverseStmt->execute();
    $reverseResult = $reverseStmt->get_result();
    
    if ($reverseResult->num_rows > 0) {
        $reverse = $reverseResult->fetch_assoc();
        $reverseStmt->close();
        
        if ($reverse['status'] === 'pending') {
            ob_clean();
            echo json_encode([
                "success" => false,
                "error" => "This user has already sent you a friend request"
            ]);
            exit;
        } elseif ($reverse['status'] === 'accepted') {
            ob_clean();
            echo json_encode([
                "success" => false,
                "error" => "Already friends with this user"
            ]);
            exit;
        }
    }
    $reverseStmt->close();
    
    // Insert new friend request
    $insertSql = "INSERT INTO friend_requests (requester_id, receiver_id, status) VALUES (?, ?, 'pending')";
    $insertStmt = $conn->prepare($insertSql);
    $insertStmt->bind_param('ii', $requesterId, $receiverId);
    $insertStmt->execute();
    $insertStmt->close();
    
    ob_clean();
    echo json_encode([
        "success" => true,
        "message" => "Friend request sent successfully"
    ]);
    
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;

