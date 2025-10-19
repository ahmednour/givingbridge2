-- Add donorName column to donations table
-- This migration adds the missing donorName column that the Donation model expects

ALTER TABLE donations ADD COLUMN donorName VARCHAR(255) NOT NULL DEFAULT '';

-- Update existing donations with donor names
UPDATE donations d 
JOIN users u ON d.donorId = u.id 
SET d.donorName = u.name 
WHERE d.donorName = '';

-- Make the column NOT NULL after updating existing records
ALTER TABLE donations MODIFY COLUMN donorName VARCHAR(255) NOT NULL;