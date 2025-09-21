const mongoose = require('mongoose');
require('dotenv').config();

async function createAssistant() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth');
    console.log('✅ Connected to MongoDB Atlas');
    
    const HospitalAssistant = require('./src/models/HospitalAssistant');
    
    const assistant = new HospitalAssistant({
      assistantId: 'ASST-001',
      hospitalId: 'HOSP-001',
      username: 'assistant123',
      password: '$2b$10$hash123456',
      assistantName: 'Sarah Johnson',
      email: 'assistant@testhospital.com',
      contactNumber: '9876543214',
      qualification: {
        degree: 'B.Sc Nursing'
      },
      assignedDepartment: 'Cardiology',
      isActive: true
    });
    
    const result = await assistant.save();
    console.log('✅ Hospital Assistant created:', result.assistantId);
    console.log('   Username:', result.username);
    console.log('   Department:', result.assignedDepartment);
    
  } catch (error) {
    console.error('❌ Error creating Assistant:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

createAssistant();