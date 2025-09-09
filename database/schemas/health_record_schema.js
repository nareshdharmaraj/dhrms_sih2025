const mongoose = require('mongoose');

const healthRecordSchema = new mongoose.Schema({
  // Patient Reference
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  healthId: {
    type: String,
    required: true,
    index: true
  },
  
  // Record Information
  recordType: {
    type: String,
    enum: [
      'consultation',
      'diagnosis',
      'prescription',
      'lab_report',
      'vaccination',
      'surgery',
      'emergency',
      'checkup',
      'treatment'
    ],
    required: true
  },
  
  // Medical Details
  chiefComplaint: {
    type: String,
    required: function() {
      return ['consultation', 'diagnosis', 'emergency'].includes(this.recordType);
    }
  },
  diagnosis: {
    primary: String,
    secondary: [String],
    icd10Codes: [String]
  },
  symptoms: [String],
  treatment: {
    description: String,
    medications: [{
      name: String,
      dosage: String,
      frequency: String,
      duration: String,
      instructions: String
    }],
    procedures: [String]
  },
  
  // Healthcare Provider Information
  providerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  providerName: String,
  hospitalName: String,
  department: String,
  
  // Visit Information
  visitDate: {
    type: Date,
    required: true,
    default: Date.now
  },
  visitType: {
    type: String,
    enum: ['outpatient', 'inpatient', 'emergency', 'telemedicine'],
    required: true
  },
  
  // Vital Signs
  vitals: {
    bloodPressure: {
      systolic: Number,
      diastolic: Number
    },
    heartRate: Number,
    temperature: Number,
    respiratoryRate: Number,
    oxygenSaturation: Number,
    weight: Number,
    height: Number,
    bmi: Number
  },
  
  // Lab Reports
  labReports: [{
    testName: String,
    testDate: Date,
    results: String,
    normalRange: String,
    reportFile: String,
    isAbnormal: Boolean
  }],
  
  // Imaging/Radiology
  imaging: [{
    type: String, // X-ray, CT, MRI, etc.
    bodyPart: String,
    date: Date,
    findings: String,
    imageFiles: [String]
  }],
  
  // Allergies & Warnings
  allergies: [String],
  warnings: [String],
  
  // Follow-up
  followUp: {
    required: Boolean,
    date: Date,
    instructions: String
  },
  
  // AI Predictions
  aiPredictions: {
    riskScore: Number,
    diseasePredictions: [{
      disease: String,
      probability: Number,
      confidence: Number
    }],
    recommendations: [String]
  },
  
  // Files and Documents
  attachments: [{
    fileName: String,
    fileType: String,
    fileSize: Number,
    filePath: String,
    uploadDate: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Status
  status: {
    type: String,
    enum: ['active', 'resolved', 'ongoing', 'referred'],
    default: 'active'
  },
  
  // Privacy and Sharing
  isPrivate: {
    type: Boolean,
    default: false
  },
  sharedWith: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    role: String,
    permissions: [String],
    sharedDate: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Notes
  notes: String,
  
  // Geolocation (for outbreak tracking)
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  }

}, {
  timestamps: true
});

// Indexes for better performance
healthRecordSchema.index({ patientId: 1, visitDate: -1 });
healthRecordSchema.index({ healthId: 1, visitDate: -1 });
healthRecordSchema.index({ recordType: 1 });
healthRecordSchema.index({ 'diagnosis.primary': 1 });
healthRecordSchema.index({ visitDate: -1 });

// Virtual for record age
healthRecordSchema.virtual('recordAge').get(function() {
  const now = new Date();
  const diffTime = Math.abs(now - this.visitDate);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays;
});

// Method to check if record needs follow-up
healthRecordSchema.methods.needsFollowUp = function() {
  if (!this.followUp.required) return false;
  if (!this.followUp.date) return true;
  return new Date() >= this.followUp.date;
};

// Static method to get recent records
healthRecordSchema.statics.getRecentRecords = function(patientId, days = 30) {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - days);
  
  return this.find({
    patientId: patientId,
    visitDate: { $gte: cutoffDate }
  }).sort({ visitDate: -1 });
};

module.exports = mongoose.model('HealthRecord', healthRecordSchema);
