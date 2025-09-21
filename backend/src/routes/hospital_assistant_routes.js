const express = require('express');
const router = express.Router();

// Controllers
const {
  assistantLogin,
  getAssistantDashboard,
  getAssistantProfile,
  updateAssistantProfile,
  updateDutyStatus,
  getAssignedDoctor,
  updateSchedule,
  changePassword,
  getDuties,
  updateDutyTaskStatus
} = require('../controllers/hospital_assistant_controller');

// Middleware
const { authenticateHospitalAssistant } = require('../middleware/hospitalAuth');
const { 
  validateStaffLogin,
  validatePasswordChange,
  validateDutyStatusUpdate,
  validateScheduleUpdate
} = require('../middleware/hospitalValidation');

// ==================== HOSPITAL ASSISTANT ROUTES ====================

// @route   POST /api/hospital-assistant/login
// @desc    Assistant login
// @access  Public
router.post('/login', validateStaffLogin, assistantLogin);

// @route   GET /api/hospital-assistant/dashboard
// @desc    Get assistant dashboard data
// @access  Private (Hospital Assistant)
router.get('/dashboard', authenticateHospitalAssistant, getAssistantDashboard);

// @route   GET /api/hospital-assistant/profile
// @desc    Get assistant profile
// @access  Private (Hospital Assistant)
router.get('/profile', authenticateHospitalAssistant, getAssistantProfile);

// @route   PUT /api/hospital-assistant/profile
// @desc    Update assistant profile
// @access  Private (Hospital Assistant)
router.put('/profile', authenticateHospitalAssistant, updateAssistantProfile);

// @route   PUT /api/hospital-assistant/duty-status
// @desc    Update assistant duty status
// @access  Private (Hospital Assistant)
router.put('/duty-status', authenticateHospitalAssistant, validateDutyStatusUpdate, updateDutyStatus);

// @route   GET /api/hospital-assistant/assigned-doctor
// @desc    Get assigned doctor details
// @access  Private (Hospital Assistant)
router.get('/assigned-doctor', authenticateHospitalAssistant, getAssignedDoctor);

// @route   PUT /api/hospital-assistant/schedule
// @desc    Update duty schedule
// @access  Private (Hospital Assistant)
router.put('/schedule', authenticateHospitalAssistant, validateScheduleUpdate, updateSchedule);

// @route   PUT /api/hospital-assistant/change-password
// @desc    Change password
// @access  Private (Hospital Assistant)
router.put('/change-password', authenticateHospitalAssistant, validatePasswordChange, changePassword);

// @route   GET /api/hospital-assistant/duties
// @desc    Get duties/tasks
// @access  Private (Hospital Assistant)
router.get('/duties', authenticateHospitalAssistant, getDuties);

// @route   PUT /api/hospital-assistant/duties/:dutyId
// @desc    Update duty status
// @access  Private (Hospital Assistant)
router.put('/duties/:dutyId', authenticateHospitalAssistant, updateDutyTaskStatus);

module.exports = router;