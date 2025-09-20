// Check WHO admin password and update permissions manually
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: '.env.local' });

async function fixWhoAdmin() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
    
    const WhoAdmin = require('./src/models/WhoAdmin');
    
    // Find the WHO admin
    const whoAdmin = await WhoAdmin.findOne({ adminId: 'WHO_ADMIN_001' });
    
    if (!whoAdmin) {
      console.log('❌ WHO Admin not found');
      return;
    }
    
    console.log('📋 Current WHO Admin:');
    console.log('   Admin ID:', whoAdmin.adminId);
    console.log('   Name:', whoAdmin.fullName);
    console.log('   Email:', whoAdmin.email);
    console.log('   Current permissions:', whoAdmin.permissions);
    
    // Check password
    const testPassword = 'admin123';
    const isPasswordCorrect = await bcrypt.compare(testPassword, whoAdmin.password);
    console.log(`🔍 Password 'admin123' is ${isPasswordCorrect ? 'CORRECT' : 'INCORRECT'}`);
    
    // Test other common passwords
    const commonPasswords = ['whoAdmin123', 'password', 'admin', '123456'];
    for (const pwd of commonPasswords) {
      const isCorrect = await bcrypt.compare(pwd, whoAdmin.password);
      if (isCorrect) {
        console.log(`✅ Password '${pwd}' is CORRECT`);
        break;
      }
    }
    
    // Update permissions manually
    console.log('\n🔧 Updating permissions manually...');
    whoAdmin.permissions = {
      // Dashboard and Analytics
      canAccessAnalytics: true,
      canViewAllStates: true,
      canExportData: true,
      canGenerateReports: true,
      
      // SHO Management (NEW)
      canManageStateOfficers: true,
      canViewStateOfficers: true,
      
      // Regional Officers (Limited)
      canManageRegionalOfficers: false,
      canViewRegionalOfficers: true,
      
      // Hospital oversight
      canViewHospitals: true,
      canManageHospitals: false,
      
      // User management
      canManageUsers: false,
      canViewUsers: true
    };
    
    // Also ensure password is set correctly
    if (!isPasswordCorrect) {
      console.log('🔧 Setting password to admin123...');
      whoAdmin.password = await bcrypt.hash('admin123', 10);
    }
    
    await whoAdmin.save();
    console.log('✅ WHO Admin updated successfully');
    console.log('📋 New permissions:', whoAdmin.permissions);
    console.log('🔑 Login credentials: WHO_ADMIN_001 / admin123');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB');
  }
}

fixWhoAdmin();