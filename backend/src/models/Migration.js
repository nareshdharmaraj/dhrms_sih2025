const mongoose = require('mongoose');

const migrationSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  uhid: {
    type: String,
    required: true
  },
  
  // Migration Details
  fromState: {
    type: String,
    required: true
  },
  fromCity: {
    type: String,
    required: true
  },
  fromHospital: {
    type: String
  },
  
  toState: {
    type: String,
    required: true
  },
  toCity: {
    type: String,
    required: true
  },
  toHospital: {
    type: String,
    required: true
  },
  
  // Migration Tracking
  migrationDate: {
    type: Date,
    default: Date.now
  },
  migrationReason: {
    type: String,
    enum: ['work', 'family', 'medical', 'education', 'other'],
    required: true
  },
  expectedDuration: {
    type: String, // e.g., "6 months", "permanent", "temporary"
    required: true
  },
  
  // Employment Details (for work migration)
  employmentDetails: {
    employerName: String,
    employerAddress: String,
    workPermitNumber: String,
    contractDuration: String
  },
  
  // Health Status at Migration
  healthStatusAtMigration: {
    hasOngoingTreatment: { type: Boolean, default: false },
    currentMedications: [String],
    chronicConditions: [String],
    lastCheckupDate: Date
  },
  
  // Assigned Healthcare Provider
  assignedProvider: {
    hospitalId: String,
    hospitalName: String,
    doctorId: String,
    doctorName: String,
    assignmentDate: { type: Date, default: Date.now }
  },
  
  // Migration Status
  status: {
    type: String,
    enum: ['active', 'completed', 'cancelled'],
    default: 'active'
  },
  
  // Return Details (if applicable)
  returnDate: Date,
  returnReason: String,
  
  // System Fields
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
migrationSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Migration', migrationSchema);
