const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Hospital = require('./src/models/Hospital');
const RegionalOfficer = require('./src/models/RegionalOfficer');
const HospitalAdmin = require('./src/models/HospitalAdmin');
const HospitalDoctor = require('./src/models/HospitalDoctor');
const HospitalAssistant = require('./src/models/HospitalAssistant');

async function checkDatabaseData() {
  try {
    console.log('🔌 Connecting to MongoDB Atlas...');
    
    const mongoURI = process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth';
    await mongoose.connect(mongoURI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB Atlas successfully\n');

    // Check each collection
    const hospitalCount = await Hospital.countDocuments();
    const regionalOfficerCount = await RegionalOfficer.countDocuments();
    const adminCount = await HospitalAdmin.countDocuments();
    const doctorCount = await HospitalDoctor.countDocuments();
    const assistantCount = await HospitalAssistant.countDocuments();

    console.log('📊 Database Collection Counts:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🏥 Hospitals: ${hospitalCount}`);
    console.log(`👨‍💼 Regional Officers: ${regionalOfficerCount}`);
    console.log(`🔧 Hospital Admins: ${adminCount}`);
    console.log(`👨‍⚕️ Doctors: ${doctorCount}`);
    console.log(`👩‍⚕️ Assistants: ${assistantCount}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (hospitalCount > 0) {
      console.log('\n🏥 Hospital Records:');
      const hospitals = await Hospital.find({}, 'hospitalId name location.city location.state').lean();
      hospitals.forEach((hospital, index) => {
        console.log(`${index + 1}. ${hospital.name} (${hospital.hospitalId}) - ${hospital.location?.city}, ${hospital.location?.state}`);
      });
    }

    if (adminCount > 0) {
      console.log('\n👨‍💼 Hospital Admin Records:');
      const admins = await HospitalAdmin.find({}, 'adminId adminName hospitalId email').lean();
      admins.forEach((admin, index) => {
        console.log(`${index + 1}. ${admin.adminName} (${admin.adminId}) - Hospital: ${admin.hospitalId}`);
      });
    }

    if (doctorCount > 0) {
      console.log('\n👨‍⚕️ Doctor Records:');
      const doctors = await HospitalDoctor.find({}, 'doctorId doctorName hospitalId specialization').lean();
      doctors.forEach((doctor, index) => {
        console.log(`${index + 1}. ${doctor.doctorName} (${doctor.doctorId}) - ${doctor.specialization} - Hospital: ${doctor.hospitalId}`);
      });
    }

    if (assistantCount > 0) {
      console.log('\n👩‍⚕️ Assistant Records:');
      const assistants = await HospitalAssistant.find({}, 'assistantId assistantName hospitalId assignedDepartment').lean();
      assistants.forEach((assistant, index) => {
        console.log(`${index + 1}. ${assistant.assistantName} (${assistant.assistantId}) - ${assistant.assignedDepartment} - Hospital: ${assistant.hospitalId}`);
      });
    }

    console.log('\n✅ Database check completed!');

  } catch (error) {
    console.error('❌ Database check failed:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

checkDatabaseData();