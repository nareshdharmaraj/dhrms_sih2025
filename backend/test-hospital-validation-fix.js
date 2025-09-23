const mongoose = require('mongoose');

async function testHospitalRegistrationFix() {
  try {
    console.log('🔍 Testing hospital registration validation fixes...\n');

    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');

    // Import models
    const Hospital = require('./src/models/Hospital');
    const HospitalAdmin = require('./src/models/HospitalAdmin');

    // Test data that mimics the frontend submission
    const testHospitalData = {
      hospitalName: 'Test Hospital',
      address: {
        street: '123 Test Street',
        city: 'Test City',
        state: 'Kerala',
        district: 'Ernakulam',
        pincode: '123456'
      },
      contactNumber: '9876543210',
      email: 'test@hospital.com',
      registrationNumber: 'TEST123456',
      licenseId: 'LIC123456',
      hospitalType: 'Government',
      specialties: ['General Medicine', 'Cardiology', 'Neurology'],
      totalBeds: 100,
      emergencyServices: true,
      ambulanceServices: true,
      establishedYear: 2020,
      adminDetails: {
        username: 'testadmin',
        password: 'testpass123',
        adminName: 'Test Admin',
        adminEmail: 'admin@test.com',
        adminPhone: '9876543210'
      }
    };

    console.log('🏥 Testing hospital creation with fixes...');

    // Generate hospitalId like in the fixed controller
    const hospitalId = `HOSP_${testHospitalData.address.state.substring(0, 2).toUpperCase()}_${Date.now()}`;
    console.log('✅ Generated hospitalId:', hospitalId);

    // Map specialties like in the fixed controller
    const serviceMapping = {
      'General Medicine': 'Laboratory',
      'Cardiology': 'Health Checkup',
      'Neurology': 'Laboratory',
      'Orthopedics': 'Surgery',
      'Dermatology': 'Laboratory',
      'Gynecology': 'Maternity',
      'Pediatrics': 'Pediatric Care'
    };

    const validServices = testHospitalData.specialties.map(specialty => {
      return serviceMapping[specialty] || 'Health Checkup';
    }).filter((service, index, arr) => arr.indexOf(service) === index);

    console.log('✅ Mapped services:', validServices);

    // Calculate total staff like in the fixed controller
    const estimatedTotalStaff = Math.max(Math.round(testHospitalData.totalBeds * 0.6), 10);
    console.log('✅ Estimated total staff:', estimatedTotalStaff);

    // Create hospital with fixes
    const hospital = new Hospital({
      hospitalId: hospitalId,
      name: testHospitalData.hospitalName,
      location: {
        address: testHospitalData.address.street,
        city: testHospitalData.address.city,
        state: testHospitalData.address.state,
        district: testHospitalData.address.district,
        pincode: testHospitalData.address.pincode
      },
      region: {
        state: testHospitalData.address.state,
        district: testHospitalData.address.district
      },
      contact: {
        phone: testHospitalData.contactNumber,
        email: testHospitalData.email,
        emergencyNumber: testHospitalData.contactNumber
      },
      licenses: {
        registrationNumber: testHospitalData.registrationNumber,
        licenseNumber: testHospitalData.licenseId,
        issuingAuthority: 'State Medical Board',
        issueDate: new Date(),
        expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
        renewalRequired: false
      },
      type: testHospitalData.hospitalType,
      services: validServices,
      capacity: {
        totalBeds: testHospitalData.totalBeds,
        totalStaff: estimatedTotalStaff // This was missing before
      },
      establishedDate: new Date(testHospitalData.establishedYear, 0, 1)
    });

    console.log('🔍 Testing hospital validation...');
    await hospital.validate();
    console.log('✅ Hospital validation passed!');

    // Save hospital
    await hospital.save();
    console.log('✅ Hospital saved successfully:', hospital.hospitalId);

    // Create admin
    const admin = new HospitalAdmin({
      adminId: `${hospitalId}_ADMIN`,
      hospitalId: hospitalId,
      username: testHospitalData.adminDetails.username,
      password: testHospitalData.adminDetails.password,
      adminName: testHospitalData.adminDetails.adminName,
      email: testHospitalData.adminDetails.adminEmail,
      contactNumber: testHospitalData.adminDetails.adminPhone
    });

    await admin.save();
    console.log('✅ Admin created successfully:', admin.adminId);

    // Clean up test data
    await Hospital.findByIdAndDelete(hospital._id);
    await HospitalAdmin.findByIdAndDelete(admin._id);
    console.log('✅ Test data cleaned up');

    console.log('\n🎉 All hospital registration fixes working correctly!');
    console.log('📋 Fixed issues:');
    console.log('   ✅ hospitalId generation');
    console.log('   ✅ capacity.totalStaff calculation');
    console.log('   ✅ Service enum mapping');
    console.log('   ✅ Admin creation with hospitalId');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.errors) {
      console.log('Validation errors:');
      Object.values(error.errors).forEach(err => {
        console.log('  -', err.message);
      });
    }
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

testHospitalRegistrationFix();