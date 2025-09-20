const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import WHO Admin model
const WhoAdmin = require('../src/models/WhoAdmin');

async function createDefaultWhoAdmin() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to MongoDB');

    // Check if WHO admin already exists
    const existingAdmin = await WhoAdmin.findOne({ username: 'who_admin' });
    
    if (existingAdmin) {
      console.log('ℹ️  WHO Admin already exists');
      console.log('Username:', existingAdmin.username);
      console.log('Email:', existingAdmin.email);
      process.exit(0);
    }

    // Create default WHO admin
    const defaultPassword = 'WhoAdmin@2024';
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
      profileCompleted: true
    });

    await whoAdmin.save();

    console.log('🎉 Default WHO Admin created successfully!');
    console.log('');
    console.log('=== LOGIN CREDENTIALS ===');
    console.log('Admin ID:', 'WHO_ADMIN_001');
    console.log('Username:', 'who_admin');
    console.log('Password:', defaultPassword);
    console.log('Email:', 'who.admin@healthcare.gov.in');
    console.log('Role:', 'super_admin');
    console.log('Designation:', 'Country Representative');
    console.log('');
    console.log('⚠️  IMPORTANT: Please change the default password after first login!');
    console.log('');
    console.log('🌐 API Endpoints:');
    console.log('Login: POST /api/who/login');
    console.log('Dashboard: GET /api/who/dashboard/stats');
    console.log('Officers: GET /api/who/regional-officers');
    console.log('Hospitals: GET /api/who/hospitals');

  } catch (error) {
    console.error('❌ Error creating WHO admin:', error);
    
    if (error.code === 11000) {
      console.log('ℹ️  WHO Admin with this username or email already exists');
    }
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

// Run the script
createDefaultWhoAdmin();