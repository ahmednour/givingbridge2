# Solution: 403 Forbidden Error Fixed

## The Problem
You were getting `403 (Forbidden)` errors on:
- `http://localhost:3000/api/donations/7/approve`
- `http://localhost:3000/api/donations/8/approve`

This happens because these endpoints require **admin privileges**.

## The Solution

### Option 1: Use Existing Admin Account (Recommended)

Your database already has an admin account:

**Email:** `admin@givingbridge.com`  
**Password:** (whatever password was set during initial setup)

**Steps:**
1. Logout from your current account
2. Login with `admin@givingbridge.com`
3. Try approving donations again - it will work! ✅

### Option 2: Make Your Current User an Admin

If you want to use your current account as admin:

```bash
cd backend
node scripts/list-users.js          # See all users
node scripts/make-admin.js your-email@example.com
```

Then **logout and login again** to get a new JWT token with admin role.

## Verify It Works

After logging in as admin, check in browser console:

```javascript
// Check your role
const token = localStorage.getItem('token');
const payload = JSON.parse(atob(token.split('.')[1]));
console.log('Your role:', payload.role); // Should show "admin"
```

## Why This Happened

The approval endpoints have this middleware:
```javascript
router.put("/:id/approve", 
  authenticateToken,    // ✅ Checks if logged in
  requireAdmin,         // ❌ Checks if role === "admin"
  ...
);
```

Your JWT token didn't have `role: "admin"`, so the `requireAdmin` middleware blocked the request with 403 Forbidden.

## All Admin Endpoints

Once logged in as admin, you can access:
- ✅ `GET /api/donations/admin/pending` - Get pending donations
- ✅ `PUT /api/donations/:id/approve` - Approve donation
- ✅ `PUT /api/donations/:id/reject` - Reject donation
- ✅ `GET /api/donations/stats` - Get donation statistics
- ✅ Admin dashboard with pending count badge

## Testing

Test the approval endpoint:
```javascript
fetch('http://localhost:3000/api/donations/7/approve', {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('token'),
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => console.log('✅ Success:', data));
```

Expected response:
```json
{
  "message": "Donation approved successfully",
  "donation": {
    "id": 7,
    "approvalStatus": "approved",
    "approvedBy": 1,
    "approvedAt": "2025-11-02T..."
  }
}
```
