# User Safety Features Implementation Guide

**Status:** Backend Complete ✅ | Frontend In Progress 🚧  
**Date:** 2025-10-21

---

## Overview

This guide documents the implementation of user safety features (block and report functionality) for the GivingBridge platform. These features protect users from harassment, spam, and inappropriate behavior.

---

## ✅ Backend Implementation (COMPLETE)

### 1. Database Migrations

**Created Files:**

- `backend/src/migrations/008_create_blocked_users_table.js` ✅
- `backend/src/migrations/009_create_user_reports_table.js` ✅

**Tables:**

#### `blocked_users` Table

```sql
- id (INT, PRIMARY KEY, AUTO_INCREMENT)
- blockerId (INT, FOREIGN KEY -> users.id)
- blockedId (INT, FOREIGN KEY -> users.id)
- reason (TEXT, nullable)
- createdAt (TIMESTAMP)
- updatedAt (TIMESTAMP)
- UNIQUE INDEX (blockerId, blockedId)
```

#### `user_reports` Table

```sql
- id (INT, PRIMARY KEY, AUTO_INCREMENT)
- reporterId (INT, FOREIGN KEY -> users.id)
- reportedId (INT, FOREIGN KEY -> users.id)
- reason (ENUM: spam, harassment, inappropriate_content, scam, fake_profile, other)
- description (TEXT)
- status (ENUM: pending, reviewed, resolved, dismissed, DEFAULT: pending)
- reviewedBy (INT, nullable, FOREIGN KEY -> users.id)
- reviewNotes (TEXT, nullable)
- reviewedAt (TIMESTAMP, nullable)
- createdAt (TIMESTAMP)
- updatedAt (TIMESTAMP)
```

### 2. Sequelize Models

**Created Files:**

- `backend/src/models/BlockedUser.js` ✅
- `backend/src/models/UserReport.js` ✅

### 3. Controller Methods

**Updated File:** `backend/src/controllers/userController.js`

**New Methods:**

1. `blockUser(userId, user, reason)` - Block a user
2. `unblockUser(userId, user)` - Unblock a user
3. `getBlockedUsers(user)` - Get list of blocked users
4. `isUserBlocked(userId, user)` - Check if user is blocked
5. `reportUser(userId, user, reportData)` - Report a user
6. `getUserReports(user)` - Get user's submitted reports
7. `getAllReports(filters)` - Get all reports (admin only)
8. `updateReportStatus(reportId, updateData, user)` - Update report status (admin)

### 4. API Routes

**Updated File:** `backend/src/routes/users.js`

**New Endpoints:**

| Method | Endpoint                   | Auth     | Description              |
| ------ | -------------------------- | -------- | ------------------------ |
| POST   | `/users/:id/block`         | Required | Block a user             |
| DELETE | `/users/:id/block`         | Required | Unblock a user           |
| GET    | `/users/blocked/list`      | Required | Get blocked users list   |
| GET    | `/users/:id/blocked`       | Required | Check if user is blocked |
| POST   | `/users/:id/report`        | Required | Report a user            |
| GET    | `/users/reports/my`        | Required | Get my submitted reports |
| GET    | `/users/reports/all`       | Admin    | Get all reports          |
| PATCH  | `/users/reports/:reportId` | Admin    | Update report status     |

---

## 🚧 Frontend Implementation (IN PROGRESS)

### Next Steps:

#### 1. Add API Service Methods (`api_service.dart`)

```dart
// Block/Unblock Methods
static Future<ApiResponse> blockUser(int userId, {String? reason})
static Future<ApiResponse> unblockUser(int userId)
static Future<ApiResponse<List<BlockedUser>>> getBlockedUsers()
static Future<ApiResponse<bool>> isUserBlocked(int userId)

// Report Methods
static Future<ApiResponse> reportUser(int userId, String reason, String description)
static Future<ApiResponse<List<UserReport>>> getMyReports()

// Admin Methods (if admin role)
static Future<ApiResponse<PaginatedResponse<UserReport>>> getAllReports({
  String? status,
  int page = 1,
  int limit = 20
})
static Future<ApiResponse> updateReportStatus(int reportId, {
  String? status,
  String? reviewNotes
})
```

#### 2. Create Flutter Models

**Files to Create:**

- `frontend/lib/models/blocked_user.dart`
- `frontend/lib/models/user_report.dart`

```dart
// blocked_user.dart
class BlockedUser {
  final int id;
  final User blockedUser;
  final String? reason;
  final DateTime blockedAt;
}

// user_report.dart
class UserReport {
  final int id;
  final User? reportedUser;
  final String reason;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
}
```

#### 3. Implement Block User Dialog

**Update:** `frontend/lib/screens/chat_screen_enhanced.dart`

```dart
void _showBlockConfirmation() {
  showDialog(
    context: context,
    builder: (context) => GBBlockUserDialog(
      userName: widget.otherUserName,
      onBlock: (reason) async {
        // Call API to block user
        final response = await ApiService.blockUser(
          int.parse(widget.otherUserId),
          reason: reason,
        );

        if (response.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User blocked successfully')),
          );
          Navigator.pop(context); // Close chat
        }
      },
    ),
  );
}
```

#### 4. Implement Report User Dialog

**Update:** `frontend/lib/screens/chat_screen_enhanced.dart`

```dart
void _showReportDialog() {
  showDialog(
    context: context,
    builder: (context) => GBReportUserDialog(
      userName: widget.otherUserName,
      onReport: (reason, description) async {
        // Call API to report user
        final response = await ApiService.reportUser(
          int.parse(widget.otherUserId),
          reason,
          description,
        );

        if (response.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report submitted. Our team will review it shortly.'),
            ),
          );
        }
      },
    ),
  );
}
```

#### 5. Create Block User Dialog Widget

**File to Create:** `frontend/lib/widgets/common/gb_block_user_dialog.dart`

**Features:**

- User name display
- Optional reason text field
- Warning message
- Confirm/Cancel buttons
- Uses DesignSystem colors
- Supports dark mode

#### 6. Create Report User Dialog Widget

**File to Create:** `frontend/lib/widgets/common/gb_report_user_dialog.dart`

**Features:**

- User name display
- Reason dropdown (spam, harassment, inappropriate_content, scam, fake_profile, other)
- Description text field (required, min 10 chars)
- Form validation
- Submit/Cancel buttons
- Uses DesignSystem colors
- Supports dark mode

#### 7. Create Blocked Users Management Screen

**File to Create:** `frontend/lib/screens/blocked_users_screen.dart`

**Features:**

- List of blocked users
- Unblock button for each user
- Empty state when no blocked users
- Pull-to-refresh
- Uses WebCard and GB components

**Access:** Add to profile settings or messages settings menu

#### 8. Update Message Provider

**Update:** `frontend/lib/providers/message_provider.dart`

**Add Method:**

```dart
Future<void> loadConversations() async {

  // Filter out conversations with blocked users
  final blockedUsers = await ApiService.getBlockedUsers();
  final blockedIds = blockedUsers.data?.map((b) => b.blockedUser.id).toSet() ?? {};

  conversations = conversations.where((conv) =>
    !blockedIds.contains(int.tryParse(conv.otherParticipantId))
  ).toList();

  // ... rest of code ...
}
```

---

## Testing Checklist

### Backend Tests

- [ ] Block user successfully
- [ ] Prevent blocking yourself
- [ ] Prevent duplicate blocks
- [ ] Unblock user successfully
- [ ] Get blocked users list
- [ ] Check if user is blocked
- [ ] Report user with valid data
- [ ] Prevent reporting yourself
- [ ] Validate report reasons
- [ ] Get user's submitted reports
- [ ] Admin: Get all reports
- [ ] Admin: Update report status

### Frontend Tests

- [ ] Block user dialog appears
- [ ] Block user confirmation works
- [ ] Blocked user disappears from messages list
- [ ] Cannot send messages to blocked user
- [ ] Unblock user works
- [ ] Report dialog appears
- [ ] Report form validation works
- [ ] Report submission successful
- [ ] Blocked users screen displays correctly
- [ ] Pull-to-refresh works on blocked users
- [ ] Dark mode support

---

## Usage Examples

### Block a User (Backend)

```bash
POST /users/123/block
Authorization: Bearer <token>
Content-Type: application/json

{
  "reason": "Spam messages"
}
```

**Response:**

```json
{
  "success": true,
  "message": "User blocked successfully",
  "blockedUser": {
    "id": 1,
    "blockedUserId": 123,
    "blockedUserName": "John Doe",
    "reason": "Spam messages",
    "createdAt": "2025-10-21T10:30:00Z"
  }
}
```

### Report a User (Backend)

```bash
POST /users/123/report
Authorization: Bearer <token>
Content-Type: application/json

{
  "reason": "harassment",
  "description": "User sent inappropriate messages repeatedly despite being asked to stop."
}
```

**Response:**

```json
{
  "success": true,
  "message": "User reported successfully. Our team will review it shortly.",
  "report": {
    "id": 1,
    "reportedUserId": 123,
    "reportedUserName": "John Doe",
    "reason": "harassment",
    "status": "pending",
    "createdAt": "2025-10-21T10:35:00Z"
  }
}
```

---

## Security Considerations

1. **Authorization**: All endpoints require authentication
2. **Self-Actions Prevented**: Users cannot block/report themselves
3. **Duplicate Prevention**: Unique constraint on block relationships
4. **Admin Oversight**: All reports are logged and reviewable by admins
5. **Data Validation**: Input validation on all endpoints
6. **Audit Trail**: CreatedAt/UpdatedAt timestamps on all records

---

## Database Migration Commands

```bash
# Run migrations
cd backend
npm run migrate

# Rollback if needed
npm run migrate:undo
```

---

## Next Implementation Steps

1. ✅ Create backend migrations
2. ✅ Create Sequelize models
3. ✅ Add controller methods
4. ✅ Create API routes
5. 🚧 Add API service methods in Flutter
6. ⏳ Create Flutter models
7. ⏳ Implement block user dialog
8. ⏳ Implement report user dialog
9. ⏳ Create blocked users screen
10. ⏳ Update message provider
11. ⏳ Test end-to-end functionality

---

## Notes for Developers

- **Report Reasons**: The ENUM values are predefined. If you need to add new reasons, update both the migration and model.
- **Admin Dashboard**: Consider adding a reports management section to the admin dashboard.
- **Notifications**: Consider notifying admins when new reports are submitted.
- **Email Alerts**: Could send email to admins for high-priority reports (harassment, scam).
- **User Feedback**: After reporting, show a confirmation and explain the review process.

---

**Status:** Backend infrastructure is 100% complete. Frontend implementation ready to begin.

**Estimated Time to Complete Frontend:** 4-6 hours

Would you like me to continue with the frontend implementation now?
