<?php
/**
 * Encryption helper functions for messages, posts, and bio
 * Uses AES-256-CBC encryption
 */

// Encryption key - CHANGE THIS IN PRODUCTION!
// Should be stored securely (environment variable, secure config file, etc.)
define('ENCRYPTION_KEY', 'LivApp_SecretKey_2024_ChangeMeInProduction!');
define('ENCRYPTION_METHOD', 'AES-256-CBC');

/**
 * Encrypt data
 * @param string $data Data to encrypt
 * @return string Encrypted data with IV prepended
 */
function encrypt_data($data) {
    if (empty($data)) {
        return $data;
    }
    
    // Generate a random IV for each encryption
    $iv_length = openssl_cipher_iv_length(ENCRYPTION_METHOD);
    $iv = openssl_random_pseudo_bytes($iv_length);
    
    // Encrypt the data
    $encrypted = openssl_encrypt($data, ENCRYPTION_METHOD, ENCRYPTION_KEY, 0, $iv);
    
    // Prepend IV to encrypted data (IV is needed for decryption)
    return base64_encode($iv . $encrypted);
}

/**
 * Decrypt data
 * @param string $encrypted_data Encrypted data with IV prepended
 * @return string Decrypted data
 */
function decrypt_data($encrypted_data) {
    if (empty($encrypted_data)) {
        return $encrypted_data;
    }
    
    try {
        // Decode from base64
        $data = base64_decode($encrypted_data);
        
        if ($data === false) {
            // If base64 decode fails, might be unencrypted data (for backwards compatibility)
            return $encrypted_data;
        }
        
        // Extract IV (first bytes) and encrypted content
        $iv_length = openssl_cipher_iv_length(ENCRYPTION_METHOD);
        if (strlen($data) < $iv_length) {
            // Data too short, might be unencrypted
            return $encrypted_data;
        }
        
        $iv = substr($data, 0, $iv_length);
        $encrypted = substr($data, $iv_length);
        
        // Decrypt the data
        $decrypted = openssl_decrypt($encrypted, ENCRYPTION_METHOD, ENCRYPTION_KEY, 0, $iv);
        
        // If decryption fails, return original (might be unencrypted legacy data)
        return $decrypted !== false ? $decrypted : $encrypted_data;
    } catch (Exception $e) {
        // If anything fails, return original data (for backwards compatibility)
        return $encrypted_data;
    }
}

