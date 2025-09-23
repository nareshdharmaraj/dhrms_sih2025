const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function verifyPassword() {
  try {
    console.log('🔍 Verifying RHO password...');

    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // Find the RHO
    const rho = await RegionalHealthOfficer.findOne({ officerId: 'RHO_Pathanamthitta_001' });
    
    if (!rho) {
      console.log('❌ RHO not found');
      process.exit(1);
    }

    console.log('✅ Found RHO:', rho.officerId);
    console.log('📧 Email:', rho.email);
    console.log('🏛️ State:', rho.assignedState);
    console.log('🏙️ District:', rho.assignedDistrict);
    console.log('✅ Active:', rho.isActive);
    console.log('🔑 Password hash exists:', !!rho.password);
    console.log('🔑 Password hash length:', rho.password ? rho.password.length : 0);

    if (rho.password) {
      // Test password comparison
      const testPasswords = ['password123', 'Password123', 'TestPassword@123', 'TempPassword@2024'];
      
      for (const pwd of testPasswords) {
        const isMatch = await bcrypt.compare(pwd, rho.password);
        console.log(`🔍 Password "${pwd}": ${isMatch ? '✅ MATCH' : '❌ NO MATCH'}`);
      }
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

verifyPassword();