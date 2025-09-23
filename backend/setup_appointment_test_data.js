// Setup proper test data for appointments with real ObjectIds
require('dotenv').config();
const mongoose = require('mongoose');

// Import models
const Hospital = require('./src/models/Hospital');
const HospitalDoctor = require('./src/models/HospitalDoctor');  
const Patient = require('./src/models/Patient');
const HospitalAppointment = require('./src/models/HospitalAppointment');

console.log('🔧 SETTING UP APPOINTMENT TEST DATA');
console.log('='.repeat(50));

async function setupTestData() {
  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // 1. Check if hospital exists, create if not
    console.log('\n📋 Setting up Hospital...');
    let hospital = await Hospital.findOne({ hospitalName: 'Apollo Main Hospital' });
    if (!hospital) {
      hospital = new Hospital({
        hospitalName: 'Apollo Main Hospital',
        location: 'Mumbai',
        state: 'Maharashtra',
        pincode: '400001',
        phone: '9876543210',
        email: 'apollo@gmail.com',
        status: 'Active'
      });
      await hospital.save();
      console.log('✅ Created hospital:', hospital.hospitalName);
    } else {
      console.log('✅ Hospital already exists:', hospital.hospitalName);
    }

    // 2. Check if doctor exists, create if not
    console.log('\n👨‍⚕️ Setting up Doctor...');
    let doctor = await HospitalDoctor.findOne({ fullName: 'Dr. Test Doctor' });
    if (!doctor) {
      doctor = new HospitalDoctor({
        fullName: 'Dr. Test Doctor',
        email: 'testdoctor@apollo.com',
        phone: '9876543210',
        specialization: 'Cardiology',
        qualification: 'MBBS, MD',
        hospitalId: hospital._id,
        hospitalName: hospital.hospitalName,
        status: 'active'
      });
      await doctor.save();
      console.log('✅ Created doctor:', doctor.fullName);
    } else {
      console.log('✅ Doctor already exists:', doctor.fullName);
    }

    // 3. Check if patient exists, create if not
    console.log('\n🏥 Setting up Patient...');
    let patient = await Patient.findOne({ fullName: 'Test Patient Flutter' });
    if (!patient) {
      patient = new Patient({
        fullName: 'Test Patient Flutter',
        email: 'testpatient@gmail.com',
        phone: '8765432109',
        bloodGroup: 'O+',
        gender: 'male',
        age: 30,
        state: 'Maharashtra'
      });
      await patient.save();
      console.log('✅ Created patient:', patient.fullName);
    } else {
      console.log('✅ Patient already exists:', patient.fullName);
    }

    // 4. Create multiple test appointments
    console.log('\n📅 Setting up Appointments...');
    
    // Clear existing test appointments
    await HospitalAppointment.deleteMany({ 
      appointmentId: { $regex: /^TEST-APT-/ }
    });

    const testAppointments = [
      {
        appointmentId: 'TEST-APT-001',
        patientId: patient._id,
        patientName: patient.fullName,
        patientUhid: `UHID-${patient._id.toString().slice(-6)}`,
        patientGender: patient.gender,
        patientAge: patient.age,
        patientState: patient.state,
        hospitalStaffId: doctor._id,
        doctorName: doctor.fullName,
        hospitalId: hospital._id,
        hospitalName: hospital.hospitalName,
        appointmentDate: new Date('2025-09-23'),
        appointmentTime: '10:00 AM',
        reason: 'Regular checkup',
        consultationFee: 500,
        status: 'scheduled',
        notes: 'First appointment for the patient'
      },
      {
        appointmentId: 'TEST-APT-002',
        patientId: patient._id,
        patientName: patient.fullName,
        patientUhid: `UHID-${patient._id.toString().slice(-6)}`,
        patientGender: patient.gender,
        patientAge: patient.age,
        patientState: patient.state,
        hospitalStaffId: doctor._id,
        doctorName: doctor.fullName,
        hospitalId: hospital._id,
        hospitalName: hospital.hospitalName,
        appointmentDate: new Date('2025-09-24'),
        appointmentTime: '2:00 PM',
        reason: 'Follow-up consultation',
        consultationFee: 500,
        status: 'scheduled',
        notes: 'Follow-up after initial consultation'
      },
      {
        appointmentId: 'TEST-APT-003',
        patientId: patient._id,
        patientName: patient.fullName,
        patientUhid: `UHID-${patient._id.toString().slice(-6)}`,
        patientGender: patient.gender,
        patientAge: patient.age,
        patientState: patient.state,
        hospitalStaffId: doctor._id,
        doctorName: doctor.fullName,
        hospitalId: hospital._id,
        hospitalName: hospital.hospitalName,
        appointmentDate: new Date('2025-09-22'),
        appointmentTime: '4:00 PM',
        reason: 'Emergency consultation',
        consultationFee: 750,
        status: 'completed',
        notes: 'Emergency case - treated successfully'
      }
    ];

    for (const appointmentData of testAppointments) {
      const appointment = new HospitalAppointment(appointmentData);
      await appointment.save();
      console.log(`✅ Created appointment: ${appointment.appointmentId}`);
    }

    // 5. Verify data by fetching appointments for the doctor
    console.log('\n🔍 Verifying setup...');
    const doctorAppointments = await HospitalAppointment.find({ 
      hospitalStaffId: doctor._id 
    }).populate('patientId', 'fullName bloodGroup phone');

    console.log(`✅ Found ${doctorAppointments.length} appointments for doctor`);
    
    if (doctorAppointments.length > 0) {
      console.log('📋 Sample appointment:');
      const sample = doctorAppointments[0];
      console.log({
        appointmentId: sample.appointmentId,
        patientName: sample.patientName,
        doctorName: sample.doctorName,
        hospitalName: sample.hospitalName,
        date: sample.appointmentDate,
        time: sample.appointmentTime,
        status: sample.status
      });
    }

    console.log('\n✅ Test data setup completed successfully!');
    console.log(`🏥 Hospital ID: ${hospital._id}`);
    console.log(`👨‍⚕️ Doctor ID: ${doctor._id}`);
    console.log(`🏥 Patient ID: ${patient._id}`);
    
  } catch (error) {
    console.error('❌ Error setting up test data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('📡 Disconnected from MongoDB');
  }
}

setupTestData();