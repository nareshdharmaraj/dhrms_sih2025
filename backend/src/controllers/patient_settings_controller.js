const bcrypt = require('bcryptjs');
const Patient = require('../models/Patient');
const HealthReminder = require('../models/HealthReminder');
const PatientSettings = require('../models/PatientSettings');

// ==================== PROFILE MANAGEMENT ====================

/**
 * @desc    Get patient profile
 * @route   GET /api/patients/:patientId/profile
 * @access  Private
 */
const getPatientProfile = async (req, res) => {
  try {
    const { patientId } = req.params;
    
    const patient = await Patient.findById(patientId).select('-password');
    
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    res.json({
      success: true,
      data: {
        fullName: patient.fullName,
        email: patient.email,
        phone: patient.phone,
        address: patient.address,
        dateOfBirth: patient.dateOfBirth,
        gender: patient.gender,
        uhid: patient.uhid
      }
    });
  } catch (error) {
    console.error('Get patient profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Update patient profile
 * @route   PUT /api/patients/:patientId/profile
 * @access  Private
 */
const updatePatientProfile = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { fullName, email, phone, address } = req.body;

    const patient = await Patient.findById(patientId);
    
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Update profile fields
    if (fullName) patient.fullName = fullName;
    if (email) patient.email = email;
    if (phone) patient.phone = phone;
    if (address) patient.address = address;

    patient.updatedAt = new Date();
    await patient.save();

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        fullName: patient.fullName,
        email: patient.email,
        phone: patient.phone,
        address: patient.address
      }
    });
  } catch (error) {
    console.error('Update patient profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Change patient password
 * @route   POST /api/patients/:patientId/change-password
 * @access  Private
 */
const changePassword = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { currentPassword, newPassword } = req.body;

    const patient = await Patient.findById(patientId);
    
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Verify current password
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, patient.password);
    
    if (!isCurrentPasswordValid) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Hash new password
    const saltRounds = 12;
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    patient.password = hashedNewPassword;
    patient.updatedAt = new Date();
    await patient.save();

    res.json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// ==================== PRIVACY SETTINGS ====================

/**
 * @desc    Get privacy settings
 * @route   GET /api/patients/:patientId/privacy-settings
 * @access  Private
 */
const getPrivacySettings = async (req, res) => {
  try {
    const { patientId } = req.params;
    
    let settings = await PatientSettings.findOne({ patientId });
    
    if (!settings) {
      // Create default settings if none exist
      settings = new PatientSettings({
        patientId,
        privacySettings: {
          shareDataWithDoctors: true,
          shareDataWithResearchers: false,
          shareLocationData: false,
          shareHealthMetrics: true,
          allowEmergencyAccess: true
        }
      });
      await settings.save();
    }

    res.json({
      success: true,
      data: settings.privacySettings
    });
  } catch (error) {
    console.error('Get privacy settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Update privacy settings
 * @route   PUT /api/patients/:patientId/privacy-settings
 * @access  Private
 */
const updatePrivacySettings = async (req, res) => {
  try {
    const { patientId } = req.params;
    const privacySettings = req.body;

    let settings = await PatientSettings.findOne({ patientId });
    
    if (!settings) {
      settings = new PatientSettings({ patientId });
    }

    settings.privacySettings = { ...settings.privacySettings, ...privacySettings };
    settings.updatedAt = new Date();
    await settings.save();

    res.json({
      success: true,
      message: 'Privacy settings updated successfully',
      data: settings.privacySettings
    });
  } catch (error) {
    console.error('Update privacy settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// ==================== NOTIFICATION SETTINGS ====================

/**
 * @desc    Get notification settings
 * @route   GET /api/patients/:patientId/notification-settings
 * @access  Private
 */
const getNotificationSettings = async (req, res) => {
  try {
    const { patientId } = req.params;
    
    let settings = await PatientSettings.findOne({ patientId });
    
    if (!settings) {
      // Create default settings if none exist
      settings = new PatientSettings({
        patientId,
        notificationSettings: {
          pushNotifications: true,
          medicationReminders: true,
          appointmentReminders: true,
          emergencyAlerts: true,
          healthTips: false
        }
      });
      await settings.save();
    }

    res.json({
      success: true,
      data: settings.notificationSettings
    });
  } catch (error) {
    console.error('Get notification settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Update notification settings
 * @route   PUT /api/patients/:patientId/notification-settings
 * @access  Private
 */
const updateNotificationSettings = async (req, res) => {
  try {
    const { patientId } = req.params;
    const notificationSettings = req.body;

    let settings = await PatientSettings.findOne({ patientId });
    
    if (!settings) {
      settings = new PatientSettings({ patientId });
    }

    settings.notificationSettings = { ...settings.notificationSettings, ...notificationSettings };
    settings.updatedAt = new Date();
    await settings.save();

    res.json({
      success: true,
      message: 'Notification settings updated successfully',
      data: settings.notificationSettings
    });
  } catch (error) {
    console.error('Update notification settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// ==================== HEALTH REMINDERS ====================

/**
 * @desc    Get health reminders
 * @route   GET /api/patients/:patientId/health-reminders
 * @access  Private
 */
const getHealthReminders = async (req, res) => {
  try {
    const { patientId } = req.params;
    
    const reminders = await HealthReminder.find({ patientId, isActive: true })
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      data: reminders
    });
  } catch (error) {
    console.error('Get health reminders error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Create health reminder
 * @route   POST /api/patients/:patientId/health-reminders
 * @access  Private
 */
const createHealthReminder = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { title, description, reminderTime, frequency, isEnabled } = req.body;

    const reminder = new HealthReminder({
      patientId,
      title,
      description,
      reminderTime,
      frequency,
      isEnabled: isEnabled !== undefined ? isEnabled : true
    });

    await reminder.save();

    res.status(201).json({
      success: true,
      message: 'Health reminder created successfully',
      data: reminder
    });
  } catch (error) {
    console.error('Create health reminder error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Update health reminder
 * @route   PUT /api/patients/:patientId/health-reminders/:reminderId
 * @access  Private
 */
const updateHealthReminder = async (req, res) => {
  try {
    const { patientId, reminderId } = req.params;
    const updates = req.body;

    const reminder = await HealthReminder.findOne({ 
      _id: reminderId, 
      patientId 
    });

    if (!reminder) {
      return res.status(404).json({
        success: false,
        message: 'Health reminder not found'
      });
    }

    Object.assign(reminder, updates);
    reminder.updatedAt = new Date();
    await reminder.save();

    res.json({
      success: true,
      message: 'Health reminder updated successfully',
      data: reminder
    });
  } catch (error) {
    console.error('Update health reminder error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Delete health reminder
 * @route   DELETE /api/patients/:patientId/health-reminders/:reminderId
 * @access  Private
 */
const deleteHealthReminder = async (req, res) => {
  try {
    const { patientId, reminderId } = req.params;

    const reminder = await HealthReminder.findOne({ 
      _id: reminderId, 
      patientId 
    });

    if (!reminder) {
      return res.status(404).json({
        success: false,
        message: 'Health reminder not found'
      });
    }

    // Soft delete by setting isActive to false
    reminder.isActive = false;
    reminder.updatedAt = new Date();
    await reminder.save();

    res.json({
      success: true,
      message: 'Health reminder deleted successfully'
    });
  } catch (error) {
    console.error('Delete health reminder error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// ==================== BIOMETRIC AUTHENTICATION ====================

/**
 * @desc    Enable biometric authentication
 * @route   POST /api/patients/:patientId/enable-biometric
 * @access  Private
 */
const enableBiometricAuth = async (req, res) => {
  try {
    const { patientId } = req.params;

    let settings = await PatientSettings.findOne({ patientId });
    
    if (!settings) {
      settings = new PatientSettings({ patientId });
    }

    settings.biometricEnabled = true;
    settings.updatedAt = new Date();
    await settings.save();

    res.json({
      success: true,
      message: 'Biometric authentication enabled successfully'
    });
  } catch (error) {
    console.error('Enable biometric auth error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Disable biometric authentication
 * @route   POST /api/patients/:patientId/disable-biometric
 * @access  Private
 */
const disableBiometricAuth = async (req, res) => {
  try {
    const { patientId } = req.params;

    let settings = await PatientSettings.findOne({ patientId });
    
    if (!settings) {
      settings = new PatientSettings({ patientId });
    }

    settings.biometricEnabled = false;
    settings.updatedAt = new Date();
    await settings.save();

    res.json({
      success: true,
      message: 'Biometric authentication disabled successfully'
    });
  } catch (error) {
    console.error('Disable biometric auth error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// ==================== LOCATION SERVICES ====================

/**
 * @desc    Enable location services
 * @route   POST /api/patients/:patientId/location-settings
 * @access  Private
 */
const enableLocationServices = async (req, res) => {
  try {
    const { patientId } = req.params;

    let settings = await PatientSettings.findOne({ patientId });
    
    if (!settings) {
      settings = new PatientSettings({ patientId });
    }

    settings.locationEnabled = true;
    settings.updatedAt = new Date();
    await settings.save();

    res.json({
      success: true,
      message: 'Location services enabled successfully'
    });
  } catch (error) {
    console.error('Enable location services error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Disable location services
 * @route   DELETE /api/patients/:patientId/location-settings
 * @access  Private
 */
const disableLocationServices = async (req, res) => {
  try {
    const { patientId } = req.params;

    let settings = await PatientSettings.findOne({ patientId });
    
    if (!settings) {
      settings = new PatientSettings({ patientId });
    }

    settings.locationEnabled = false;
    settings.updatedAt = new Date();
    await settings.save();

    res.json({
      success: true,
      message: 'Location services disabled successfully'
    });
  } catch (error) {
    console.error('Disable location services error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

// ==================== DATA MANAGEMENT ====================

/**
 * @desc    Export patient data
 * @route   GET /api/patients/:patientId/export-data
 * @access  Private
 */
const exportPatientData = async (req, res) => {
  try {
    const { patientId } = req.params;

    const patient = await Patient.findById(patientId).select('-password');
    const settings = await PatientSettings.findOne({ patientId });
    const reminders = await HealthReminder.find({ patientId });

    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    const exportData = {
      profile: patient,
      settings: settings,
      healthReminders: reminders,
      exportedAt: new Date()
    };

    res.json({
      success: true,
      message: 'Patient data exported successfully',
      data: exportData
    });
  } catch (error) {
    console.error('Export patient data error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

/**
 * @desc    Delete patient account
 * @route   DELETE /api/patients/:patientId/delete-account
 * @access  Private
 */
const deletePatientAccount = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { confirmPassword } = req.body;

    const patient = await Patient.findById(patientId);
    
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Verify password for account deletion
    const isPasswordValid = await bcrypt.compare(confirmPassword, patient.password);
    
    if (!isPasswordValid) {
      return res.status(400).json({
        success: false,
        message: 'Password confirmation failed'
      });
    }

    // Soft delete by setting isActive to false
    patient.isActive = false;
    patient.deletedAt = new Date();
    await patient.save();

    // Also deactivate related settings and reminders
    await PatientSettings.updateOne({ patientId }, { isActive: false });
    await HealthReminder.updateMany({ patientId }, { isActive: false });

    res.json({
      success: true,
      message: 'Patient account deleted successfully'
    });
  } catch (error) {
    console.error('Delete patient account error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error'
    });
  }
};

module.exports = {
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
};