const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const RegionalHealthOfficerSchema = new mongoose.Schema({
  // Identity & Authentication
  officerId: {
    type: String,
    required: true,
    unique: true,
    match: /^RHO_[A-Za-z\s]+_\d{3}(-[A-Z]{3})?$/ // Format: RHO_Chennai_001 or RHO_CHENNAI_001-AMB
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  password: {
    type: String,
    required: true,
    minlength: 8
  },
  
  // Personal Information
  fullName: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  phone: {
    type: String,
    required: true
  },
  
  // Regional Assignment - District-wise
  assignedState: {
    type: String,
    required: true,
    enum: [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
      'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
      'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
      'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
      'West Bengal'
    ]
  },
  assignedDistrict: {
    type: String,
    required: true,
    trim: true
  },
  assignedRegion: {
    type: String,
    required: true,
    trim: true
  },
  regionCode: {
    type: String,
    required: true,
    trim: true
  },
  districtCode: {
    type: String,
    required: true,
    trim: true
  },
  
  // Specific Areas Assignment (for dense districts)
  assignedAreas: [{
    name: { type: String, required: true }, // e.g., "Ambattur", "Sholinganallur"
    code: { type: String, required: true }, // e.g., "AMB", "SGL"
    type: { type: String, enum: ['area', 'full-district'], default: 'area' },
    population: { type: Number, default: 0 },
    areaKm2: { type: Number, default: 0 }
  }],
  
  // Hierarchy - Managed by SHO
  parentSHO: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'StateHealthOfficer',
    required: true
  },
  
  // Permissions for RHO
  permissions: {
    // Hospital Management
    canViewHospitals: { type: Boolean, default: true },
    canManageHospitalStaff: { type: Boolean, default: true },
    canViewHospitalReports: { type: Boolean, default: true },
    
    // Patient Data Access
    canViewPatientData: { type: Boolean, default: true },
    canAccessMedicalRecords: { type: Boolean, default: false },
    
    // Regional Reporting
    canGenerateReports: { type: Boolean, default: true },
    canViewRegionalStats: { type: Boolean, default: true },
    
    // Emergency Response
    canInitiateEmergencyResponse: { type: Boolean, default: true },
    canAccessEmergencyContacts: { type: Boolean, default: true },
    
    // System Access
    canManageProfile: { type: Boolean, default: true },
    canChangePassword: { type: Boolean, default: true }
  },
  
  // Staff and Resource Limits
  staffLimits: {
    maxDirectStaff: { type: Number, default: 50 },
    maxHospitalsOversight: { type: Number, default: 20 },
    maxRegionsManaged: { type: Number, default: 5 }
  },
  
  // Coverage Area Details - District-focused
  coverage: {
    primaryDistrict: { type: String, required: true }, // Main district assigned
    subDistricts: [{ type: String }], // Sub-districts/tehsils under the main district
    blocks: [{ type: String }], // Administrative blocks
    villages: [{ type: String }], // Villages covered
    hospitals: [{ 
      type: mongoose.Schema.Types.ObjectId, 
      ref: 'Hospital' 
    }],
    primaryHealthCenters: [{ type: String }], // PHCs in the district
    communityHealthCenters: [{ type: String }], // CHCs in the district
    population: { type: Number, default: 0 },
    areaKm2: { type: Number, default: 0 },
    ruralPopulation: { type: Number, default: 0 },
    urbanPopulation: { type: Number, default: 0 }
  },
  
  // Performance Statistics
  statistics: {
    totalStaffManaged: { type: Number, default: 0 },
    hospitalsOverseen: { type: Number, default: 0 },
    patientsServed: { type: Number, default: 0 },
    emergencyResponsesHandled: { type: Number, default: 0 },
    reportsGenerated: { type: Number, default: 0 },
    lastReportDate: { type: Date },
    performanceRating: { type: Number, min: 1, max: 5, default: 3 }
  },
  
  // Office Information
  officeAddress: {
    buildingName: { type: String },
    street: { type: String },
    city: { type: String, required: true },
    state: { type: String, required: true },
    zipCode: { type: String },
    country: { type: String, default: 'India' }
  },
  officePhone: {
    type: String
  },
  
  // Emergency Contact
  emergencyContact: {
    name: { type: String },
    relationship: { type: String },
    phone: { type: String },
    email: { type: String }
  },
  
  // Professional Details
  qualification: {
    type: String,
    required: true
  },
  experience: {
    type: Number, // years
    required: true
  },
  licenseNumber: {
    type: String,
    required: true,
    unique: true
  },
  department: {
    type: String,
    default: 'Regional Health Department'
  },
  
  // System Status
  isActive: {
    type: Boolean,
    default: true
  },
  emailVerified: {
    type: Boolean,
    default: false
  },
  profileCompleted: {
    type: Boolean,
    default: false
  },
  
  // Security
  loginAttempts: {
    type: Number,
    default: 0
  },
  lockUntil: {
    type: Date
  },
  lastLogin: {
    type: Date
  },
  
  // Session Management
  sessions: [{
    token: String,
    createdAt: { type: Date, default: Date.now },
    expiresAt: Date,
    deviceInfo: String
  }],
  
  // Audit Trail
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'StateHealthOfficer',
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Virtual for account lock status
RegionalHealthOfficerSchema.virtual('isLocked').get(function() {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

// Generate username from officerId if not provided (must be before password hashing)
RegionalHealthOfficerSchema.pre('save', function(next) {
  if (!this.username && this.officerId) {
    this.username = this.officerId.toLowerCase().replace(/_/g, '');
  }
  next();
});

// Hash password before saving
RegionalHealthOfficerSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Instance method to compare passwords
RegionalHealthOfficerSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Instance method to increment login attempts
RegionalHealthOfficerSchema.methods.incrementLoginAttempts = async function() {
  // If we have a previous lock that has expired, restart at 1
  if (this.lockUntil && this.lockUntil < Date.now()) {
    return this.updateOne({
      $unset: { lockUntil: 1 },
      $set: { loginAttempts: 1 }
    });
  }
  
  const updates = { $inc: { loginAttempts: 1 } };
  
  // Lock account after 5 failed attempts for 2 hours
  if (this.loginAttempts + 1 >= 5 && !this.isLocked) {
    updates.$set = {
      lockUntil: Date.now() + 2 * 60 * 60 * 1000 // 2 hours
    };
  }
  
  return this.updateOne(updates);
};

// Instance method to reset login attempts
RegionalHealthOfficerSchema.methods.resetLoginAttempts = async function() {
  return this.updateOne({
    $unset: { loginAttempts: 1, lockUntil: 1 }
  });
};

// Static method to find RHOs by district
RegionalHealthOfficerSchema.statics.findByDistrict = function(district, state) {
  return this.find({ 
    assignedDistrict: district,
    assignedState: state,
    isActive: true 
  }).populate('parentSHO', 'fullName officerId');
};

// Static method to find active RHOs by state
RegionalHealthOfficerSchema.statics.findByState = function(state) {
  return this.find({ 
    assignedState: state, 
    isActive: true 
  }).populate('parentSHO', 'fullName officerId');
};

// Static method to find RHOs by SHO
RegionalHealthOfficerSchema.statics.findBySHO = function(shoId) {
  return this.find({ 
    parentSHO: shoId, 
    isActive: true 
  }).sort({ createdAt: -1 });
};

module.exports = mongoose.model('RegionalHealthOfficer', RegionalHealthOfficerSchema);
