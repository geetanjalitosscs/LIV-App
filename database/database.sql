-- ============================================
-- LIV App Database Setup Script
-- ============================================
-- This script creates the database, users table, and likes table
-- Run this in your MySQL/XAMPP phpMyAdmin or MySQL command line
-- ============================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS liv CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use the database
USE liv;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    gender ENUM('Male', 'Female', 'Other') DEFAULT NULL,
    age INT DEFAULT NULL,
    location VARCHAR(100) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create likes table
CREATE TABLE IF NOT EXISTS likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    liked_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_like (user_id, liked_user_id),
    INDEX idx_liked_user (liked_user_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (liked_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Database Setup Complete
-- ============================================
-- Tables created:
-- 1. users - Stores user profile information
-- 2. likes - Stores like relationships between users
-- ============================================

