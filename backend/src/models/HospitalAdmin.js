const mongoose = require('mongoose');

const hospitalAdminSchema = new mongoose.Schema({
  adminId: {
    type: String,
    required: true,
    unique: true
  },
  
  hospitalId: {
    type: String,
    required: true,
    ref: 'Hospital'
  },
  
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 50
  },
  
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  
  adminName: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  
  email: {
    type: String,
    required: true,
    lowercase: true,
    match: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  },
  
  contactNumber: {
    type: String,
    required: true,
    match: /^[6-9]\d{9}$/
  },
  
  designation: {
    type: String,
    default: 'Hospital Administrator'
  },
  
  department: {
    type: String,
    default: 'Administration'
  },
  
  qualification: {
    type: String,
    trim: true
  },
  
  experience: {
    type: Number,
    min: 0,
    default: 0
  },
  
  permissions: {
    canCreateDoctors: {
      type: Boolean,
      default: true
    },
    canCreateAssistants: {
      type: Boolean,
      default: true
    },
    canManageHospital: {
      type: Boolean,
      default: true
    },
    canViewReports: {
      type: Boolean,
      default: true
    }
  },
  
  lastLogin: {
    type: Date
  },
  
  loginAttempts: {
    type: Number,
    default: 0
  },
  
  isActive: {
    type: Boolean,
    default: true
  },
  
  isLocked: {
    type: Boolean,
    default: false
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Pre-save middleware
hospitalAdminSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Indexes
hospitalAdminSchema.index({ adminId: 1 });
hospitalAdminSchema.index({ hospitalId: 1 });
hospitalAdminSchema.index({ username: 1 });
hospitalAdminSchema.index({ email: 1 });
hospitalAdminSchema.index({ isActive: 1 });

// Static methods
hospitalAdminSchema.statics.findByHospital = function(hospitalId) {
  return this.findOne({ hospitalId, isActive: true });
};

hospitalAdminSchema.statics.findByUsername = function(username) {
  return this.findOne({ username, isActive: true });
};

// Instance methods
hospitalAdminSchema.methods.updateLastLogin = function() {
  this.lastLogin = new Date();
  this.loginAttempts = 0;
  return this.save();
};

hospitalAdminSchema.methods.incrementLoginAttempts = function() {
  this.loginAttempts += 1;
  if (this.loginAttempts >= 5) {
    this.isLocked = true;
  }
  return this.save();
};

module.exports = mongoose.model('HospitalAdmin', hospitalAdminSchema);