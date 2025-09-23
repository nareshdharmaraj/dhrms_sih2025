const jwt = require('jsonwebtoken');
const RegionalHealthOfficer = require('../models/RegionalHealthOfficer');

// RHO Authentication Middleware
const rhoAuth = async (req, res, next) => {
  try {
    console.log('🔍 RHO Auth Middleware - Starting authentication...');
    
    const authHeader = req.header('Authorization');
    console.log('🔍 Authorization Header:', authHeader ? 'Present' : 'Missing');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No valid token provided.'
      });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    console.log('🔍 Extracted Token:', token ? 'Present' : 'Missing');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.'
      });
    }

    try {
      console.log('🔍 Verifying JWT token...');
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
      console.log('🔍 Token decoded successfully:', { 
        rhoId: decoded.rhoId, 
        userType: decoded.userType,
        id: decoded.id 
      });

      // Verify this is an RHO token
      if (decoded.userType !== 'RHO') {
        console.log('❌ Invalid token type:', decoded.userType);
        return res.status(401).json({
          success: false,
          message: 'Access denied. Invalid token type.'
        });
      }

      // Get RHO data from database
      const rho = await RegionalHealthOfficer.findById(decoded.id);
      if (!rho) {
        console.log('❌ RHO not found for ID:', decoded.id);
        return res.status(401).json({
          success: false,
          message: 'Access denied. RHO not found.'
        });
      }

      // Check if RHO is active
      if (!rho.isActive) {
        console.log('❌ RHO account is deactivated:', rho.officerId);
        return res.status(401).json({
          success: false,
          message: 'Account is deactivated. Please contact your State Health Officer.'
        });
      }

      // Add RHO data to request object
      req.rho = {
        rhoId: rho._id,
        officerId: rho.officerId,
        fullName: rho.fullName,
        email: rho.email,
        assignedState: rho.assignedState,
        assignedDistrict: rho.assignedDistrict,
        assignedRegion: rho.assignedRegion,
        parentSHO: rho.parentSHO,
        permissions: rho.permissions
      };

      console.log('✅ RHO authentication successful:', rho.officerId);
      next();

    } catch (jwtError) {
      console.log('❌ JWT verification failed:', jwtError.message);
      return res.status(401).json({
        success: false,
        message: 'Access denied. Invalid token.'
      });
    }

  } catch (error) {
    console.error('RHO Auth Middleware Error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

// Middleware to check if RHO has specific permission
const checkRHOPermission = (permission) => {
  return (req, res, next) => {
    try {
      if (!req.rho) {
        return res.status(401).json({
          success: false,
          message: 'Authentication required'
        });
      }

      if (!req.rho.permissions || !req.rho.permissions[permission]) {
        console.log(`❌ RHO ${req.rho.officerId} lacks permission: ${permission}`);
        return res.status(403).json({
          success: false,
          message: `Access denied. Permission required: ${permission}`
        });
      }

      console.log(`✅ RHO ${req.rho.officerId} has permission: ${permission}`);
      next();

    } catch (error) {
      console.error('RHO Permission Check Error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error checking permissions'
      });
    }
  };
};

// Audit logging for RHO operations
const auditRHOSelfOperation = (operation) => {
  return (req, res, next) => {
    try {
      const auditData = {
        operation,
        rhoId: req.rho?.rhoId,
        officerId: req.rho?.officerId,
        rhoName: req.rho?.fullName,
        timestamp: new Date(),
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        requestData: {
          params: req.params,
          query: req.query,
          // Don't log sensitive data
          body: operation.includes('PASSWORD') 
            ? { ...req.body, password: '[REDACTED]', newPassword: '[REDACTED]' } 
            : req.body
        }
      };

      console.log(`📋 RHO Self-Service Audit [${operation}]:`, JSON.stringify(auditData, null, 2));
      
      // Store original res.json to capture response
      const originalJson = res.json;
      res.json = function(data) {
        auditData.response = {
          statusCode: res.statusCode,
          success: data?.success,
          message: data?.message
        };
        
        console.log(`📋 RHO Self-Service Audit Complete [${operation}]:`, {
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

// Combined middleware for different RHO access levels
const rhoProfileAccess = [
  rhoAuth,
  checkRHOPermission('canManageProfile')
];

const rhoViewAccess = [
  rhoAuth,
  checkRHOPermission('canViewRegionalStats')
];

const rhoReportAccess = [
  rhoAuth,
  checkRHOPermission('canGenerateReports')
];

const rhoHospitalAccess = [
  rhoAuth,
  checkRHOPermission('canViewHospitals')
];

module.exports = {
  rhoAuth,
  checkRHOPermission,
  auditRHOSelfOperation,
  rhoProfileAccess,
  rhoViewAccess,
  rhoReportAccess,
  rhoHospitalAccess
};