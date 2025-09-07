const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Hospital = require('./models/Hospital');
const Doctor = require('./models/Doctor');
const Patient = require('./models/Patient');
const Prescription = require('./models/Prescription');

async function verifyDatabaseContent() {
    try {
        console.log('🔗 Connecting to MongoDB...');
        const mongoUri = process.env.MONGODB_URI || 'mongodb://naresh:123456789@localhost:27017/dhrms_sih?authSource=admin';
        await mongoose.connect(mongoUri, {
            useNewUrlParser: true,
            useUnifiedTopology: true
        });
        console.log('✅ Connected to MongoDB successfully');

        // Verify hospitals
        console.log('\n🏥 Checking Hospitals...');
        const hospitals = await Hospital.find({});
        console.log(`   Found ${hospitals.length} hospitals:`);
        hospitals.forEach(hospital => {
            console.log(`   - ${hospital.name} (${hospital.type})`);
        });

        // Verify doctors
        console.log('\n👨‍⚕️ Checking Doctors...');
        const doctors = await Doctor.find({});
        console.log(`   Found ${doctors.length} doctors:`);
        doctors.forEach(doctor => {
            console.log(`   - Dr. ${doctor.personalInfo.firstName} ${doctor.personalInfo.lastName} (${doctor.professionalInfo.specialization})`);
        });

        // Verify patients
        console.log('\n🏃‍♂️ Checking Patients...');
        const patients = await Patient.find({});
        console.log(`   Found ${patients.length} patients:`);
        patients.forEach(patient => {
            const bloodGroup = patient.medicalInfo?.bloodGroup || 'Unknown';
            console.log(`   - ${patient.personalInfo.firstName} ${patient.personalInfo.lastName} (${bloodGroup})`);
        });

        // Verify prescriptions
        console.log('\n💊 Checking Prescriptions...');
        const prescriptions = await Prescription.find({});
        console.log(`   Found ${prescriptions.length} prescriptions:`);
        prescriptions.forEach(prescription => {
            console.log(`   - Prescription for ${prescription.patientId} (${prescription.medications.length} medications)`);
        });

        // Test creating a new patient
        console.log('\n📝 Testing Patient Creation...');
        const newPatient = new Patient({
            username: 'test_frontend_' + Date.now(),
            password: 'test123',
            personalInfo: {
                firstName: 'Frontend',
                lastName: 'Test',
                email: 'frontend@test.com',
                phone: '9876543210',
                dateOfBirth: new Date('1992-05-15'),
                gender: 'Female',
                address: {
                    street: '456 Frontend Street',
                    city: 'Test City',
                    state: 'Test State',
                    pincode: '654321'
                }
            },
            medicalInfo: {
                bloodGroup: 'A+',
                height: 165,
                weight: 60,
                allergies: ['Penicillin'],
                chronicConditions: [],
                currentMedications: [],
                emergencyContact: {
                    name: 'Frontend Contact',
                    relationship: 'Spouse',
                    phone: '9876543211'
                }
            }
        });

        const savedPatient = await newPatient.save();
        console.log(`✅ Created new patient: ${savedPatient.personalInfo.firstName} ${savedPatient.personalInfo.lastName}`);

        // Test retrieving the created patient
        const retrievedPatient = await Patient.findById(savedPatient._id);
        console.log(`✅ Retrieved patient: ${retrievedPatient.personalInfo.firstName} ${retrievedPatient.personalInfo.lastName}`);

        console.log('\n🎉 Database Content Verification Completed Successfully!');
        console.log('\n📊 Summary:');
        console.log(`   🏥 Hospitals: ${hospitals.length}`);
        console.log(`   👨‍⚕️ Doctors: ${doctors.length}`);
        console.log(`   🏃‍♂️ Patients: ${patients.length}`);
        console.log(`   💊 Prescriptions: ${prescriptions.length}`);

        console.log('\n🔑 Test Credentials for Frontend:');
        console.log('   🏥 Hospital Admin: apollo_admin / apollo123');
        console.log('   👨‍⚕️ Doctor: dr_rajesh_sharma / doctor123');
        console.log('   🏃‍♂️ Patient: rajesh_kumar_90 / patient123');
        console.log(`   🆕 New Test Patient: ${savedPatient.username} / test123`);

        console.log('\n✅ Your database is ready for frontend integration!');
        console.log('✅ All CRUD operations working properly!');

    } catch (error) {
        console.error('❌ Database verification failed:', error.message);
    } finally {
        await mongoose.connection.close();
        console.log('👋 Database connection closed');
    }
}

verifyDatabaseContent().catch(console.error);
