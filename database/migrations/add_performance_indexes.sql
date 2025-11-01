-- ============================================
-- Performance Optimization Indexes
-- Created: October 29, 2025
-- Purpose: Improve query performance
-- ============================================

-- Foreign Key Indexes
-- These improve JOIN performance significantly
CREATE INDEX idx_donations_donor_id ON donations(donorId);
CREATE INDEX idx_requests_donation_id ON requests(donationId);
CREATE INDEX idx_requests_donor_id ON requests(donorId);
CREATE INDEX idx_requests_receiver_id ON requests(receiverId);
CREATE INDEX idx_messages_sender_id ON messages(senderId);
CREATE INDEX idx_messages_receiver_id ON messages(receiverId);
CREATE INDEX idx_notifications_user_id ON notifications(userId);
CREATE INDEX idx_ratings_rater_id ON ratings(raterId);
CREATE INDEX idx_ratings_rated_user_id ON ratings(ratedUserId);

-- Query Optimization Indexes
-- These improve common query patterns
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

CREATE INDEX idx_notifications_user_read 
  ON notifications(userId, isRead, createdAt DESC);

-- Category and Status Indexes
CREATE INDEX idx_donations_category ON donations(category);
CREATE INDEX idx_donations_location ON donations(location(50));
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_messages_isread ON messages(isRead);
CREATE INDEX idx_users_role ON users(role);

-- Email lookup optimization
CREATE INDEX idx_users_email ON users(email);

-- Full-Text Search Indexes
-- These enable fast text search
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

-- ============================================
-- Index Statistics
-- ============================================
-- Run these queries to check index usage:
-- SHOW INDEX FROM donations;
-- SHOW INDEX FROM requests;
-- SHOW INDEX FROM messages;
-- 
-- Check index effectiveness:
-- EXPLAIN SELECT * FROM donations WHERE isAvailable = true ORDER BY createdAt DESC;
-- ============================================
