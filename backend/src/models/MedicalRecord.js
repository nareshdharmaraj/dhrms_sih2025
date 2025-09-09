const mongoose = require('mongoose');

const medicalRecordSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  hospitalStaffId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'HospitalStaff',
    required: true
  },
  recordType: {
    type: String,
    enum: ['consultation', 'diagnosis', 'treatment', 'prescription', 'lab_report', 'imaging'],
    required: true
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  diagnosis: {
    type: String
  },
  treatment: {
    type: String
  },
  medications: [{
    name: String,
    dosage: String,
    frequency: String,
    duration: String
  }],
  vitals: {
    bloodPressure: String,
    heartRate: Number,
    temperature: Number,
    weight: Number,
    height: Number
  },
  labResults: [{
    testName: String,
    result: String,
    normalRange: String,
    unit: String
  }],
  visitDate: {
    type: Date,
    required: true
  },
  followUpDate: {
    type: Date
  },
  severity: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  status: {
    type: String,
    enum: ['active', 'resolved', 'ongoing'],
    default: 'active'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('MedicalRecord', medicalRecordSchema);
