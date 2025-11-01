<?php
// Prevent any output before JSON
ob_start();
header('Content-Type: application/json');
require_once './config_db.php';
// Clean any output from config_db.php
ob_end_clean();
ob_start();

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

if (empty($input['request_id']) || empty($input['action'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Request ID and action required"]);
    exit;
}

$requestId = (int)$input['request_id'];
$action = $input['action']; // 'accept' or 'reject'

if (!in_array($action, ['accept', 'reject'])) {
    ob_clean();
    echo json_encode(["success" => false, "error" => "Invalid action. Use 'accept' or 'reject'"]);
    exit;
}

try {
    // Get the request details
    $getSql = "SELECT requester_id, receiver_id, status FROM friend_requests WHERE id = ?";
    $getStmt = $conn->prepare($getSql);
    $getStmt->bind_param('i', $requestId);
    $getStmt->execute();
    $result = $getStmt->get_result();
    
    if ($result->num_rows === 0) {
        $getStmt->close();
        ob_clean();
        echo json_encode(["success" => false, "error" => "Friend request not found"]);
        exit;
    }
    
    $request = $result->fetch_assoc();
    
    if ($request['status'] !== 'pending') {
        $getStmt->close();
        ob_clean();
        echo json_encode(["success" => false, "error" => "Friend request already processed"]);
        exit;
    }
    
    $getStmt->close();
    
    if ($action === 'accept') {
        // Update the request status to accepted
        $updateSql = "UPDATE friend_requests SET status = 'accepted', updated_at = NOW() WHERE id = ?";
        $updateStmt = @$conn->prepare($updateSql);
        if (!$updateStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $updateStmt->bind_param('i', $requestId);
        @$updateStmt->execute();
        // Clean any output from UPDATE query
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $updateStmt->close();
        
        ob_clean();
        echo json_encode([
            "success" => true,
            "message" => "Friend request accepted",
            "status" => "accepted"
        ]);
    } else {
        // Delete the request instead of storing rejected status
        // This allows users to send requests again after rejection
        $deleteSql = "DELETE FROM friend_requests WHERE id = ?";
        $deleteStmt = @$conn->prepare($deleteSql);
        if (!$deleteStmt) {
            ob_clean();
            echo json_encode(["success" => false, "error" => "Database error: " . $conn->error]);
            exit;
        }
        $deleteStmt->bind_param('i', $requestId);
        @$deleteStmt->execute();
        // Clean any output from DELETE query
        if (ob_get_level() > 0) {
            ob_clean();
        }
        $deleteStmt->close();
        
        ob_clean();
        echo json_encode([
            "success" => true,
            "message" => "Friend request rejected",
            "status" => "deleted"
        ]);
    }
    
} catch (Exception $e) {
    ob_clean();
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
    exit;
}

$conn->close();
exit;

