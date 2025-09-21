const mongoose = require('mongoose');
require('dotenv').config();

async function createDoctor() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth');
    console.log('✅ Connected to MongoDB Atlas');
    
    const HospitalDoctor = require('./src/models/HospitalDoctor');
    
    const doctor = new HospitalDoctor({
      doctorId: 'DOC-001',
      hospitalId: 'HOSP-001',
      username: 'doctor123',
      password: '$2b$10$hash123456',
      doctorName: 'Dr. John Smith',
      specialization: 'Cardiology',
      email: 'doctor@testhospital.com',
      contactNumber: '9876543213',
      qualification: {
        degree: 'MBBS, MD'
      },
      registrationNumber: 'REG12345',
      department: 'Cardiology',
      isActive: true
    });
    
    const result = await doctor.save();
    console.log('✅ Hospital Doctor created:', result.doctorId);
    console.log('   Username:', result.username);
    console.log('   Specialization:', result.specialization);
    
  } catch (error) {
    console.error('❌ Error creating Doctor:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

createDoctor();