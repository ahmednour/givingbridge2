/**
 * Application constants to eliminate magic numbers and strings
 */

// User roles
const USER_ROLES = {
  DONOR: "donor",
  RECEIVER: "receiver",
  ADMIN: "admin",
};

// Donation categories
const DONATION_CATEGORIES = {
  FOOD: "food",
  CLOTHES: "clothes",
  BOOKS: "books",
  ELECTRONICS: "electronics",
  OTHER: "other",
};

// Donation conditions
const DONATION_CONDITIONS = {
  NEW: "new",
  LIKE_NEW: "like-new",
  GOOD: "good",
  FAIR: "fair",
};

// Donation statuses
const DONATION_STATUSES = {
  AVAILABLE: "available",
  PENDING: "pending",
  COMPLETED: "completed",
  CANCELLED: "cancelled",
};

// Request statuses
const REQUEST_STATUSES = {
  PENDING: "pending",
  APPROVED: "approved",
  DECLINED: "declined",
  COMPLETED: "completed",
  CANCELLED: "cancelled",
};

// Validation limits
const VALIDATION_LIMITS = {
  PASSWORD_MIN_LENGTH: 6,
  PASSWORD_MAX_LENGTH: 255,
  NAME_MIN_LENGTH: 2,
  NAME_MAX_LENGTH: 255,
  TITLE_MIN_LENGTH: 3,
  TITLE_MAX_LENGTH: 255,
  DESCRIPTION_MIN_LENGTH: 10,
  DESCRIPTION_MAX_LENGTH: 5000,
  LOCATION_MIN_LENGTH: 2,
  LOCATION_MAX_LENGTH: 255,
  MESSAGE_MAX_LENGTH: 500,
  PHONE_MAX_LENGTH: 20,
  IMAGE_URL_MAX_LENGTH: 500,
  AVATAR_URL_MAX_LENGTH: 500,
};

// Pagination defaults
const PAGINATION = {
  DEFAULT_LIMIT: 20,
  MAX_LIMIT: 100,
  DEFAULT_PAGE: 1,
};

// JWT settings
const JWT_SETTINGS = {
  EXPIRES_IN: "7d",
  ALGORITHM: "HS256",
};

// Rate limiting
const RATE_LIMITS = {
  WINDOW_MS: 15 * 60 * 1000, // 15 minutes
  MAX_REQUESTS: 100,
  LOGIN_WINDOW_MS: 15 * 60 * 1000, // 15 minutes
  LOGIN_MAX_ATTEMPTS: 5,
};

// Database settings
const DATABASE = {
  SYNC_OPTIONS: {
    alter: false, // Never use alter in production
    force: false, // Never use force in production
  },
};

// HTTP status codes
const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  INTERNAL_SERVER_ERROR: 500,
};

// Error messages
const ERROR_MESSAGES = {
  VALIDATION_FAILED: "Validation failed",
  USER_NOT_FOUND: "User not found",
  DONATION_NOT_FOUND: "Donation not found",
  REQUEST_NOT_FOUND: "Request not found",
  MESSAGE_NOT_FOUND: "Message not found",
  INVALID_CREDENTIALS: "Invalid email or password",
  ACCESS_DENIED: "Access denied",
  ADMIN_REQUIRED: "Admin access required",
  TOKEN_REQUIRED: "Access token required",
  INVALID_TOKEN: "Invalid or expired token",
  USER_EXISTS: "User with this email already exists",
  DONATION_UNAVAILABLE: "This donation is no longer available",
  OWN_DONATION_REQUEST: "You cannot request your own donation",
  DUPLICATE_REQUEST: "You have already requested this donation",
  OWN_RESOURCE_ONLY: "You can only access your own resources",
  INVALID_STATUS_TRANSITION: "Cannot update a completed or cancelled request",
};

// Success messages
const SUCCESS_MESSAGES = {
  USER_REGISTERED: "User registered successfully",
  LOGIN_SUCCESS: "Login successful",
  LOGOUT_SUCCESS: "Logged out successfully",
  DONATION_CREATED: "Donation created successfully",
  DONATION_UPDATED: "Donation updated successfully",
  DONATION_DELETED: "Donation deleted successfully",
  REQUEST_SENT: "Request sent successfully",
  REQUEST_UPDATED: "Request status updated successfully",
  REQUEST_DELETED: "Request deleted successfully",
  MESSAGE_SENT: "Message sent successfully",
  PROFILE_UPDATED: "Profile updated successfully",
};

// API endpoints
const API_ENDPOINTS = {
  AUTH: {
    LOGIN: "/auth/login",
    REGISTER: "/auth/register",
    LOGOUT: "/auth/logout",
    PROFILE: "/auth/me",
  },
  USERS: "/users",
  DONATIONS: "/donations",
  REQUESTS: "/requests",
  MESSAGES: "/messages",
};

// Frontend constants for Flutter
const FRONTEND_CONSTANTS = {
  SIDEBAR_WIDTH: 280,
  IMAGE_HEIGHT: 200,
  AVATAR_RADIUS: 20,
  ICON_SIZE: 24,
  SPACING: {
    XS: 4,
    S: 8,
    M: 16,
    L: 24,
    XL: 32,
  },
  BORDER_RADIUS: {
    S: 4,
    M: 8,
    L: 12,
    XL: 16,
  },
};

module.exports = {
  USER_ROLES,
  DONATION_CATEGORIES,
  DONATION_CONDITIONS,
  DONATION_STATUSES,
  REQUEST_STATUSES,
  VALIDATION_LIMITS,
  PAGINATION,
  JWT_SETTINGS,
  RATE_LIMITS,
  DATABASE,
  HTTP_STATUS,
  ERROR_MESSAGES,
  SUCCESS_MESSAGES,
  API_ENDPOINTS,
  FRONTEND_CONSTANTS,
};
