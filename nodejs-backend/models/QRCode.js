const mongoose = require('mongoose');

const qrCodeSchema = new mongoose.Schema({
  qrCodeId: {
    type: String,
    required: true,
    unique: true
  },
  patient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  type: {
    type: String,
    enum: ['health_record', 'prescription', 'appointment', 'emergency', 'profile'],
    required: true
  },
  data: {
    // Embedded data structure based on type
    patientInfo: {
      patientId: String,
      name: String,
      age: Number,
      bloodType: String,
      emergencyContact: String,
      allergies: [String],
      chronicConditions: [String]
    },
    medicalSummary: {
      lastVisit: Date,
      primaryDoctor: String,
      currentMedications: [String],
      vitalSigns: {
        bloodPressure: String,
        heartRate: Number,
        temperature: Number,
        weight: Number
      }
    },
    emergencyInfo: {
      emergencyContacts: [{
        name: String,
        relationship: String,
        phone: String
      }],
      medicalAlerts: [String],
      insuranceInfo: String
    },
    specificData: mongoose.Schema.Types.Mixed // For type-specific data
  },
  accessSettings: {
    isPublic: {
      type: Boolean,
      default: false
    },
    expiresAt: Date,
    accessCount: {
      type: Number,
      default: 0
    },
    maxAccess: Number,
    authorizedRoles: [{
      type: String,
      enum: ['doctor', 'hospital', 'emergency', 'pharmacy']
    }]
  },
  qrCodeData: {
    qrString: String, // The actual QR code content
    format: {
      type: String,
      enum: ['json', 'url', 'text'],
      default: 'json'
    },
    size: {
      type: String,
      enum: ['small', 'medium', 'large'],
      default: 'medium'
    },
    errorCorrection: {
      type: String,
      enum: ['L', 'M', 'Q', 'H'],
      default: 'M'
    }
  },
  usage: {
    scanCount: {
      type: Number,
      default: 0
    },
    lastScanned: Date,
    scanHistory: [{
      scannedBy: String,
      scannerType: {
        type: String,
        enum: ['patient', 'doctor', 'hospital', 'emergency', 'anonymous']
      },
      timestamp: Date,
      location: {
        type: {
          type: String,
          enum: ['Point'],
          default: 'Point'
        },
        coordinates: [Number] // [longitude, latitude]
      },
      scanResult: String
    }]
  },
  security: {
    encryptionLevel: {
      type: String,
      enum: ['none', 'basic', 'advanced'],
      default: 'basic'
    },
    verificationCode: String,
    isActive: {
      type: Boolean,
      default: true
    },
    revokedAt: Date,
    revokedBy: String
  }
}, {
  timestamps: true
});

// Indexes
qrCodeSchema.index({ qrCodeId: 1 });
qrCodeSchema.index({ patient: 1 });
qrCodeSchema.index({ type: 1 });
qrCodeSchema.index({ 'accessSettings.expiresAt': 1 });
qrCodeSchema.index({ 'security.isActive': 1 });

// Instance methods
qrCodeSchema.methods.isExpired = function() {
  return this.accessSettings.expiresAt && this.accessSettings.expiresAt < new Date();
};

qrCodeSchema.methods.canAccess = function(role) {
  if (!this.security.isActive) return false;
  if (this.isExpired()) return false;
  if (this.accessSettings.maxAccess && this.accessSettings.accessCount >= this.accessSettings.maxAccess) return false;
  
  return this.accessSettings.isPublic || 
         this.accessSettings.authorizedRoles.includes(role) ||
         role === 'emergency';
};

qrCodeSchema.methods.recordScan = function(scannerInfo) {
  this.usage.scanCount += 1;
  this.usage.lastScanned = new Date();
  this.usage.scanHistory.push({
    scannedBy: scannerInfo.scannedBy || 'anonymous',
    scannerType: scannerInfo.scannerType || 'anonymous',
    timestamp: new Date(),
    location: scannerInfo.location,
    scanResult: scannerInfo.scanResult || 'success'
  });
  this.accessSettings.accessCount += 1;
};

// Static methods
qrCodeSchema.statics.generateQRId = function() {
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substr(2, 5);
  return `QR${timestamp}${random}`.toUpperCase();
};

qrCodeSchema.statics.createHealthRecordQR = async function(patientId, patientData) {
  const qrCodeId = this.generateQRId();
  
  const qrData = {
    type: 'HEALTH_RECORD',
    id: qrCodeId,
    patient: patientData.patientId,
    name: patientData.name,
    bloodType: patientData.bloodType,
    emergencyContact: patientData.emergencyContact,
    allergies: patientData.allergies,
    chronicConditions: patientData.chronicConditions,
    timestamp: new Date().toISOString(),
    verification: 'DHRMS_VERIFIED'
  };

  return new this({
    qrCodeId,
    patient: patientId,
    type: 'health_record',
    data: {
      patientInfo: {
        patientId: patientData.patientId,
        name: patientData.name,
        age: patientData.age,
        bloodType: patientData.bloodType,
        emergencyContact: patientData.emergencyContact,
        allergies: patientData.allergies || [],
        chronicConditions: patientData.chronicConditions || []
      }
    },
    qrCodeData: {
      qrString: JSON.stringify(qrData),
      format: 'json'
    },
    accessSettings: {
      isPublic: false,
      authorizedRoles: ['doctor', 'hospital', 'emergency'],
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
    }
  });
};

module.exports = mongoose.model('QRCode', qrCodeSchema);
