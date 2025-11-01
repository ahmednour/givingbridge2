# ⚡ Quick Start: Security Fixes

**Time Required:** 1.5 - 2 hours  
**Difficulty:** Medium  
**Prerequisites:** Node.js, npm, Flutter installed

---

## 🚀 Fast Track Implementation

### 1️⃣ Install Packages (5 min)

```bash
cd backend
npm install csurf cookie-parser sanitize-html validator xss
```

### 2️⃣ Setup Environment (10 min)

```bash
# Copy example to .env
cp backend/.env.example backend/.env

# Edit backend/.env and update these critical values:
# JWT_SECRET=ce30038a642b0048e88b7624b396932292b58d67858ec1c71fcf78c5e5cb15e163c0357d0f9a7f86463808eb5530a54837494f852feaa93ce78998844d7b4b54
# DB_PASSWORD=<your-secure-password>
# EMAIL_USER=<your-email>
# EMAIL_PASS=<your-email-password>
```

### 3️⃣ Update Server (15 min)

Add to `backend/src/server.js` after line 30 (after body parsing):

```javascript
// Import new middleware
const cookieParser = require('cookie-parser');
const { csrfProtection, csrfErrorHandler, getCsrfToken } = require('./middleware/csrf');
const { sanitizeInput } = require('./middleware/sanitization');

// Add middleware (after body parsing, before routes)
app.use(cookieParser());
app.use(sanitizeInput);
app.use('/api', csrfProtection);

// Add CSRF token endpoint (after health check)
app.get('/api/csrf-token', getCsrfToken);

// Add CSRF error handler (before general error handler, around line 200)
app.use(csrfErrorHandler);
```

### 4️⃣ Test Backend (10 min)

```bash
# Start backend
cd backend
npm start

# In another terminal, test CSRF endpoint
curl http://localhost:3000/api/csrf-token

# Should return: {"success":true,"csrfToken":"...","timestamp":"..."}
```

### 5️⃣ Update Frontend (20 min)

Create `frontend/lib/services/csrf_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class CsrfService {
  static String? _csrfToken;
  static DateTime? _tokenExpiry;
  
  static Future<String> getToken() async {
    if (_csrfToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _csrfToken!;
    }
    
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/csrf-token'),
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
  
  static void clearToken() {
    _csrfToken = null;
    _tokenExpiry = null;
  }
}
```

Update `frontend/lib/services/api_service.dart` - Add at top:

```dart
import 'csrf_service.dart';
```

Update `_getHeaders` method (around line 50):

```dart
static Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  if (includeAuth) {
    String? token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    // Add CSRF token
    try {
      final csrfToken = await CsrfService.getToken();
      headers['X-CSRF-Token'] = csrfToken;
    } catch (e) {
      print('Warning: Could not get CSRF token: $e');
    }
  }

  return headers;
}
```

### 6️⃣ Test Frontend (10 min)

```bash
# Start frontend
cd frontend
flutter run -d chrome --web-port 8080

# Test:
# 1. Login as donor (demo@example.com / demo123)
# 2. Try to create a donation
# 3. Should work without errors
# 4. Check browser console - no CSRF errors
```

### 7️⃣ Verify Security (10 min)

```bash
# Test 1: CSRF Protection
# Try to create donation without CSRF token (should fail)
curl -X POST http://localhost:3000/api/donations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-token>" \
  -d '{"title":"Test"}'

# Expected: 403 Forbidden - Invalid CSRF token

# Test 2: XSS Prevention
# Try to inject script (should be sanitized)
curl -X POST http://localhost:3000/api/donations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-token>" \
  -H "X-CSRF-Token: <csrf-token>" \
  -d '{"title":"<script>alert(\"XSS\")</script>Test"}'

# Expected: Title should be "Test" (script removed)
```

---

## ✅ Verification Checklist

- [ ] Packages installed successfully
- [ ] .env file created and configured
- [ ] Server starts without errors
- [ ] CSRF token endpoint works
- [ ] Frontend can fetch CSRF token
- [ ] Login still works
- [ ] Create donation still works
- [ ] CSRF protection blocks requests without token
- [ ] XSS attempts are sanitized
- [ ] No errors in browser console
- [ ] No errors in server logs

---

## 🎯 Success Indicators

✅ **Backend:** Server starts, CSRF endpoint returns token  
✅ **Frontend:** App loads, can login, can create donations  
✅ **Security:** CSRF blocks unauthorized requests, XSS is prevented  
✅ **Logs:** No security warnings or errors

---

## ⚠️ Common Issues & Solutions

### Issue: "Cannot find module 'csurf'"
**Solution:** Run `npm install` in backend directory

### Issue: "Invalid CSRF token"
**Solution:** 
1. Clear browser cookies
2. Restart backend server
3. Refresh frontend

### Issue: Frontend can't fetch CSRF token
**Solution:**
1. Check CORS configuration
2. Verify backend is running
3. Check browser console for errors

### Issue: Existing functionality broken
**Solution:**
1. Check that all middleware is in correct order
2. Verify .env file has all required values
3. Check server logs for errors

---

## 🆘 Emergency Rollback

If something goes wrong:

```bash
# 1. Stop servers
# Ctrl+C in both terminals

# 2. Revert changes
git checkout backend/src/server.js
git checkout frontend/lib/services/api_service.dart

# 3. Remove new files
rm frontend/lib/services/csrf_service.dart

# 4. Restart
cd backend && npm start
cd frontend && flutter run -d chrome
```

---

## 📞 Need Help?

1. Check `SECURITY_IMPLEMENTATION_GUIDE.md` for detailed steps
2. Check `COMPREHENSIVE_AUDIT_REPORT.md` for context
3. Check server logs: `backend/logs/`
4. Check browser console for frontend errors

---

## 🎉 Done!

Once all checks pass, you've successfully implemented critical security fixes!

**Next Steps:**
1. Deploy to staging environment
2. Run full test suite
3. Security audit verification
4. Deploy to production

---

**Estimated Time:** 1.5 - 2 hours  
**Status:** Ready to implement  
**Priority:** 🔴 Critical
