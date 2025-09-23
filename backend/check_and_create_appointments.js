// Check existing data in the database and use it for appointments
require('dotenv').config();
const mongoose = require('mongoose');

// Import models
const Hospital = require('./src/models/Hospital');
const HospitalDoctor = require('./src/models/HospitalDoctor');  
const Patient = require('./src/models/Patient');
const HospitalAppointment = require('./src/models/HospitalAppointment');

console.log('🔍 CHECKING EXISTING DATA FOR APPOINTMENTS');
console.log('='.repeat(50));

async function checkExistingData() {
  try {
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms';
    await mongoose.connect(mongoUri);
    console.log('✅ Connected to MongoDB');

    // 1. Check existing hospitals
    console.log('\n🏥 Checking existing hospitals...');
    const hospitals = await Hospital.find({}).limit(5);
    console.log(`Found ${hospitals.length} hospitals`);
    if (hospitals.length > 0) {
      console.log('Sample hospital:', {
        _id: hospitals[0]._id,
        name: hospitals[0].name,
        hospitalId: hospitals[0].hospitalId
      });
    }

    // 2. Check existing doctors
    console.log('\n👨‍⚕️ Checking existing doctors...');
    const doctors = await HospitalDoctor.find({}).limit(5);
    console.log(`Found ${doctors.length} doctors`);
    if (doctors.length > 0) {
      console.log('Sample doctor:', {
        _id: doctors[0]._id,
        name: doctors[0].name,
        doctorName: doctors[0].doctorName,
        specialization: doctors[0].specialization
      });
    }

    // 3. Check existing patients
    console.log('\n🏥 Checking existing patients...');
    const patients = await Patient.find({}).limit(5);
    console.log(`Found ${patients.length} patients`);
    if (patients.length > 0) {
      console.log('Sample patient:', {
        _id: patients[0]._id,
        fullName: patients[0].fullName,
        bloodGroup: patients[0].bloodGroup
      });
    }

    // 4. Check existing appointments
    console.log('\n📅 Checking existing appointments...');
    const appointments = await HospitalAppointment.find({}).limit(5).populate('patientId');
    console.log(`Found ${appointments.length} appointments`);
    if (appointments.length > 0) {
      console.log('Sample appointment:', {
        _id: appointments[0]._id,
        appointmentId: appointments[0].appointmentId,
        patientName: appointments[0].patientName,
        doctorName: appointments[0].doctorName,
        status: appointments[0].status
      });
    }

    if (hospitals.length > 0 && doctors.length > 0 && patients.length > 0) {
      console.log('\n✅ Found existing data! Creating sample appointments...');
      await createSampleAppointments(hospitals[0], doctors[0], patients[0]);
    } else {
      console.log('\n❌ Not enough existing data to create appointments');
      console.log('Missing:');
      if (hospitals.length === 0) console.log('- Hospitals');
      if (doctors.length === 0) console.log('- Doctors');  
      if (patients.length === 0) console.log('- Patients');
    }
    
  } catch (error) {
    console.error('❌ Error checking data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('📡 Disconnected from MongoDB');
  }
}

async function createSampleAppointments(hospital, doctor, patient) {
  try {
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
        patientGender: patient.gender || 'male',
        patientAge: patient.age || 30,
        patientState: patient.state || 'Maharashtra',
        hospitalStaffId: doctor._id,
        doctorName: doctor.name || doctor.doctorName || 'Dr. Unknown',
        hospitalId: hospital._id,
        hospitalName: hospital.name || hospital.hospitalName,
        appointmentDate: new Date('2025-09-23'),
        appointmentTime: '10:00 AM',
        reason: 'Regular checkup',
        consultationFee: 500,
        status: 'approved',
        notes: 'First appointment for the patient'
      },
      {
        appointmentId: 'TEST-APT-002',
        patientId: patient._id,
        patientName: patient.fullName,
        patientUhid: `UHID-${patient._id.toString().slice(-6)}`,
        patientGender: patient.gender || 'male',
        patientAge: patient.age || 30,
        patientState: patient.state || 'Maharashtra',
        hospitalStaffId: doctor._id,
        doctorName: doctor.name || doctor.doctorName || 'Dr. Unknown',
        hospitalId: hospital._id,
        hospitalName: hospital.name || hospital.hospitalName,
        appointmentDate: new Date('2025-09-24'),
        appointmentTime: '2:00 PM',
        reason: 'Follow-up consultation',
        consultationFee: 500,
        status: 'approved',
        notes: 'Follow-up after initial consultation'
      },
      {
        appointmentId: 'TEST-APT-003',
        patientId: patient._id,
        patientName: patient.fullName,
        patientUhid: `UHID-${patient._id.toString().slice(-6)}`,
        patientGender: patient.gender || 'male',
        patientAge: patient.age || 30,
        patientState: patient.state || 'Maharashtra',
        hospitalStaffId: doctor._id,
        doctorName: doctor.name || doctor.doctorName || 'Dr. Unknown',
        hospitalId: hospital._id,
        hospitalName: hospital.name || hospital.hospitalName,
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

    // Verify by fetching appointments for the doctor
    console.log('\n🔍 Verifying appointments...');
    const doctorAppointments = await HospitalAppointment.find({ 
      hospitalStaffId: doctor._id 
    }).populate('patientId', 'fullName bloodGroup phone');

    console.log(`✅ Found ${doctorAppointments.length} appointments for doctor ${doctor.name || doctor.doctorName}`);
    
    if (doctorAppointments.length > 0) {
      console.log('📋 Sample appointment details:');
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

    console.log('\n✅ Appointments created successfully!');
    console.log(`🏥 Hospital: ${hospital.name || hospital.hospitalName}`);
    console.log(`👨‍⚕️ Doctor: ${doctor.name || doctor.doctorName} (ID: ${doctor._id})`);
    console.log(`🏥 Patient: ${patient.fullName}`);
    
  } catch (error) {
    console.error('❌ Error creating appointments:', error);
  }
}

checkExistingData();