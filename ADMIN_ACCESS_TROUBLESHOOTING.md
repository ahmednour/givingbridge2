# Admin Access Troubleshooting Guide

## Issue: 403 Forbidden on Approval Endpoints

The error `403 (Forbidden)` on `/api/donations/:id/approve` means the current user doesn't have admin privileges.

## Quick Fix Steps

### 1. Check Current User Role

Open browser console and run:
```javascript
// Check if you're logged in and what role you have
fetch('http://localhost:3000/api/auth/me', {
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('token')
  }
})
.then(r => r.json())
.then(data => console.log('Current user:', data));
```

### 2. Login as Admin

You need to log in with an admin account. Check your database for admin users:

```sql
-- Check existing admin users
SELECT id, name, email, role FROM users WHERE role = 'admin';
```

If no admin exists, create one:

```sql
-- Update an existing user to admin
UPDATE users SET role = 'admin' WHERE email = 'your-email@example.com';

-- Or create a new admin user (you'll need to register first, then update)
-- 1. Register a new user through the app
-- 2. Then run: UPDATE users SET role = 'admin' WHERE email = 'new-admin@example.com';
```

### 3. Login with Admin Account

1. Logout from current account (if logged in)
2. Login with the admin email and password
3. The JWT token will now include `role: "admin"`
4. Try approving donations again

### 4. Verify Admin Access

After logging in as admin, verify in console:
```javascript
// Decode your JWT token to see the role
const token = localStorage.getItem('token');
if (token) {
  const payload = JSON.parse(atob(token.split('.')[1]));
  console.log('Token payload:', payload);
  console.log('Your role:', payload.role);
}
```

## Alternative: Direct Database Update

If you need to quickly make your current user an admin:

```sql
-- Find your user ID from the token or email
SELECT id, email, role FROM users WHERE email = 'your-current-email@example.com';

-- Update to admin
UPDATE users SET role = 'admin' WHERE email = 'your-current-email@example.com';
```

**Important:** After updating the database, you must **logout and login again** to get a new JWT token with the admin role.

## Testing Admin Endpoints

Once logged in as admin, test the approval endpoint:

```javascript
// Test approve endpoint
fetch('http://localhost:3000/api/donations/7/approve', {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('token'),
    'Content-Type': 'application/json'
  }
})
.then(r => r.json())
.then(data => console.log('Approval result:', data))
.catch(err => console.error('Error:', err));
```

## Common Issues

### Issue: Still getting 403 after database update
**Solution:** Logout and login again to get a fresh JWT token with the updated role.

### Issue: Token is null or undefined
**Solution:** You're not logged in. Go to the login page and sign in.

### Issue: Token exists but role is not "admin"
**Solution:** 
1. Check database: `SELECT role FROM users WHERE email = 'your-email@example.com'`
2. Update if needed: `UPDATE users SET role = 'admin' WHERE email = 'your-email@example.com'`
3. Logout and login again

## Quick SQL Commands

```sql
-- View all users and their roles
SELECT id, name, email, role, created_at FROM users ORDER BY created_at DESC;

-- Make a user admin
UPDATE users SET role = 'admin' WHERE id = 1;

-- Check pending donations
SELECT id, title, approval_status, donor_id FROM donations WHERE approval_status = 'pending';
```

## Expected Behavior

When logged in as admin:
- ✅ Can access `/api/donations/admin/pending`
- ✅ Can approve donations: `PUT /api/donations/:id/approve`
- ✅ Can reject donations: `PUT /api/donations/:id/reject`
- ✅ Can see all donations regardless of approval status
- ✅ Admin dashboard shows pending donations count

When NOT admin:
- ❌ 403 Forbidden on admin endpoints
- ❌ Cannot see pending donations
- ❌ Cannot approve/reject donations
