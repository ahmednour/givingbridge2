-- ============================================
-- Performance Optimization Indexes (Safe Version)
-- Created: October 29, 2025
-- Only creates indexes for existing tables
-- ============================================

-- Foreign Key Indexes for donations table
CREATE INDEX idx_donations_donor_id ON donations(donorId);

-- Foreign Key Indexes for requests table
CREATE INDEX idx_requests_donation_id ON requests(donationId);
CREATE INDEX idx_requests_donor_id ON requests(donorId);
CREATE INDEX idx_requests_receiver_id ON requests(receiverId);

-- Foreign Key Indexes for messages table
CREATE INDEX idx_messages_sender_id ON messages(senderId);
CREATE INDEX idx_messages_receiver_id ON messages(receiverId);

-- Query Optimization Indexes
CREATE INDEX idx_donations_available_created 
  ON donations(isAvailable, createdAt DESC);

CREATE INDEX idx_donations_category_location 
  ON donations(category, location(50));

CREATE INDEX idx_donations_status_created 
  ON donations(status, createdAt DESC);

CREATE INDEX idx_requests_status_created 
  ON requests(status, createdAt DESC);

CREATE INDEX idx_messages_receiver_read_created 
  ON messages(receiverId, isRead, createdAt DESC);

-- Category and Status Indexes
CREATE INDEX idx_donations_category ON donations(category);
CREATE INDEX idx_donations_location ON donations(location(50));
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_messages_isread ON messages(isRead);
CREATE INDEX idx_users_role ON users(role);

-- Email lookup optimization
CREATE INDEX idx_users_email ON users(email);

-- Full-Text Search Indexes
CREATE FULLTEXT INDEX idx_donations_search 
  ON donations(title, description);

CREATE FULLTEXT INDEX idx_requests_search 
  ON requests(message);

-- Composite Indexes for Complex Queries
CREATE INDEX idx_donations_donor_available 
  ON donations(donorId, isAvailable);

CREATE INDEX idx_requests_receiver_status 
  ON requests(receiverId, status);

CREATE INDEX idx_requests_donor_status 
  ON requests(donorId, status);

-- Show created indexes
SELECT 'Indexes created successfully!' as Status;
