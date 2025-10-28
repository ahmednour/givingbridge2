const { sendErrorResponse } = require("../utils/errorHandler");
const { HTTP_STATUS } = require("../constants");

/**
 * API Versioning Middleware
 * Handles API version routing and compatibility
 */

const SUPPORTED_VERSIONS = ['v1'];
const DEFAULT_VERSION = 'v1';
const CURRENT_VERSION = 'v1';

/**
 * Extract API version from request
 * Supports version in:
 * 1. URL path: /api/v1/users
 * 2. Accept header: Accept: application/vnd.givingbridge.v1+json
 * 3. Custom header: X-API-Version: v1
 * 4. Query parameter: ?version=v1
 */
function extractVersion(req) {
  // 1. Check URL path
  const pathMatch = req.path.match(/^\/api\/v(\d+)\//);
  if (pathMatch) {
    return `v${pathMatch[1]}`;
  }

  // 2. Check Accept header
  const acceptHeader = req.get('Accept');
  if (acceptHeader) {
    const acceptMatch = acceptHeader.match(/application\/vnd\.givingbridge\.v(\d+)\+json/);
    if (acceptMatch) {
      return `v${acceptMatch[1]}`;
    }
  }

  // 3. Check custom header
  const versionHeader = req.get('X-API-Version');
  if (versionHeader) {
    return versionHeader.toLowerCase();
  }

  // 4. Check query parameter
  if (req.query.version) {
    return req.query.version.toLowerCase();
  }

  return DEFAULT_VERSION;
}

/**
 * Validate API version
 */
function validateVersion(version) {
  return SUPPORTED_VERSIONS.includes(version);
}

/**
 * API Version middleware
 */
function apiVersioning(req, res, next) {
  const requestedVersion = extractVersion(req);
  
  // Validate version
  if (!validateVersion(requestedVersion)) {
    return sendErrorResponse(
      res,
      `Unsupported API version: ${requestedVersion}. Supported versions: ${SUPPORTED_VERSIONS.join(', ')}`,
      HTTP_STATUS.BAD_REQUEST,
      {
        code: 'UNSUPPORTED_API_VERSION',
        supportedVersions: SUPPORTED_VERSIONS,
        requestedVersion
      }
    );
  }

  // Add version info to request
  req.apiVersion = requestedVersion;
  req.isLatestVersion = requestedVersion === CURRENT_VERSION;

  // Add version headers to response
  res.set({
    'X-API-Version': requestedVersion,
    'X-API-Current-Version': CURRENT_VERSION,
    'X-API-Supported-Versions': SUPPORTED_VERSIONS.join(', ')
  });

  // Add deprecation warning for older versions
  if (requestedVersion !== CURRENT_VERSION) {
    res.set('X-API-Deprecation-Warning', `API version ${requestedVersion} is deprecated. Please upgrade to ${CURRENT_VERSION}`);
  }

  next();
}

/**
 * Version-specific route wrapper
 * Usage: versionedRoute('v1', handler)
 */
function versionedRoute(version, handler) {
  return (req, res, next) => {
    if (req.apiVersion === version) {
      return handler(req, res, next);
    }
    next(); // Continue to next route handler
  };
}

/**
 * Backward compatibility middleware
 * Handles breaking changes between versions
 */
function backwardCompatibility(req, res, next) {
  // Transform request/response based on version
  switch (req.apiVersion) {
    case 'v1':
      // Current version - no transformation needed
      break;
    default:
      // Future versions can be handled here
      break;
  }

  // Override res.json to transform response format
  const originalJson = res.json;
  res.json = function(data) {
    const transformedData = transformResponseForVersion(data, req.apiVersion);
    return originalJson.call(this, transformedData);
  };

  next();
}

/**
 * Transform response data based on API version
 */
function transformResponseForVersion(data, version) {
  switch (version) {
    case 'v1':
      return data; // Current format
    default:
      return data;
  }
}

/**
 * Get version info endpoint
 */
function getVersionInfo(req, res) {
  res.json({
    currentVersion: CURRENT_VERSION,
    supportedVersions: SUPPORTED_VERSIONS,
    requestedVersion: req.apiVersion,
    isLatestVersion: req.isLatestVersion,
    deprecationWarning: req.apiVersion !== CURRENT_VERSION ? 
      `Version ${req.apiVersion} is deprecated. Please upgrade to ${CURRENT_VERSION}` : null
  });
}

module.exports = {
  apiVersioning,
  versionedRoute,
  backwardCompatibility,
  getVersionInfo,
  SUPPORTED_VERSIONS,
  CURRENT_VERSION,
  DEFAULT_VERSION
};