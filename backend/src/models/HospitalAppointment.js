const mongoose = require('mongoose');

const hospitalAppointmentSchema = new mongoose.Schema({
  appointmentId: {
    type: String,
    required: true,
    unique: true
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  patientName: {
    type: String,
    required: true
  },
  patientUhid: {
    type: String,
    required: true
  },
  patientGender: {
    type: String,
    enum: ['male', 'female', 'other']
  },
  patientAge: {
    type: Number
  },
  patientState: {
    type: String
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'HospitalDoctor',
    required: true
  },
  doctorName: {
    type: String,
    required: true
  },
  hospitalId: {
    type: String,
    required: true
  },
  hospitalName: {
    type: String,
    required: true
  },
  appointmentDate: {
    type: String, // YYYY-MM-DD format
    required: true
  },
  appointmentTime: {
    type: String, // HH:MM AM/PM format
    required: true
  },
  reason: {
    type: String,
    required: true
  },
  consultationFee: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'completed'],
    default: 'pending'
  },
  bookedAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update the updatedAt field before saving
hospitalAppointmentSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('HospitalAppointment', hospitalAppointmentSchema);