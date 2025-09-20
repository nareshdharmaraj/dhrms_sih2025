const express = require('express');
const { body } = require('express-validator');
const router = express.Router();

// Import middleware
const { verifyWhoToken, checkWhoPermission, auditLog } = require('../middleware/whoAuth');

// Import SHO controller
const {
  getAllSHOs,
  getSHOById,
  createSHO,
  updateSHO,
  deactivateSHO,
  activateSHO,
  changeSHOPassword,
  getSHOStatistics,
  resetPassword
} = require('../controllers/shoController');

// All routes require WHO admin authentication
router.use(verifyWhoToken);

// Get all SHOs
router.get('/', 
  checkWhoPermission('manage_state_officers'),
  auditLog('WHO_VIEW_SHOS'),
  getAllSHOs
);

// Get SHO statistics
router.get('/statistics', 
  checkWhoPermission('manage_state_officers'),
  auditLog('WHO_VIEW_SHO_STATS'),
  getSHOStatistics
);

// Get SHO by ID
router.get('/:shoId', 
  checkWhoPermission('manage_state_officers'),
  auditLog('WHO_VIEW_SHO'),
  getSHOById
);

// Create new SHO
router.post('/', [
  checkWhoPermission('manage_state_officers'),
  body('officerId')
    .trim()
    .matches(/^SHO_[A-Z]{2}_\d{3}$/)
    .withMessage('Officer ID must follow format: SHO_XX_001'),
  body('fullName')
    .trim()
    .isLength({ min: 2 })
    .withMessage('Full name must be at least 2 characters'),
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('phone')
    .isLength({ min: 10, max: 15 })
    .withMessage('Please provide a valid phone number (10-15 digits)'),
  body('assignedState')
    .isIn([
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
      'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
      'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
      'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
      'West Bengal'
    ])
    .withMessage('Please provide a valid Indian state'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
], auditLog('WHO_CREATE_SHO'), createSHO);

// Update SHO
router.put('/:shoId', [
  checkWhoPermission('manage_state_officers'),
  body('fullName')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Full name must be at least 2 characters'),
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('phone')
    .optional()
    .isLength({ min: 10, max: 15 })
    .withMessage('Please provide a valid phone number (10-15 digits)'),
  body('assignedState')
    .optional()
    .isIn([
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
      'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
      'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
      'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
      'West Bengal'
    ])
    .withMessage('Please provide a valid Indian state')
], auditLog('WHO_UPDATE_SHO'), updateSHO);

// Change SHO password
router.patch('/:shoId/change-password', [
  checkWhoPermission('manage_state_officers'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
], auditLog('WHO_CHANGE_SHO_PASSWORD'), changeSHOPassword);

// Reset SHO password (generates new random password)
router.patch('/:shoId/reset-password', 
  checkWhoPermission('manage_state_officers'),
  auditLog('WHO_RESET_SHO_PASSWORD'),
  resetPassword
);

// Deactivate SHO
router.patch('/:shoId/deactivate', 
  checkWhoPermission('manage_state_officers'),
  auditLog('WHO_DEACTIVATE_SHO'),
  deactivateSHO
);

// Activate SHO
router.patch('/:shoId/activate', 
  checkWhoPermission('manage_state_officers'),
  auditLog('WHO_ACTIVATE_SHO'),
  activateSHO
);

module.exports = router;
