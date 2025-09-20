const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: '.env.local' });

// Models
const WhoAdmin = require('../src/models/WhoAdmin');

async function connectToDatabase() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    throw error;
  }
}

async function fixWhoAdminPermissions() {
  console.log('\n🔧 Fixing WHO Admin Permissions...');
  
  const whoAdmin = await WhoAdmin.findOne({ adminId: 'WHO_ADMIN_001' });
  
  if (!whoAdmin) {
    console.log('❌ WHO Admin not found');
    return;
  }
  
  // Update permissions for correct hierarchy
  whoAdmin.permissions = {
    // Dashboard and Analytics
    canAccessAnalytics: true,
    canViewAllStates: true,
    canExportData: true,
    canGenerateReports: true,
    
    // WHO Admin manages SHOs (State Health Officers)
    canManageStateOfficers: true,  // NEW: Manage SHOs
    canViewStateOfficers: true,    // NEW: View SHOs
    
    // WHO should NOT directly manage Regional Officers
    canManageRegionalOfficers: false,  // CHANGED: Remove direct access
    canViewRegionalOfficers: true,     // Can view but not manage
    
    // Hospital oversight (read-only)
    canViewHospitals: true,
    canManageHospitals: false,  // SHOs manage hospitals
    
    // User management (limited)
    canManageUsers: false,  // SHOs manage users in their states
    canViewUsers: true
  };
  
  await whoAdmin.save();
  console.log('✅ WHO Admin permissions updated');
  console.log('📋 New permissions:', whoAdmin.permissions);
}

async function createSHOSchema() {
  console.log('\n🔧 Creating SHO (State Health Officer) Schema...');
  
  // SHO Model Schema (we'll need to create this)
  const shoSchemaDefinition = `
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const StateHealthOfficerSchema = new mongoose.Schema({
  // Identity
  officerId: {
    type: String,
    required: true,
    unique: true,
    match: /^SHO_[A-Z]{2}_\\d{3}$/ // Format: SHO_TN_001, SHO_KL_002
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
  `;
  
  console.log('📋 SHO Schema definition ready');
  console.log('📝 Create file: src/models/StateHealthOfficer.js');
  console.log(shoSchemaDefinition);
}

async function main() {
  try {
    console.log('🚀 Starting WHO Hierarchy Fix...');
    
    await connectToDatabase();
    await fixWhoAdminPermissions();
    await createSHOSchema();
    
    console.log('\n✅ WHO Hierarchy Fix Complete!');
    console.log('\n📋 Summary:');
    console.log('1. ✅ WHO Admin permissions updated');
    console.log('2. 📝 SHO Schema definition provided');
    console.log('3. 🔄 Hierarchy: WHO -> SHO -> Regional Officers');
    
    console.log('\n📋 Next Steps:');
    console.log('1. Create src/models/StateHealthOfficer.js with the schema above');
    console.log('2. Create SHO management routes and controllers');
    console.log('3. Update WHO dashboard to show SHO management');
    console.log('4. Update permissions middleware');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
    process.exit(0);
  }
}

main();