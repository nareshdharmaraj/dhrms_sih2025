const mongoose = require('mongoose');
require('dotenv').config();

const DB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth';

async function checkAppointmentsForPrescriptionTest() {
    try {
        console.log('\n🔍 CHECKING APPOINTMENTS FOR PRESCRIPTION TEST DATA');
        console.log('=' .repeat(60));
        
        await mongoose.connect(DB_URI);
        console.log('✅ Connected to MongoDB:', DB_URI);
        
        // Check appointments collection
        const appointmentsCollection = mongoose.connection.db.collection('appointments');
        const appointments = await appointmentsCollection.find({}).limit(5).toArray();
        
        console.log(`\n📋 Found ${appointments.length} appointments:`);
        appointments.forEach((appointment, index) => {
            console.log(`\nAppointment ${index + 1}:`);
            console.log('- ID:', appointment._id);
            console.log('- Patient ID:', appointment.patientId);
            console.log('- Doctor ID:', appointment.doctorId);
            console.log('- Hospital ID:', appointment.hospitalId);
            console.log('- Date:', appointment.appointmentDate);
            console.log('- Status:', appointment.status);
            console.log('- Patient Name:', appointment.patientName);
            console.log('- Doctor Name:', appointment.doctorName);
        });
        
        // Check for any existing prescriptions
        const prescriptionsCollection = mongoose.connection.db.collection('hospitalprescriptions');
        const existingPrescriptions = await prescriptionsCollection.find({}).toArray();
        
        console.log(`\n💊 Found ${existingPrescriptions.length} existing prescriptions in 'hospitalprescriptions' collection:`);
        if (existingPrescriptions.length > 0) {
            existingPrescriptions.forEach((prescription, index) => {
                console.log(`\nPrescription ${index + 1}:`);
                console.log('- ID:', prescription._id);
                console.log('- Patient ID:', prescription.patientId);
                console.log('- Doctor ID:', prescription.doctorId || prescription.doctorIdentifier);
                console.log('- Hospital ID:', prescription.hospitalId);
                console.log('- Date:', prescription.createdAt);
                console.log('- Medicines:', prescription.medicines?.length || 0);
            });
        }
        
        // Prepare test prescription data based on existing appointment
        if (appointments.length > 0) {
            const testAppointment = appointments[0];
            console.log('\n🧪 PREPARING TEST PRESCRIPTION DATA');
            console.log('=' .repeat(60));
            
            const testPrescriptionData = {
                patientId: testAppointment.patientId,
                doctorId: testAppointment.doctorId,
                hospitalId: testAppointment.hospitalId,
                appointmentId: testAppointment._id,
                patientName: testAppointment.patientName || "Test Patient",
                doctorName: testAppointment.doctorName || "Test Doctor",
                medicines: [
                    {
                        name: "Paracetamol",
                        type: "tablet",
                        dosage: "500mg",
                        frequency: "3 times daily",
                        duration: "5 days",
                        instructions: "Take after meals"
                    },
                    {
                        name: "Cough Syrup",
                        type: "tonic",
                        dosage: "10ml",
                        frequency: "2 times daily",
                        duration: "7 days",
                        instructions: "Take before bedtime"
                    }
                ],
                symptoms: "Fever and cough",
                diagnosis: "Common cold",
                notes: "Rest and drink plenty of fluids"
            };
            
            console.log('\n✨ Test Prescription Data Ready:');
            console.log(JSON.stringify(testPrescriptionData, null, 2));
            
            return testPrescriptionData;
        } else {
            console.log('\n❌ No appointments found for testing');
            return null;
        }
        
    } catch (error) {
        console.error('\n❌ Error checking appointments:', error);
        return null;
    } finally {
        await mongoose.disconnect();
        console.log('\n🔌 Disconnected from MongoDB');
    }
}

checkAppointmentsForPrescriptionTest();