-- ============================================
-- Add Missing Performance Indexes
-- Created: October 29, 2025
-- ============================================

-- Messages indexes (if not exist)
CREATE INDEX idx_messages_sender_id ON messages(senderId);
CREATE INDEX idx_messages_receiver_id ON messages(receiverId);
CREATE INDEX idx_messages_receiver_read_created ON messages(receiverId, isRead, createdAt DESC);
CREATE INDEX idx_messages_isread ON messages(isRead);

-- Donations optimization indexes
CREATE INDEX idx_donations_available_created ON donations(isAvailable, createdAt DESC);
CREATE INDEX idx_donations_category_location ON donations(category, location(50));
CREATE INDEX idx_donations_status_created ON donations(status, createdAt DESC);
CREATE INDEX idx_donations_category ON donations(category);
CREATE INDEX idx_donations_location ON donations(location(50));
CREATE INDEX idx_donations_donor_available ON donations(donorId, isAvailable);

-- Requests optimization indexes
CREATE INDEX idx_requests_status_created ON requests(status, createdAt DESC);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_requests_receiver_status ON requests(receiverId, status);
CREATE INDEX idx_requests_donor_status ON requests(donorId, status);

-- Users indexes
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_email ON users(email);

-- Full-text search indexes
CREATE FULLTEXT INDEX idx_donations_search ON donations(title, description);
CREATE FULLTEXT INDEX idx_requests_search ON requests(message);

SELECT 'Performance indexes added successfully!' as Status;
