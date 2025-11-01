<?php
// One-time script to clean up existing rejected friend requests
// Run this once to delete all rejected requests from the database
header('Content-Type: application/json');
require_once './config_db.php';

try {
    $deleteSql = "DELETE FROM friend_requests WHERE status = 'rejected'";
    $result = $conn->query($deleteSql);
    
    $deletedCount = $conn->affected_rows;
    
    echo json_encode([
        "success" => true,
        "message" => "Cleaned up rejected friend requests",
        "deleted_count" => $deletedCount
    ]);
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}

$conn->close();

