# Demo User Credentials

This document contains the login credentials for demo/test users in the GivingBridge application.

## Password Requirements

All passwords must meet the following requirements:
- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 lowercase letter

## Demo Accounts

### Admin Account
- **Email:** admin@givingbridge.com
- **Password:** Admin1234
- **Role:** Admin
- **Description:** Full administrative access to the platform

### English Demo Accounts

#### Demo Donor
- **Email:** demo@example.com
- **Password:** Demo1234
- **Role:** Donor
- **Location:** New York, NY
- **Phone:** +1234567890

#### Demo Receiver
- **Email:** receiver@example.com
- **Password:** Receive1234
- **Role:** Receiver
- **Location:** Los Angeles, CA
- **Phone:** +1234567892

### Arabic Demo Accounts (حسابات تجريبية عربية)

#### المتبرع أحمد
- **Email:** ahmed.donor@example.com
- **Password:** Demo1234
- **Role:** Donor (متبرع)
- **Location:** نجران، المملكة العربية السعودية
- **Phone:** +966505111111

#### المستفيد فاطمة
- **Email:** fatimah.receiver@example.com
- **Password:** Receive1234
- **Role:** Receiver (مستفيد)
- **Location:** أبها، المملكة العربية السعودية
- **Phone:** +966506222222

### Charity Organizations (منظمات خيرية)

#### جمعية البر بنجران
- **Email:** najran.charity@example.com
- **Password:** Charity1234
- **Role:** Receiver (مستفيد مؤسسي)
- **Location:** نجران، المملكة العربية السعودية
- **Phone:** +966507333333

#### جمعية الوفاء الخيرية
- **Email:** alwafa.charity@example.com
- **Password:** Charity1234
- **Role:** Receiver (مستفيد مؤسسي)
- **Location:** جدة، المملكة العربية السعودية
- **Phone:** +966508444444

## Quick Login Buttons

The login screen includes quick login buttons for easy testing:
- **Demo Donor** - Automatically fills in demo@example.com / Demo1234
- **Demo Admin** - Automatically fills in admin@givingbridge.com / Admin1234
- **Demo Receiver** - Automatically fills in receiver@example.com / Receive1234

## Security Notes

⚠️ **Important:** These are demo credentials for development and testing purposes only. 
- Never use these credentials in production
- Change all default passwords before deploying to production
- Implement proper password policies and security measures for production use

## Updating Passwords

To update demo user passwords:

1. Generate new password hash:
```bash
docker exec givingbridge_backend node -e "
const bcrypt = require('bcryptjs');
(async () => {
  console.log(await bcrypt.hash('YourNewPassword', 12));
  process.exit(0);
})();
"
```

2. Update the password in the database or init.sql file

3. Update this documentation file

## Related Files

- `backend/sql/init.sql` - Initial database setup with demo users
- `backend/src/seeders/seed-demo-users.js` - Seeder script for demo users
- `backend/src/seeders/create-demo-users.js` - Script to create missing demo users
- `backend/src/seeders/update-demo-passwords.js` - Script to update demo passwords
- `frontend/lib/screens/login_screen.dart` - Login screen with quick login buttons
