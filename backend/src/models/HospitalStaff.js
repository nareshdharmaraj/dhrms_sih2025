const mongoose = require('mongoose');

const hospitalStaffSchema = new mongoose.Schema({
  // Authentication credentials
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  
  // Universal Health Identity for Staff
  uhi: {
    type: String,
    unique: true,
    trim: true
  },
  
  // Personal Information
  firstName: {
    type: String,
    required: true,
    trim: true
  },
  lastName: {
    type: String,
    required: true,
    trim: true
  },
  fullName: {
    type: String,
    required: true,
    trim: true
  },
  aadhaarNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    validate: {
      validator: function(v) {
        return /^\d{12}$/.test(v);
      },
      message: 'Aadhaar number must be exactly 12 digits'
    }
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  phone: {
    type: String,
    required: true,
    trim: true
  },
  dateOfBirth: {
    type: Date,
    required: true
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other'],
    required: true
  },
  
  // Professional Information
  staffRole: {
    type: String,
    enum: ['doctor', 'nurse', 'admin', 'pharmacist', 'technician', 'assistant'],
    required: true
  },
  department: {
    type: String,
    required: true
  },
  specialization: {
    type: String,
    required: function() {
      return this.staffRole === 'doctor';
    }
  },
  licenseNumber: {
    type: String,
    required: function() {
      return this.staffRole === 'doctor' || this.staffRole === 'nurse';
    }
  },
  yearsOfExperience: {
    type: Number,
    required: true
  },
  
  // Hospital Information
  hospitalName: {
    type: String,
    required: true
  },
  hospitalId: {
    type: String,
    required: true
  },
  hospitalAddress: {
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    zipCode: { type: String, required: true },
    country: { type: String, default: 'India' }
  },
  
  // Work Schedule
  workingHours: {
    startTime: { type: String, required: true }, // e.g., "09:00"
    endTime: { type: String, required: true },   // e.g., "17:00"
    workingDays: [{ type: String, enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'] }]
  },
  
  // Permissions and Access
  permissions: [{
    type: String,
    enum: ['read_patient_records', 'write_patient_records', 'prescribe_medication', 'schedule_appointments', 'view_reports', 'admin_access']
  }],
  
  // Personal Address
  address: {
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    zipCode: { type: String, required: true },
    country: { type: String, default: 'India' }
  },
  
  // System fields
  isActive: {
    type: Boolean,
    default: true
  },
  hireDate: {
    type: Date,
    required: true
  },
  lastLogin: {
    type: Date
  }
});

module.exports = mongoose.model('HospitalStaff', hospitalStaffSchema);
