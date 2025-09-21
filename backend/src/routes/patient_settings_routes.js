const express = require('express');
const router = express.Router();

// Patient settings controller functions
const {
  getPatientProfile,
  updatePatientProfile,
  changePassword,
  getPrivacySettings,
  updatePrivacySettings,
  getNotificationSettings,
  updateNotificationSettings,
  getHealthReminders,
  createHealthReminder,
  updateHealthReminder,
  deleteHealthReminder,
  enableBiometricAuth,
  disableBiometricAuth,
  enableLocationServices,
  disableLocationServices,
  exportPatientData,
  deletePatientAccount
} = require('../controllers/patient_settings_controller');

// Middleware
const { authenticateToken, authorizeRole } = require('../middleware/auth');

// Apply authentication to all patient settings routes
router.use(authenticateToken);
router.use(authorizeRole(['patient']));

// ==================== PROFILE MANAGEMENT ====================

// @route   GET /api/patients/:patientId/profile
// @desc    Get patient profile
// @access  Private (Patient)
router.get('/:patientId/profile', getPatientProfile);

// @route   PUT /api/patients/:patientId/profile  
// @desc    Update patient profile
// @access  Private (Patient)
router.put('/:patientId/profile', updatePatientProfile);

// @route   POST /api/patients/:patientId/change-password
// @desc    Change patient password
// @access  Private (Patient)
router.post('/:patientId/change-password', changePassword);

// ==================== PRIVACY SETTINGS ====================

// @route   GET /api/patients/:patientId/privacy-settings
// @desc    Get patient privacy settings
// @access  Private (Patient)
router.get('/:patientId/privacy-settings', getPrivacySettings);

// @route   PUT /api/patients/:patientId/privacy-settings
// @desc    Update patient privacy settings
// @access  Private (Patient)
router.put('/:patientId/privacy-settings', updatePrivacySettings);

// ==================== NOTIFICATION SETTINGS ====================

// @route   GET /api/patients/:patientId/notification-settings
// @desc    Get patient notification settings
// @access  Private (Patient)
router.get('/:patientId/notification-settings', getNotificationSettings);

// @route   PUT /api/patients/:patientId/notification-settings
// @desc    Update patient notification settings
// @access  Private (Patient)
router.put('/:patientId/notification-settings', updateNotificationSettings);

// ==================== HEALTH REMINDERS ====================

// @route   GET /api/patients/:patientId/health-reminders
// @desc    Get patient health reminders
// @access  Private (Patient)
router.get('/:patientId/health-reminders', getHealthReminders);

// @route   POST /api/patients/:patientId/health-reminders
// @desc    Create new health reminder
// @access  Private (Patient)
router.post('/:patientId/health-reminders', createHealthReminder);

// @route   PUT /api/patients/:patientId/health-reminders/:reminderId
// @desc    Update health reminder
// @access  Private (Patient)
router.put('/:patientId/health-reminders/:reminderId', updateHealthReminder);

// @route   DELETE /api/patients/:patientId/health-reminders/:reminderId
// @desc    Delete health reminder
// @access  Private (Patient)
router.delete('/:patientId/health-reminders/:reminderId', deleteHealthReminder);

// ==================== BIOMETRIC AUTHENTICATION ====================

// @route   POST /api/patients/:patientId/enable-biometric
// @desc    Enable biometric authentication
// @access  Private (Patient)
router.post('/:patientId/enable-biometric', enableBiometricAuth);

// @route   POST /api/patients/:patientId/disable-biometric
// @desc    Disable biometric authentication
// @access  Private (Patient)
router.post('/:patientId/disable-biometric', disableBiometricAuth);

// ==================== LOCATION SERVICES ====================

// @route   POST /api/patients/:patientId/location-settings
// @desc    Update location services settings
// @access  Private (Patient)
router.post('/:patientId/location-settings', enableLocationServices);

// @route   DELETE /api/patients/:patientId/location-settings
// @desc    Disable location services
// @access  Private (Patient)
router.delete('/:patientId/location-settings', disableLocationServices);

// ==================== DATA MANAGEMENT ====================

// @route   GET /api/patients/:patientId/export-data
// @desc    Export patient data
// @access  Private (Patient)
router.get('/:patientId/export-data', exportPatientData);

// @route   DELETE /api/patients/:patientId/delete-account
// @desc    Delete patient account
// @access  Private (Patient)
router.delete('/:patientId/delete-account', deletePatientAccount);

module.exports = router;