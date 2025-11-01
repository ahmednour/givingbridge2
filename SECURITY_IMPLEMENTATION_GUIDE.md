# 🔒 Security Implementation Guide

**Status:** ✅ Security fixes prepared and ready to implement  
**Date:** October 29, 2025

---

## 📦 Step 1: Install Required Packages

Run these commands in the backend directory:

```bash
cd backend

# Install security packages
npm install csurf cookie-parser sanitize-html validator xss

# Install monitoring (optional but recommended)
npm install @sentry/node

# Install Redis for caching (optional)
npm install redis ioredis
```

---

## 🔐 Step 2: Update Environment Variables

### 2.1 Generate New JWT Secret

```bash
# Generate a secure JWT secret
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
```

**Generated Secret:**
```
ce30038a642b0048e88b7624b396932292b58d67858ec1c71fcf78c5e5cb15e163c0357d0f9a7f86463808eb5530a54837494f852feaa93ce78998844d7b4b54
```

### 2.2 Create .env File

Copy `.env.example` to `.env` and update with your values:

```bash
cp backend/.env.example backend/.env
```

Then edit `backend/.env`:

```env
# Database
DB_HOST=localhost
DB_PORT=3307
DB_NAME=givingbridge
DB_USER=givingbridge_user
DB_PASSWORD=<GENERATE_STRONG_PASSWORD>

# JWT - Use the generated secret above
JWT_SECRET=ce30038a642b0048e88b7624b396932292b58d67858ec1c71fcf78c5e5cb15e163c0357d0f9a7f86463808eb5530a54837494f852feaa93ce78998844d7b4b54

# Server
PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:8080

# Email (configure with your SMTP)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
EMAIL_FROM=noreply@givingbridge.org
APP_NAME=Giving Bridge
```

### 2.3 Secure the .env File

```bash
# Ensure .env is in .gitignore (already done)
# Set proper file permissions (Linux/Mac)
chmod 600 backend/.env

# Windows: Right-click .env → Properties → Security → Edit permissions
```

---

## 🛠️ Step 3: Update Server Configuration

Update `backend/src/server.js` to include new security middleware:

```javascript
// Add after existing imports
const cookieParser = require('cookie-parser');
const { csrfProtection, csrfErrorHandler, getCsrfToken } = require('./middleware/csrf');
const { sanitizeInput } = require('./middleware/sanitization');

// Add after body parsing middleware
app.use(cookieParser());

// Add sanitization middleware (before routes)
app.use(sanitizeInput);

// Add CSRF protection (before routes, after sanitization)
app.use('/api', csrfProtection);

// Add CSRF token endpoint
app.get('/api/csrf-token', getCsrfToken);

// Add CSRF error handler (after routes, before general error handler)
app.use(csrfErrorHandler);
```

---

## 🔄 Step 4: Update Frontend to Handle CSRF

### 4.1 Create CSRF Service

Create `frontend/lib/services/csrf_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class CsrfService {
  static String? _csrfToken;
  static DateTime? _tokenExpiry;
  
  /// Get CSRF token (cached for 1 hour)
  static Future<String> getToken() async {
    // Return cached token if still valid
    if (_csrfToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _csrfToken!;
    }
    
    // Fetch new token
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/csrf-token'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _csrfToken = data['csrfToken'];
        _tokenExpiry = DateTime.now().add(Duration(hours: 1));
        return _csrfToken!;
      }
    } catch (e) {
      print('Error fetching CSRF token: $e');
    }
    
    throw Exception('Failed to get CSRF token');
  }
  
  /// Clear cached token
  static void clearToken() {
    _csrfToken = null;
    _tokenExpiry = null;
  }
}
```

### 4.2 Update API Service

Update `frontend/lib/services/api_service.dart` to include CSRF token:

```dart
// Add import
import 'csrf_service.dart';

// Update _getHeaders method
static Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  if (includeAuth) {
    String? token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
  }
  
  // Add CSRF token for state-changing requests
  try {
    final csrfToken = await CsrfService.getToken();
    headers['X-CSRF-Token'] = csrfToken;
  } catch (e) {
    print('Warning: Could not get CSRF token: $e');
  }

  return headers;
}
```

---

## 🧪 Step 5: Test Security Implementations

### 5.1 Test CSRF Protection

```bash
# Should fail without CSRF token
curl -X POST http://localhost:3000/api/donations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"title":"Test"}'

# Should succeed with CSRF token
# 1. Get CSRF token
curl http://localhost:3000/api/csrf-token

# 2. Use token in request
curl -X POST http://localhost:3000/api/donations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -H "X-CSRF-Token: <csrf-token>" \
  -d '{"title":"Test"}'
```

### 5.2 Test Input Sanitization

```bash
# Test XSS prevention
curl -X POST http://localhost:3000/api/donations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -H "X-CSRF-Token: <csrf-token>" \
  -d '{"title":"<script>alert(\"XSS\")</script>Test"}'

# Should return sanitized: "Test" (script tags removed)
```

### 5.3 Test SQL Injection Prevention

```bash
# Test SQL injection in search
curl "http://localhost:3000/api/donations?location=New%20York';%20DROP%20TABLE%20users;--"

# Should be sanitized and not execute SQL
```

---

## 📋 Step 6: Verification Checklist

- [ ] All required packages installed
- [ ] New JWT secret generated and set in .env
- [ ] .env file secured (not in git, proper permissions)
- [ ] Database password changed
- [ ] CSRF protection middleware added
- [ ] Input sanitization middleware added
- [ ] Frontend updated to handle CSRF tokens
- [ ] CSRF protection tested
- [ ] Input sanitization tested
- [ ] SQL injection prevention tested
- [ ] XSS prevention tested
- [ ] All tests passing

---

## 🚀 Step 7: Deploy Changes

### Development

```bash
# Restart backend server
cd backend
npm start

# Restart frontend
cd frontend
flutter run -d chrome --web-port 8080
```

### Production

```bash
# Build frontend
cd frontend
flutter build web

# Deploy backend with new environment variables
# Ensure .env is NOT deployed - use environment variables instead

# On production server:
export JWT_SECRET="<your-secret>"
export DB_PASSWORD="<your-password>"

# Start backend
cd backend
npm start
```

---

## 🔍 Step 8: Monitor and Verify

### Check Logs

```bash
# Backend logs
tail -f backend/logs/app.log

# Look for:
# - No CSRF errors for legitimate requests
# - Sanitization working (no HTML in logs)
# - No security warnings
```

### Monitor Security Events

```bash
# Check for suspicious activity
grep "CSRF" backend/logs/security.log
grep "sanitization" backend/logs/security.log
grep "failed_login" backend/logs/security.log
```

---

## ⚠️ Important Notes

1. **Never commit .env file** - It's in .gitignore, keep it that way
2. **Use different secrets** for dev/staging/production
3. **Rotate secrets regularly** (every 90 days recommended)
4. **Monitor logs** for security events
5. **Test thoroughly** before deploying to production

---

## 🆘 Troubleshooting

### CSRF Token Issues

**Problem:** "Invalid CSRF token" errors

**Solutions:**
1. Clear browser cookies
2. Restart backend server
3. Check that cookie-parser is installed
4. Verify CSRF middleware is before routes

### Sanitization Breaking Functionality

**Problem:** Legitimate input being over-sanitized

**Solutions:**
1. Check sanitization rules in `sanitization.js`
2. Add exceptions for specific fields if needed
3. Use different sanitization levels for different fields

### Frontend Not Getting CSRF Token

**Problem:** Frontend can't fetch CSRF token

**Solutions:**
1. Check CORS configuration
2. Verify `/api/csrf-token` endpoint is accessible
3. Check browser console for errors
4. Ensure cookie-parser is configured correctly

---

## 📞 Need Help?

If you encounter issues:
1. Check the logs first
2. Review the error messages
3. Verify all steps were completed
4. Test in isolation (one feature at a time)

---

**Implementation Status:** Ready to deploy  
**Next Review:** After implementation and testing
