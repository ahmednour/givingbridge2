# Database Design Improvements

This document summarizes the improvements made to the database design to address the identified issues:

## 1. Added Proper Associations Between Models

### Before

The models had no proper associations defined, which made it difficult to navigate relationships between entities.

### After

Added proper associations between all models using the Sequelize ORM:

#### User Model

- `User.hasMany(Donation, { foreignKey: "donorId", as: "donations" })`
- `User.hasMany(Request, { foreignKey: "receiverId", as: "receivedRequests" })`
- `User.hasMany(Request, { foreignKey: "donorId", as: "donatedRequests" })`

#### Donation Model

- `Donation.belongsTo(User, { foreignKey: "donorId", as: "donor" })`
- `Donation.hasMany(Request, { foreignKey: "donationId", as: "requests" })`

#### Request Model

- `Request.belongsTo(User, { foreignKey: "receiverId", as: "receiver" })`
- `Request.belongsTo(User, { foreignKey: "donorId", as: "requestDonor" })`
- `Request.belongsTo(Donation, { foreignKey: "donationId", as: "donation" })`

#### Message Model

- `Message.belongsTo(User, { foreignKey: "senderId", as: "sender" })`
- `Message.belongsTo(User, { foreignKey: "receiverId", as: "receiver" })`
- `Message.belongsTo(Donation, { foreignKey: "donationId", as: "donation" })`
- `Message.belongsTo(Request, { foreignKey: "requestId", as: "request" })`

#### ActivityLog Model

- `ActivityLog.belongsTo(User, { foreignKey: "userId", as: "user" })`

#### NotificationPreference Model

- `NotificationPreference.belongsTo(User, { foreignKey: "user_id", as: "user" })`

## 2. Added Missing Indexes on Frequently Queried Fields

### Before

Some frequently queried fields were missing indexes, which could lead to performance issues.

### After

Verified that all models have appropriate indexes on frequently queried fields:

#### User Model

- Index on `email` (unique)

#### Donation Model

- Index on `donorId`
- Index on `category`
- Index on `isAvailable`
- Index on `status`

#### Request Model

- Index on `donationId`
- Index on `donorId`
- Index on `receiverId`
- Index on `status`

#### Message Model

- Index on `senderId`
- Index on `receiverId`
- Index on `donationId`
- Index on `requestId`
- Index on `isRead`
- Index on `createdAt`

## 3. Ensured Proper Timestamps for Donations

### Before

The donation model already had proper timestamps, but it's worth confirming they're correctly implemented.

### After

Verified that the Donation model has proper timestamps:

- `createdAt` - automatically set when a donation is created
- `updatedAt` - automatically updated when a donation is modified

These timestamps allow tracking donation history properly.

## 4. Created Models Index for Proper Initialization

### Before

Models were loaded directly in various files, which could lead to circular dependency issues.

### After

Created a models index file (`models/index.js`) that:

- Loads all models
- Initializes associations in the correct order
- Avoids circular dependency issues

## 5. Updated All Models to Use Associate Functions

### Before

Some models had direct associations defined, which could cause conflicts.

### After

Updated all models to use associate functions that are called after all models are loaded, preventing circular dependency issues.

## Benefits of These Improvements

1. **Better Data Integrity**: Proper foreign key relationships ensure data consistency
2. **Improved Performance**: Indexes on frequently queried fields improve query performance
3. **Easier Development**: Associations make it easier to navigate relationships in code
4. **Better Maintainability**: Centralized model loading and association management
5. **Proper History Tracking**: Timestamps allow tracking donation history over time

## Usage Examples

With these improvements, you can now easily navigate relationships:

```javascript
// Get a donation with its requests and donor
const donation = await Donation.findByPk(donationId, {
  include: [
    { model: User, as: "donor" },
    { model: Request, as: "requests" },
  ],
});

// Get a user with their donations
const user = await User.findByPk(userId, {
  include: [{ model: Donation, as: "donations" }],
});

// Get a request with its donation and users
const request = await Request.findByPk(requestId, {
  include: [
    { model: Donation, as: "donation" },
    { model: User, as: "receiver" },
    { model: User, as: "requestDonor" },
  ],
});
```
