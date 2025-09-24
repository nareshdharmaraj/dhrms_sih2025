const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const HospitalAppointment = require('./src/models/HospitalAppointment');
const HospitalDoctor = require('./src/models/HospitalDoctor');
const HospitalPrescription = require('./src/models/HospitalPrescription');

async function testPrescriptionSystem() {
  try {
    console.log('🔄 Connecting to MongoDB...');
    
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms_db';
    await mongoose.connect(mongoUri);
    
    console.log('✅ Connected to MongoDB successfully');
    
    // 1. Check existing appointments
    console.log('\n📋 Checking existing appointments...');
    const appointments = await HospitalAppointment.find({ status: 'confirmed' }).limit(5);
    console.log(`Found ${appointments.length} confirmed appointments`);
    
    if (appointments.length > 0) {
      const appointment = appointments[0];
      console.log('Sample appointment data:', {
        _id: appointment._id,
        appointmentNumber: appointment.appointmentNumber,
        patientName: appointment.patientName,
        patientUhid: appointment.patientUhid,
        doctorId: appointment.doctorId,
        status: appointment.status
      });
      
      // 2. Check if doctor exists
      console.log('\n👨‍⚕️ Checking doctor data...');
      const doctor = await HospitalDoctor.findById(appointment.doctorId);
      if (doctor) {
        console.log('Doctor found:', {
          _id: doctor._id,
          name: doctor.name,
          doctorId: doctor.doctorId,
          hospitalName: doctor.hospitalName,
          hospitalId: doctor.hospitalId
        });
        
        // 3. Try to create a test prescription
        console.log('\n💊 Creating test prescription...');
        
        const testPrescription = new HospitalPrescription({
          appointmentId: appointment._id,
          doctorId: doctor._id,
          patientId: appointment.patientId || new mongoose.Types.ObjectId(),
          hospitalId: doctor.hospitalId,
          patientName: appointment.patientName,
          patientUHID: appointment.patientUhid || 'TEST-UHID-001',
          doctorName: doctor.name,
          doctorId: doctor.doctorId,
          hospitalName: doctor.hospitalName,
          hospitalAddress: doctor.hospitalAddress || 'Test Address',
          hospitalContact: {
            phone: doctor.hospitalPhone || '1234567890',
            email: doctor.hospitalEmail || 'test@hospital.com'
          },
          appointmentNumber: appointment.appointmentNumber,
          diseaseName: 'Test Disease',
          diseaseType: 'not_communicable',
          medicines: [{
            type: 'tablet',
            name: 'Test Medicine',
            power: '500mg',
            countPerDose: 1,
            timing: ['morning'],
            beforeAfterFood: 'after',
            duration: 7,
            totalCount: 7
          }],
          isConfirmed: true,
          confirmedAt: new Date()
        });

        const savedPrescription = await testPrescription.save();
        console.log('✅ Test prescription created successfully!');
        console.log('Prescription ID:', savedPrescription._id);
        
        // 4. Verify the prescription was saved
        const verifyPrescription = await HospitalPrescription.findById(savedPrescription._id);
        if (verifyPrescription) {
          console.log('✅ Prescription verified in database');
          
          // Clean up - delete the test prescription
          await HospitalPrescription.findByIdAndDelete(savedPrescription._id);
          console.log('🧹 Test prescription cleaned up');
        }
        
      } else {
        console.log('❌ Doctor not found for appointment');
      }
    } else {
      console.log('❌ No confirmed appointments found');
    }
    
    // 5. Check prescription collection structure
    console.log('\n🗂️ Checking prescription collection...');
    const prescriptionCount = await HospitalPrescription.countDocuments();
    console.log(`Total prescriptions in database: ${prescriptionCount}`);
    
    // 6. List all collections
    console.log('\n📊 Database collections:');
    const collections = await mongoose.connection.db.listCollections().toArray();
    collections.forEach(col => {
      console.log(`  - ${col.name}`);
    });
    
  } catch (error) {
    console.error('❌ Error in prescription test:', error);
    console.error('Error details:', error.message);
    if (error.stack) {
      console.error('Stack trace:', error.stack);
    }
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
}

// Run the test
testPrescriptionSystem();