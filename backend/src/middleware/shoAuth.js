const jwt = require('jsonwebtoken');
const SHO = require('../models/StateHealthOfficer');

// Middleware to authenticate SHO tokens
const shoAuth = async (req, res, next) => {
  try {
    console.log('🔍 SHO Auth Middleware - Starting authentication...');
    
    const authHeader = req.header('Authorization');
    console.log('🔍 Authorization Header:', authHeader);
    
    if (!authHeader) {
      console.log('❌ No authorization header found');
      return res.status(401).json({
        success: false,
        message: 'Access denied. No authorization header provided.'
      });
    }

    if (!authHeader.startsWith('Bearer ')) {
      console.log('❌ Invalid authorization header format');
      return res.status(401).json({
        success: false,
        message: 'Access denied. Invalid authorization header format.'
      });
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    console.log('🔍 Extracted Token:', token ? 'Present' : 'Missing');

    if (!token) {
      console.log('❌ No token found after Bearer prefix');
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.'
      });
    }

    try {
      console.log('🔍 Verifying JWT token...');
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dhrms-sho-secret-key');
      console.log('🔍 Token decoded successfully:', { 
        shoId: decoded.shoId, 
        type: decoded.type 
      });

      if (decoded.type !== 'sho') {
        console.log('❌ Invalid token type:', decoded.type);
        return res.status(401).json({
          success: false,
          message: 'Access denied. Invalid token type.'
        });
      }

      // Find the SHO and verify they exist and are active
      console.log('🔍 Looking up SHO in database...');
      const sho = await SHO.findById(decoded.shoId);
      
      if (!sho) {
        console.log('❌ SHO not found in database');
        return res.status(401).json({
          success: false,
          message: 'Access denied. SHO not found.'
        });
      }

      if (!sho.isActive) {
        console.log('❌ SHO account is not active');
        return res.status(401).json({
          success: false,
          message: 'Access denied. Account is deactivated.'
        });
      }

      console.log('✅ SHO authentication successful:', {
        id: sho._id,
        username: sho.username,
        assignedState: sho.assignedState
      });

      // Add SHO info to request object
      req.sho = {
        shoId: sho._id,
        username: sho.username,
        email: sho.email,
        fullName: sho.fullName,
        assignedState: sho.assignedState,
        designation: sho.designation
      };

      next();

    } catch (jwtError) {
      console.log('❌ JWT verification failed:', jwtError.message);
      
      if (jwtError.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'Access denied. Token has expired.'
        });
      }
      
      if (jwtError.name === 'JsonWebTokenError') {
        return res.status(401).json({
          success: false,
          message: 'Access denied. Invalid token.'
        });
      }

      return res.status(401).json({
        success: false,
        message: 'Access denied. Token verification failed.'
      });
    }

  } catch (error) {
    console.error('SHO Auth Middleware Error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

// Optional middleware - doesn't fail if no token, but adds SHO info if present
const optionalShoAuth = async (req, res, next) => {
  try {
    const authHeader = req.header('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      // No token provided, continue without authentication
      return next();
    }

    const token = authHeader.substring(7);
    
    if (!token) {
      return next();
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dhrms-sho-secret-key');
      
      if (decoded.type === 'sho') {
        const sho = await SHO.findById(decoded.shoId);
        
        if (sho && sho.isActive) {
          req.sho = {
            shoId: sho._id,
            username: sho.username,
            email: sho.email,
            fullName: sho.fullName,
            assignedState: sho.assignedState,
            designation: sho.designation
          };
        }
      }
    } catch (jwtError) {
      // Token invalid, but continue without authentication
      console.log('Optional SHO auth - Invalid token, continuing without auth');
    }

    next();

  } catch (error) {
    console.error('Optional SHO Auth Middleware Error:', error);
    next(); // Continue even if there's an error
  }
};

module.exports = {
  shoAuth,
  optionalShoAuth
};