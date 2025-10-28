/**
 * Disaster Recovery API Routes
 * Provides endpoints for disaster recovery monitoring and management
 */

const express = require('express');
const router = express.Router();
const disasterRecoveryService = require('../services/disasterRecoveryService');
// Simple authentication middleware for disaster recovery
const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token required'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        success: false,
        message: 'Invalid or expired token'
      });
    }
    req.user = user;
    next();
  });
};
const { requireAdmin, asyncHandler } = require('../middleware');
const logger = require('../utils/logger');

/**
 * @route GET /api/disaster-recovery/status
 * @desc Get disaster recovery status and readiness
 * @access Admin only
 */
router.get('/status', authenticateToken, requireAdmin, asyncHandler(async (req, res) => {
  const status = await disasterRecoveryService.getRecoveryStatus();
  
  res.json({
    success: true,
    data: status
  });
}));

/**
 * @route GET /api/disaster-recovery/health
 * @desc Check system health for disaster recovery
 * @access Admin only
 */
router.get('/health', authenticateToken, requireAdmin, asyncHandler(async (req, res) => {
  const health = await disasterRecoveryService.checkSystemHealth();
  
  res.json({
    success: true,
    data: health
  });
}));

/**
 * @route GET /api/disaster-recovery/readiness
 * @desc Monitor disaster recovery readiness
 * @access Admin only
 */
router.get('/readiness', authenticateToken, requireAdmin, asyncHandler(async (req, res) => {
  const readiness = await disasterRecoveryService.monitorRecoveryReadiness();
  
  res.json({
    success: true,
    data: readiness
  });
}));

/**
 * @route POST /api/disaster-recovery/test
 * @desc Test disaster recovery procedures
 * @access Admin only
 */
router.post('/test', authenticateToken, requireAdmin, asyncHandler(async (req, res) => {
  logger.info(`Recovery test initiated by user ${req.user.id}`);
  
  const testResult = await disasterRecoveryService.testRecoveryProcedures();
  
  res.json({
    success: true,
    data: testResult,
    message: testResult.success ? 'Recovery test completed successfully' : 'Recovery test failed'
  });
}));

/**
 * @route POST /api/disaster-recovery/recover
 * @desc Perform actual disaster recovery (DESTRUCTIVE)
 * @access Admin only with explicit confirmation
 */
router.post('/recover', authenticateToken, requireAdmin, asyncHandler(async (req, res) => {
  const { confirmation } = req.body;
  
  if (confirmation !== 'I_UNDERSTAND_THIS_IS_DESTRUCTIVE') {
    return res.status(400).json({
      success: false,
      message: 'Explicit confirmation required for disaster recovery',
      requiredConfirmation: 'I_UNDERSTAND_THIS_IS_DESTRUCTIVE'
    });
  }
  
  logger.critical(`DISASTER RECOVERY initiated by user ${req.user.id}`);
  
  const recoveryResult = await disasterRecoveryService.performDisasterRecovery(true);
  
  res.json({
    success: true,
    data: recoveryResult,
    message: recoveryResult.success ? 'Disaster recovery completed' : 'Disaster recovery failed'
  });
}));

/**
 * @route GET /api/disaster-recovery/metrics
 * @desc Get recovery time metrics and objectives
 * @access Admin only
 */
router.get('/metrics', authenticateToken, requireAdmin, asyncHandler(async (req, res) => {
  const metrics = disasterRecoveryService.getRecoveryTimeMetrics();
  
  res.json({
    success: true,
    data: metrics
  });
}));

module.exports = router;