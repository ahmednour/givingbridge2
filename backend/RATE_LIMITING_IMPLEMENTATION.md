# Rate Limiting Implementation

## Overview

This document describes the rate limiting implementation for the GivingBridge platform. Rate limiting is applied to prevent abuse and ensure fair usage of the API by limiting the number of requests that can be made within specific time windows.

## Rate Limiting Strategy

The rate limiting implementation uses different strategies for different types of endpoints:

### 1. General API Endpoints

- **Rate**: 100 requests per 15 minutes per IP
- **Applied to**: Most public and authenticated API endpoints
- **Purpose**: Prevent general API abuse while allowing normal usage

### 2. Authentication Endpoints

- **Rate**: 5 requests per 15 minutes per IP
- **Applied to**: Login and registration endpoints
- **Purpose**: Prevent brute force attacks and credential stuffing

### 3. Registration Endpoints

- **Rate**: 3 requests per hour per IP
- **Applied to**: User registration endpoints
- **Purpose**: Prevent spam account creation

### 4. Password Reset Endpoints

- **Rate**: 3 requests per hour per IP
- **Applied to**: Password reset request endpoints
- **Purpose**: Prevent abuse of password reset functionality

### 5. Email Verification Endpoints

- **Rate**: 5 requests per hour per IP
- **Applied to**: Email verification endpoints
- **Purpose**: Prevent abuse of email verification system

### 6. File Upload Endpoints

- **Rate**: 20 requests per hour per IP
- **Applied to**: File upload endpoints
- **Purpose**: Prevent abuse of file upload functionality

### 7. Heavy Operation Endpoints

- **Rate**: 30 requests per 15 minutes per IP
- **Applied to**: Analytics, statistics, and search endpoints
- **Purpose**: Prevent resource exhaustion from heavy operations

## Implementation Details

### Rate Limiting Middleware

Rate limiting is implemented using the `express-rate-limit` middleware with the following configuration:

```javascript
const rateLimit = require("express-rate-limit");

// General API rate limiter
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: "Too many requests from this IP, please try again later.",
    error: "RATE_LIMIT_EXCEEDED",
  },
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});
```

### Endpoint-Specific Rate Limiting

Different rate limits are applied to different endpoints based on their sensitivity and resource usage:

#### Authentication Endpoints

- `POST /api/auth/register` - Registration rate limiter (3/hr)
- `POST /api/auth/login` - Login rate limiter (5/15min)
- `POST /api/auth/forgot-password` - Password reset rate limiter (3/hr)
- `POST /api/auth/reset-password` - Password reset rate limiter (3/hr)
- `POST /api/auth/verify-email` - Email verification rate limiter (5/hr)
- `POST /api/auth/resend-verification` - Email verification rate limiter (5/hr)

#### API Endpoints

- Most GET endpoints - General rate limiter (100/15min)
- Most POST/PUT/DELETE endpoints - General rate limiter (100/15min)
- File upload endpoints - Upload rate limiter (20/hr)

#### Heavy Operation Endpoints

- Analytics endpoints - Heavy operation rate limiter (30/15min)
- Search endpoints - General rate limiter (100/15min)
- Statistics endpoints - Heavy operation rate limiter (30/15min)

## Configuration

Rate limiting parameters can be configured through environment variables:

- `RATE_LIMIT_WINDOW_MS` - Window size in milliseconds (default: 900000 - 15 minutes)
- `RATE_LIMIT_MAX_REQUESTS` - Maximum requests per window (default: 100)
- `LOGIN_RATE_LIMIT_WINDOW_MS` - Login window size in milliseconds (default: 900000 - 15 minutes)
- `LOGIN_RATE_LIMIT_MAX_ATTEMPTS` - Maximum login attempts per window (default: 5)

## Response Format

When a rate limit is exceeded, the API returns a 429 (Too Many Requests) status code with the following JSON response:

```json
{
  "success": false,
  "message": "Too many requests from this IP, please try again later.",
  "error": "RATE_LIMIT_EXCEEDED"
}
```

## Headers

The rate limiting middleware adds the following headers to responses when rate limiting is applied:

- `RateLimit-Limit` - The maximum number of requests allowed in the window
- `RateLimit-Remaining` - The number of requests remaining in the current window
- `RateLimit-Reset` - The time at which the current window resets (in UTC epoch seconds)

## Testing

Rate limiting can be tested by making multiple requests to rate-limited endpoints within a short period. The system should return 429 responses when limits are exceeded.

## Future Enhancements

Potential future enhancements to the rate limiting system include:

1. User-based rate limiting in addition to IP-based limiting
2. Dynamic rate limiting based on user roles or subscription tiers
3. Integration with external services for more sophisticated rate limiting
4. Rate limiting based on specific API keys or tokens
5. Whitelisting of trusted IPs or users
6. More granular rate limiting for specific endpoints based on usage patterns

## Security Considerations

The rate limiting implementation helps protect against several types of attacks:

1. **Brute Force Attacks** - By limiting login attempts
2. **Credential Stuffing** - By limiting authentication requests
3. **Denial of Service** - By preventing resource exhaustion
4. **Spam** - By limiting account creation and messaging
5. **Data Scraping** - By limiting API requests

The implementation uses IP-based limiting which provides a good balance between security and usability while being resistant to simple circumvention methods.
