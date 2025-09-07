const mongoose = require('mongoose');

async function checkDatabase() {
  try {
    console.log('🔍 Checking database contents...');
    
    // Connect to MongoDB
    await mongoose.connect('mongodb://naresh:123456789@localhost:27017/myhealth?authSource=admin');
    console.log('✅ Connected to MongoDB');

    // Get all collections
    const collections = await mongoose.connection.db.listCollections().toArray();
    console.log('\n📊 Available Collections:');
    collections.forEach(col => console.log(`   - ${col.name}`));

    // Check patients collection specifically
    console.log('\n👥 Checking Patients Collection:');
    const patientsCollection = mongoose.connection.db.collection('patients');
    const patientCount = await patientsCollection.countDocuments();
    console.log(`   Total patients: ${patientCount}`);

    if (patientCount > 0) {
      console.log('\n📋 Sample patient records:');
      const samplePatients = await patientsCollection.find({}, { 
        'credentials.username': 1, 
        'personalInfo.firstName': 1, 
        'personalInfo.lastName': 1,
        'credentials.isActive': 1 
      }).limit(5).toArray();
      
      samplePatients.forEach((patient, index) => {
        console.log(`   ${index + 1}. Username: ${patient.credentials?.username || 'N/A'}`);
        console.log(`      Name: ${patient.personalInfo?.firstName || 'N/A'} ${patient.personalInfo?.lastName || 'N/A'}`);
        console.log(`      Active: ${patient.credentials?.isActive || 'N/A'}`);
        console.log('      ---');
      });
    }

    // Check doctors collection
    console.log('\n👨‍⚕️ Checking Doctors Collection:');
    const doctorsCollection = mongoose.connection.db.collection('doctors');
    const doctorCount = await doctorsCollection.countDocuments();
    console.log(`   Total doctors: ${doctorCount}`);

    if (doctorCount > 0) {
      console.log('\n📋 Sample doctor records:');
      const sampleDoctors = await doctorsCollection.find({}, { 
        'credentials.username': 1, 
        'personalInfo.firstName': 1, 
        'personalInfo.lastName': 1,
        'credentials.isActive': 1 
      }).limit(3).toArray();
      
      sampleDoctors.forEach((doctor, index) => {
        console.log(`   ${index + 1}. Username: ${doctor.credentials?.username || 'N/A'}`);
        console.log(`      Name: ${doctor.personalInfo?.firstName || 'N/A'} ${doctor.personalInfo?.lastName || 'N/A'}`);
        console.log(`      Active: ${doctor.credentials?.isActive || 'N/A'}`);
        console.log('      ---');
      });
    }

    // Check hospitals collection
    console.log('\n🏥 Checking Hospitals Collection:');
    const hospitalsCollection = mongoose.connection.db.collection('hospitals');
    const hospitalCount = await hospitalsCollection.countDocuments();
    console.log(`   Total hospitals: ${hospitalCount}`);

    if (hospitalCount > 0) {
      console.log('\n📋 Sample hospital records:');
      const sampleHospitals = await hospitalsCollection.find({}, { 
        'credentials.username': 1, 
        'name': 1,
        'credentials.isActive': 1 
      }).limit(3).toArray();
      
      sampleHospitals.forEach((hospital, index) => {
        console.log(`   ${index + 1}. Username: ${hospital.credentials?.username || 'N/A'}`);
        console.log(`      Name: ${hospital.name || 'N/A'}`);
        console.log(`      Active: ${hospital.credentials?.isActive || 'N/A'}`);
        console.log('      ---');
      });
    }

  } catch (error) {
    console.error('❌ Database check error:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('\n🔚 Database check completed');
  }
}

checkDatabase();
