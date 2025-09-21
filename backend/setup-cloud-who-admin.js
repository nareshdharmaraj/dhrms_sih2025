const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import WHO Admin model
const WhoAdmin = require('./src/models/WhoAdmin');

async function setupCloudWhoAdmin() {
  try {
    // Use the cloud MongoDB URI
    const cloudMongoUri = 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0';
    
    console.log('🔗 Connecting to cloud MongoDB...');
    await mongoose.connect(cloudMongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to cloud MongoDB');

    // Check if WHO admin already exists
    const existingAdmin = await WhoAdmin.findOne({ 
      $or: [
        { adminId: 'WHO_ADMIN_001' },
        { username: 'who_admin' }
      ]
    });
    
    if (existingAdmin) {
      console.log('ℹ️  WHO Admin already exists in cloud database');
      console.log('Admin ID:', existingAdmin.adminId);
      console.log('Username:', existingAdmin.username);
      console.log('Email:', existingAdmin.email);
      console.log('Is Active:', existingAdmin.isActive);
      console.log('');
      console.log('🔑 Login credentials:');
      console.log('Admin ID: WHO_ADMIN_001');
      console.log('Password: WhoAdmi@2024');
      console.log('');
      console.log('🌐 API Endpoint: https://dhrms-sih2025.onrender.com/api/who/login');
      
      await mongoose.connection.close();
      return;
    }

    // Create WHO admin for cloud database
    const defaultPassword = 'WhoAdmi@2024';
    const hashedPassword = await bcrypt.hash(defaultPassword, 12);

    const whoAdmin = new WhoAdmin({
      adminId: 'WHO_ADMIN_001',
      username: 'who_admin',
      email: 'who.admin@healthcare.gov.in',
      password: hashedPassword,
      fullName: 'WHO System Administrator',
      phone: '+91-9876543210',
      designation: 'Country Representative',
      region: 'South-East Asia',
      role: 'super_admin',
      permissions: [
        'view_dashboard',
        'view_state_stats',
        'view_officers',
        'manage_officers',
        'view_hospitals',
        'export_data',
        'system_admin'
      ],
      managedStates: [
        'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
        'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
        'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
        'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
        'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
        'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
      ],
      phoneNumber: '+91-9876543210',
      department: 'World Health Organization - India',
      isActive: true,
      emailVerified: true,
      profileCompleted: true,
      loginAttempts: 0,
      sessions: [],
      createdAt: new Date(),
      updatedAt: new Date()
    });

    await whoAdmin.save();

    console.log('🎉 WHO Admin created successfully in cloud database!');
    console.log('');
    console.log('=== CLOUD LOGIN CREDENTIALS ===');
    console.log('Admin ID: WHO_ADMIN_001');
    console.log('Username: who_admin');
    console.log('Password:', defaultPassword);
    console.log('Email: who.admin@healthcare.gov.in');
    console.log('Role: super_admin');
    console.log('');
    console.log('🌐 Cloud API Endpoints:');
    console.log('Base URL: https://dhrms-sih2025.onrender.com/api');
    console.log('Login: POST https://dhrms-sih2025.onrender.com/api/who/login');
    console.log('Dashboard: GET https://dhrms-sih2025.onrender.com/api/who/dashboard/stats');
    console.log('');
    console.log('⚠️  IMPORTANT: Make sure to redeploy your Render service to get the latest WHO management code!');

  } catch (error) {
    console.error('❌ Error setting up cloud WHO admin:', error);
    
    if (error.code === 11000) {
      console.log('ℹ️  WHO Admin already exists in cloud database');
    }
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

// Run the script
console.log('🚀 Setting up WHO Admin in cloud database...');
setupCloudWhoAdmin();