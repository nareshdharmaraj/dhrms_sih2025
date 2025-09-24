const mongoose = require('mongoose');
const Patient = require('./src/models/Patient');
const HospitalDoctor = require('./src/models/HospitalDoctor');
const Hospital = require('./src/models/Hospital');
const HospitalAppointment = require('./src/models/HospitalAppointment');

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function seedTestData() {
  try {
    console.log('🌱 Seeding test data for appointment workflow...');

    // Create test patient
    const testPatient = await Patient.findOneAndUpdate(
      { uhid: 'TEST_PATIENT_001' },
      {
        uhid: 'TEST_PATIENT_001',
        name: 'John Doe',
        gender: 'male',
        age: 35,
        state: 'Karnataka',
        district: 'Bangalore Urban',
        phoneNumber: '9876543210',
        email: 'john.doe@test.com',
        address: 'Test Address, Bangalore',
        bloodGroup: 'O+',
        emergencyContact: {
          name: 'Jane Doe',
          relationship: 'spouse',
          phoneNumber: '9876543211'
        }
      },
      { upsert: true, new: true }
    );

    // Create test hospital
    const testHospital = await Hospital.findOneAndUpdate(
      { hospitalId: 'HOSP_TEST_001' },
      {
        hospitalId: 'HOSP_TEST_001',
        hospitalName: 'Apollo Test Hospital',
        address: {
          street: 'Test Street',
          city: 'Bangalore',
          state: 'Karnataka',
          zipCode: '560001',
          district: 'Bangalore Urban'
        },
        contactInfo: {
          phone: '080-12345678',
          email: 'info@apollotest.com'
        },
        hospitalType: 'multi_specialty',
        accreditation: ['NABH', 'NABL'],
        facilities: ['emergency', 'icu', 'cardiology', 'orthopedics'],
        capacity: {
          totalBeds: 200,
          icuBeds: 20,
          emergencyBeds: 10
        }
      },
      { upsert: true, new: true }
    );

    // Create test doctor
    const testDoctor = await HospitalDoctor.findOneAndUpdate(
      { doctorId: 'DOC_TEST_001' },
      {
        doctorId: 'DOC_TEST_001',
        doctorName: 'Dr. Smith Kumar',
        specialization: 'General Medicine',
        qualification: 'MBBS, MD',
        experience: 10,
        hospitalId: testHospital.hospitalId,
        hospitalName: testHospital.hospitalName,
        consultationFee: 500,
        availability: {
          days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
          timeSlots: ['09:00-12:00', '14:00-17:00']
        },
        contactInfo: {
          phone: '9876543212',
          email: 'dr.smith@apollotest.com'
        },
        department: 'General Medicine',
        status: 'active'
      },
      { upsert: true, new: true }
    );

    // Create a few test appointments with different statuses
    const testAppointments = [
      {
        appointmentId: 'APT_TEST_001',
        patientId: testPatient._id,
        patientName: testPatient.name,
        patientUhid: testPatient.uhid,
        patientGender: testPatient.gender,
        patientAge: testPatient.age,
        patientState: testPatient.state,
        doctorId: testDoctor._id,
        doctorName: testDoctor.doctorName,
        hospitalId: testHospital.hospitalId,
        hospitalName: testHospital.hospitalName,
        appointmentDate: '2024-02-20',
        appointmentTime: '10:00 AM',
        reason: 'Regular checkup',
        consultationFee: testDoctor.consultationFee,
        status: 'pending'
      },
      {
        appointmentId: 'APT_TEST_002',
        patientId: testPatient._id,
        patientName: testPatient.name,
        patientUhid: testPatient.uhid,
        patientGender: testPatient.gender,
        patientAge: testPatient.age,
        patientState: testPatient.state,
        doctorId: testDoctor._id,
        doctorName: testDoctor.doctorName,
        hospitalId: testHospital.hospitalId,
        hospitalName: testHospital.hospitalName,
        appointmentDate: '2024-02-21',
        appointmentTime: '02:00 PM',
        reason: 'Follow-up consultation',
        consultationFee: testDoctor.consultationFee,
        status: 'approved'
      },
      {
        appointmentId: 'APT_TEST_003',
        patientId: testPatient._id,
        patientName: testPatient.name,
        patientUhid: testPatient.uhid,
        patientGender: testPatient.gender,
        patientAge: testPatient.age,
        patientState: testPatient.state,
        doctorId: testDoctor._id,
        doctorName: testDoctor.doctorName,
        hospitalId: testHospital.hospitalId,
        hospitalName: testHospital.hospitalName,
        appointmentDate: '2024-02-19',
        appointmentTime: '11:00 AM',
        reason: 'Health screening',
        consultationFee: testDoctor.consultationFee,
        status: 'completed'
      }
    ];

    // Insert test appointments
    for (const appointmentData of testAppointments) {
      await HospitalAppointment.findOneAndUpdate(
        { appointmentId: appointmentData.appointmentId },
        appointmentData,
        { upsert: true, new: true }
      );
    }

    console.log('✅ Test data seeded successfully!');
    console.log(`📋 Created/Updated:`);
    console.log(`   Patient: ${testPatient.name} (${testPatient.uhid})`);
    console.log(`   Hospital: ${testHospital.hospitalName} (${testHospital.hospitalId})`);
    console.log(`   Doctor: ${testDoctor.doctorName} (${testDoctor.doctorId})`);
    console.log(`   Appointments: ${testAppointments.length} test appointments`);
    console.log(`\n🔧 Test Configuration:`);
    console.log(`   Patient ID: ${testPatient._id}`);
    console.log(`   Doctor ID: ${testDoctor._id}`);
    console.log(`   Hospital ID: ${testHospital.hospitalId}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding test data:', error);
    process.exit(1);
  }
}

// Handle database connection
mongoose.connection.on('connected', () => {
  console.log('✅ Connected to MongoDB');
  seedTestData();
});

mongoose.connection.on('error', (error) => {
  console.error('❌ MongoDB connection error:', error);
  process.exit(1);
});

mongoose.connection.on('disconnected', () => {
  console.log('📋 Disconnected from MongoDB');
});