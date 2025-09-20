const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config({ path: '.env.local' });

// Models
const WhoAdmin = require('../src/models/WhoAdmin');

async function connectToDatabase() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    throw error;
  }
}

async function updateWhoAdminForSHO() {
  console.log('\n🔧 Updating WHO Admin permissions for SHO management...');
  
  const whoAdmin = await WhoAdmin.findOne({ adminId: 'WHO_ADMIN_001' });
  
  if (!whoAdmin) {
    console.log('❌ WHO Admin not found');
    return;
  }
  
  // Update permissions for SHO management
  whoAdmin.permissions = {
    // Dashboard and Analytics
    canAccessAnalytics: true,
    canViewAllStates: true,
    canExportData: true,
    canGenerateReports: true,
    
    // SHO Management - WHO Admin manages SHOs
    canManageStateOfficers: true,  // NEW: Manage SHOs
    canViewStateOfficers: true,    // NEW: View SHOs
    
    // Regional Officers - WHO should NOT directly manage them
    canManageRegionalOfficers: false,  // SHOs manage Regional Officers
    canViewRegionalOfficers: true,     // Can view but not manage directly
    
    // Hospital oversight (read-only for WHO, SHOs manage hospitals)
    canViewHospitals: true,
    canManageHospitals: false,  // SHOs manage hospitals
    
    // User management (limited - SHOs manage users in their states)
    canManageUsers: false,  // SHOs manage users in their states
    canViewUsers: true
  };
  
  await whoAdmin.save();
  console.log('✅ WHO Admin permissions updated for SHO management');
  console.log('📋 New permissions:', whoAdmin.permissions);
}

async function main() {
  try {
    console.log('🚀 Starting WHO Admin SHO Permission Update...');
    
    await connectToDatabase();
    await updateWhoAdminForSHO();
    
    console.log('\n✅ WHO Admin SHO Permission Update Complete!');
    console.log('\n📋 Summary:');
    console.log('1. ✅ WHO Admin can now manage SHOs (canManageStateOfficers: true)');
    console.log('2. ✅ WHO Admin can view SHOs (canViewStateOfficers: true)');
    console.log('3. ❌ WHO Admin cannot directly manage Regional Officers (canManageRegionalOfficers: false)');
    console.log('4. 🔄 Hierarchy: WHO Admin -> SHO -> Regional Officers');
    
    console.log('\n📋 Next Steps:');
    console.log('1. SHO backend system is ready');
    console.log('2. Update WHO dashboard to show SHO management');
    console.log('3. Create Flutter SHO management interface');
    console.log('4. Test SHO creation and management');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
    process.exit(0);
  }
}

main();