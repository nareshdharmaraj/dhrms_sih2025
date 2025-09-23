const express = require('express');
const router = express.Router();

// Authentication controller functions
const {
  registerUser,
  loginUser,
  logout,
  refreshToken,
  forgotPassword,
  resetPassword,
  verifyEmail,
  registerPatient,
  registerHospitalStaff,
  // registerRegionalOfficer - Disabled: RHOs created by SHOs only
} = require('../controllers/auth_controller');

// Middleware
const { validateRegister, validateLogin, validatePatientRegister, validateHospitalStaffRegister } = require('../middleware/validation');
const { rateLimiter } = require('../middleware/rate_limiter');

// @route   POST /api/auth/register
// @desc    Register a new user (generic)
// @access  Public
router.post('/register', rateLimiter, validateRegister, registerUser);

// @route   POST /api/auth/register/patient
// @desc    Register a new patient with UHI generation
// @access  Public
router.post('/register/patient', rateLimiter, validatePatientRegister, registerPatient);

// @route   POST /api/auth/register/hospital-staff
// @desc    Register a new hospital staff member with UHI generation
// @access  Public
router.post('/register/hospital-staff', rateLimiter, validateHospitalStaffRegister, registerHospitalStaff);

// NOTE: Regional Officers are created by SHOs, not through self-registration
// @route   POST /api/auth/register/regional-officer
// @desc    Register a new regional officer with UHI generation
// @access  DISABLED - RHOs are created by SHOs only
// router.post('/register/regional-officer', rateLimiter, validateRegionalOfficerRegister, registerRegionalOfficer);

// @route   POST /api/auth/login
// @desc    Login user
// @access  Public
router.post('/login', rateLimiter, validateLogin, loginUser);

// @route   POST /api/auth/logout
// @desc    Logout user
// @access  Private
router.post('/logout', logout);

// @route   POST /api/auth/refresh
// @desc    Refresh access token
// @access  Public
router.post('/refresh', refreshToken);

// @route   POST /api/auth/forgot-password
// @desc    Send password reset email
// @access  Public
router.post('/forgot-password', rateLimiter, forgotPassword);

// @route   POST /api/auth/reset-password
// @desc    Reset password with token
// @access  Public
router.post('/reset-password', resetPassword);

// @route   GET /api/auth/verify-email/:token
// @desc    Verify email address
// @access  Public
router.get('/verify-email/:token', verifyEmail);

module.exports = router;
