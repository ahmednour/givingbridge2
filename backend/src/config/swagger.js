const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'GivingBridge API',
      version: '1.0.0',
      description: 'Comprehensive API documentation for the GivingBridge donation platform',
      contact: {
        name: 'GivingBridge Development Team',
        email: 'dev@givingbridge.com'
      },
      license: {
        name: 'ISC',
        url: 'https://opensource.org/licenses/ISC'
      }
    },
    servers: [
      {
        url: process.env.NODE_ENV === 'production' 
          ? 'https://api.givingbridge.com' 
          : `http://localhost:${process.env.PORT || 3000}`,
        description: process.env.NODE_ENV === 'production' ? 'Production server' : 'Development server'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'JWT token obtained from /api/auth/login endpoint'
        }
      },
      schemas: {
        User: {
          type: 'object',
          required: ['name', 'email', 'password'],
          properties: {
            id: {
              type: 'integer',
              description: 'Unique user identifier',
              example: 1
            },
            name: {
              type: 'string',
              description: 'Full name of the user',
              example: 'John Doe'
            },
            email: {
              type: 'string',
              format: 'email',
              description: 'User email address',
              example: 'john.doe@example.com'
            },
            role: {
              type: 'string',
              enum: ['donor', 'receiver', 'admin'],
              description: 'User role in the platform',
              example: 'donor'
            },
            phone: {
              type: 'string',
              description: 'User phone number',
              example: '+1234567890'
            },
            location: {
              type: 'string',
              description: 'User location',
              example: 'New York, NY'
            },
            avatar: {
              type: 'string',
              description: 'URL to user avatar image',
              example: '/uploads/avatars/user1.jpg'
            },
            isVerified: {
              type: 'boolean',
              description: 'Whether user is verified',
              example: true
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'User creation timestamp'
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
              description: 'User last update timestamp'
            }
          }
        },
        Donation: {
          type: 'object',
          required: ['title', 'description', 'category', 'location'],
          properties: {
            id: {
              type: 'integer',
              description: 'Unique donation identifier',
              example: 1
            },
            title: {
              type: 'string',
              description: 'Donation title',
              example: 'Winter Clothes for Homeless'
            },
            description: {
              type: 'string',
              description: 'Detailed donation description',
              example: 'Warm winter clothes including jackets, sweaters, and blankets'
            },
            category: {
              type: 'string',
              description: 'Donation category',
              example: 'clothing'
            },
            location: {
              type: 'string',
              description: 'Donation pickup location',
              example: 'New York, NY'
            },
            status: {
              type: 'string',
              enum: ['available', 'reserved', 'completed'],
              description: 'Current donation status',
              example: 'available'
            },
            images: {
              type: 'array',
              items: {
                type: 'string'
              },
              description: 'Array of image URLs',
              example: ['/uploads/donations/item1.jpg']
            },
            donorId: {
              type: 'integer',
              description: 'ID of the donor user',
              example: 1
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'Donation creation timestamp'
            }
          }
        },
        Request: {
          type: 'object',
          required: ['title', 'description', 'category', 'location'],
          properties: {
            id: {
              type: 'integer',
              description: 'Unique request identifier',
              example: 1
            },
            title: {
              type: 'string',
              description: 'Request title',
              example: 'Need Food for Family'
            },
            description: {
              type: 'string',
              description: 'Detailed request description',
              example: 'Family of 4 needs food assistance for the week'
            },
            category: {
              type: 'string',
              description: 'Request category',
              example: 'food'
            },
            location: {
              type: 'string',
              description: 'Request location',
              example: 'Los Angeles, CA'
            },
            urgency: {
              type: 'string',
              enum: ['low', 'medium', 'high', 'critical'],
              description: 'Request urgency level',
              example: 'high'
            },
            status: {
              type: 'string',
              enum: ['open', 'in_progress', 'fulfilled', 'closed'],
              description: 'Current request status',
              example: 'open'
            },
            requesterId: {
              type: 'integer',
              description: 'ID of the requester user',
              example: 2
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
              description: 'Request creation timestamp'
            }
          }
        },
        Error: {
          type: 'object',
          properties: {
            error: {
              type: 'string',
              description: 'Error message',
              example: 'Invalid request parameters'
            },
            code: {
              type: 'string',
              description: 'Error code',
              example: 'VALIDATION_ERROR'
            },
            details: {
              type: 'object',
              description: 'Additional error details'
            }
          }
        },
        ValidationError: {
          type: 'object',
          properties: {
            error: {
              type: 'string',
              example: 'Validation failed'
            },
            details: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  field: {
                    type: 'string',
                    example: 'email'
                  },
                  message: {
                    type: 'string',
                    example: 'Invalid email format'
                  }
                }
              }
            }
          }
        },
        RateLimitError: {
          type: 'object',
          properties: {
            error: {
              type: 'string',
              example: 'Rate limit exceeded'
            },
            retryAfter: {
              type: 'integer',
              description: 'Seconds to wait before retrying',
              example: 60
            }
          }
        }
      },
      responses: {
        UnauthorizedError: {
          description: 'Authentication token is missing or invalid',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error'
              },
              example: {
                error: 'Unauthorized access',
                code: 'UNAUTHORIZED'
              }
            }
          }
        },
        ValidationError: {
          description: 'Request validation failed',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/ValidationError'
              }
            }
          }
        },
        RateLimitError: {
          description: 'Rate limit exceeded',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/RateLimitError'
              }
            }
          },
          headers: {
            'X-RateLimit-Limit': {
              description: 'Request limit per time window',
              schema: {
                type: 'integer'
              }
            },
            'X-RateLimit-Remaining': {
              description: 'Remaining requests in current window',
              schema: {
                type: 'integer'
              }
            },
            'X-RateLimit-Reset': {
              description: 'Time when rate limit resets (Unix timestamp)',
              schema: {
                type: 'integer'
              }
            }
          }
        },
        NotFoundError: {
          description: 'Resource not found',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error'
              },
              example: {
                error: 'Resource not found',
                code: 'NOT_FOUND'
              }
            }
          }
        },
        ServerError: {
          description: 'Internal server error',
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/Error'
              },
              example: {
                error: 'Internal server error',
                code: 'INTERNAL_ERROR'
              }
            }
          }
        }
      },
      parameters: {
        PageParam: {
          name: 'page',
          in: 'query',
          description: 'Page number for pagination',
          required: false,
          schema: {
            type: 'integer',
            minimum: 1,
            default: 1
          }
        },
        LimitParam: {
          name: 'limit',
          in: 'query',
          description: 'Number of items per page',
          required: false,
          schema: {
            type: 'integer',
            minimum: 1,
            maximum: 100,
            default: 10
          }
        },
        SortParam: {
          name: 'sort',
          in: 'query',
          description: 'Sort field and direction (e.g., createdAt:desc)',
          required: false,
          schema: {
            type: 'string',
            example: 'createdAt:desc'
          }
        },
        SearchParam: {
          name: 'search',
          in: 'query',
          description: 'Search term for filtering results',
          required: false,
          schema: {
            type: 'string'
          }
        }
      }
    },
    security: [
      {
        bearerAuth: []
      }
    ],
    tags: [
      {
        name: 'Authentication',
        description: 'User authentication and authorization endpoints'
      },
      {
        name: 'Users',
        description: 'User management operations'
      },
      {
        name: 'Donations',
        description: 'Donation management operations'
      },
      {
        name: 'Requests',
        description: 'Request management operations'
      },
      {
        name: 'Messages',
        description: 'Messaging system operations'
      },
      {
        name: 'Notifications',
        description: 'Notification management operations'
      },
      {
        name: 'Analytics',
        description: 'Analytics and reporting endpoints'
      },
      {
        name: 'Search',
        description: 'Search and filtering operations'
      },
      {
        name: 'Verification',
        description: 'User and request verification operations'
      }
    ]
  },
  apis: [
    './src/routes/*.js',
    './src/controllers/*.js',
    './src/models/*.js'
  ]
};

const specs = swaggerJsdoc(options);

module.exports = {
  specs,
  swaggerUi,
  swaggerOptions: {
    explorer: true,
    swaggerOptions: {
      docExpansion: 'none',
      filter: true,
      showRequestHeaders: true,
      showCommonExtensions: true,
      tryItOutEnabled: true
    }
  }
};