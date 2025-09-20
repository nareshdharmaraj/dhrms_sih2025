// Check if token admin ID matches database
const mongoose = require('mongoose');
require('dotenv').config({ path: '.env.local' });

async function checkTokenAdminId() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
    
    const WhoAdmin = require('./src/models/WhoAdmin');
    
    // Find WHO admin by adminId string
    const adminByString = await WhoAdmin.findOne({ adminId: 'WHO_ADMIN_001' });
    console.log('📋 Admin by adminId string:', {
      _id: adminByString?._id?.toString(),
      adminId: adminByString?.adminId,
      permissions: adminByString?.permissions
    });
    
    // Find WHO admin by ObjectId (from token)
    const tokenAdminId = '68ce6dd0103ab19e4b7576f2';
    const adminByObjectId = await WhoAdmin.findById(tokenAdminId);
    console.log('📋 Admin by ObjectId from token:', {
      _id: adminByObjectId?._id?.toString(),
      adminId: adminByObjectId?.adminId,
      permissions: adminByObjectId?.permissions
    });
    
    // Check if they're the same
    const isSame = adminByString?._id?.toString() === tokenAdminId;
    console.log('🔍 Are they the same admin?', isSame ? '✅ YES' : '❌ NO');
    
    if (!isSame) {
      console.log('❌ Token contains wrong admin ID!');
      console.log('   Expected:', adminByString?._id?.toString());
      console.log('   Got in token:', tokenAdminId);
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB');
  }
}

checkTokenAdminId();