const mongoose = require('mongoose');
require('dotenv').config();

const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function resetRHOPasswordCorrectly() {
  try {
    console.log('🔑 Resetting RHO password correctly...');

    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // Find the RHO
    const rho = await RegionalHealthOfficer.findOne({ officerId: 'RHO_Pathanamthitta_001' });
    
    if (!rho) {
      console.log('❌ RHO not found with officerId: RHO_Pathanamthitta_001');
      process.exit(1);
    }

    console.log('✅ Found RHO:', {
      officerId: rho.officerId,
      fullName: rho.fullName,
      email: rho.email
    });

    // Set new password (let the model handle the hashing)
    const newPassword = 'password123';
    rho.password = newPassword; // Don't hash here, let the pre-save middleware do it
    await rho.save();

    console.log('✅ Password updated successfully!');
    console.log('🔑 New login credentials:');
    console.log('   RHO ID: RHO_Pathanamthitta_001');
    console.log('   Password: password123');
    console.log('   State: Kerala');

    // Test the password immediately
    console.log('\n🔍 Testing password immediately...');
    const isMatch = await rho.comparePassword(newPassword);
    console.log('Password test result:', isMatch ? '✅ MATCH' : '❌ NO MATCH');

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

resetRHOPasswordCorrectly();