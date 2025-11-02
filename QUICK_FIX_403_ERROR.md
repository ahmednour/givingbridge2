# Quick Fix: 403 Forbidden Error on Approval Endpoints

## Problem
You're getting `403 (Forbidden)` errors when trying to approve/reject donations because you're not logged in as an admin.

## ✅ GOOD NEWS: You Already Have an Admin Account!

**Email:** `admin@givingbridge.com`  
**Role:** admin

Just login with this account and you'll be able to approve/reject donations!

## Solution (3 Simple Steps)

### Step 1: Check Current Users
```bash
cd backend
node scripts/list-users.js
```

This will show all users and their roles.

### Step 2: Make Your User an Admin
```bash
node scripts/make-admin.js your-email@example.com
```

Replace `your-email@example.com` with the email you use to login.

### Step 3: Logout and Login Again
1. In the app, logout from your current session
2. Login again with the same email/password
3. Your new JWT token will now have admin privileges
4. Try approving donations again - it should work! ✅

## Example

```bash
# List all users
cd backend
node scripts/list-users.js

# Output shows:
# ┌─────────┬────┬──────────────┬─────────────────────┬──────────┬─────────────────────┐
# │ (index) │ id │     name     │        email        │   role   │     created_at      │
# ├─────────┼────┼──────────────┼─────────────────────┼──────────┼─────────────────────┤
# │    0    │ 1  │ 'John Doe'   │ 'john@example.com'  │ 'donor'  │ '2024-01-15...'     │
# └─────────┴────┴──────────────┴─────────────────────┴──────────┴─────────────────────┘

# Make John an admin
node scripts/make-admin.js john@example.com

# Output:
# ✅ Database connected
# ✅ User john@example.com is now an admin!
# ⚠️  IMPORTANT: User must logout and login again to get new permissions!
```

## Verify It Works

After logging in as admin, open browser console and run:

```javascript
// Check your role
const token = localStorage.getItem('token');
const payload = JSON.parse(atob(token.split('.')[1]));
console.log('Your role:', payload.role); // Should show "admin"

// Test approval endpoint
fetch('http://localhost:3000/api/donations/7/approve', {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => console.log('✅ Success:', data));
```

## Troubleshooting

**Still getting 403?**
- Make sure you logged out and logged back in after running the script
- Check that the email matches exactly (case-sensitive)
- Verify the backend server is running

**Script not found?**
- Make sure you're in the `backend` directory
- Check that Node.js is installed: `node --version`

**Database connection error?**
- Make sure MySQL is running
- Check your `.env` file has correct database credentials
