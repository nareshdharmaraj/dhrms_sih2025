const jwt = require('jsonwebtoken');

/**
 * Authenticate token middleware
 */
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token is required'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret', (err, user) => {
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

/**
 * Authorize role middleware
 */
const authorizeRole = (roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: 'Insufficient permissions'
      });
    }

    next();
  };
};

/**
 * Generate JWT token
 */
const generateToken = (payload, expiresIn = '24h') => {
  return jwt.sign(payload, process.env.JWT_SECRET || 'fallback_secret', { expiresIn });
};

/**
 * Verify JWT token
 */
const verifyToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');
  } catch (error) {
    return null;
  }
};

module.exports = {
  authenticateToken,
  authorizeRole,
  generateToken,
  verifyToken
};