const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function resetRHOPassword() {
  try {
    console.log('🔑 Resetting RHO password...');

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
      email: rho.email,
      assignedState: rho.assignedState,
      assignedDistrict: rho.assignedDistrict,
      isActive: rho.isActive
    });

    // Set new password
    const newPassword = 'password123';
    const hashedPassword = await bcrypt.hash(newPassword, 12);
    
    // Update the RHO's password
    rho.password = hashedPassword;
    await rho.save();

    console.log('✅ Password updated successfully!');
    console.log('🔑 New login credentials:');
    console.log('   RHO ID: RHO_Pathanamthitta_001');
    console.log('   Password: password123');
    console.log('   State: Kerala');

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

resetRHOPassword();