const jwt = require('jsonwebtoken');
const RegionalHealthOfficer = require('../models/RegionalHealthOfficer');
const { AreaAssignmentService } = require('../services/areaAssignmentService');

// RHO Authentication middleware
const rhoAuth = async (req, res, next) => {
  try {
    console.log('🔍 Authenticating RHO...');
    
    // Get token from header
    const authHeader = req.header('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No valid token provided'
      });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if it's an RHO token
    if (decoded.userType !== 'RHO') {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Invalid user type'
      });
    }

    // Get RHO data
    const rho = await RegionalHealthOfficer.findById(decoded.userId)
      .select('-password')
      .populate('parentSHO', 'fullName officerId assignedState');

    if (!rho) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. RHO not found'
      });
    }

    // Check if RHO is active
    if (!rho.isActive) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Account is inactive'
      });
    }

    // Attach RHO data to request
    req.rho = {
      rhoId: rho._id,
      officerId: rho.officerId,
      fullName: rho.fullName,
      email: rho.email,
      assignedState: rho.assignedState,
      assignedDistrict: rho.assignedDistrict,
      assignedAreas: rho.assignedAreas || [],
      permissions: rho.permissions,
      parentSHO: rho.parentSHO
    };

    console.log('✅ RHO authenticated:', rho.fullName);
    next();

  } catch (error) {
    console.error('RHO Authentication Error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Token expired'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

// Area-based access control middleware
const areaAccessControl = (requiredPermission = null) => {
  return async (req, res, next) => {
    try {
      if (!req.rho) {
        return res.status(401).json({
          success: false,
          message: 'RHO authentication required'
        });
      }

      // Check if RHO has the required permission
      if (requiredPermission && !req.rho.permissions[requiredPermission]) {
        return res.status(403).json({
          success: false,
          message: `Access denied. Missing permission: ${requiredPermission}`
        });
      }

      // Add area filtering helper to request
      req.getAreaFilter = (baseFilter = {}) => {
        const rho = req.rho;
        
        // Always filter by RHO's assigned district
        const areaFilter = {
          ...baseFilter,
          assignedDistrict: rho.assignedDistrict,
          assignedState: rho.assignedState
        };

        // If RHO has specific area assignments, add area-based filtering
        if (rho.assignedAreas && rho.assignedAreas.length > 0) {
          const isDenseDistrict = AreaAssignmentService.isDenseDistrict(rho.assignedState, rho.assignedDistrict);
          
          if (isDenseDistrict) {
            // For dense districts, filter by assigned areas
            const assignedAreaNames = rho.assignedAreas.map(area => area.name);
            
            // Add area-based filtering for relevant fields
            areaFilter.$or = [
              // Data that belongs to specific areas
              { 'coverage.subDistricts': { $in: assignedAreaNames } },
              { 'location.area': { $in: assignedAreaNames } },
              { 'area': { $in: assignedAreaNames } },
              // Data created by this RHO
              { createdBy: rho.rhoId },
              // Data assigned to this RHO
              { assignedRHO: rho.rhoId }
            ];
          }
        }

        return areaFilter;
      };

      // Add area validation helper
      req.validateAreaAccess = (targetArea) => {
        const rho = req.rho;
        
        // If no specific areas assigned, RHO has access to entire district
        if (!rho.assignedAreas || rho.assignedAreas.length === 0) {
          return true;
        }

        // Check if target area is in RHO's assigned areas
        return rho.assignedAreas.some(area => area.name === targetArea);
      };

      console.log(`✅ Area access control applied for RHO: ${req.rho.fullName}`);
      next();

    } catch (error) {
      console.error('Area Access Control Error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error in area access control'
      });
    }
  };
};

// Middleware to check if RHO can access specific district data
const districtAccessControl = async (req, res, next) => {
  try {
    if (!req.rho) {
      return res.status(401).json({
        success: false,
        message: 'RHO authentication required'
      });
    }

    const { district } = req.params;
    
    // Check if the requested district matches RHO's assigned district
    if (district && district !== req.rho.assignedDistrict) {
      return res.status(403).json({
        success: false,
        message: `Access denied. You can only access data for your assigned district: ${req.rho.assignedDistrict}`
      });
    }

    next();

  } catch (error) {
    console.error('District Access Control Error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error in district access control'
    });
  }
};

// Middleware to check if RHO can access specific area data
const specificAreaAccessControl = async (req, res, next) => {
  try {
    if (!req.rho) {
      return res.status(401).json({
        success: false,
        message: 'RHO authentication required'
      });
    }

    const { areaName } = req.params;
    
    // If area is specified in params, validate access
    if (areaName && !req.validateAreaAccess(areaName)) {
      const assignedAreaNames = req.rho.assignedAreas.map(area => area.name);
      return res.status(403).json({
        success: false,
        message: `Access denied. You can only access data for your assigned areas: ${assignedAreaNames.join(', ')}`
      });
    }

    next();

  } catch (error) {
    console.error('Specific Area Access Control Error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error in area access control'
    });
  }
};

// Audit logging for RHO operations
const auditRHOAccess = (operation) => {
  return (req, res, next) => {
    try {
      const auditData = {
        operation,
        rhoId: req.rho?.rhoId,
        rhoName: req.rho?.fullName,
        rhoDistrict: req.rho?.assignedDistrict,
        rhoAreas: req.rho?.assignedAreas?.map(area => area.name),
        timestamp: new Date(),
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        requestData: {
          params: req.params,
          query: req.query,
          body: operation.includes('CREATE') || operation.includes('UPDATE') 
            ? { ...req.body, password: '[REDACTED]' } 
            : req.body
        }
      };

      console.log(`📋 RHO Access Audit [${operation}]:`, JSON.stringify(auditData, null, 2));
      
      // Store original res.json to capture response
      const originalJson = res.json;
      res.json = function(data) {
        auditData.response = {
          statusCode: res.statusCode,
          success: data?.success,
          message: data?.message
        };
        
        console.log(`📋 RHO Access Audit Complete [${operation}]:`, {
          operation,
          rho: req.rho?.fullName,
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
const rhoFullAuth = [
  rhoAuth,
  areaAccessControl()
];

const rhoDistrictAuth = [
  rhoAuth,
  areaAccessControl(),
  districtAccessControl
];

const rhoAreaAuth = [
  rhoAuth,
  areaAccessControl(),
  districtAccessControl,
  specificAreaAccessControl
];

// Permission-based middleware
const rhoPermissionAuth = (permission) => [
  rhoAuth,
  areaAccessControl(permission)
];

module.exports = {
  rhoAuth,
  areaAccessControl,
  districtAccessControl,
  specificAreaAccessControl,
  auditRHOAccess,
  rhoFullAuth,
  rhoDistrictAuth,
  rhoAreaAuth,
  rhoPermissionAuth
};