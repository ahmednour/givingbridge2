-- GivingBridge Database Initialization Script
-- This script creates the necessary tables for the GivingBridge application

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'donor', 'receiver') DEFAULT 'donor',
    phone VARCHAR(20),
    location VARCHAR(255),
    avatarUrl VARCHAR(500),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create donations table
CREATE TABLE IF NOT EXISTS donations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    `condition` VARCHAR(50) NOT NULL,
    location VARCHAR(255) NOT NULL,
    imageUrl VARCHAR(500),
    donorId INT NOT NULL,
    isAvailable BOOLEAN DEFAULT TRUE,
    status ENUM('available', 'pending', 'completed', 'cancelled') DEFAULT 'available',
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (donorId) REFERENCES users(id) ON DELETE CASCADE
);

-- Create requests table
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    donationId INT NOT NULL,
    donorId INT NOT NULL,
    donorName VARCHAR(255),
    receiverId INT NOT NULL,
    receiverName VARCHAR(255) NOT NULL,
    receiverEmail VARCHAR(255) NOT NULL,
    receiverPhone VARCHAR(20),
    message TEXT,
    status ENUM('pending', 'approved', 'declined', 'completed', 'cancelled') DEFAULT 'pending',
    respondedAt TIMESTAMP NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (donationId) REFERENCES donations(id) ON DELETE CASCADE,
    FOREIGN KEY (donorId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiverId) REFERENCES users(id) ON DELETE CASCADE
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    senderId INT NOT NULL,
    receiverId INT NOT NULL,
    donationId INT,
    requestId INT,
    content TEXT NOT NULL,
    messageType ENUM('text', 'image', 'file') DEFAULT 'text',
    isRead BOOLEAN DEFAULT FALSE,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (senderId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiverId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (donationId) REFERENCES donations(id) ON DELETE SET NULL,
    FOREIGN KEY (requestId) REFERENCES requests(id) ON DELETE SET NULL
);

-- Insert default admin user (password: admin123)
INSERT IGNORE INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@givingbridge.com', '$2a$12$9d9xWajdFCBw8wNuGtumeuJ1nme/ubR10xZ8Mc..D/jSyetVRac/K', 'admin');

-- Insert sample donor user (password: donor123)
INSERT IGNORE INTO users (name, email, password, role, phone, location) VALUES 
('John Doe', 'john@example.com', '$2a$12$GEfh06w4kEYD9Jn7fXIzleRmeUODGipcI878uLIXSwNyik15IYWu6', 'donor', '+1234567890', 'New York, NY');

-- Insert sample receiver user (password: receiver123)
INSERT IGNORE INTO users (name, email, password, role, phone, location) VALUES 
('Jane Smith', 'jane@example.com', '$2a$12$1q/XLOehcMemegBwdNVSk.mK.Wh8nBDMXdV2wJwOdYc..YVs7BSC6', 'receiver', '+0987654321', 'Los Angeles, CA');

-- Insert sample donations
INSERT IGNORE INTO donations (title, description, category, `condition`, location, donorId) VALUES 
('Old Books Collection', 'A collection of classic novels and textbooks in good condition', 'books', 'good', 'New York, NY', 2),
('Winter Clothes', 'Warm winter jackets and sweaters for adults', 'clothes', 'excellent', 'New York, NY', 2),
('Kitchen Appliances', 'Various kitchen appliances including blender and toaster', 'electronics', 'good', 'Los Angeles, CA', 2);

-- Insert sample requests
INSERT IGNORE INTO requests (donationId, donorId, donorName, receiverId, receiverName, receiverEmail, receiverPhone, message, status) VALUES 
(1, 2, 'John Doe', 3, 'Jane Smith', 'jane@example.com', '+0987654321', 'I would love to have these books for my children. They are studying literature.', 'pending'),
(2, 2, 'John Doe', 3, 'Jane Smith', 'jane@example.com', '+0987654321', 'These clothes would be perfect for my family during winter.', 'pending');
