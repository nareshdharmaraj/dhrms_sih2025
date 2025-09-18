const mongoose = require('mongoose');
const Patient = require('./src/models/Patient');
require('dotenv').config();

async function debugPatients() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Find all patients
    const patients = await Patient.find({}).select('-password');
    console.log(`\n📊 Found ${patients.length} patients in database\n`);

    patients.forEach((patient, index) => {
      console.log(`=== Patient ${index + 1} ===`);
      console.log('UHID:', patient.uhid || 'MISSING');
      console.log('Username:', patient.username || 'MISSING');
      console.log('Name:', patient.fullName || 'MISSING');
      console.log('FirstName:', patient.firstName || 'MISSING');
      console.log('LastName:', patient.lastName || 'MISSING');
      console.log('Email:', patient.email || 'MISSING');
      console.log('Phone:', patient.phone || 'MISSING');
      console.log('Aadhaar:', patient.aadhaarNumber || 'MISSING');
      console.log('DOB:', patient.dateOfBirth || 'MISSING');
      console.log('Gender:', patient.gender || 'MISSING');
      console.log('Blood Group:', patient.bloodGroup || 'MISSING');
      console.log('Address:', JSON.stringify(patient.address) || 'MISSING');
      console.log('Emergency Contact:', JSON.stringify(patient.emergencyContact) || 'MISSING');
      console.log('Home State:', patient.homeState || 'MISSING');
      console.log('Registration Date:', patient.registrationDate || 'MISSING');
      console.log('Digital Card:', JSON.stringify(patient.digitalCard) || 'MISSING');
      console.log('Photo Length:', patient.photo ? patient.photo.length : 'MISSING');
      console.log('---\n');
    });

    // Close connection
    await mongoose.connection.close();
    console.log('✅ Database connection closed');

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

debugPatients();