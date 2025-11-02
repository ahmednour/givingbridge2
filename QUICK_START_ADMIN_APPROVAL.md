# Quick Start: Admin Approval System

## 🚀 Setup (5 minutes)

### Step 1: Run Migration
```bash
cd backend
npm run migrate
```

Expected output:
```
✅ Migration 034_add_approval_status_to_donations completed
```

### Step 2: Restart Backend
```bash
npm run dev
```

### Step 3: Test with cURL

#### Create a Donation (as Donor)
```bash
curl -X POST http://localhost:3000/api/donations \
  -H "Authorization: Bearer YOUR_DONOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Donation",
    "description": "This is a test donation for approval",
    "category": "clothes",
    "condition": "good",
    "location": "New York, NY"
  }'
```

Expected response:
```json
{
  "message": "Donation created successfully and pending admin approval",
  "donation": {
    "id": 1,
    "approvalStatus": "pending",
    ...
  },
  "note": "Your donation will be visible to receivers once approved by an administrator"
}
```

#### Get Pending Donations (as Admin)
```bash
curl http://localhost:3000/api/donations/admin/pending \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

#### Approve Donation (as Admin)
```bash
curl -X PUT http://localhost:3000/api/donations/1/approve \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

#### Reject Donation (as Admin)
```bash
curl -X PUT http://localhost:3000/api/donations/1/reject \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Please provide clearer images"}'
```

## 🎯 Quick Test Scenarios

### Scenario 1: Donor Creates Donation
1. Login as donor
2. Create donation
3. Check status is "pending"
4. Verify donation NOT visible in public browse

### Scenario 2: Admin Approves
1. Login as admin
2. Get pending donations
3. Approve one donation
4. Verify donation NOW visible in public browse
5. Check donor received email

### Scenario 3: Admin Rejects
1. Login as admin
2. Get pending donations
3. Reject one with reason
4. Verify donation NOT visible in public browse
5. Check donor received email with reason

## 📱 Frontend Integration Points

### Donor Dashboard - Show Status
```dart
// In donation card widget
Widget _buildStatusBadge(String approvalStatus) {
  Color color;
  String text;
  
  switch (approvalStatus) {
    case 'pending':
      color = Colors.orange;
      text = 'Pending Review';
      break;
    case 'approved':
      color = Colors.green;
      text = 'Approved';
      break;
    case 'rejected':
      color = Colors.red;
      text = 'Rejected';
      break;
    default:
      color = Colors.grey;
      text = 'Unknown';
  }
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 12)),
  );
}
```

### Admin Dashboard - Pending Count Badge
```dart
// In admin dashboard
FutureBuilder<int>(
  future: ApiService.getPendingDonationsCount(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox();
    
    final count = snapshot.data!;
    if (count == 0) return SizedBox();
    
    return Badge(
      label: Text('$count'),
      child: Icon(Icons.pending_actions),
    );
  },
)
```

### Admin Approval Interface
```dart
// Approval dialog
void _showApprovalDialog(Donation donation) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Review Donation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(donation.title),
          Text(donation.description),
          // Show images, details, etc.
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _approveDonation(donation.id),
          child: Text('Approve', style: TextStyle(color: Colors.green)),
        ),
        TextButton(
          onPressed: () => _showRejectDialog(donation.id),
          child: Text('Reject', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

Future<void> _approveDonation(int id) async {
  final result = await ApiService.approveDonation(id);
  if (result.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Donation approved successfully')),
    );
    _refreshPendingList();
  }
}
```

## 🔍 Debugging

### Check Donation Status in Database
```sql
SELECT id, title, approvalStatus, approvedBy, approvedAt, rejectionReason 
FROM donations 
WHERE id = 1;
```

### Check Migration Applied
```sql
SHOW COLUMNS FROM donations LIKE 'approvalStatus';
```

### View All Pending
```sql
SELECT id, title, donorName, approvalStatus, createdAt 
FROM donations 
WHERE approvalStatus = 'pending' 
ORDER BY createdAt ASC;
```

## ⚠️ Common Issues

### Issue: "Column 'approvalStatus' doesn't exist"
**Solution**: Run migration
```bash
cd backend && npm run migrate
```

### Issue: Receivers can see pending donations
**Solution**: Check you're not logged in as admin. Admins can see all donations.

### Issue: Email not sent
**Solution**: Check EMAIL_* environment variables are set in `.env`

### Issue: Cannot approve donation
**Solution**: Verify user has 'admin' role in database

## 📊 Monitor Approval Queue

### Get Pending Count
```bash
curl http://localhost:3000/api/admin/donations/pending/count \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

### Get Pending List
```bash
curl http://localhost:3000/api/donations/admin/pending?page=1&limit=10 \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## ✅ Success Indicators

- ✅ Migration runs without errors
- ✅ New donations have `approvalStatus: "pending"`
- ✅ Receivers cannot see pending donations
- ✅ Admins can see and approve/reject
- ✅ Emails sent on approval/rejection
- ✅ Approved donations visible to receivers

## 🎉 You're Done!

The admin approval system is now active. Donors can create donations, admins can review them, and receivers only see approved donations.

For detailed documentation, see `DONATION_APPROVAL_SYSTEM.md`
