const mongoose = require('mongoose');

const smartwatchPairingSchema = new mongoose.Schema({
  pairingId: {
    type: String,
    required: true,
    unique: true
  },
  patient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  device: {
    deviceId: {
      type: String,
      required: true
    },
    deviceName: String,
    brand: {
      type: String,
      enum: ['apple', 'samsung', 'fitbit', 'garmin', 'xiaomi', 'huawei', 'other'],
      required: true
    },
    model: String,
    osVersion: String,
    firmwareVersion: String,
    hardwareVersion: String,
    serialNumber: String,
    macAddress: String
  },
  bluetooth: {
    bluetoothAddress: String,
    bluetoothName: String,
    bluetoothVersion: String,
    supportedProfiles: [String], // HID, A2DP, etc.
    rssi: Number, // Signal strength
    connectionType: {
      type: String,
      enum: ['classic', 'ble', 'dual'],
      default: 'ble'
    }
  },
  pairing: {
    status: {
      type: String,
      enum: ['pending', 'paired', 'connected', 'disconnected', 'failed', 'revoked'],
      default: 'pending'
    },
    pairingCode: String,
    pairingMethod: {
      type: String,
      enum: ['pin', 'passkey', 'nfc', 'qr_code', 'automatic'],
      default: 'passkey'
    },
    pairingToken: String,
    pairedAt: Date,
    lastConnected: Date,
    connectionAttempts: {
      type: Number,
      default: 0
    },
    failureReasons: [String]
  },
  capabilities: {
    sensors: [{
      type: {
        type: String,
        enum: ['heart_rate', 'accelerometer', 'gyroscope', 'gps', 'temperature', 'spo2', 'ecg', 'blood_pressure']
      },
      available: Boolean,
      accuracy: String,
      sampleRate: Number
    }],
    features: [{
      type: String,
      enum: ['notifications', 'calls', 'messages', 'health_monitoring', 'emergency_sos', 'fall_detection', 'sleep_tracking']
    }],
    batteryInfo: {
      level: Number,
      isCharging: Boolean,
      lastUpdated: Date
    },
    storageInfo: {
      total: Number,
      used: Number,
      available: Number
    }
  },
  healthMonitoring: {
    enabledSensors: [String],
    monitoringSchedule: {
      heartRate: {
        enabled: Boolean,
        interval: Number, // in seconds
        alertThresholds: {
          min: Number,
          max: Number
        }
      },
      activity: {
        enabled: Boolean,
        stepGoal: Number,
        calorieGoal: Number
      },
      sleep: {
        enabled: Boolean,
        bedtimeReminder: Boolean,
        sleepGoal: Number // in hours
      },
      stress: {
        enabled: Boolean,
        measurementFrequency: String
      }
    },
    emergencyFeatures: {
      fallDetection: Boolean,
      sosButton: Boolean,
      emergencyContacts: [String],
      autoEmergencyCall: Boolean
    }
  },
  dataSync: {
    lastSyncAt: Date,
    syncInterval: {
      type: Number,
      default: 300 // 5 minutes in seconds
    },
    autoSync: {
      type: Boolean,
      default: true
    },
    syncedDataTypes: [String],
    pendingSyncCount: {
      type: Number,
      default: 0
    },
    failedSyncCount: {
      type: Number,
      default: 0
    },
    syncSettings: {
      wifiOnly: Boolean,
      backgroundSync: Boolean,
      lowPowerMode: Boolean
    }
  },
  security: {
    encryptionEnabled: {
      type: Boolean,
      default: true
    },
    encryptionMethod: String,
    certificateFingerprint: String,
    trustedDevice: {
      type: Boolean,
      default: false
    },
    accessPermissions: [{
      permission: String,
      granted: Boolean,
      grantedAt: Date
    }],
    securityAlerts: [{
      type: String,
      message: String,
      timestamp: Date,
      resolved: Boolean
    }]
  },
  notifications: {
    enabledTypes: [{
      type: String,
      enum: ['health_alerts', 'medication_reminders', 'appointment_reminders', 'emergency_alerts', 'system_notifications']
    }],
    vibrationPatterns: {
      health_alert: String,
      medication: String,
      emergency: String,
      general: String
    },
    quietHours: {
      enabled: Boolean,
      startTime: String, // HH:MM format
      endTime: String
    }
  },
  location: {
    lastKnownLocation: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: [Number] // [longitude, latitude]
    },
    locationTracking: {
      enabled: Boolean,
      accuracy: String,
      updateInterval: Number
    },
    findMyDevice: {
      enabled: Boolean,
      lastPing: Date,
      ringEnabled: Boolean
    }
  },
  maintenance: {
    firmwareUpdates: [{
      version: String,
      installedAt: Date,
      updateSize: Number,
      releaseNotes: String
    }],
    diagnostics: {
      lastDiagnostic: Date,
      batteryHealth: Number, // percentage
      memoryHealth: String,
      connectivityStatus: String,
      sensorStatus: String
    },
    troubleshooting: [{
      issue: String,
      resolution: String,
      timestamp: Date,
      resolvedBy: String
    }]
  }
}, {
  timestamps: true
});

// Indexes
smartwatchPairingSchema.index({ patient: 1 });
smartwatchPairingSchema.index({ 'device.deviceId': 1 });
smartwatchPairingSchema.index({ 'pairing.status': 1 });
smartwatchPairingSchema.index({ 'bluetooth.bluetoothAddress': 1 });
smartwatchPairingSchema.index({ 'pairing.pairedAt': 1 });

// Instance methods
smartwatchPairingSchema.methods.isConnected = function() {
  return this.pairing.status === 'connected';
};

smartwatchPairingSchema.methods.canReceiveNotifications = function() {
  return this.isConnected() && this.capabilities.features.includes('notifications');
};

smartwatchPairingSchema.methods.getBatteryStatus = function() {
  const battery = this.capabilities.batteryInfo;
  if (!battery.level) return 'unknown';
  
  if (battery.level < 20) return 'low';
  if (battery.level < 50) return 'medium';
  return 'good';
};

smartwatchPairingSchema.methods.updateConnectionStatus = function(status, reason = null) {
  this.pairing.status = status;
  
  if (status === 'connected') {
    this.pairing.lastConnected = new Date();
  } else if (status === 'failed' && reason) {
    this.pairing.failureReasons.push(reason);
  }
  
  this.pairing.connectionAttempts += 1;
};

smartwatchPairingSchema.methods.recordSync = function(dataTypes, success = true) {
  this.dataSync.lastSyncAt = new Date();
  
  if (success) {
    this.dataSync.syncedDataTypes = [...new Set([...this.dataSync.syncedDataTypes, ...dataTypes])];
    this.dataSync.pendingSyncCount = Math.max(0, this.dataSync.pendingSyncCount - 1);
  } else {
    this.dataSync.failedSyncCount += 1;
  }
};

smartwatchPairingSchema.methods.sendNotification = function(notificationType, message, vibrationPattern = null) {
  if (!this.canReceiveNotifications()) {
    throw new Error('Device cannot receive notifications');
  }
  
  // Check quiet hours
  if (this.notifications.quietHours.enabled) {
    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const { startTime, endTime } = this.notifications.quietHours;
    
    if (currentTime >= startTime && currentTime <= endTime) {
      return { sent: false, reason: 'quiet_hours' };
    }
  }
  
  const pattern = vibrationPattern || this.notifications.vibrationPatterns[notificationType] || 'general';
  
  return {
    sent: true,
    notificationType,
    message,
    vibrationPattern: pattern,
    timestamp: new Date()
  };
};

// Static methods
smartwatchPairingSchema.statics.generatePairingId = function() {
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substr(2, 6);
  return `SW${timestamp}${random}`.toUpperCase();
};

smartwatchPairingSchema.statics.generatePairingCode = function() {
  return Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit code
};

smartwatchPairingSchema.statics.findActiveDevices = function(patientId) {
  return this.find({
    patient: patientId,
    'pairing.status': { $in: ['paired', 'connected'] }
  });
};

module.exports = mongoose.model('SmartwatchPairing', smartwatchPairingSchema);
