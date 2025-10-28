## Search Endpoints

### Search Donations

- **URL**: `GET /api/search/donations`
- **Description**: Search donations with advanced filters
- **Query Parameters**:
  - `query`: Text search across title and description
  - `category`: Filter by category (food, clothes, books, electronics, other)
  - `location`: Filter by location (partial match)
  - `condition`: Filter by condition (new, like-new, good, fair)
  - `status`: Filter by status (available, pending, completed, cancelled)
  - `available`: Filter by availability (true/false)
  - `startDate`: Filter by creation date (from)
  - `endDate`: Filter by creation date (to)
  - `minDate`: Alternative date filter (from)
  - `maxDate`: Alternative date filter (to)
  - `sortBy`: Sort field (default: createdAt)
  - `sortOrder`: Sort order (ASC or DESC, default: DESC)
  - `page`: Page number (default: 1)
  - `limit`: Results per page (default: 20)
- **Response**:
  ```json
  {
    "message": "Donations search completed successfully",
    "donations": [
      {
        "id": 1,
        "title": "Gently Used Books",
        "description": "Collection of fiction and non-fiction books",
        "category": "books",
        "condition": "good",
        "location": "New York, NY",
        "donorId": 1,
        "donorName": "John Doe",
        "imageUrl": null,
        "isAvailable": true,
        "status": "available",
        "createdAt": "2023-01-01T00:00:00.000Z",
        "updatedAt": "2023-01-01T00:00:00.000Z"
      }
    ],
    "pagination": {
      "total": 1,
      "page": 1,
      "limit": 20,
      "totalPages": 1,
      "hasMore": false
    }
  }
  ```

### Search Requests

- **URL**: `GET /api/search/requests`
- **Description**: Search requests with advanced filters
- **Headers**: `Authorization: Bearer <token>`
- **Query Parameters**:
  - `query`: Text search across donation title and description
  - `status`: Filter by status (pending, approved, declined, completed, cancelled)
  - `category`: Filter by donation category (food, clothes, books, electronics, other)
  - `location`: Filter by donation location (partial match)
  - `startDate`: Filter by creation date (from)
  - `endDate`: Filter by creation date (to)
  - `minDate`: Alternative date filter (from)
  - `maxDate`: Alternative date filter (to)
  - `sortBy`: Sort field (default: createdAt)
  - `sortOrder`: Sort order (ASC or DESC, default: DESC)
  - `page`: Page number (default: 1)
  - `limit`: Results per page (default: 20)
- **Response**:
  ```json
  {
    "message": "Requests search completed successfully",
    "requests": [
      {
        "id": 1,
        "donationId": 1,
        "donorId": 1,
        "donorName": "John Doe",
        "receiverId": 2,
        "receiverName": "Jane Smith",
        "receiverEmail": "jane@example.com",
        "receiverPhone": null,
        "message": "I would love these books for my children",
        "status": "pending",
        "responseMessage": null,
        "createdAt": "2023-01-01T00:00:00.000Z",
        "updatedAt": "2023-01-01T00:00:00.000Z",
        "respondedAt": null,
        "attachmentUrl": "/uploads/request-images/request-1-1234567890-image.jpg",
        "attachmentName": "proof.jpg",
        "attachmentSize": 102400,
        "donation": {
          "id": 1,
          "title": "Gently Used Books",
          "description": "Collection of fiction and non-fiction books",
          "category": "books",
          "condition": "good",
          "location": "New York, NY"
        },
        "donor": {
          "id": 1,
          "name": "John Doe",
          "email": "john@example.com",
          "phone": null,
          "location": "New York, NY"
        },
        "receiver": {
          "id": 2,
          "name": "Jane Smith",
          "email": "jane@example.com",
          "phone": null,
          "location": "Boston, MA"
        }
      }
    ],
    "pagination": {
      "total": 1,
      "page": 1,
      "limit": 20,
      "totalPages": 1,
      "hasMore": false
    }
  }
  ```

### Get Donation Filter Options

- **URL**: `GET /api/search/donations/filters`
- **Description**: Get available filter options for donations
- **Response**:
  ```json
  {
    "message": "Donation filter options retrieved successfully",
    "filters": {
      "categories": ["food", "clothes", "books", "electronics", "other"],
      "conditions": ["new", "like-new", "good", "fair"],
      "locations": ["New York, NY", "Boston, MA", "Los Angeles, CA"]
    }
  }
  ```

### Get Request Filter Options

- **URL**: `GET /api/search/requests/filters`
- **Description**: Get available filter options for requests
- **Headers**: `Authorization: Bearer <token>`
- **Response**:
  ```json
  {
    "message": "Request filter options retrieved successfully",
    "filters": {
      "statuses": ["pending", "approved", "declined", "completed", "cancelled"]
    }
  }
  ```
