const mongoose = require('mongoose');

const patientSettingsSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true,
    unique: true
  },
  
  // Privacy Settings
  privacySettings: {
    shareDataWithDoctors: {
      type: Boolean,
      default: true
    },
    shareDataWithResearchers: {
      type: Boolean,
      default: false
    },
    shareLocationData: {
      type: Boolean,
      default: false
    },
    shareHealthMetrics: {
      type: Boolean,
      default: true
    },
    allowEmergencyAccess: {
      type: Boolean,
      default: true
    }
  },

  // Notification Settings
  notificationSettings: {
    pushNotifications: {
      type: Boolean,
      default: true
    },
    medicationReminders: {
      type: Boolean,
      default: true
    },
    appointmentReminders: {
      type: Boolean,
      default: true
    },
    emergencyAlerts: {
      type: Boolean,
      default: true
    },
    healthTips: {
      type: Boolean,
      default: false
    }
  },

  // App Preferences
  appPreferences: {
    language: {
      type: String,
      enum: ['English', 'Hindi', 'Tamil', 'Telugu', 'Malayalam', 'Kannada'],
      default: 'English'
    },
    theme: {
      type: String,
      enum: ['Light', 'Dark', 'System'],
      default: 'System'
    }
  },

  // Security Settings
  biometricEnabled: {
    type: Boolean,
    default: false
  },
  
  locationEnabled: {
    type: Boolean,
    default: false
  },

  // System fields
  isActive: {
    type: Boolean,
    default: true
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update the updatedAt field before saving
patientSettingsSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Index for better performance
patientSettingsSchema.index({ patientId: 1 });
patientSettingsSchema.index({ isActive: 1 });

module.exports = mongoose.model('PatientSettings', patientSettingsSchema);