const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Patient = require('./models/Patient');
const bcrypt = require('bcryptjs');

async function testPatientAuthentication() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get all patients
    const patients = await Patient.find({});
    console.log(`📋 Found ${patients.length} patients in database:`);

    for (const patient of patients) {
      console.log(`\n👤 Patient: ${patient.personalInfo.firstName} ${patient.personalInfo.lastName}`);
      console.log(`   Patient ID: ${patient.patientId}`);
      console.log(`   Username: ${patient.credentials.username}`);
      console.log(`   Email: ${patient.personalInfo.email}`);
      console.log(`   Phone: ${patient.personalInfo.phone}`);
      console.log(`   Active: ${patient.credentials.isActive}`);
      console.log(`   Verified: ${patient.credentials.isVerified}`);
      
      // Test password verification
      const testPassword = 'patient123';
      const isPasswordValid = await bcrypt.compare(testPassword, patient.credentials.password);
      console.log(`   Password '${testPassword}' valid: ${isPasswordValid}`);
      
      if (!isPasswordValid) {
        console.log(`   Actual password hash: ${patient.credentials.password}`);
      }
    }

    // Test specific patient credentials that should work with frontend
    console.log('\n🔐 Testing Authentication Credentials:');
    const testCredentials = [
      { username: 'rajesh_kumar_90', password: 'patient123' },
      { username: 'meera_nair_85', password: 'patient123' },
      { username: 'arun_pillai_75', password: 'patient123' },
      { username: 'sita_sharma_92', password: 'patient123' },
      { username: 'arjun_kumar_88', password: 'patient123' }
    ];

    for (const cred of testCredentials) {
      const patient = await Patient.findOne({ 'credentials.username': cred.username });
      if (patient) {
        const isValid = await bcrypt.compare(cred.password, patient.credentials.password);
        console.log(`✅ ${cred.username} / ${cred.password} -> ${isValid ? 'VALID' : 'INVALID'}`);
      } else {
        console.log(`❌ ${cred.username} -> NOT FOUND`);
      }
    }

    console.log('\n🎯 Authentication Summary:');
    console.log('These credentials should work in the Flutter app:');
    console.log('Role: Normal User (user)');
    for (const cred of testCredentials) {
      console.log(`   Username: ${cred.username}, Password: ${cred.password}`);
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n👋 Disconnected from MongoDB');
  }
}

testPatientAuthentication();
