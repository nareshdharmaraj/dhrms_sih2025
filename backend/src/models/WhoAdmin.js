const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const whoAdminSchema = new mongoose.Schema({
  adminId: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 20
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    minlength: 3,
    maxlength: 20
  },
  fullName: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 100
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
  },
  phone: {
    type: String,
    required: true,
    match: [/^\+?[\d\s-()]{10,}$/, 'Please enter a valid phone number']
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  designation: {
    type: String,
    required: true,
    enum: [
      'WHO Director-General',
      'Regional Director',
      'Country Representative',
      'Technical Officer',
      'Health Systems Analyst',
      'Data Manager',
      'Policy Advisor'
    ],
    default: 'Technical Officer'
  },
  region: {
    type: String,
    required: true,
    enum: [
      'Global',
      'South-East Asia',
      'Western Pacific',
      'Americas',
      'Europe',
      'Africa',
      'Eastern Mediterranean'
    ],
    default: 'South-East Asia'
  },
  managedStates: [{
    type: String,
    enum: [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
      'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
      'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
      'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
    ]
  }],
  permissions: {
    canViewAllStates: { type: Boolean, default: true },
    canManageRegionalOfficers: { type: Boolean, default: true },
    canGenerateReports: { type: Boolean, default: true },
    canExportData: { type: Boolean, default: true },
    canManageHospitals: { type: Boolean, default: false }, // Only view access
    canAccessAnalytics: { type: Boolean, default: true },
    canManageUsers: { type: Boolean, default: false },
    
    // SHO Management permissions
    canManageStateOfficers: { type: Boolean, default: true },
    canViewStateOfficers: { type: Boolean, default: true }
  },
  securityClearance: {
    type: String,
    enum: ['Basic', 'Confidential', 'Secret', 'Top Secret'],
    default: 'Confidential'
  },
  lastLogin: {
    type: Date,
    default: null
  },
  loginAttempts: {
    type: Number,
    default: 0
  },
  accountLocked: {
    type: Boolean,
    default: false
  },
  lockUntil: {
    type: Date,
    default: null
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'WhoAdmin',
    default: null
  }
}, {
  timestamps: true,
  toJSON: {
    transform: function(doc, ret) {
      delete ret.password;
      delete ret.loginAttempts;
      delete ret.__v;
      return ret;
    }
  }
});

// Indexes
whoAdminSchema.index({ adminId: 1 });
whoAdminSchema.index({ username: 1 });
whoAdminSchema.index({ email: 1 });
whoAdminSchema.index({ region: 1 });
whoAdminSchema.index({ managedStates: 1 });
whoAdminSchema.index({ isActive: 1 });

// Pre-save middleware to hash password
whoAdminSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Method to compare password
whoAdminSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Method to check if account is locked
whoAdminSchema.methods.isLocked = function() {
  return !!(this.accountLocked && this.lockUntil && this.lockUntil > Date.now());
};

// Method to increment login attempts
whoAdminSchema.methods.incLoginAttempts = function() {
  const MAX_LOGIN_ATTEMPTS = 5;
  const LOCK_TIME = 2 * 60 * 60 * 1000; // 2 hours

  // If we have a previous lock that has expired, restart at 1
  if (this.lockUntil && this.lockUntil < Date.now()) {
    return this.updateOne({
      $unset: { lockUntil: 1 },
      $set: { loginAttempts: 1, accountLocked: false }
    });
  }

  const updates = { $inc: { loginAttempts: 1 } };

  // If we've exceeded max attempts and it's not locked yet, lock the account
  if (this.loginAttempts + 1 >= MAX_LOGIN_ATTEMPTS && !this.isLocked()) {
    updates.$set = {
      lockUntil: Date.now() + LOCK_TIME,
      accountLocked: true
    };
  }

  return this.updateOne(updates);
};

// Method to reset login attempts
whoAdminSchema.methods.resetLoginAttempts = function() {
  return this.updateOne({
    $unset: { loginAttempts: 1, lockUntil: 1 },
    $set: { accountLocked: false, lastLogin: new Date() }
  });
};

// Static method to find active admins
whoAdminSchema.statics.findActive = function() {
  return this.find({ isActive: true });
};

// Static method to find by region
whoAdminSchema.statics.findByRegion = function(region) {
  return this.find({ region, isActive: true });
};

// Static method to find by managed states
whoAdminSchema.statics.findByState = function(state) {
  return this.find({ managedStates: state, isActive: true });
};

module.exports = mongoose.model('WhoAdmin', whoAdminSchema);