const bcrypt = require('bcryptjs');
const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth')
  .then(() => {
    console.log('✅ Connected to MongoDB');
    checkSHOPassword();
  })
  .catch(error => {
    console.error('❌ MongoDB connection error:', error);
  });

async function checkSHOPassword() {
  try {
    const StateHealthOfficer = require('./src/models/StateHealthOfficer');
    
    // Find the SHO
    const sho = await StateHealthOfficer.findOne({ email: 'sho.tn@myhealth.gov.in' });
    
    if (!sho) {
      console.log('❌ SHO not found');
      process.exit(1);
    }
    
    console.log('🔍 Found SHO:', {
      id: sho._id,
      email: sho.email,
      fullName: sho.fullName,
      hashedPassword: sho.password
    });
    
    // Test common passwords
    const passwords = [
      'TestPassword@123',
      'testpassword123',
      'password123',
      'admin123',
      'TamilNadu@123',
      'SHO@123',
      'dhrms123'
    ];
    
    console.log('\n🔍 Testing passwords...');
    
    for (const password of passwords) {
      const isMatch = await bcrypt.compare(password, sho.password);
      console.log(`Password "${password}": ${isMatch ? '✅ MATCH' : '❌ no match'}`);
      
      if (isMatch) {
        console.log(`\n✅ CORRECT PASSWORD FOUND: "${password}"`);
        break;
      }
    }
    
    // If no password matches, let's set a known password
    console.log('\n🔧 Setting known password: "TestPassword@123"');
    const hashedPassword = await bcrypt.hash('TestPassword@123', 12);
    
    await StateHealthOfficer.findByIdAndUpdate(sho._id, {
      password: hashedPassword
    });
    
    console.log('✅ Password updated successfully');
    
    // Verify the new password
    const updatedSHO = await StateHealthOfficer.findById(sho._id);
    const isNewMatch = await bcrypt.compare('TestPassword@123', updatedSHO.password);
    console.log(`New password verification: ${isNewMatch ? '✅ WORKS' : '❌ failed'}`);
    
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}