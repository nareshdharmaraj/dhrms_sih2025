const express = require('express');
const router = express.Router();

// Controllers
const {
  getAllHospitals,
  getHospitalById,
  registerHospital,
  updateHospital,
  deleteHospital,
  searchHospitals
} = require('../controllers/hospital_management_controller');

// Hospital Admin Controllers
const {
  adminLogin,
  getAdminDashboard,
  createDoctor,
  getAllDoctors,
  updateDoctor,
  deleteDoctor,
  createAssistant,
  getAllAssistants,
  updateDoctorStatus,
  updateAssistantStatus
} = require('../controllers/hospital_admin_controller');

// Middleware
const { authenticateHospitalAdmin } = require('../middleware/hospitalAuth');
const { 
  validateHospitalRegistration,
  validateHospitalSearch,
  validateAdminLogin,
  validateDoctorCreation,
  validateAssistantCreation
} = require('../middleware/hospitalValidation');

// ==================== HOSPITAL MANAGEMENT ROUTES ====================

// @route   GET /api/hospital/list
// @desc    Get all hospitals (for admin login hospital selection)
// @access  Public
router.get('/list', getAllHospitals);

// @route   GET /api/hospital/search
// @desc    Search hospitals by name or location
// @access  Public
router.get('/search', searchHospitals);

// @route   GET /api/hospital/:hospitalId
// @desc    Get hospital details by ID
// @access  Public
router.get('/:hospitalId', getHospitalById);

// @route   POST /api/hospital/register
// @desc    Register new hospital with admin
// @access  Public
router.post('/register', validateHospitalRegistration, registerHospital);

// @route   PUT /api/hospital/:hospitalId
// @desc    Update hospital details
// @access  Private (Hospital Admin)
router.put('/:hospitalId', authenticateHospitalAdmin, updateHospital);

// @route   DELETE /api/hospital/:hospitalId
// @desc    Delete/deactivate hospital
// @access  Private (System Admin)
router.delete('/:hospitalId', deleteHospital);

// ==================== HOSPITAL ADMIN ROUTES ====================
// These routes match what the frontend dashboard expects

// @route   POST /api/hospital/admin/login
// @desc    Hospital admin login
// @access  Public
router.post('/admin/login', validateAdminLogin, adminLogin);

// @route   GET /api/hospital/admin/dashboard
// @desc    Get admin dashboard data
// @access  Private (Hospital Admin)
router.get('/admin/dashboard', authenticateHospitalAdmin, getAdminDashboard);

// @route   POST /api/hospital/admin/doctor
// @desc    Create new doctor
// @access  Private (Hospital Admin)
router.post('/admin/doctor', authenticateHospitalAdmin, validateDoctorCreation, createDoctor);

// @route   GET /api/hospital/admin/doctors
// @desc    Get all doctors
// @access  Private (Hospital Admin)
router.get('/admin/doctors', authenticateHospitalAdmin, getAllDoctors);

// @route   PATCH /api/hospital/admin/doctor/:doctorId/status
// @desc    Update doctor status (active/inactive)
// @access  Private (Hospital Admin)
router.patch('/admin/doctor/:doctorId/status', authenticateHospitalAdmin, updateDoctorStatus);

// @route   POST /api/hospital/admin/assistant
// @desc    Create new assistant
// @access  Private (Hospital Admin)
router.post('/admin/assistant', authenticateHospitalAdmin, validateAssistantCreation, createAssistant);

// @route   GET /api/hospital/admin/assistants
// @desc    Get all assistants
// @access  Private (Hospital Admin)
router.get('/admin/assistants', authenticateHospitalAdmin, getAllAssistants);

// @route   PATCH /api/hospital/admin/assistant/:assistantId/status
// @desc    Update assistant status (active/inactive)
// @access  Private (Hospital Admin)
router.patch('/admin/assistant/:assistantId/status', authenticateHospitalAdmin, updateAssistantStatus);

module.exports = router;