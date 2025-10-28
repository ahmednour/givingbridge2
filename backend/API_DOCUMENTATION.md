# GivingBridge API Documentation

## Overview

The GivingBridge API provides a comprehensive set of endpoints for managing donations, requests, users, and all platform functionality. This RESTful API follows modern standards and best practices.

## Base URL

- **Development**: `http://localhost:3000/api`
- **Production**: `https://api.givingbridge.com/api`

## Interactive Documentation

Visit the interactive Swagger documentation at:
- **Development**: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
- **Production**: [https://api.givingbridge.com/api-docs](https://api.givingbridge.com/api-docs)

## API Versioning

The GivingBridge API uses versioning to ensure backward compatibility and smooth transitions between API versions.

### Version Information
- **Current Version**: v1
- **Supported Versions**: v1
- **Default Version**: v1 (when no version is specified)

### Version Specification Methods

1. **URL Path** (Recommended)
   ```
   GET /api/v1/users
   ```

2. **Accept Header**
   ```
   Accept: application/vnd.givingbridge.v1+json
   ```

3. **Custom Header**
   ```
   X-API-Version: v1
   ```

4. **Query Parameter**
   ```
   GET /api/users?version=v1
   ```

### Version Headers

All responses include version information in headers:
- `X-API-Version`: The version used for this request
- `X-API-Current-Version`: The latest available version
- `X-API-Supported-Versions`: All supported versions

## Authentication

The API uses JWT (JSON Web Token) based authentication.

### Getting a Token

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "your_password"
}
```

### Using the Token

Include the token in the Authorization header:

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

### Token Expiration

Tokens expire after 7 days by default. You'll receive a `401 Unauthorized` response when the token expires.

## Rate Limiting

The API implements rate limiting to ensure fair usage and prevent abuse.

### Rate Limit Headers

All responses include rate limit information:
- `X-RateLimit-Limit`: Maximum requests allowed in the time window
- `X-RateLimit-Remaining`: Remaining requests in the current window
- `X-RateLimit-Reset`: Unix timestamp when the rate limit resets

### Rate Limits by Endpoint Type

| Endpoint Type | Limit | Window |
|---------------|-------|--------|
| General API | 100 requests | 15 minutes |
| Authentication | 5 attempts | 15 minutes |
| File Upload | 10 uploads | 1 minute |
| Password Reset | 3 requests | 1 hour |
| Email Verification | 5 requests | 1 hour |
| Search | 30 requests | 1 minute |

### Rate Limit Exceeded

When rate limits are exceeded, you'll receive a `429 Too Many Requests` response:

```json
{
  "success": false,
  "message": "Rate limit exceeded",
  "errorType": "RATE_LIMIT_EXCEEDED",
  "retryAfter": 60,
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## Response Format

All API responses follow a consistent format:

### Success Response

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data here
  },
  "timestamp": "2024-01-01T12:00:00.000Z",
  "version": "v1"
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error description",
  "errorId": "ERR_1234567890_abc123",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "version": "v1",
  "errors": [
    // Detailed error information (for validation errors)
  ]
}
```

### Paginated Response

```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [
    // Array of items
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5
    }
  },
  "timestamp": "2024-01-01T12:00:00.000Z",
  "version": "v1"
}
```

## Error Codes

| HTTP Status | Error Type | Description |
|-------------|------------|-------------|
| 400 | VALIDATION_ERROR | Request validation failed |
| 401 | UNAUTHORIZED | Authentication required or invalid |
| 403 | FORBIDDEN | Access denied |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource conflict (e.g., duplicate email) |
| 429 | RATE_LIMIT_EXCEEDED | Rate limit exceeded |
| 500 | INTERNAL_ERROR | Server error |

## Pagination

List endpoints support pagination using query parameters:

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 100)
- `sort`: Sort field and direction (e.g., `createdAt:desc`)

Example:
```
GET /api/donations?page=2&limit=10&sort=createdAt:desc
```

## Filtering and Search

Many endpoints support filtering and search:

- `search`: Full-text search across relevant fields
- Field-specific filters (varies by endpoint)

Example:
```
GET /api/donations?category=clothing&location=New York&search=winter
```

## File Uploads

File upload endpoints accept multipart/form-data:

```http
POST /api/upload
Content-Type: multipart/form-data

file: [binary data]
```

### File Restrictions
- Maximum file size: 10MB
- Allowed types: Images (jpg, png, gif), Documents (pdf)
- Files are scanned for security

## Webhooks

The API supports webhooks for real-time notifications:

- Donation created/updated
- Request created/updated
- User verification status changed
- Message received

Contact support to configure webhooks for your integration.

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Get current user profile
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password

### Users
- `GET /api/users` - List users
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user
- `POST /api/users/:id/verify` - Verify user

### Donations
- `GET /api/donations` - List donations
- `POST /api/donations` - Create donation
- `GET /api/donations/:id` - Get donation by ID
- `PUT /api/donations/:id` - Update donation
- `DELETE /api/donations/:id` - Delete donation

### Requests
- `GET /api/requests` - List requests
- `POST /api/requests` - Create request
- `GET /api/requests/:id` - Get request by ID
- `PUT /api/requests/:id` - Update request
- `DELETE /api/requests/:id` - Delete request

### Messages
- `GET /api/messages` - List messages
- `POST /api/messages` - Send message
- `GET /api/messages/:id` - Get message by ID
- `PUT /api/messages/:id/read` - Mark as read

### Search
- `GET /api/search/donations` - Search donations
- `GET /api/search/requests` - Search requests
- `GET /api/search/users` - Search users
- `GET /api/search/suggestions` - Get search suggestions

### Analytics
- `GET /api/analytics/overview` - Platform overview
- `GET /api/analytics/donations` - Donation analytics
- `GET /api/analytics/requests` - Request analytics
- `GET /api/analytics/users` - User analytics

## SDKs and Libraries

### JavaScript/Node.js
```bash
npm install givingbridge-api-client
```

### Python
```bash
pip install givingbridge-api-client
```

### PHP
```bash
composer require givingbridge/api-client
```

## Code Examples

### JavaScript (Node.js)

```javascript
const GivingBridge = require('givingbridge-api-client');

const client = new GivingBridge({
  baseURL: 'https://api.givingbridge.com',
  apiKey: 'your-api-key'
});

// Get donations
const donations = await client.donations.list({
  category: 'clothing',
  limit: 10
});

// Create a donation
const newDonation = await client.donations.create({
  title: 'Winter Clothes',
  description: 'Warm winter clothing for homeless',
  category: 'clothing',
  location: 'New York, NY'
});
```

### Python

```python
from givingbridge import GivingBridgeClient

client = GivingBridgeClient(
    base_url='https://api.givingbridge.com',
    api_key='your-api-key'
)

# Get donations
donations = client.donations.list(
    category='clothing',
    limit=10
)

# Create a donation
new_donation = client.donations.create({
    'title': 'Winter Clothes',
    'description': 'Warm winter clothing for homeless',
    'category': 'clothing',
    'location': 'New York, NY'
})
```

### cURL

```bash
# Login
curl -X POST https://api.givingbridge.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}'

# Get donations (with token)
curl -X GET https://api.givingbridge.com/api/donations \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"

# Create donation
curl -X POST https://api.givingbridge.com/api/donations \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Winter Clothes",
    "description": "Warm winter clothing for homeless",
    "category": "clothing",
    "location": "New York, NY"
  }'
```

## Testing

### Postman Collection

Import our Postman collection for easy API testing:
- [Download Postman Collection](./postman/GivingBridge-API.postman_collection.json)
- [Download Environment Variables](./postman/GivingBridge-Environment.postman_environment.json)

### Test Environment

Use our test environment for development:
- **Base URL**: `https://test-api.givingbridge.com`
- **Test Users**: Available in the Postman collection
- **Test Data**: Reset daily at midnight UTC

## Support

### Documentation
- [Interactive API Docs](http://localhost:3000/api-docs)
- [Developer Guide](./DEVELOPMENT_SETUP.md)
- [Contributing Guidelines](../CONTRIBUTING.md)

### Community
- [GitHub Issues](https://github.com/givingbridge/api/issues)
- [Developer Discord](https://discord.gg/givingbridge-dev)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/givingbridge)

### Contact
- **Email**: api-support@givingbridge.com
- **Response Time**: 24-48 hours
- **Emergency**: For critical issues affecting production

## Changelog

### v1.0.0 (Current)
- Initial API release
- Full CRUD operations for all resources
- JWT authentication
- Rate limiting
- File upload support
- Search functionality
- Analytics endpoints

## Roadmap

### v1.1.0 (Planned)
- GraphQL endpoint
- Real-time subscriptions
- Advanced filtering
- Bulk operations
- Enhanced analytics

### v2.0.0 (Future)
- Breaking changes will be announced 6 months in advance
- Migration guide will be provided
- v1 will be supported for 12 months after v2 release

---

For the most up-to-date information, always refer to the [interactive documentation](http://localhost:3000/api-docs).