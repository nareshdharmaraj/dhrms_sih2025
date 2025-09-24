const mongoose = require('mongoose');

async function checkAdmin() {
  try {
    // Connect to MongoDB (use localhost like the server)
    await mongoose.connect('mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');

    // Import models
    const HospitalAdmin = require('./src/models/HospitalAdmin');
    const Hospital = require('./src/models/Hospital');

    // Check for existing hospitals and admins
    const hospitals = await Hospital.find({});
    console.log('Hospitals found:', hospitals.length);

    if (hospitals.length > 0) {
      console.log('First hospital:', {
        hospitalId: hospitals[0].hospitalId,
        name: hospitals[0].name,
        status: hospitals[0].status
      });
    }

    const admins = await HospitalAdmin.find({});
    console.log('Admins found:', admins.length);

    if (admins.length > 0) {
      console.log('First admin:', {
        adminId: admins[0].adminId,
        hospitalId: admins[0].hospitalId,
        username: admins[0].username,
        isActive: admins[0].isActive
      });
    }

    // Check doctors
    const HospitalDoctor = require('./src/models/HospitalDoctor');
    const doctors = await HospitalDoctor.find({});
    console.log('Doctors found:', doctors.length);

    if (doctors.length > 0) {
      console.log('Sample doctor fields:', {
        doctorId: doctors[0].doctorId,
        name: doctors[0].name,
        doctorName: doctors[0].doctorName,
        gender: doctors[0].gender,
        specializations: doctors[0].specializations,
        experienceYears: doctors[0].experienceYears
      });
    }

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await mongoose.disconnect();
  }
}

checkAdmin();