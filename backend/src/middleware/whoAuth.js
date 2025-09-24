const jwt = require('jsonwebtoken');
const WhoAdmin = require('../models/WhoAdmin');

// Verify WHO admin JWT token
const verifyWhoToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json({
        success: false,
        message: 'Access token required'
      });
    }

    const token = authHeader.split(' ')[1]; // Bearer <token>
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token format'
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Check if admin exists and is active
    const admin = await WhoAdmin.findById(decoded.adminId);
    
    console.log('🔍 WHO Admin found:', {
      adminId: admin?.adminId,
      permissions: admin?.permissions,
      isActive: admin?.isActive
    });
    
    if (!admin) {
      return res.status(401).json({
        success: false,
        message: 'Admin not found'
      });
    }

    if (!admin.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Account deactivated'
      });
    }

    // Check account lock status (simplified for WHO admin)
    if (admin.lockUntil && admin.lockUntil > new Date()) {
      return res.status(423).json({
        success: false,
        message: 'Account temporarily locked due to failed login attempts'
      });
    }

    // For WHO admins, we don't use session tracking - JWT is sufficient
    // The token was already verified by jwt.verify() above
    
    // Update last activity (optional, can be removed for better performance)
    // admin.lastLogin = new Date();
    // await admin.save();

    // Add admin info to request
    req.admin = {
      adminId: admin._id,
      username: admin.username,
      email: admin.email,
      role: admin.role,
      permissions: admin.permissions,
      managedStates: admin.managedStates
    };

    next();

  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    console.error('Token verification error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

// Check WHO admin permissions
const checkWhoPermission = (requiredPermission) => {
  return (req, res, next) => {
    const adminPermissions = req.admin?.permissions || {};
    
    console.log('🔍 Checking WHO permission:', requiredPermission);
    console.log('🔍 Admin permissions:', adminPermissions);
    console.log('🔍 Admin role:', req.admin?.role);
    
    // Super admin has all permissions
    if (req.admin?.role === 'super_admin') {
      console.log('🔍 Super admin access granted');
      return next();
    }
    
    // Map route permissions to actual permission keys
    const permissionMap = {
      'view_dashboard': 'canAccessAnalytics',
      'view_state_stats': 'canAccessAnalytics', 
      'view_analytics': 'canAccessAnalytics', // NEW: Comprehensive analytics access
      'view_officers': 'canManageRegionalOfficers',
      'manage_officers': 'canManageRegionalOfficers',
      'manage_state_officers': 'canManageStateOfficers', // NEW: SHO management
      'export_data': 'canExportData',
      'generate_reports': 'canGenerateReports'
    };
    
    const actualPermission = permissionMap[requiredPermission] || requiredPermission;
    console.log('🔍 Mapped permission:', actualPermission);
    console.log('🔍 Has permission value:', adminPermissions[actualPermission]);
    console.log('🔍 Permission check result:', adminPermissions[actualPermission] === true);
    
    // Check if admin has the permission (object format)
    if (adminPermissions[actualPermission] === true) {
      console.log('🔍 Permission granted');
      return next();
    }
    
    console.log('🔍 Permission denied');
    return res.status(403).json({
      success: false,
      message: `Insufficient permissions. Required: ${actualPermission}`
    });
  };
};

// Check if admin manages specific state
const checkStateAccess = (req, res, next) => {
  const { state } = req.params;
  const adminStates = req.admin?.managedStates || [];
  
  // Super admin has access to all states
  if (req.admin?.role === 'super_admin') {
    return next();
  }
  
  // Check if admin manages this state
  if (state && !adminStates.includes(state)) {
    return res.status(403).json({
      success: false,
      message: 'Access denied for this state'
    });
  }
  
  next();
};

// Rate limiting middleware for WHO operations
const whoRateLimit = (maxRequests = 100, windowMs = 15 * 60 * 1000) => {
  const requests = new Map();
  
  return (req, res, next) => {
    const adminId = req.admin?.adminId;
    
    if (!adminId) {
      return next();
    }
    
    const now = Date.now();
    const windowStart = now - windowMs;
    
    // Get admin's request history
    const adminRequests = requests.get(adminId) || [];
    
    // Filter requests within the time window
    const recentRequests = adminRequests.filter(timestamp => timestamp > windowStart);
    
    if (recentRequests.length >= maxRequests) {
      return res.status(429).json({
        success: false,
        message: 'Too many requests. Please try again later.',
        retryAfter: Math.ceil((recentRequests[0] + windowMs - now) / 1000)
      });
    }
    
    // Add current request
    recentRequests.push(now);
    requests.set(adminId, recentRequests);
    
    // Cleanup old entries periodically
    if (Math.random() < 0.01) { // 1% chance
      for (const [id, timestamps] of requests.entries()) {
        const filtered = timestamps.filter(timestamp => timestamp > windowStart);
        if (filtered.length === 0) {
          requests.delete(id);
        } else {
          requests.set(id, filtered);
        }
      }
    }
    
    next();
  };
};

// Validate admin session
const validateSession = async (req, res, next) => {
  try {
    const adminId = req.admin?.adminId;
    
    if (!adminId) {
      return res.status(401).json({
        success: false,
        message: 'Admin not authenticated'
      });
    }

    const admin = await WhoAdmin.findById(adminId);
    
    if (!admin) {
      return res.status(401).json({
        success: false,
        message: 'Admin not found'
      });
    }

    // Check for session timeout (24 hours)
    const sessionTimeout = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
    const lastActivity = new Date(admin.lastActivity);
    const now = new Date();

    if (now - lastActivity > sessionTimeout) {
      // Deactivate all sessions
      admin.sessions = admin.sessions.map(session => ({
        ...session,
        isActive: false
      }));
      await admin.save();

      return res.status(401).json({
        success: false,
        message: 'Session expired due to inactivity'
      });
    }

    next();

  } catch (error) {
    console.error('Session validation error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during session validation'
    });
  }
};

// Audit log middleware
const auditLog = (action) => {
  return async (req, res, next) => {
    const originalSend = res.send;
    let logged = false; // Prevent double logging
    
    const logAndSend = function(data) {
      // Only log once
      if (!logged) {
        logged = true;
        
        // Log the action
        const logData = {
          adminId: req.admin?.adminId,
          username: req.admin?.username,
          action,
          method: req.method,
          url: req.originalUrl,
          ip: req.ip,
          userAgent: req.get('User-Agent'),
          timestamp: new Date(),
          success: res.statusCode < 400
        };

        // You can save this to a separate audit log collection
        console.log('WHO Admin Audit Log:', logData);
      }
      
      return data;
    };
    
    res.send = function(data) {
      logAndSend(data);
      return originalSend.call(this, data);
    };
    
    next();
  };
};

module.exports = {
  verifyWhoToken,
  checkWhoPermission,
  checkStateAccess,
  whoRateLimit,
  validateSession,
  auditLog
};