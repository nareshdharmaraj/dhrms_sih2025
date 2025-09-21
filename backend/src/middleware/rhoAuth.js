const { shoAuth } = require('./shoAuth');
const StateHealthOfficer = require('../models/StateHealthOfficer');

// Middleware to check if SHO has permission to manage RHOs
const checkRHOManagementPermission = async (req, res, next) => {
  try {
    console.log('🔍 Checking RHO management permissions for SHO:', req.sho?.fullName);
    
    if (!req.sho) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required for RHO management'
      });
    }

    // Get full SHO data to check permissions
    const shoData = await StateHealthOfficer.findById(req.sho.shoId);
    if (!shoData) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    // Check if SHO has permission to manage Regional Officers
    if (!shoData.permissions?.canManageRegionalOfficers) {
      console.log('❌ SHO does not have permission to manage Regional Officers');
      return res.status(403).json({
        success: false,
        message: 'Access denied. Insufficient permissions to manage Regional Health Officers'
      });
    }

    console.log('✅ RHO management permission verified for SHO');
    next();

  } catch (error) {
    console.error('RHO Permission Check Error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error checking permissions'
    });
  }
};

// Middleware to check if SHO can view RHOs
const checkRHOViewPermission = async (req, res, next) => {
  try {
    if (!req.sho) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    // Get full SHO data to check permissions
    const shoData = await StateHealthOfficer.findById(req.sho.shoId);
    if (!shoData) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    // Check if SHO has permission to view Regional Officers
    if (!shoData.permissions?.canViewRegionalOfficers) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Insufficient permissions to view Regional Health Officers'
      });
    }

    next();

  } catch (error) {
    console.error('RHO View Permission Check Error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error checking permissions'
    });
  }
};

// Audit logging for RHO operations
const auditRHOOperation = (operation) => {
  return (req, res, next) => {
    try {
      const auditData = {
        operation,
        shoId: req.sho?.shoId,
        shoName: req.sho?.fullName,
        timestamp: new Date(),
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        requestData: {
          params: req.params,
          query: req.query,
          // Don't log sensitive data like passwords
          body: operation.includes('CREATE') || operation.includes('UPDATE') 
            ? { ...req.body, password: '[REDACTED]' } 
            : req.body
        }
      };

      console.log(`📋 RHO Audit Log [${operation}]:`, JSON.stringify(auditData, null, 2));
      
      // Store original res.json to capture response
      const originalJson = res.json;
      res.json = function(data) {
        auditData.response = {
          statusCode: res.statusCode,
          success: data?.success,
          message: data?.message
        };
        
        console.log(`📋 RHO Audit Complete [${operation}]:`, {
          operation,
          status: res.statusCode,
          success: data?.success
        });
        
        // Call original json method
        originalJson.call(this, data);
      };

      next();

    } catch (error) {
      console.error('RHO Audit Logging Error:', error);
      next(); // Continue even if audit logging fails
    }
  };
};

// Combined middleware that includes authentication and permission checks
const rhoManagementAuth = [
  shoAuth,
  checkRHOManagementPermission
];

const rhoViewAuth = [
  shoAuth,
  checkRHOViewPermission
];

module.exports = {
  checkRHOManagementPermission,
  checkRHOViewPermission,
  auditRHOOperation,
  rhoManagementAuth,
  rhoViewAuth
};