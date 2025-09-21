const mongoose = require('mongoose');
const StateHealthOfficer = require('./src/models/StateHealthOfficer');

// Create a test SHO
async function createTestSHO() {
  try {
    console.log('🔍 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');

    // Clean up any existing test SHO
    console.log('🧹 Cleaning up existing test SHO...');
    await StateHealthOfficer.deleteMany({ 
      $or: [
        { email: 'test.sho@tn.gov.in' },
        { officerId: 'SHO_TN_999' }
      ]
    });

    // Create new test SHO
    console.log('👤 Creating new test SHO...');
    const testSHO = new StateHealthOfficer({
      officerId: 'SHO_TN_999',
      username: 'test_sho_tn',
      fullName: 'Dr. Test SHO Tamil Nadu',
      email: 'test.sho@tn.gov.in',
      phone: '+91-9000000001',
      password: 'TestPassword@123', // Will be hashed by pre-save middleware
      assignedState: 'Tamil Nadu',
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

    await testSHO.save();
    console.log('✅ Test SHO created successfully:', testSHO.officerId);
    
    // Verify the SHO was created
    const savedSHO = await StateHealthOfficer.findById(testSHO._id).select('-password');
    console.log('📋 Saved SHO details:', JSON.stringify(savedSHO, null, 2));

    // Test password comparison
    console.log('🔍 Testing password comparison...');
    const isValidPassword = await testSHO.comparePassword('TestPassword@123');
    console.log('🔍 Password comparison result:', isValidPassword);

  } catch (error) {
    console.error('❌ Error creating test SHO:', error);
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

createTestSHO();