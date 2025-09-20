// Check WHO admin credentials in database
const mongoose = require('mongoose');
require('dotenv').config({ path: '.env.local' });

async function checkWhoAdmin() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
    
    const WhoAdmin = require('./src/models/WhoAdmin');
    
    // Find all WHO admins
    const whoAdmins = await WhoAdmin.find({}).select('adminId fullName email role permissions');
    
    console.log('\n📋 WHO Admins in database:');
    whoAdmins.forEach((admin, index) => {
      console.log(`${index + 1}. Admin ID: ${admin.adminId}`);
      console.log(`   Name: ${admin.fullName}`);
      console.log(`   Email: ${admin.email}`);
      console.log(`   Role: ${admin.role}`);
      console.log(`   Permissions:`, admin.permissions);
      console.log('   ---');
    });
    
    if (whoAdmins.length === 0) {
      console.log('❌ No WHO admins found in database');
      console.log('🔧 Creating a test WHO admin...');
      
      const newAdmin = new WhoAdmin({
        adminId: 'WHO_ADMIN_001',
        fullName: 'WHO Administrator',
        email: 'admin@who.int',
        password: 'admin123', // Will be hashed
        role: 'admin',
        designation: 'World Health Organization Administrator',
        region: 'Global',
        permissions: {
          canAccessAnalytics: true,
          canViewAllStates: true,
          canExportData: true,
          canGenerateReports: true,
          canManageStateOfficers: true,
          canViewStateOfficers: true,
          canManageRegionalOfficers: false,
          canViewRegionalOfficers: true,
          canViewHospitals: true,
          canManageHospitals: false,
          canManageUsers: false,
          canViewUsers: true
        }
      });
      
      await newAdmin.save();
      console.log('✅ Test WHO admin created with ID: WHO_ADMIN_001, password: admin123');
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB');
  }
}

checkWhoAdmin();