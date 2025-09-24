const mongoose = require('mongoose');

// Contact Tracing Schema for BLE proximity detection
const contactTracingSchema = new mongoose.Schema({
  deviceId: {
    type: String,
    required: true,
    unique: true,
    index: true,
    trim: true
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true,
    index: true
  },
  uhid: {
    type: String,
    required: true,
    index: true
  },
  isInfected: {
    type: Boolean,
    default: false,
    index: true
  },
  infectionStatus: {
    type: String,
    enum: ['healthy', 'infected', 'recovered', 'quarantined'],
    default: 'healthy',
    index: true
  },
  communicableDiseases: [{
    diseaseName: {
      type: String,
      required: true
    },
    diagnosisDate: {
      type: Date,
      required: true
    },
    expectedRecoveryDate: {
      type: Date,
      required: true
    },
    prescriptionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'HospitalPrescription'
    },
    isActive: {
      type: Boolean,
      default: true
    }
  }],
  lastActiveDate: {
    type: Date,
    default: Date.now,
    index: true
  },
  registrationDate: {
    type: Date,
    default: Date.now
  },
  metadata: {
    deviceInfo: {
      platform: String,
      version: String,
      model: String
    },
    location: {
      state: String,
      district: String,
      coordinates: {
        latitude: Number,
        longitude: Number
      }
    }
  }
}, {
  timestamps: true,
  collection: 'contact_tracing'
});

// Indexes for performance
contactTracingSchema.index({ deviceId: 1, isInfected: 1 });
contactTracingSchema.index({ patientId: 1, isInfected: 1 });
contactTracingSchema.index({ uhid: 1, isInfected: 1 });
contactTracingSchema.index({ 'communicableDiseases.isActive': 1, isInfected: 1 });
contactTracingSchema.index({ lastActiveDate: 1 });

// Contact Exposure Schema for tracking proximities
const contactExposureSchema = new mongoose.Schema({
  sourceDeviceId: {
    type: String,
    required: true,
    index: true
  },
  targetDeviceId: {
    type: String,
    required: true,
    index: true
  },
  exposureDate: {
    type: Date,
    required: true,
    index: true
  },
  duration: {
    type: Number, // in minutes
    required: true
  },
  proximity: {
    type: Number, // estimated distance in meters
    required: true
  },
  riskLevel: {
    type: String,
    enum: ['low', 'medium', 'high'],
    required: true
  },
  location: {
    coordinates: {
      latitude: Number,
      longitude: Number
    },
    address: String
  },
  isReported: {
    type: Boolean,
    default: false
  },
  healthAuthorityNotified: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true,
  collection: 'contact_exposures'
});

// Indexes for contact exposures
contactExposureSchema.index({ sourceDeviceId: 1, exposureDate: -1 });
contactExposureSchema.index({ targetDeviceId: 1, exposureDate: -1 });
contactExposureSchema.index({ exposureDate: -1, riskLevel: 1 });

// Methods for ContactTracing
contactTracingSchema.methods.addCommunicableDisease = function(diseaseData) {
  this.communicableDiseases.push(diseaseData);
  this.isInfected = true;
  this.infectionStatus = 'infected';
  return this.save();
};

contactTracingSchema.methods.markRecovered = function(diseaseName) {
  const disease = this.communicableDiseases.find(d => d.diseaseName === diseaseName && d.isActive);
  if (disease) {
    disease.isActive = false;
  }
  
  // Check if any active communicable diseases remain
  const hasActiveDiseases = this.communicableDiseases.some(d => d.isActive);
  if (!hasActiveDiseases) {
    this.isInfected = false;
    this.infectionStatus = 'recovered';
  }
  
  return this.save();
};

contactTracingSchema.methods.updateLastActive = function() {
  this.lastActiveDate = new Date();
  return this.save();
};

// Static methods
contactTracingSchema.statics.getInfectedDeviceIds = function() {
  return this.find({ isInfected: true }, 'deviceId').lean();
};

contactTracingSchema.statics.findByDeviceId = function(deviceId) {
  return this.findOne({ deviceId }).populate('patientId', 'username fullName phone');
};

contactTracingSchema.statics.getInfectedByLocation = function(state, district) {
  return this.find({
    isInfected: true,
    'metadata.location.state': state,
    'metadata.location.district': district
  });
};

module.exports = {
  ContactTracing: mongoose.model('ContactTracing', contactTracingSchema),
  ContactExposure: mongoose.model('ContactExposure', contactExposureSchema)
};
