const mongoose = require('mongoose');
const StateHealthOfficer = require('./src/models/StateHealthOfficer');

// Connect to MongoDB
async function checkSHOData() {
  try {
    console.log('🔍 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');

    // Find all SHOs
    const shos = await StateHealthOfficer.find({}).select('-password');
    console.log('📋 All SHOs in database:');
    console.log(JSON.stringify(shos, null, 2));

    // Find the test SHO specifically
    const testSHO = await StateHealthOfficer.findOne({ 
      $or: [
        { email: 'test.sho@tn.gov.in' },
        { officerId: 'SHO_TN_999' }
      ]
    });
    
    if (testSHO) {
      console.log('🔍 Test SHO found:');
      console.log({
        officerId: testSHO.officerId,
        email: testSHO.email,
        username: testSHO.username,
        isActive: testSHO.isActive,
        isLocked: testSHO.isLocked,
        loginAttempts: testSHO.loginAttempts,
        assignedState: testSHO.assignedState
      });
      
      // Test password comparison
      const testPassword = 'TestPassword@123';
      console.log('🔍 Testing password comparison for:', testPassword);
      const isValidPassword = await testSHO.comparePassword(testPassword);
      console.log('🔍 Password comparison result:', isValidPassword);
    } else {
      console.log('❌ Test SHO not found');
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

checkSHOData();