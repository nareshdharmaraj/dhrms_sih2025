const mongoose = require('mongoose');
const databaseService = require('./src/services/databaseService');
require('dotenv').config();

async function testLogin() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Test login with your patient credentials
    console.log('\n🧪 Testing login for UHID: SARD029205');
    
    const loginResult = await databaseService.validateUserCredentials('SARD029205', 'sar1234');
    
    console.log('\n📊 Login Result:');
    console.log('Success:', loginResult.success);
    console.log('User Type:', loginResult.userType);
    console.log('User Data:', JSON.stringify(loginResult.user, null, 2));
    
    if (loginResult.patientData) {
      console.log('\n👤 Patient Data:');
      console.log('UHID:', loginResult.patientData.uhid);
      console.log('Full Name:', loginResult.patientData.fullName);
      console.log('Blood Group:', loginResult.patientData.bloodGroup);
      console.log('Date of Birth:', loginResult.patientData.dateOfBirth);
      console.log('Email:', loginResult.patientData.email);
      console.log('Phone:', loginResult.patientData.phone);
      console.log('Address:', JSON.stringify(loginResult.patientData.address, null, 2));
      console.log('Emergency Contact:', JSON.stringify(loginResult.patientData.emergencyContact, null, 2));
      console.log('Home State:', loginResult.patientData.homeState);
    } else {
      console.log('❌ No patient data returned');
    }

    // Close connection
    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

testLogin();