const mongoose = require('mongoose');
const StateHealthOfficer = require('./src/models/StateHealthOfficer');

// Create a Kerala SHO for testing
async function createKeralaSHO() {
  try {
    console.log('🔍 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');

    // Clean up any existing Kerala SHO
    console.log('🧹 Cleaning up existing Kerala SHO...');
    await StateHealthOfficer.deleteMany({ 
      $or: [
        { email: 'sho.kerala@myhealth.gov.in' },
        { officerId: 'SHO_KL_001' },
        { assignedState: 'Kerala' }
      ]
    });

    // Create new Kerala SHO
    console.log('👤 Creating new Kerala SHO...');
    const keralaSHO = new StateHealthOfficer({
      officerId: 'SHO_KL_001',
      username: 'sho_kerala_001',
      fullName: 'Dr. Kerala State Health Officer',
      email: 'sho.kerala@myhealth.gov.in',
      phone: '+91-9876543210',
      password: 'TestPassword@123', // Will be hashed by pre-save middleware
      assignedState: 'Kerala',
      designation: 'State Health Officer',
      permissions: {
        canManageRegionalOfficers: true,
        canViewRegionalOfficers: true,
        canManageHospitals: true,
        canViewHospitals: true,
        canManageUsers: true,
        canViewUsers: true,
        canGenerateReports: true,
        canExportData: true,
        canViewAnalytics: true,
        canManageProfile: true,
        canChangePassword: true
      },
      createdBy: new mongoose.Types.ObjectId(), // Dummy WHO admin ID
      isActive: true,
      loginAttempts: 0,
      isLocked: false
    });

    await keralaSHO.save();
    console.log('✅ Kerala SHO created successfully:', keralaSHO.officerId);
    
    // Verify the SHO was created
    const savedSHO = await StateHealthOfficer.findById(keralaSHO._id).select('-password');
    console.log('📋 Saved Kerala SHO details:', JSON.stringify(savedSHO, null, 2));

    // Test password comparison
    console.log('🔍 Testing password comparison...');
    const isValidPassword = await keralaSHO.comparePassword('TestPassword@123');
    console.log('🔍 Password comparison result:', isValidPassword);

    console.log('\n✅ Kerala SHO created successfully!');
    console.log('\n📋 Login credentials:');
    console.log('Username: sho_kerala_001');
    console.log('Email: sho.kerala@myhealth.gov.in');
    console.log('Password: TestPassword@123');
    console.log('State: Kerala');

  } catch (error) {
    console.error('❌ Error creating Kerala SHO:', error);
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

createKeralaSHO();