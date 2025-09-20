const express = require('express');
const { body } = require('express-validator');
const router = express.Router();

// Import controllers and middleware
const {
  login,
  logout,
  logoutAll,
  getProfile,
  updateProfile,
  changePassword
} = require('../controllers/whoAuthController');

const {
  getDashboardStats,
  getAllStatesStatistics,
  getRegionalOfficers,
  addRegionalOfficer,
  updateRegionalOfficer,
  deactivateRegionalOfficer,
  getAllHospitals,
  exportData
} = require('../controllers/whoController');

const {
  verifyWhoToken,
  checkWhoPermission,
  checkStateAccess,
  whoRateLimit,
  validateSession,
  auditLog
} = require('../middleware/whoAuth');

// Authentication routes (no token required)
// WHO Admin Login
router.post('/login', [
  // Debug middleware to log request
  (req, res, next) => {
    console.log('🔍 WHO Login Route - Request Body:', req.body);
    console.log('🔍 WHO Login Route - Content-Type:', req.headers['content-type']);
    next();
  },
  body('adminId')
    .trim()
    .isLength({ min: 3 })
    .withMessage('Admin ID must be at least 3 characters'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters')
], auditLog('WHO_LOGIN'), login);

// Protected routes (require valid WHO token)
router.use(verifyWhoToken);
router.use(validateSession);
router.use(whoRateLimit(100, 15 * 60 * 1000)); // 100 requests per 15 minutes

// Authentication management
router.post('/logout', auditLog('WHO_LOGOUT'), logout);
router.post('/logout-all', auditLog('WHO_LOGOUT_ALL'), logoutAll);

// Profile management
router.get('/profile', auditLog('WHO_GET_PROFILE'), getProfile);
router.put('/profile', [
  body('email')
    .optional()
    .isEmail()
    .withMessage('Invalid email format'),
  body('fullName')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Full name must be at least 2 characters'),
  body('phoneNumber')
    .optional()
    .matches(/^[+]?[1-9][\d]{10,14}$/)
    .withMessage('Invalid phone number format')
], auditLog('WHO_UPDATE_PROFILE'), updateProfile);

router.put('/change-password', [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('New password must be at least 8 characters')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('New password must contain at least one uppercase letter, one lowercase letter, one number, and one special character')
], auditLog('WHO_CHANGE_PASSWORD'), changePassword);

// Dashboard and Statistics
router.get('/dashboard/stats', 
  checkWhoPermission('view_dashboard'),
  auditLog('WHO_VIEW_DASHBOARD'),
  getDashboardStats
);

router.get('/states/statistics', 
  checkWhoPermission('view_state_stats'),
  auditLog('WHO_VIEW_STATE_STATS'),
  getAllStatesStatistics
);

// Regional Officers Management
router.get('/regional-officers', 
  checkWhoPermission('view_officers'),
  auditLog('WHO_VIEW_OFFICERS'),
  getRegionalOfficers
);

router.post('/regional-officers', [
  checkWhoPermission('manage_officers'),
  body('officerId')
    .trim()
    .isLength({ min: 5 })
    .withMessage('Officer ID must be at least 5 characters'),
  body('fullName')
    .trim()
    .isLength({ min: 2 })
    .withMessage('Full name must be at least 2 characters'),
  body('email')
    .isEmail()
    .withMessage('Invalid email format'),
  body('phoneNumber')
    .matches(/^[+]?[1-9][\d]{10,14}$/)
    .withMessage('Invalid phone number format'),
  body('state')
    .notEmpty()
    .withMessage('State is required'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
], auditLog('WHO_ADD_OFFICER'), addRegionalOfficer);

router.put('/regional-officers/:officerId', [
  checkWhoPermission('manage_officers'),
  body('email')
    .optional()
    .isEmail()
    .withMessage('Invalid email format'),
  body('fullName')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Full name must be at least 2 characters'),
  body('phoneNumber')
    .optional()
    .matches(/^[+]?[1-9][\d]{10,14}$/)
    .withMessage('Invalid phone number format')
], auditLog('WHO_UPDATE_OFFICER'), updateRegionalOfficer);

router.delete('/regional-officers/:officerId', 
  checkWhoPermission('manage_officers'),
  auditLog('WHO_DEACTIVATE_OFFICER'),
  deactivateRegionalOfficer
);

// Hospital Management (View-only for WHO admins)
router.get('/hospitals', 
  checkWhoPermission('view_hospitals'),
  auditLog('WHO_VIEW_HOSPITALS'),
  getAllHospitals
);

// State-specific hospital access
router.get('/states/:state/hospitals', [
  checkWhoPermission('view_hospitals'),
  checkStateAccess
], auditLog('WHO_VIEW_STATE_HOSPITALS'), getAllHospitals);

// Data Export
router.get('/export', [
  checkWhoPermission('export_data'),
  auditLog('WHO_EXPORT_DATA')
], exportData);

// Health check for WHO system
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'WHO Admin system is healthy',
    timestamp: new Date(),
    admin: {
      id: req.admin.adminId,
      username: req.admin.username,
      role: req.admin.role
    }
  });
});

// Error handling middleware for WHO routes
router.use((error, req, res, next) => {
  console.error('WHO Routes Error:', error);
  
  res.status(error.statusCode || 500).json({
    success: false,
    message: error.message || 'WHO system error',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
});

module.exports = router;