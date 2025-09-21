// Set WHO admin password correctly
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: '.env.local' });

async function setWhoAdminPassword() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
    
    // Create the correct hash for WhoAdmin@2024
    const correctPassword = 'WhoAdmin@2024';
    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(correctPassword, salt);
    
    console.log('🔧 Created password hash for:', correctPassword);
    console.log('   Hash:', hashedPassword.substring(0, 29) + '...');
    
    // Test the hash
    const testHash = await bcrypt.compare(correctPassword, hashedPassword);
    console.log('   Hash test:', testHash ? '✅ WORKS' : '❌ FAILED');
    
    // Update directly in database using updateOne to bypass pre-save hook
    const result = await mongoose.connection.collection('whoadmins').updateOne(
      { adminId: 'WHO_ADMIN_001' },
      { 
        $set: { 
          password: hashedPassword,
          'permissions.canManageStateOfficers': true,
          'permissions.canViewStateOfficers': true,
          'permissions.canManageRegionalOfficers': false,
          updatedAt: new Date()
        }
      }
    );
    
    console.log('✅ Database update result:', {
      matched: result.matchedCount,
      modified: result.modifiedCount
    });
    
    // Verify the update
    const WhoAdmin = require('./src/models/WhoAdmin');
    const updatedAdmin = await WhoAdmin.findOne({ adminId: 'WHO_ADMIN_001' }).select('+password');
    
    if (updatedAdmin) {
      console.log('\n📋 Verification:');
      console.log('   Admin ID:', updatedAdmin.adminId);
      console.log('   Password hash preview:', updatedAdmin.password.substring(0, 29) + '...');
      
      const finalTest = await bcrypt.compare(correctPassword, updatedAdmin.password);
      console.log('   Password test:', finalTest ? '✅ SUCCESS' : '❌ FAILED');
      
      console.log('   Permissions:', {
        canManageStateOfficers: updatedAdmin.permissions.canManageStateOfficers,
        canViewStateOfficers: updatedAdmin.permissions.canViewStateOfficers,
        canManageRegionalOfficers: updatedAdmin.permissions.canManageRegionalOfficers
      });
      
      if (finalTest) {
        console.log('\n🎉 WHO Admin credentials are now:');
        console.log('   Username: WHO_ADMIN_001');
        console.log('   Password: WhoAdmin@2024');
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB');
  }
}

setWhoAdminPassword();