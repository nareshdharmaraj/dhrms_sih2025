const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import WHO Admin model
const WhoAdmin = require('./src/models/WhoAdmin');

async function debugCloudWhoAdmin() {
  try {
    // Use the cloud MongoDB URI
    const cloudMongoUri = 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0';
    
    console.log('🔗 Connecting to cloud MongoDB...');
    await mongoose.connect(cloudMongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to cloud MongoDB');

    // Find the WHO admin and check details
    const admin = await WhoAdmin.findOne({ 
      $or: [
        { adminId: 'WHO_ADMIN_001' },
        { username: 'who_admin' }
      ]
    }).select('+password'); // Include password field for debugging
    
    if (!admin) {
      console.log('❌ No WHO admin found in cloud database');
      await mongoose.connection.close();
      return;
    }

    console.log('🔍 WHO Admin found in cloud database:');
    console.log('Admin ID:', admin.adminId);
    console.log('Username:', admin.username);
    console.log('Email:', admin.email);
    console.log('Is Active:', admin.isActive);
    console.log('Password Hash Exists:', !!admin.password);
    console.log('Password Hash Length:', admin.password ? admin.password.length : 0);
    console.log('');

    // Test password verification
    const testPassword = 'WhoAdmi@2024';
    console.log('🔐 Testing password verification...');
    console.log('Test Password:', testPassword);
    
    if (admin.password) {
      const isValidPassword = await bcrypt.compare(testPassword, admin.password);
      console.log('Password Match:', isValidPassword);
      
      if (!isValidPassword) {
        console.log('❌ Password does not match!');
        console.log('');
        console.log('🔧 Updating password...');
        
        // Update the password
        const newHashedPassword = await bcrypt.hash(testPassword, 12);
        await WhoAdmin.updateOne(
          { _id: admin._id },
          { password: newHashedPassword, updatedAt: new Date() }
        );
        
        console.log('✅ Password updated successfully!');
        console.log('');
        console.log('🔑 Updated login credentials:');
        console.log('Admin ID: WHO_ADMIN_001');
        console.log('Password: WhoAdmi@2024');
      } else {
        console.log('✅ Password is correct!');
      }
    }

  } catch (error) {
    console.error('❌ Error debugging cloud WHO admin:', error);
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

// Run the script
console.log('🔍 Debugging WHO Admin in cloud database...');
debugCloudWhoAdmin();