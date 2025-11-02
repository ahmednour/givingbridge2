# Quick Start Guide - After Critical Fixes

**Last Updated:** November 2, 2025

---

## 🚀 Getting Started After Security Fixes

All critical code issues have been fixed. Follow these steps to complete the setup:

---

## Step 1: Generate New Secrets (5 minutes)

```bash
# Generate JWT Secret (copy the output)
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# Generate Database Password (copy the output)
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

**Save these values!** You'll need them in the next steps.

---

## Step 2: Configure Environment (2 minutes)

```bash
# Open the new environment template
cd backend
nano .env.new  # or use your preferred editor

# Replace these placeholders:
# - REPLACE_WITH_NEW_SECRET_FROM_COMMAND_BELOW → paste JWT secret
# - CHANGE_THIS_TO_NEW_SECURE_PASSWORD → paste database password

# Save and rename
mv .env.new .env
```

---

## Step 3: Update Database Password (3 minutes)

```bash
# Connect to MySQL
mysql -h localhost -P 3307 -u root -p
# Enter root password: secure_root_password_2024

# Update the user password (use the password you generated)
ALTER USER 'givingbridge_user'@'%' IDENTIFIED BY 'YOUR_NEW_PASSWORD_HERE';
FLUSH PRIVILEGES;
EXIT;
```

---

## Step 4: Start the Application (2 minutes)

### Option A: Using Docker (Recommended)

```bash
# From project root
docker-compose down
docker-compose up -d

# Check logs
docker-compose logs -f backend
```

### Option B: Local Development

```bash
# Start database only
docker-compose up -d db

# Start backend
cd backend
npm install
npm run migrate
npm run dev

# In another terminal, start frontend
cd frontend
flutter pub get
flutter run -d chrome --web-port 8080
```

---

## Step 5: Verify Everything Works (5 minutes)

### Test Backend:

```bash
# Health check
curl http://localhost:3000/health

# Expected response:
# {
#   "status": "healthy",
#   "services": {
#     "database": "connected",
#     "models": "loaded"
#   }
# }
```

### Test Authentication:

```bash
# Login with demo account
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "demo@example.com",
    "password": "demo123"
  }'

# Expected: You'll get a new JWT token
```

### Test Frontend:

1. Open browser: http://localhost:8080
2. Click "Login"
3. Use demo credentials:
   - Email: `demo@example.com`
   - Password: `demo123`
4. You should be logged in successfully

---

## ✅ Success Checklist

- [ ] New secrets generated
- [ ] `.env` file updated with new secrets
- [ ] Database password rotated
- [ ] Backend starts without errors
- [ ] Health check returns "healthy"
- [ ] Can login with demo account
- [ ] Frontend loads correctly
- [ ] Can create a donation
- [ ] Can search donations

---

## 🐛 Troubleshooting

### Issue: "Cannot connect to database"

```bash
# Check if database is running
docker-compose ps db

# Check database logs
docker-compose logs db

# Verify credentials in .env match database
```

### Issue: "Invalid token" or "Authentication failed"

```bash
# Make sure JWT_SECRET in .env is correct
# Clear browser localStorage
# Try logging in again
```

### Issue: "Port already in use"

```bash
# Find process using port 3000
lsof -ti:3000

# Kill the process (on Windows use Task Manager)
kill -9 $(lsof -ti:3000)

# Or change PORT in .env to 3001
```

### Issue: Backend won't start

```bash
# Check for syntax errors
cd backend
npm run lint

# Check dependencies
npm install

# Check logs
npm run dev
```

---

## 📊 What Was Fixed

### ✅ Critical Issues Resolved:

1. **TypeScript Configuration** - Fixed invalid deprecation setting
2. **SQL Injection** - All queries now use parameterized statements
3. **Port Conflicts** - Standardized on port 3000
4. **Exposed Credentials** - New secure environment template created

### 🔒 Security Improvements:

- Table name validation
- Parameterized queries throughout
- Proper identifier escaping
- Query type specification
- Comprehensive error handling

---

## 📚 Additional Resources

- **Full Audit Report:** `PROJECT_ISSUES_REPORT.md`
- **Security Incident Details:** `SECURITY_INCIDENT_REPORT.md`
- **Detailed Fix Summary:** `CRITICAL_ISSUES_FIXED.md`
- **Original README:** `README.md`

---

## 🎯 Next Steps (Optional but Recommended)

### This Week:
1. Update critical dependencies:
   ```bash
   cd backend
   npm install bcryptjs@latest helmet@latest multer@latest
   npm test
   ```

2. Setup pre-commit hooks:
   ```bash
   npm install --save-dev husky
   npx husky install
   ```

3. Enable secret scanning on GitHub

### This Month:
1. Implement automated backups
2. Setup monitoring (Sentry, Datadog)
3. Add comprehensive logging
4. Conduct load testing

---

## 💡 Pro Tips

1. **Never commit .env files** - They're in .gitignore for a reason
2. **Rotate secrets regularly** - Every 90 days minimum
3. **Use different secrets per environment** - Dev, staging, production
4. **Enable 2FA** - For all admin accounts
5. **Monitor logs** - Watch for suspicious activity

---

## 🆘 Need Help?

If you're stuck:

1. Check the troubleshooting section above
2. Review the detailed documentation files
3. Run diagnostics: `npm test`
4. Check logs: `docker-compose logs -f`

---

## ✨ You're All Set!

Once you complete these steps, your application will be:
- ✅ Secure from SQL injection
- ✅ Using fresh credentials
- ✅ Properly configured
- ✅ Ready for development

**Estimated Total Time:** 15-20 minutes

---

**Happy Coding! 🚀**
