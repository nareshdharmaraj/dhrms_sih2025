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

async function updateWhoAdminPermissions() {
  console.log('\n🔧 Updating WHO Admin Permissions for SHO Management...');
  
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
    
    // WHO Admin manages SHOs (State Health Officers)
    canManageStateOfficers: true,  // NEW: Manage SHOs
    canViewStateOfficers: true,    // NEW: View SHOs
    
    // WHO should NOT directly manage Regional Officers
    canManageRegionalOfficers: false,  // SHOs manage Regional Officers
    canViewRegionalOfficers: true,     // Can view but not manage
    
    // Hospital oversight (read-only)
    canViewHospitals: true,
    canManageHospitals: false,  // SHOs manage hospitals
    
    // User management (limited)
    canManageUsers: false,  // SHOs manage users in their states
    canViewUsers: true
  };
  
  await whoAdmin.save();
  console.log('✅ WHO Admin permissions updated');
  console.log('📋 New permissions:', whoAdmin.permissions);
}

async function main() {
  try {
    console.log('🚀 Starting WHO Admin Permission Update for SHO Management...');
    
    await connectToDatabase();
    await updateWhoAdminPermissions();
    
    console.log('\n✅ WHO Admin Permission Update Complete!');
    console.log('\n📋 Summary:');
    console.log('1. ✅ Added canManageStateOfficers: true');
    console.log('2. ✅ Added canViewStateOfficers: true');
    console.log('3. ✅ Confirmed canManageRegionalOfficers: false');
    console.log('4. 🔄 Hierarchy: WHO Admin → SHO → Regional Officers');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('\n🔌 Database connection closed');
    process.exit(0);
  }
}

main();