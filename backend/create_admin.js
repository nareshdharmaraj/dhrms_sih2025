const mongoose = require('mongoose');
require('dotenv').config();

async function updatePasswords() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth');
    console.log('✅ Connected to MongoDB Atlas');
    
    const HospitalAdmin = require('./src/models/HospitalAdmin');
    const HospitalDoctor = require('./src/models/HospitalDoctor');
    const HospitalAssistant = require('./src/models/HospitalAssistant');
    
    // Update admin password
    await HospitalAdmin.updateOne(
      {username: 'admin456'}, 
      {password: 'password123'}
    );
    console.log('✅ Updated admin password to: password123');
    
    // Update doctor password
    await HospitalDoctor.updateOne(
      {username: 'doctor123'}, 
      {password: 'password123'}
    );
    console.log('✅ Updated doctor password to: password123');
    
    // Update assistant password
    await HospitalAssistant.updateOne(
      {username: 'assistant123'}, 
      {password: 'password123'}
    );
    console.log('✅ Updated assistant password to: password123');
    
    console.log('\n🎉 All passwords updated successfully!');
    console.log('📋 Login Credentials:');
    console.log('   Admin:     admin456 / password123');
    console.log('   Doctor:    doctor123 / password123');
    console.log('   Assistant: assistant123 / password123');
    console.log('   Hospital:  Test Hospital (HOSP-001)');
    
  } catch (error) {
    console.error('❌ Error updating passwords:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

updatePasswords();