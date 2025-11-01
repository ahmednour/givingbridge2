# 🔒 Security Fix Checklist - Giving Bridge Platform

**Priority:** CRITICAL  
**Timeline:** Complete within 2 weeks  
**Status:** 🔴 Not Started

---

## Week 1: Critical Security Fixes

### Day 1-2: Secrets Management

- [ ] **Generate new JWT secret**
  ```bash
  node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
  ```

- [ ] **Update .gitignore**
  ```bash
  echo ".env" >> .gitignore
  echo ".env.local" >> .gitignore
  echo ".env.production" >> .gitignore
  ```

- [ ] **Remove .env from git history**
  ```bash
  git filter-branch --force --index-filter \
    "git rm --cached --ignore-unmatch backend/.env" \
    --prune-empty --tag-name-filter cat -- --all
  ```

- [ ] **Set up environment variables on server**
  - Use AWS Secrets Manager / Azure Key Vault / HashiCorp Vault
  - Never commit secrets to repository

- [ ] **Rotate database password**
  ```sql
  ALTER USER 'givingbridge_user'@'localhost' IDENTIFIED BY '<new-password>';
  ```

- [ ] **Update all team members**
  - Notify about secret rotation
  - Provide new credentials securely
  - Update local .env files

---

### Day 3-4: CSRF Protection

- [ ] **Install csurf package**
  ```bash
  cd backend
  npm install csurf cookie-parser
  ```

- [ ] **Add CSRF middleware**
  ```javascript
  const csrf = require('csurf');
  const cookieParser = require('cookie-parser');
  
  app.use(cookieParser());
  const csrfProtection = csrf({ cookie: true });
  app.use('/api', csrfProtection);
  ```

- [ ] **Create CSRF token endpoint**
  ```javascript
  app.get('/api/csrf-token', csrfProtection, (req, res) => {
    res.json({ csrfToken: req.csrfToken() });
  });
  ```

- [ ] **Update frontend to include CSRF token**
  ```dart
  // Fetch token on app start
  final csrfToken = await ApiService.getCsrfToken();
  
  // Include in all requests
  headers['X-CSRF-Token'] = csrfToken;
  ```

- [ ] **Test CSRF protection**
  - Verify requests without token are rejected
  - Verify requests with valid token succeed

---

### Day 5-7: Input Sanitization

- [ ] **Install sanitization packages**
  ```bash
  npm install validator sanitize-html xss
  ```

- [ ] **Create sanitization middleware**
  ```javascript
  const sanitizeHtml = require('sanitize-html');
  const validator = require('validator');
  
  const sanitizeInput = (req, res, next) => {
    for (const key in req.body) {
      if (typeof req.body[key] === 'string') {
        req.body[key] = sanitizeHtml(req.body[key], {
          allowedTags: [],
          allowedAttributes: {}
        });
      }
    }
    next();
  };
  ```

- [ ] **Apply to all POST/PUT routes**
  ```javascript
  app.use('/api', sanitizeInput);
  ```

- [ ] **Add SQL injection protection**
  ```javascript
  const sanitizeSearchInput = (input) => {
    return input.replace(/[%_\\]/g, '\\$&').substring(0, 100);
  };
  ```

- [ ] **Test input sanitization**
  - Test with XSS payloads
  - Test with SQL injection attempts
  - Verify legitimate input still works

---

## Week 2: Additional Security Measures

### Day 8-9: Password Policy

- [ ] **Update password validation**
  ```javascript
  const validatePassword = (password) => {
    const errors = [];
    if (password.length < 12) errors.push('Min 12 characters');
    if (!/[A-Z]/.test(password)) errors.push('Need uppercase');
    if (!/[a-z]/.test(password)) errors.push('Need lowercase');
    if (!/[0-9]/.test(password)) errors.push('Need number');
    if (!/[!@#$%^&*]/.test(password)) errors.push('Need special char');
    return errors;
  };
  ```

- [ ] **Add password strength meter in frontend**
  ```dart
  PasswordStrengthIndicator(
    password: _passwordController.text,
    onStrengthChanged: (strength) {
      setState(() => _passwordStrength = strength);
    },
  );
  ```

- [ ] **Force password reset for existing users**
  - Send email notification
  - Require password change on next login

---

### Day 10-11: Logging & Monitoring

- [ ] **Implement log sanitization**
  ```javascript
  const sanitizeLog = (data) => {
    const sensitive = ['password', 'token', 'secret', 'apiKey'];
    const sanitized = { ...data };
    for (const key in sanitized) {
      if (sensitive.some(s => key.toLowerCase().includes(s))) {
        sanitized[key] = '[REDACTED]';
      }
    }
    return sanitized;
  };
  ```

- [ ] **Set up error tracking (Sentry)**
  ```bash
  npm install @sentry/node
  ```
  ```javascript
  const Sentry = require('@sentry/node');
  Sentry.init({ dsn: process.env.SENTRY_DSN });
  app.use(Sentry.Handlers.errorHandler());
  ```

- [ ] **Add security event logging**
  ```javascript
  logger.logSecurityEvent('failed_login', 'MEDIUM', {
    email: req.body.email,
    ip: req.ip,
    timestamp: new Date()
  });
  ```

---

### Day 12-14: Testing & Validation

- [ ] **Security testing**
  - [ ] Run OWASP ZAP scan
  - [ ] Test authentication bypass attempts
  - [ ] Test CSRF protection
  - [ ] Test input sanitization
  - [ ] Test rate limiting

- [ ] **Penetration testing**
  - [ ] SQL injection tests
  - [ ] XSS tests
  - [ ] Authentication tests
  - [ ] Authorization tests
  - [ ] Session management tests

- [ ] **Code review**
  - [ ] Review all authentication code
  - [ ] Review all authorization code
  - [ ] Review all input validation
  - [ ] Review all database queries

- [ ] **Documentation**
  - [ ] Document security measures
  - [ ] Create security guidelines
  - [ ] Update deployment docs
  - [ ] Create incident response plan

---

## Verification Checklist

### Before Deployment

- [ ] All secrets removed from repository
- [ ] New secrets generated and stored securely
- [ ] CSRF protection tested and working
- [ ] Input sanitization tested and working
- [ ] Password policy enforced
- [ ] Logging sanitization implemented
- [ ] Security tests passed
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Team trained on new security measures

### Post-Deployment

- [ ] Monitor logs for security events
- [ ] Set up alerts for suspicious activity
- [ ] Schedule regular security audits
- [ ] Plan for security updates
- [ ] Establish incident response procedures

---

## Emergency Contacts

**Security Lead:** [Name]  
**DevOps Lead:** [Name]  
**CTO/Technical Lead:** [Name]

---

## Resources

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Node.js Security Checklist: https://blog.risingstack.com/node-js-security-checklist/
- CSRF Protection Guide: https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html
- Input Validation Guide: https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html

---

**Last Updated:** October 29, 2025  
**Next Review:** After all items completed
