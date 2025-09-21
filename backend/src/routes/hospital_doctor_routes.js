const express = require('express');
const router = express.Router();

// Controllers
const {
  doctorLogin,
  getDoctorDashboard,
  getDoctorProfile,
  updateDoctorProfile,
  updateDutyStatus,
  getAssignedAssistants,
  updateSchedule,
  changePassword
} = require('../controllers/hospital_doctor_controller');

// Middleware
const { authenticateHospitalDoctor } = require('../middleware/hospitalAuth');
const { 
  validateStaffLogin,
  validatePasswordChange,
  validateDutyStatusUpdate,
  validateScheduleUpdate
} = require('../middleware/hospitalValidation');

// ==================== HOSPITAL DOCTOR ROUTES ====================

// @route   POST /api/hospital-doctor/login
// @desc    Doctor login
// @access  Public
router.post('/login', validateStaffLogin, doctorLogin);

// ==================== DOCTOR DASHBOARD ====================

// @route   GET /api/hospital-doctor/dashboard
// @desc    Get doctor dashboard data
// @access  Private (Doctor)
router.get('/dashboard', authenticateHospitalDoctor, getDoctorDashboard);

// ==================== DOCTOR PROFILE MANAGEMENT ====================

// @route   GET /api/hospital-doctor/profile
// @desc    Get doctor profile
// @access  Private (Hospital Doctor)
router.get('/profile', authenticateHospitalDoctor, getDoctorProfile);

// @route   PUT /api/hospital-doctor/profile
// @desc    Update doctor profile
// @access  Private (Doctor)
router.put('/profile', authenticateHospitalDoctor, updateDoctorProfile);

// @route   PUT /api/hospital-doctor/duty-status
// @desc    Update doctor duty status
// @access  Private (Hospital Doctor)
router.put('/duty-status', authenticateHospitalDoctor, validateDutyStatusUpdate, updateDutyStatus);

// ==================== ASSISTANT MANAGEMENT ====================

// @route   GET /api/hospital-doctor/assistants
// @desc    Get assigned assistants
// @access  Private (Hospital Doctor)
router.get('/assistants', authenticateHospitalDoctor, getAssignedAssistants);

// ==================== DOCTOR SCHEDULE MANAGEMENT ====================

// @route   PUT /api/hospital-doctor/schedule
// @desc    Update duty schedule
// @access  Private (Hospital Doctor)
router.put('/schedule', authenticateHospitalDoctor, validateScheduleUpdate, updateSchedule);

// @route   PUT /api/hospital-doctor/change-password
// @desc    Change password
// @access  Private (Hospital Doctor)
router.put('/change-password', authenticateHospitalDoctor, validatePasswordChange, changePassword);
router.put('/schedule', authenticateHospitalDoctor, updateSchedule);

// @route   POST /api/hospital-doctor/duty-status
// @desc    Set duty status (on/off duty)
// @access  Private (Doctor)
router.post('/duty-status', authenticateHospitalDoctor, updateDutyStatus);

module.exports = router;