const mongoose = require('mongoose');

const medicineSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['tablet', 'tonic', 'injection'],
    required: true
  },
  name: {
    type: String,
    required: true
  },
  // Tablet specific fields
  power: {
    type: String, // Optional for tablets (e.g., "500mg")
  },
  countPerDose: {
    type: Number, // For tablets
  },
  timing: {
    type: [String],
    enum: ['morning', 'afternoon', 'evening', 'night'],
  },
  beforeAfterFood: {
    type: String,
    enum: ['before', 'after'],
  },
  duration: {
    type: Number, // Number of days
  },
  totalCount: {
    type: Number, // Auto-calculated for tablets
  },
  // Tonic specific fields
  mlPerDose: {
    type: Number, // For tonics
  },
  // Injection specific fields
  dosageDetails: {
    type: String, // For injections - free text
  },
  frequency: {
    type: String, // For injections - free text
  },
  additionalNotes: {
    type: String, // For injections - additional notes
  }
});

const prescriptionSchema = new mongoose.Schema({
  appointmentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'HospitalAppointment',
    required: true,
    unique: true
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'HospitalDoctor',
    required: true
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  hospitalId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hospital',
    required: true
  },
  
  // Patient Details
  patientName: {
    type: String,
    required: true
  },
  patientUHID: {
    type: String,
    required: true
  },
  
  // Doctor Details
  doctorName: {
    type: String,
    required: true
  },
  doctorIdentifier: {
    type: String,
    required: true
  },
  
  // Hospital Details
  hospitalName: {
    type: String,
    required: true
  },
  hospitalAddress: {
    type: String,
    required: true
  },
  hospitalContact: {
    phone: String,
    email: String
  },
  
  // Consultation Details
  consultationDate: {
    type: Date,
    required: true,
    default: Date.now
  },
  appointmentNumber: {
    type: String,
    required: true
  },
  
  // Disease Information
  diseaseName: {
    type: String, // Keep for backward compatibility - will store comma-separated list
    required: true
  },
  diseases: [{
    name: {
      type: String,
      required: true
    },
    isCustom: {
      type: Boolean,
      default: false // true if manually entered via "Others"
    }
  }], // Array of selected diseases - new field
  diseaseType: {
    type: String,
    enum: ['communicable', 'not_communicable'],
    required: true
  },
  expectedRecoveryDays: {
    type: Number,
    min: 1,
    max: 100,
    required: function() {
      return this.diseaseType === 'communicable';
    }
  },
  
  // Prescription Details
  medicines: [medicineSchema],
  
  // Next Visit
  nextVisitDate: {
    type: Date,
    required: false
  },
  nextVisitMandatory: {
    type: Boolean,
    default: false
  },
  
  // Status and Confirmation
  isConfirmed: {
    type: Boolean,
    default: false
  },
  confirmedAt: {
    type: Date
  },
  
  // Metadata
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Auto-update updatedAt field
prescriptionSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Calculate total tablet count before saving
prescriptionSchema.pre('save', function(next) {
  this.medicines.forEach(medicine => {
    if (medicine.type === 'tablet' && medicine.countPerDose && medicine.timing && medicine.duration) {
      medicine.totalCount = medicine.countPerDose * medicine.timing.length * medicine.duration;
    }
  });
  next();
});

// Index for better query performance
prescriptionSchema.index({ appointmentId: 1 });
prescriptionSchema.index({ doctorId: 1 });
prescriptionSchema.index({ patientId: 1 });
prescriptionSchema.index({ hospitalId: 1 });
prescriptionSchema.index({ consultationDate: -1 });

module.exports = mongoose.model('HospitalPrescription', prescriptionSchema);