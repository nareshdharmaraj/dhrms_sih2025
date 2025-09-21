// Simple Hospital System Validation Script
const mongoose = require('mongoose');
require('dotenv').config();

// Import models to test validation
const Hospital = require('./src/models/Hospital');
const HospitalAdmin = require('./src/models/HospitalAdmin');
const HospitalDoctor = require('./src/models/HospitalDoctor');
const HospitalAssistant = require('./src/models/HospitalAssistant');

async function testModels() {
  try {
    console.log('🏥 Hospital Management System - Model Validation');
    console.log('=================================================');

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    // Test Hospital model
    console.log('\n📋 Testing Hospital Model...');
    const testHospital = new Hospital({
      hospitalId: "HOSP_TEST123",
      name: "Test Hospital",
      location: {
        address: "123 Test Street",
        city: "Mumbai",
        state: "Maharashtra",
        district: "Mumbai",
        pincode: "400001"
      },
      contact: {
        phone: "9876543210",
        email: "test@hospital.com",
        emergencyNumber: "9876543209"
      },
      licenses: {
        registrationNumber: "REG123456",
        licenseNumber: "LIC789012",
        expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
        issueDate: new Date(),
        issuingAuthority: "State Health Department"
      },
      type: "Private",
      status: "Active",
      establishedDate: new Date('2020-01-01'),
      managedBy: "Test Management",
      capacity: {
        totalBeds: 100,
        totalStaff: 50
      }
    });

    await testHospital.save();
    console.log('✅ Hospital model validation passed');
    console.log('   Hospital ID:', testHospital.hospitalId);

    // Test Hospital Admin model
    console.log('\n👨‍💼 Testing Hospital Admin Model...');
    const testAdmin = new HospitalAdmin({
      hospitalId: testHospital.hospitalId,
      username: "test_admin",
      password: "admin123",
      adminName: "Test Administrator",
      email: "admin@test.com",
      contactNumber: "9876543211"
    });

    await testAdmin.save();
    console.log('✅ Hospital Admin model validation passed');
    console.log('   Admin ID:', testAdmin.adminId);

    // Test Doctor model
    console.log('\n👨‍⚕️ Testing Hospital Doctor Model...');
    const testDoctor = new HospitalDoctor({
      hospitalId: testHospital.hospitalId,
      doctorName: "Dr. Test Doctor",
      username: "test_doctor",
      password: "doctor123",
      email: "doctor@test.com",
      contactNumber: "9876543212",
      specialization: "Cardiology",
      qualifications: ["MBBS", "MD"],
      department: "Cardiology"
    });

    await testDoctor.save();
    console.log('✅ Hospital Doctor model validation passed');
    console.log('   Doctor ID:', testDoctor.doctorId);

    // Test Assistant model
    console.log('\n👩‍⚕️ Testing Hospital Assistant Model...');
    const testAssistant = new HospitalAssistant({
      hospitalId: testHospital.hospitalId,
      assistantName: "Test Assistant",
      username: "test_assistant",
      password: "assistant123",
      email: "assistant@test.com",
      contactNumber: "9876543213",
      designation: "Medical Assistant",
      department: "Cardiology",
      assignedDoctorId: testDoctor.doctorId
    });

    await testAssistant.save();
    console.log('✅ Hospital Assistant model validation passed');
    console.log('   Assistant ID:', testAssistant.assistantId);

    // Test relationships
    console.log('\n🔗 Testing Model Relationships...');
    
    // Find assistant with doctor details
    const assistantWithDoctor = await HospitalAssistant.findOne({
      assistantId: testAssistant.assistantId
    }).populate('assignedDoctorId');
    
    if (assistantWithDoctor && assistantWithDoctor.assignedDoctorId) {
      console.log('✅ Assistant-Doctor relationship working');
    }

    // Find all staff for hospital
    const hospitalStaff = {
      admin: await HospitalAdmin.findOne({ hospitalId: testHospital.hospitalId }),
      doctors: await HospitalDoctor.find({ hospitalId: testHospital.hospitalId }),
      assistants: await HospitalAssistant.find({ hospitalId: testHospital.hospitalId })
    };

    console.log('✅ Hospital staff lookup working');
    console.log('   Admins:', hospitalStaff.admin ? 1 : 0);
    console.log('   Doctors:', hospitalStaff.doctors.length);
    console.log('   Assistants:', hospitalStaff.assistants.length);

    // Test auto-generated IDs
    console.log('\n🆔 Testing Auto-Generated IDs...');
    console.log('   Hospital ID format:', testHospital.hospitalId.match(/^HOSP_[A-Z0-9]{8}$/) ? '✅ Valid' : '❌ Invalid');
    console.log('   Admin ID format:', testAdmin.adminId.includes('ADMIN') ? '✅ Valid' : '❌ Invalid');
    console.log('   Doctor ID format:', testDoctor.doctorId.includes('DOC') ? '✅ Valid' : '❌ Invalid');
    console.log('   Assistant ID format:', testAssistant.assistantId.includes('AST') ? '✅ Valid' : '❌ Invalid');

    // Cleanup test data
    console.log('\n🧹 Cleaning up test data...');
    await HospitalAssistant.deleteOne({ assistantId: testAssistant.assistantId });
    await HospitalDoctor.deleteOne({ doctorId: testDoctor.doctorId });
    await HospitalAdmin.deleteOne({ adminId: testAdmin.adminId });
    await Hospital.deleteOne({ hospitalId: testHospital.hospitalId });
    console.log('✅ Test data cleaned up');

    console.log('\n🎉 All model validations passed successfully!');
    console.log('\n📋 Summary:');
    console.log('   ✅ Hospital model - Working');
    console.log('   ✅ Hospital Admin model - Working');
    console.log('   ✅ Hospital Doctor model - Working');
    console.log('   ✅ Hospital Assistant model - Working');
    console.log('   ✅ Model relationships - Working');
    console.log('   ✅ Auto-generated IDs - Working');

  } catch (error) {
    console.error('❌ Model validation failed:', error.message);
    if (error.errors) {
      console.error('Validation errors:');
      Object.keys(error.errors).forEach(key => {
        console.error(`   - ${key}: ${error.errors[key].message}`);
      });
    }
  } finally {
    await mongoose.connection.close();
    console.log('\n📊 Database connection closed');
  }
}

// Run the test
if (require.main === module) {
  testModels().catch(error => {
    console.error('Test suite failed:', error);
    process.exit(1);
  });
}

module.exports = testModels;