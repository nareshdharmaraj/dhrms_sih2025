const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import WHO Admin model
const WhoAdmin = require('../src/models/WhoAdmin');

async function fixMainDatabaseWhoAdmin() {
  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth';
    console.log('Connecting to:', mongoUri);
    
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to MongoDB');

    // Hash the correct password
    const password = 'WhoAdmin@2024';
    const hashedPassword = await bcrypt.hash(password, 12);
    console.log('🔐 Password hashed');

    // Update the WHO admin with username and correct password
    const result = await WhoAdmin.updateOne(
      { adminId: 'WHO_ADMIN_001' },
      {
        $set: { 
          username: 'who_admin',
          password: hashedPassword
        },
        $unset: { 
          lockUntil: 1,
          loginAttempts: 1
        }
      }
    );

    if (result.matchedCount > 0) {
      console.log('✅ WHO Admin updated successfully!');
      console.log('✅ Username added: who_admin');
      console.log('✅ Password reset to: WhoAdmin@2024');
      console.log('✅ Account unlocked');
    } else {
      console.log('❌ WHO Admin not found');
    }

    // Display current admin status
    const admin = await WhoAdmin.findOne({ adminId: 'WHO_ADMIN_001' });
    if (admin) {
      console.log('\n📋 Updated Admin Status:');
      console.log('Admin ID:', admin.adminId);
      console.log('Username:', admin.username);
      console.log('Email:', admin.email);
      console.log('Full Name:', admin.fullName);
      console.log('Is Active:', admin.isActive);
      console.log('Account Locked:', admin.accountLocked);
      console.log('Login Attempts:', admin.loginAttempts || 0);
      console.log('Password Hash Set:', admin.password ? 'YES' : 'NO');
    }

  } catch (error) {
    console.error('❌ Error fixing WHO admin:', error);
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

// Run the script
fixMainDatabaseWhoAdmin();