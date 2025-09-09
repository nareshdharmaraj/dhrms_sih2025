const express = require('express');
const router = express.Router();

// Patient controller functions
const {
  getPatientProfile,
  updatePatientProfile,
  getHealthRecords,
  addHealthRecord,
  getAppointments,
  bookAppointment,
  cancelAppointment,
  getVitals,
  addVitals
} = require('../controllers/patient_controller');

// Middleware
const { authenticateToken, authorizeRole } = require('../middleware/auth');
const { validateHealthRecord, validateVitals } = require('../middleware/validation');

// Apply authentication to all patient routes
router.use(authenticateToken);
router.use(authorizeRole(['patient']));

// @route   GET /api/patients/profile
// @desc    Get patient profile
// @access  Private (Patient)
router.get('/profile', getPatientProfile);

// @route   PUT /api/patients/profile
// @desc    Update patient profile
// @access  Private (Patient)
router.put('/profile', updatePatientProfile);

// @route   GET /api/patients/health-records
// @desc    Get patient health records
// @access  Private (Patient)
router.get('/health-records', getHealthRecords);

// @route   POST /api/patients/health-records
// @desc    Add new health record
// @access  Private (Patient)
router.post('/health-records', validateHealthRecord, addHealthRecord);

// @route   GET /api/patients/appointments
// @desc    Get patient appointments
// @access  Private (Patient)
router.get('/appointments', getAppointments);

// @route   POST /api/patients/appointments
// @desc    Book new appointment
// @access  Private (Patient)
router.post('/appointments', bookAppointment);

// @route   DELETE /api/patients/appointments/:id
// @desc    Cancel appointment
// @access  Private (Patient)
router.delete('/appointments/:id', cancelAppointment);

// @route   GET /api/patients/vitals
// @desc    Get patient vitals
// @access  Private (Patient)
router.get('/vitals', getVitals);

// @route   POST /api/patients/vitals
// @desc    Add new vitals
// @access  Private (Patient)
router.post('/vitals', validateVitals, addVitals);

module.exports = router;
