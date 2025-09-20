const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const StateHealthOfficerSchema = new mongoose.Schema({
  // Identity
  officerId: {
    type: String,
    required: true,
    unique: true,
    match: /^SHO_[A-Z]{2}_\d{3}$/ // Format: SHO_TN_001, SHO_KL_002
  },
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
  
  // Password and Security
  password: {
    type: String,
    required: true,
    minlength: 8
  },
  
  // State Assignment
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
  
  // Permissions for SHO
  permissions: {
    // Regional Officer Management
    canManageRegionalOfficers: { type: Boolean, default: true },
    canViewRegionalOfficers: { type: Boolean, default: true },
    
    // Hospital Management in their state
    canManageHospitals: { type: Boolean, default: true },
    canViewHospitals: { type: Boolean, default: true },
    
    // User Management in their state
    canManageUsers: { type: Boolean, default: true },
    canViewUsers: { type: Boolean, default: true },
    
    // Reports and Analytics for their state
    canGenerateReports: { type: Boolean, default: true },
    canExportData: { type: Boolean, default: true },
    canViewAnalytics: { type: Boolean, default: true }
  },
  
  // Status and Management
  isActive: {
    type: Boolean,
    default: true
  },
  lastLogin: {
    type: Date
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'WhoAdmin',
    required: true
  },
  
  // Security
  loginAttempts: {
    type: Number,
    default: 0
  },
  lockUntil: Date,
  
  // Audit
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Virtual for account locked
StateHealthOfficerSchema.virtual('isLocked').get(function() {
  return !!(this.lockUntil && this.lockUntil > Date.now());
});

// Pre-save middleware to hash password
StateHealthOfficerSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Update timestamp on save
StateHealthOfficerSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Instance method to compare password
StateHealthOfficerSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Instance method to increment login attempts
StateHealthOfficerSchema.methods.incLoginAttempts = async function() {
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
StateHealthOfficerSchema.methods.resetLoginAttempts = async function() {
  return this.updateOne({
    $unset: { loginAttempts: 1, lockUntil: 1 }
  });
};

module.exports = mongoose.model('StateHealthOfficer', StateHealthOfficerSchema);
