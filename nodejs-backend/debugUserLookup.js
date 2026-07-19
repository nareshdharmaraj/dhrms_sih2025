// Debug script to check user lookups and password comparison
const mongoose = require('mongoose');
require('dotenv').config();

const Hospital = require('./models/Hospital');
const Doctor = require('./models/Doctor');
const Patient = require('./models/Patient');

async function debugAuth() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms_db');
    console.log('🍃 Connected to MongoDB for debugging\n');

    // Test Patient lookup
    console.log('🔍 Testing Patient lookup...');
    const patient = await Patient.findOne({ 'credentials.username': 'rajesh_kumar_90' });
    
    if (patient) {
      console.log('✅ Patient found:');
      console.log('  - ID:', patient._id);
      console.log('  - Username:', patient.credentials.username);
      console.log('  - Password (stored):', patient.credentials.password);
      console.log('  - Password type:', typeof patient.credentials.password);
      console.log('  - Is Active:', patient.credentials.isActive);
      
      // Test password comparison
      const testPassword = 'patient123';
      console.log('  - Test password:', testPassword);
      console.log('  - Test password type:', typeof testPassword);
      
      const isMatch = await patient.comparePassword(testPassword);
      console.log('  - Password match result:', isMatch);
      
      // Manual comparison
      const manualMatch = testPassword === patient.credentials.password;
      console.log('  - Manual comparison:', manualMatch);
    } else {
      console.log('❌ Patient not found');
      
      // Check what patients exist
      const allPatients = await Patient.find({}, 'credentials.username personalInfo.firstName personalInfo.lastName');
      console.log('Available patients:');
      allPatients.forEach(p => {
        console.log(`  - Username: ${p.credentials.username}, Name: ${p.personalInfo.firstName} ${p.personalInfo.lastName}`);
      });
    }

    // Test Hospital lookup
    console.log('\n🔍 Testing Hospital lookup...');
    const hospital = await Hospital.findOne({ 'credentials.username': 'apollo_admin' });
    
    if (hospital) {
      console.log('✅ Hospital found:');
      console.log('  - ID:', hospital._id);
      console.log('  - Username:', hospital.credentials.username);
      console.log('  - Password (stored):', hospital.credentials.password);
      console.log('  - Is Active:', hospital.credentials.isActive);
      
      const isMatch = await hospital.comparePassword('apollo123');
      console.log('  - Password match result:', isMatch);
    } else {
      console.log('❌ Hospital not found');
      
      const allHospitals = await Hospital.find({}, 'credentials.username name');
      console.log('Available hospitals:');
      allHospitals.forEach(h => {
        console.log(`  - Username: ${h.credentials.username}, Name: ${h.name}`);
      });
    }

    // Test Doctor lookup
    console.log('\n🔍 Testing Doctor lookup...');
    const doctor = await Doctor.findOne({ 'credentials.username': 'dr_rajesh_sharma' });
    
    if (doctor) {
      console.log('✅ Doctor found:');
      console.log('  - ID:', doctor._id);
      console.log('  - Username:', doctor.credentials.username);
      console.log('  - Password (stored):', doctor.credentials.password);
      console.log('  - Is Active:', doctor.credentials.isActive);
      
      const isMatch = await doctor.comparePassword('doctor123');
      console.log('  - Password match result:', isMatch);
    } else {
      console.log('❌ Doctor not found');
      
      const allDoctors = await Doctor.find({}, 'credentials.username personalInfo.firstName personalInfo.lastName');
      console.log('Available doctors:');
      allDoctors.forEach(d => {
        console.log(`  - Username: ${d.credentials.username}, Name: ${d.personalInfo.firstName} ${d.personalInfo.lastName}`);
      });
    }

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n👋 Database connection closed');
  }
}

debugAuth();
