# Donation Approval System

## Overview
Implemented an admin approval workflow for donations. All donations submitted by donors must be approved by an administrator before they become visible to receivers.

## Features Implemented

### 1. Database Schema Changes
**Migration**: `034_add_approval_status_to_donations.js`

New fields added to `donations` table:
- `approvalStatus` - ENUM('pending', 'approved', 'rejected') - Default: 'pending'
- `approvedBy` - INTEGER - References admin user who approved/rejected
- `approvedAt` - DATETIME - Timestamp of approval/rejection
- `rejectionReason` - TEXT - Reason for rejection (optional)

### 2. Model Updates
**File**: `backend/src/models/Donation.js`

- Added approval status fields to Donation model
- Added association to `approver` (User who approved/rejected)
- Added index on `approvalStatus` for query performance

### 3. Controller Logic
**File**: `backend/src/controllers/donationController.js`

#### New Methods:
- `approveDonation(donationId, adminId)` - Approve a pending donation
- `rejectDonation(donationId, adminId, reason)` - Reject a donation with reason
- `getPendingDonations(pagination)` - Get list of pending donations for admin review

#### Updated Methods:
- `getAllDonations()` - Now filters by approval status based on user role
  - Non-admin users: Only see approved donations
  - Admin users: Can see all donations and filter by status
  
- `getDonationById()` - Respects approval status
  - Non-admin users: Can only view approved donations
  - Admin users: Can view any donation
  
- `createDonation()` - Sets `approvalStatus` to 'pending' by default

- `getDonationStats()` - Added approval status counts

### 4. API Routes

#### Public/Donor Routes (`/api/donations`)
- `GET /` - List donations (only approved for non-admin)
- `GET /:id` - Get donation details (only approved for non-admin)
- `POST /` - Create donation (sets status to pending)
- `GET /user/my-donations` - Get user's own donations (all statuses)

#### Admin Routes (`/api/donations`)
- `GET /admin/pending` - Get pending donations for review
- `PUT /:id/approve` - Approve a donation
- `PUT /:id/reject` - Reject a donation with reason

#### Admin Dashboard Routes (`/api/admin`)
- `GET /donations` - Get all donations with filtering
- `GET /donations/pending/count` - Get count of pending donations (for badge)

### 5. Notification System
**Files**: 
- `backend/src/services/notificationService.js`
- `backend/src/services/emailService.js`

#### Email Notifications:
- **Approval Email**: Sent to donor when donation is approved
  - Confirms donation is now visible to receivers
  - Includes donation details
  
- **Rejection Email**: Sent to donor when donation is rejected
  - Explains rejection with reason
  - Encourages resubmission or contact with support

## API Endpoints

### For Donors

#### Create Donation
```http
POST /api/donations
Authorization: Bearer <token>
Content-Type: multipart/form-data

{
  "title": "Winter Clothes",
  "description": "Warm winter clothing",
  "category": "clothes",
  "condition": "good",
  "location": "New York, NY",
  "image": <file>
}

Response:
{
  "message": "Donation created successfully and pending admin approval",
  "donation": { ... },
  "note": "Your donation will be visible to receivers once approved by an administrator"
}
```

#### View My Donations
```http
GET /api/donations/user/my-donations
Authorization: Bearer <token>

Response:
{
  "donations": [
    {
      "id": 1,
      "title": "Winter Clothes",
      "approvalStatus": "pending",
      ...
    }
  ]
}
```

### For Receivers

#### Browse Donations (Only Approved)
```http
GET /api/donations?page=1&limit=20

Response:
{
  "donations": [ /* only approved donations */ ],
  "pagination": { ... }
}
```

### For Admins

#### Get Pending Donations
```http
GET /api/donations/admin/pending?page=1&limit=20
Authorization: Bearer <admin-token>

Response:
{
  "donations": [
    {
      "id": 1,
      "title": "Winter Clothes",
      "approvalStatus": "pending",
      "donor": {
        "id": 5,
        "name": "John Doe",
        "email": "john@example.com"
      },
      ...
    }
  ],
  "pagination": { ... }
}
```

#### Approve Donation
```http
PUT /api/donations/123/approve
Authorization: Bearer <admin-token>

Response:
{
  "message": "Donation approved successfully",
  "donation": {
    "id": 123,
    "approvalStatus": "approved",
    "approvedBy": 1,
    "approvedAt": "2024-01-15T10:30:00Z"
  }
}
```

#### Reject Donation
```http
PUT /api/donations/123/reject
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "reason": "Images are unclear. Please provide better photos."
}

Response:
{
  "message": "Donation rejected successfully",
  "donation": {
    "id": 123,
    "approvalStatus": "rejected",
    "approvedBy": 1,
    "approvedAt": "2024-01-15T10:30:00Z",
    "rejectionReason": "Images are unclear. Please provide better photos."
  }
}
```

#### Get All Donations (Admin View)
```http
GET /api/admin/donations?approvalStatus=pending&page=1&limit=20
Authorization: Bearer <admin-token>

Response:
{
  "donations": [ /* all donations matching filter */ ],
  "pagination": { ... }
}
```

#### Get Pending Count (For Badge)
```http
GET /api/admin/donations/pending/count
Authorization: Bearer <admin-token>

Response:
{
  "count": 5,
  "message": "Pending donations count retrieved successfully"
}
```

## User Experience Flow

### Donor Flow
1. Donor creates a donation
2. System shows message: "Donation created successfully and pending admin approval"
3. Donation appears in donor's "My Donations" with status "pending"
4. Donor receives email notification when approved/rejected
5. If approved: Donation becomes visible to receivers
6. If rejected: Donor can see rejection reason and resubmit

### Receiver Flow
1. Receiver browses donations
2. Only sees approved donations
3. Cannot see pending or rejected donations
4. Can request approved donations normally

### Admin Flow
1. Admin logs into dashboard
2. Sees badge with count of pending donations
3. Navigates to pending donations list
4. Reviews each donation:
   - Views donation details
   - Views donor information
   - Checks images and description
5. Makes decision:
   - **Approve**: Donation becomes visible to receivers, donor notified
   - **Reject**: Provides reason, donor notified, donation hidden

## Database Migration

To apply the changes:

```bash
cd backend
npm run migrate
```

This will:
1. Add new columns to donations table
2. Create index on approvalStatus
3. Set existing donations to 'approved' (backward compatibility)

## Backward Compatibility

- Existing donations are automatically set to 'approved' status
- No breaking changes to existing API endpoints
- New fields are optional in responses

## Security Considerations

1. **Authorization**: Only admins can approve/reject donations
2. **Validation**: Approval status transitions are validated
3. **Audit Trail**: Tracks who approved/rejected and when
4. **Data Integrity**: Foreign key constraints on approvedBy field

## Testing Checklist

### Donor Tests
- [ ] Create donation → Status is 'pending'
- [ ] View my donations → See all statuses
- [ ] Receive approval email
- [ ] Receive rejection email

### Receiver Tests
- [ ] Browse donations → Only see approved
- [ ] View donation details → Only approved accessible
- [ ] Cannot see pending/rejected donations

### Admin Tests
- [ ] View pending donations list
- [ ] Approve donation → Status changes, donor notified
- [ ] Reject donation with reason → Status changes, donor notified
- [ ] View all donations with filters
- [ ] See pending count badge

### API Tests
- [ ] Non-admin cannot access admin endpoints
- [ ] Approval status filters work correctly
- [ ] Pagination works for pending donations
- [ ] Email notifications sent successfully

## Future Enhancements

1. **Bulk Actions**: Approve/reject multiple donations at once
2. **Review Comments**: Allow admins to add internal notes
3. **Appeal System**: Let donors appeal rejections
4. **Auto-Approval**: Auto-approve donations from trusted donors
5. **Review Queue**: Assign donations to specific admins
6. **Analytics**: Track approval rates and times
7. **Notification Preferences**: Let donors choose notification methods

## Configuration

### Environment Variables
No new environment variables required. Uses existing email configuration:
- `EMAIL_HOST`
- `EMAIL_PORT`
- `EMAIL_USER`
- `EMAIL_PASS`
- `EMAIL_FROM`

## Troubleshooting

### Donations not showing for receivers
- Check `approvalStatus` is 'approved'
- Verify migration ran successfully
- Check database indexes

### Email notifications not sending
- Verify email service is configured
- Check email credentials in .env
- Review email service logs

### Admin cannot approve
- Verify user has 'admin' role
- Check authentication token
- Review admin middleware

## Summary

This implementation provides a complete admin approval workflow for donations, ensuring quality control while maintaining a smooth user experience for both donors and receivers. The system is secure, scalable, and includes proper notifications and audit trails.
