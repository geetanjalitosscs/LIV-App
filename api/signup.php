<?php
header('Content-Type: application/json');
require_once './config_db.php';
require_once './encryption_helper.php';

// Auto-create users table if not exists
$conn->query("CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    gender VARCHAR(15) NOT NULL,
    age INT NOT NULL,
    location VARCHAR(100) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)");

// Read JSON or form POST
$input = $_POST;
if (empty($input)) {
    $input = json_decode(file_get_contents('php://input'), true) ?: [];
}

$required = ['full_name', 'email', 'phone', 'password', 'gender', 'age'];
foreach ($required as $field) {
    if (empty($input[$field])) {
        echo json_encode(["success" => false, "error" => "Missing: $field"]); exit;
    }
}

$full_name = $conn->real_escape_string(trim($input['full_name']));
$email = strtolower($conn->real_escape_string(trim($input['email'])));
$phone = $conn->real_escape_string(trim($input['phone']));
$password = password_hash($input['password'], PASSWORD_DEFAULT);
$gender = $conn->real_escape_string(trim($input['gender']));
$age = (int)$input['age'];
$location = isset($input['location']) ? $conn->real_escape_string(trim($input['location'])) : '';
$bio = isset($input['bio']) ? trim($input['bio']) : '';

// Check for duplicate email
$chk = $conn->query("SELECT id FROM users WHERE email='$email' LIMIT 1");
if ($chk && $chk->num_rows > 0) {
    echo json_encode(["success" => false, "error" => "Email already registered."]); exit;
}

// Encrypt bio if provided
$encryptedBio = !empty($bio) ? encrypt_data($bio) : null;
$encryptedBioEscaped = $encryptedBio ? $conn->real_escape_string($encryptedBio) : null;

if ($encryptedBioEscaped) {
    $sql = "INSERT INTO users (full_name, email, phone, password, gender, age, location, bio) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('sssssiss', $full_name, $email, $phone, $password, $gender, $age, $location, $encryptedBioEscaped);
} else {
    $sql = "INSERT INTO users (full_name, email, phone, password, gender, age, location) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param('sssssis', $full_name, $email, $phone, $password, $gender, $age, $location);
}

if ($stmt->execute()) {
    $userId = $stmt->insert_id;
    // Fetch the created user data
    $getUser = $conn->query("SELECT id, full_name, email, phone, gender, age, location, bio, created_at FROM users WHERE id=$userId LIMIT 1");
    $user = $getUser->fetch_assoc();
    
    // Decrypt bio before sending to client
    if (isset($user['bio']) && !empty($user['bio'])) {
        $user['bio'] = decrypt_data($user['bio']);
    }
    
    echo json_encode(["success" => true, "user" => $user]);
} else {
    echo json_encode(["success" => false, "error" => $stmt->error]);
}
$stmt->close();
$conn->close();
