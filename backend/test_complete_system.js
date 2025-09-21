const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Hospital = require('./src/models/Hospital');
const RegionalOfficer = require('./src/models/RegionalOfficer');
const HospitalAdmin = require('./src/models/HospitalAdmin');
const HospitalDoctor = require('./src/models/HospitalDoctor');
const HospitalAssistant = require('./src/models/HospitalAssistant');

async function testCompleteSystem() {
  try {
    console.log('🔌 Connecting to MongoDB Atlas...');
    
    const mongoURI = process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth';
    console.log('URI:', mongoURI.replace(/\/\/.*:.*@/, '//***:***@'));
    
    await mongoose.connect(mongoURI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('✅ Connected to MongoDB Atlas successfully\n');

    // Step 1: Create a Regional Officer
    console.log('👨‍💼 Creating Regional Officer...');
    const regionalOfficer = new RegionalOfficer({
      username: 'rajesh.kumar',
      password: '$2b$10$hash123456', // In real app, this would be properly hashed
      firstName: 'Rajesh',
      lastName: 'Kumar',
      fullName: 'Dr. Rajesh Kumar',
      aadhaarNumber: '123456789012',
      email: 'rajesh.kumar@health.gov.in',
      phone: '9876543210',
      dateOfBirth: new Date('1975-05-15'),
      gender: 'male',
      officerRank: 'regional_director',
      employeeId: 'EMP-RO-2024-001',
      department: 'Health Department',
      assignedRegion: 'South Zone',
      assignedDistricts: ['Bangalore Urban', 'Bangalore Rural', 'Mysore'],
      assignedStates: ['Karnataka'],
      jurisdictionLevel: 'regional',
      officeAddress: {
        buildingName: 'Karnataka Health Department',
        street: 'Vidhana Soudha Road',
        city: 'Bangalore',
        state: 'Karnataka',
        zipCode: '560001'
      },
      officePhone: '080-22251000',
      responsibilities: ['health_monitoring', 'policy_implementation', 'hospital_oversight'],
      clearanceLevel: 'advanced',
      address: {
        street: '123 MG Road',
        city: 'Bangalore',
        state: 'Karnataka',
        zipCode: '560001'
      },
      yearsOfService: 15,
      appointmentDate: new Date('2009-06-01'),
      isActive: true
    });

    await regionalOfficer.save();
    console.log('✅ Regional Officer created:', regionalOfficer._id);

    // Step 2: Create Hospital with proper ObjectId references
    console.log('\n🏥 Creating test hospital...');
    const hospital = new Hospital({
      hospitalId: 'HOSP-KA-BLR-001',
      name: 'Apollo Hospital Bangalore',
      location: {
        address: '154/11, Opposite IIMBangalore, Bannerghatta Road',
        city: 'Bangalore',
        state: 'Karnataka',
        district: 'Bangalore Urban',
        pincode: '560076',
        coordinates: {
          latitude: 12.8438,
          longitude: 77.6632
        }
      },
      contact: {
        phone: '080-26304050',
        email: 'info@apollohospitals.com',
        website: 'https://www.apollohospitals.com',
        emergencyContact: '080-26304444'
      },
      type: 'Multi-Specialty',
      category: 'Corporate',
      capacity: {
        totalBeds: 550,
        icuBeds: 50,
        emergencyBeds: 30,
        operationTheaters: 12
      },
      services: [
        'Cardiology',
        'Neurology',
        'Oncology',
        'Orthopedics',
        'Emergency Medicine',
        'ICU',
        'Laboratory',
        'Radiology'
      ],
      facilities: [
        'Blood Bank',
        'Pharmacy',
        'Ambulance Service',
        'Cafeteria',
        'Parking',
        '24x7 Emergency'
      ],
      licenses: [
        {
          type: 'Hospital License',
          number: 'HL-KA-2024-001',
          issuedBy: 'Karnataka Health Department',
          issuedDate: new Date('2024-01-15'),
          expiryDate: new Date('2029-01-14'),
          isActive: true
        }
      ],
      accreditations: [
        {
          type: 'NABH',
          level: 'Full Accreditation',
          validFrom: new Date('2023-06-01'),
          validUntil: new Date('2026-05-31'),
          isActive: true
        }
      ],
      managedBy: regionalOfficer._id,
      establishedDate: new Date('2010-03-15'),
      status: 'Active',
      isActive: true
    });

    await hospital.save();
    console.log('✅ Hospital created:', hospital._id);

    // Step 3: Create Hospital Admin
    console.log('\n👨‍💼 Creating Hospital Admin...');
    const hospitalAdmin = new HospitalAdmin({
      adminId: 'ADMIN-' + hospital.hospitalId + '-001',
      hospitalId: hospital.hospitalId,
      username: 'priya.admin',
      password: '$2b$10$hash123456', // In real app, this would be properly hashed
      adminName: 'Priya Sharma',
      email: 'priya.sharma@apollohospitals.com',
      contactNumber: '9876543211',
      isActive: true
    });

    await hospitalAdmin.save();
    console.log('✅ Hospital Admin created:', hospitalAdmin._id);

    // Step 4: Create Hospital Doctor
    console.log('\n👨‍⚕️ Creating Hospital Doctor...');
    const hospitalDoctor = new HospitalDoctor({
      doctorId: 'DOC-' + hospital.hospitalId + '-001',
      hospitalId: hospital.hospitalId,
      username: 'arun.doctor',
      password: '$2b$10$hash123456', // In real app, this would be properly hashed
      doctorName: 'Dr. Arun Patel',
      specialization: 'Cardiology',
      email: 'arun.patel@apollohospitals.com',
      contactNumber: '9876543212',
      qualification: {
        degree: 'MBBS, MD Cardiology'
      },
      registrationNumber: 'KMC67890',
      department: 'Cardiology',
      isActive: true
    });

    await hospitalDoctor.save();
    console.log('✅ Hospital Doctor created:', hospitalDoctor._id);

    // Step 5: Create Hospital Assistant
    console.log('\n👩‍⚕️ Creating Hospital Assistant...');
    const hospitalAssistant = new HospitalAssistant({
      assistantId: 'ASST-' + hospital.hospitalId + '-001',
      hospitalId: hospital.hospitalId,
      username: 'sunita.assistant',
      password: '$2b$10$hash123456', // In real app, this would be properly hashed
      assistantName: 'Sunita Rao',
      email: 'sunita.rao@apollohospitals.com',
      contactNumber: '9876543213',
      qualification: {
        degree: 'B.Sc Nursing'
      },
      assignedDepartment: 'Cardiology',
      isActive: true
    });

    await hospitalAssistant.save();
    console.log('✅ Hospital Assistant created:', hospitalAssistant._id);

    // Verification: Check all created records
    console.log('\n📊 Verification Summary:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🏥 Hospital: ${hospital.name} (ID: ${hospital.hospitalId})`);
    console.log(`👨‍💼 Regional Officer: ${regionalOfficer.fullName} (${regionalOfficer.employeeId})`);
    console.log(`🔧 Admin: ${hospitalAdmin.adminName} (${hospitalAdmin.adminId})`);
    console.log(`👨‍⚕️ Doctor: ${hospitalDoctor.doctorName} (${hospitalDoctor.doctorId})`);
    console.log(`👩‍⚕️ Assistant: ${hospitalAssistant.assistantName} (${hospitalAssistant.assistantId})`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    console.log('\n✅ All records created successfully in MongoDB Atlas!');
    console.log('🎉 Database test completed successfully!');

  } catch (error) {
    console.error('❌ Database test failed:', error.message);
    console.error('Full error:', error);
  } finally {
    console.log('\n🔌 Disconnecting from MongoDB...');
    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB');
  }
}

// Run the test
testCompleteSystem();