-- SQL to add location column to users table
-- Run this in your MySQL database

ALTER TABLE users ADD COLUMN location VARCHAR(100) DEFAULT NULL AFTER age;

