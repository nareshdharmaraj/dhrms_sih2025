const mongoose = require('mongoose');
const HospitalDoctor = require('./src/models/HospitalDoctor');
require('dotenv').config();

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth')
.then(async () => {
  console.log('Connected to database');
  
  // Check all doctors
  const doctors = await HospitalDoctor.find({}).limit(5);
  console.log('Total doctors found:', doctors.length);
  
  doctors.forEach(doctor => {
    console.log(`Doctor: ${doctor.doctorName || doctor.name} - Hospital ID: ${doctor.hospitalId}`);
  });
  
  // Check doctors for specific hospital IDs
  const doctorsForHOSP001 = await HospitalDoctor.find({ hospitalId: 'HOSP-001' });
  console.log('\nDoctors for HOSP-001:', doctorsForHOSP001.length);
  
  const doctorsForHOSPTEST001 = await HospitalDoctor.find({ hospitalId: 'HOSP_TEST_001' });
  console.log('Doctors for HOSP_TEST_001:', doctorsForHOSPTEST001.length);
  
  process.exit(0);
})
.catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});