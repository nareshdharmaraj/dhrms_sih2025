const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const HospitalAdmin = require('./src/models/HospitalAdmin');
const Hospital = require('./src/models/Hospital');

// MongoDB connection
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
};

// Generate admin ID
const generateAdminId = (hospitalId, adminName) => {
  const namePart = adminName.replace(/\s+/g, '').substring(0, 3).toUpperCase();
  const timestamp = Date.now().toString().slice(-4);
  return `${hospitalId}_ADM_${namePart}${timestamp}`;
};

// Create hospital admin
const createHospitalAdmin = async (adminData) => {
  try {
    const {
      hospitalId,
      adminName,
      username,
      password,
      email,
      contactNumber,
      designation = 'Hospital Administrator',
      permissions = {
        manageStaff: true,
        manageDepartments: true,
        viewReports: true,
        manageSchedules: true,
        systemSettings: true
      }
    } = adminData;

    // Check if hospital exists
    const hospital = await Hospital.findOne({ hospitalId });
    if (!hospital) {
      throw new Error(`Hospital with ID ${hospitalId} not found`);
    }

    // Check if admin already exists
    const existingAdmin = await HospitalAdmin.findOne({
      $or: [
        { username },
        { email },
        { hospitalId, adminName }
      ]
    });

    if (existingAdmin) {
      throw new Error('Admin with this username, email, or name already exists for this hospital');
    }

    // Generate admin ID
    const adminId = generateAdminId(hospitalId, adminName);

    // Create new admin
    const admin = new HospitalAdmin({
      adminId,
      hospitalId,
      adminName,
      username,
      password, // Plain text as per project requirements
      email,
      contactNumber,
      designation,
      permissions,
      isActive: true,
      createdAt: new Date()
    });

    await admin.save();

    console.log('✅ Hospital Admin created successfully!');
    console.log('Admin Details:');
    console.log('- Admin ID:', adminId);
    console.log('- Name:', adminName);
    console.log('- Username:', username);
    console.log('- Email:', email);
    console.log('- Hospital ID:', hospitalId);
    console.log('- Hospital Name:', hospital.name);

    return admin;

  } catch (error) {
    console.error('❌ Error creating hospital admin:', error.message);
    throw error;
  }
};

// Main execution function
const main = async () => {
  console.log('🏥 Creating Hospital Administrator...\n');

  await connectDB();

  // Example admin data - modify as needed
  const adminData = {
    hospitalId: 'HOSP-001', // Make sure this hospital exists
    adminName: 'Dr. Admin Kumar',
    username: 'admin',
    password: 'admin123',
    email: 'admin@hospital.com',
    contactNumber: '9876543210',
    designation: 'Chief Administrator'
  };

  try {
    await createHospitalAdmin(adminData);
    console.log('\n🎉 Admin creation completed successfully!');
  } catch (error) {
    console.error('\n💥 Admin creation failed:', error.message);
  }

  mongoose.connection.close();
};

// Run if this file is executed directly
if (require.main === module) {
  main();
}

module.exports = { createHospitalAdmin, generateAdminId };
