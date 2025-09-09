const mongoose = require('mongoose');

const regionalOfficerSchema = new mongoose.Schema({
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
  
  // Universal Health Identity for Officers
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
  
  // Official Information
  officerRank: {
    type: String,
    enum: ['assistant_health_officer', 'health_officer', 'district_health_officer', 'state_health_officer', 'regional_director'],
    required: true
  },
  employeeId: {
    type: String,
    required: true,
    unique: true
  },
  department: {
    type: String,
    default: 'Health Department',
    required: true
  },
  
  // Jurisdiction Information
  assignedRegion: {
    type: String,
    required: true
  },
  assignedDistricts: [{
    type: String,
    required: true
  }],
  assignedStates: [{
    type: String,
    required: true
  }],
  jurisdictionLevel: {
    type: String,
    enum: ['district', 'state', 'regional', 'national'],
    required: true
  },
  
  // Office Information
  officeAddress: {
    buildingName: { type: String, required: true },
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    zipCode: { type: String, required: true },
    country: { type: String, default: 'India' }
  },
  officePhone: {
    type: String,
    required: true
  },
  
  // Responsibilities
  responsibilities: [{
    type: String,
    enum: [
      'health_monitoring', 
      'disease_surveillance', 
      'policy_implementation', 
      'hospital_oversight', 
      'migrant_health_coordination',
      'data_analysis',
      'resource_allocation',
      'emergency_response'
    ]
  }],
  
  // Clearance and Access Levels
  clearanceLevel: {
    type: String,
    enum: ['basic', 'intermediate', 'advanced', 'top_secret'],
    required: true
  },
  accessPermissions: [{
    type: String,
    enum: [
      'view_regional_data',
      'view_hospital_data', 
      'view_patient_statistics',
      'generate_reports',
      'policy_management',
      'resource_management',
      'emergency_coordination'
    ]
  }],
  
  // Personal Address
  address: {
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    zipCode: { type: String, required: true },
    country: { type: String, default: 'India' }
  },
  
  // Professional Background
  yearsOfService: {
    type: Number,
    required: true
  },
  previousPostings: [{
    location: String,
    position: String,
    duration: String
  }],
  
  // System fields
  isActive: {
    type: Boolean,
    default: true
  },
  appointmentDate: {
    type: Date,
    required: true
  },
  lastLogin: {
    type: Date
  }
});

module.exports = mongoose.model('RegionalOfficer', regionalOfficerSchema);
