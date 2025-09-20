const express = require('express');
const router = express.Router();
const shoAuthController = require('../controllers/shoAuthController');
const { shoAuth } = require('../middleware/shoAuth');
const { body } = require('express-validator');

// Validation rules
const loginValidation = [
  body('username')
    .optional()
    .isLength({ min: 3 })
    .withMessage('Username must be at least 3 characters long'),
  body('email')
    .optional()
    .isEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long')
];

const updateProfileValidation = [
  body('fullName')
    .optional()
    .isLength({ min: 2 })
    .withMessage('Full name must be at least 2 characters long'),
  body('email')
    .optional()
    .isEmail()
    .withMessage('Please provide a valid email'),
  body('phone')
    .optional()
    .isMobilePhone()
    .withMessage('Please provide a valid phone number')
];

const changePasswordValidation = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  body('newPassword')
    .isLength({ min: 6 })
    .withMessage('New password must be at least 6 characters long')
];

// Public routes (no authentication required)
router.post('/login', loginValidation, shoAuthController.login);

// Protected routes (authentication required)
router.use(shoAuth); // Apply authentication middleware to all routes below

// Authentication and profile routes
router.post('/logout', shoAuthController.logout);
router.get('/verify-token', shoAuthController.verifyToken);
router.get('/profile', shoAuthController.getProfile);
router.put('/profile', updateProfileValidation, shoAuthController.updateProfile);
router.put('/change-password', changePasswordValidation, shoAuthController.changePassword);

// Dashboard routes
router.get('/dashboard', shoAuthController.getDashboardData);

module.exports = router;