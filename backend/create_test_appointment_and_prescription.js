const mongoose = require('mongoose');
require('dotenv').config();

const DB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth';

async function createTestAppointmentAndPrescription() {
    try {
        console.log('\n🏥 CREATING TEST APPOINTMENT AND PRESCRIPTION');
        console.log('=' .repeat(70));
        
        await mongoose.connect(DB_URI);
        console.log('✅ Connected to MongoDB:', DB_URI);
        
        // Step 1: Create a confirmed appointment
        console.log('\n🔵 STEP 1: CREATING CONFIRMED APPOINTMENT');
        console.log('=' .repeat(50));
        
        const appointmentsCollection = mongoose.connection.db.collection('appointments');
        
        const testAppointment = {
            _id: new mongoose.Types.ObjectId("68d29fdc8cd6da1fca2c18d0"), // Use the exact ID from frontend
            patientId: "NARE523407",
            doctorId: new mongoose.Types.ObjectId("68cfb6f6fd481e8dcf67744c"),
            hospitalId: "HOSP-001",
            patientName: "NARESHD NARESHD",
            patientUHID: "NARE523407",
            doctorName: "Dr. A John Smith",
            hospitalName: "Apollo Main Hospital",
            appointmentDate: new Date("2025-01-23"),
            appointmentTime: "10:00 AM",
            status: "confirmed", // This is key!
            isConfirmed: true,   // This too!
            createdAt: new Date(),
            updatedAt: new Date()
        };
        
        try {
            // Remove any existing appointment with same ID
            await appointmentsCollection.deleteOne({_id: testAppointment._id});
            
            const appointmentResult = await appointmentsCollection.insertOne(testAppointment);
            console.log('✅ Test appointment created successfully!');
            console.log('📄 Appointment ID:', appointmentResult.insertedId);
            console.log('📋 Status:', testAppointment.status);
            console.log('📋 Confirmed:', testAppointment.isConfirmed);
            
        } catch (appointmentError) {
            console.error('❌ Failed to create appointment:', appointmentError);
            return;
        }
        
        // Step 2: Create a doctor record
        console.log('\n🔵 STEP 2: CREATING DOCTOR RECORD');
        console.log('=' .repeat(50));
        
        const doctorsCollection = mongoose.connection.db.collection('doctors');
        
        const testDoctor = {
            _id: new mongoose.Types.ObjectId("68cfb6f6fd481e8dcf67744c"),
            doctorId: "DOC-001",
            name: "Dr. A John Smith",
            hospitalId: "HOSP-001",
            specialization: "General Medicine",
            experience: 10,
            createdAt: new Date(),
            updatedAt: new Date()
        };
        
        try {
            // Remove any existing doctor with same ID
            await doctorsCollection.deleteOne({_id: testDoctor._id});
            
            const doctorResult = await doctorsCollection.insertOne(testDoctor);
            console.log('✅ Test doctor created successfully!');
            console.log('📄 Doctor ID:', doctorResult.insertedId);
            console.log('📋 Doctor Name:', testDoctor.name);
            
        } catch (doctorError) {
            console.error('❌ Failed to create doctor:', doctorError);
        }
        
        // Step 3: Create patient record
        console.log('\n🔵 STEP 3: CREATING PATIENT RECORD');
        console.log('=' .repeat(50));
        
        const patientsCollection = mongoose.connection.db.collection('patients');
        
        const testPatient = {
            patientId: "NARE523407",
            uhid: "NARE523407",
            name: "NARESHD NARESHD",
            age: 25,
            gender: "Male",
            phone: "9876543210",
            address: "Test Address",
            createdAt: new Date(),
            updatedAt: new Date()
        };
        
        try {
            // Remove any existing patient with same ID
            await patientsCollection.deleteOne({patientId: testPatient.patientId});
            
            const patientResult = await patientsCollection.insertOne(testPatient);
            console.log('✅ Test patient created successfully!');
            console.log('📄 Patient ID:', testPatient.patientId);
            console.log('📋 Patient Name:', testPatient.name);
            
        } catch (patientError) {
            console.error('❌ Failed to create patient:', patientError);
        }
        
        // Step 4: Verify all records are created
        console.log('\n🔵 STEP 4: VERIFICATION');
        console.log('=' .repeat(50));
        
        const createdAppointment = await appointmentsCollection.findOne({_id: testAppointment._id});
        const createdDoctor = await doctorsCollection.findOne({_id: testDoctor._id});
        const createdPatient = await patientsCollection.findOne({patientId: testPatient.patientId});
        
        console.log('✅ Appointment exists:', !!createdAppointment);
        console.log('✅ Doctor exists:', !!createdDoctor);
        console.log('✅ Patient exists:', !!createdPatient);
        
        if (createdAppointment) {
            console.log('📋 Appointment Status:', createdAppointment.status);
            console.log('📋 Appointment Confirmed:', createdAppointment.isConfirmed);
        }
        
        console.log('\n🎉 Test data setup complete! Now you can test prescription creation.');
        console.log('\n📝 Use this appointment data for prescription:');
        console.log('- Appointment ID: 68d29fdc8cd6da1fca2c18d0');
        console.log('- Doctor ID: 68cfb6f6fd481e8dcf67744c');
        console.log('- Patient ID: NARE523407');
        console.log('- Status: confirmed');
        
    } catch (error) {
        console.error('\n❌ Setup failed:', error);
        console.error('🔍 Stack trace:', error.stack);
    } finally {
        await mongoose.disconnect();
        console.log('\n🔌 Disconnected from MongoDB');
    }
}

createTestAppointmentAndPrescription();