const express = require('express');
const router = express.Router();

// Controllers
const {
  adminLogin,
  getAdminDashboard,
  createDoctor,
  getAllDoctors,
  updateDoctor,
  deleteDoctor,
  createAssistant,
  getAllAssistants
} = require('../controllers/hospital_admin_controller');

// Middleware
const { 
  authenticateHospitalAdmin, 
  requireAdminPermission 
} = require('../middleware/hospitalAuth');
const { 
  validateAdminLogin,
  validateDoctorCreation,
  validateAssistantCreation
} = require('../middleware/hospitalValidation');

// ==================== HOSPITAL ADMIN AUTHENTICATION ====================

// @route   POST /api/hospital-admin/login
// @desc    Hospital admin login
// @access  Public
router.post('/login', validateAdminLogin, adminLogin);

// @route   GET /api/hospital-admin/dashboard
// @desc    Get admin dashboard data
// @access  Private (Hospital Admin)
router.get('/dashboard', authenticateHospitalAdmin, getAdminDashboard);

// ==================== DOCTOR MANAGEMENT ====================

// @route   POST /api/hospital-admin/doctors
// @desc    Create new doctor
// @access  Private (Hospital Admin)
router.post('/doctors', 
  authenticateHospitalAdmin, 
  requireAdminPermission('manageStaff'), 
  validateDoctorCreation, 
  createDoctor
);

// @route   GET /api/hospital-admin/doctors
// @desc    Get all doctors
// @access  Private (Hospital Admin)
router.get('/doctors', authenticateHospitalAdmin, getAllDoctors);

// @route   PUT /api/hospital-admin/doctors/:doctorId
// @desc    Update doctor details
// @access  Private (Hospital Admin)
router.put('/doctors/:doctorId', 
  authenticateHospitalAdmin, 
  requireAdminPermission('manageStaff'), 
  updateDoctor
);

// @route   DELETE /api/hospital-admin/doctors/:doctorId
// @desc    Delete/deactivate doctor
// @access  Private (Hospital Admin)
router.delete('/doctors/:doctorId', 
  authenticateHospitalAdmin, 
  requireAdminPermission('manageStaff'), 
  deleteDoctor
);

// ==================== ASSISTANT MANAGEMENT ====================

// @route   POST /api/hospital-admin/assistants
// @desc    Create new assistant
// @access  Private (Hospital Admin)
router.post('/assistants', 
  authenticateHospitalAdmin, 
  requireAdminPermission('manageStaff'), 
  validateAssistantCreation, 
  createAssistant
);

// @route   GET /api/hospital-admin/assistants
// @desc    Get all assistants
// @access  Private (Hospital Admin)
router.get('/assistants', authenticateHospitalAdmin, getAllAssistants);

module.exports = router;