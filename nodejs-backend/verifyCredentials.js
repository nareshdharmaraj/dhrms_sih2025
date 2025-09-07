const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Connect to MongoDB
const mongoURI = 'mongodb://naresh:123456789@localhost:27017/myhealth?authSource=admin';

async function verifyDatabase() {
    try {
        console.log('🔍 DHRMS Database Verification');
        console.log('================================');
        
        await mongoose.connect(mongoURI);
        console.log('✅ Connected to MongoDB');

        // Define the schemas (simplified versions)
        const patientSchema = new mongoose.Schema({
            username: String,
            password: String,
            name: String,
            email: String,
            role: String
        });

        const doctorSchema = new mongoose.Schema({
            username: String,
            password: String,
            name: String,
            email: String,
            specialization: String,
            role: String
        });

        const hospitalSchema = new mongoose.Schema({
            username: String,
            password: String,
            name: String,
            email: String,
            role: String
        });

        const Patient = mongoose.model('Patient', patientSchema);
        const Doctor = mongoose.model('Doctor', doctorSchema);
        const Hospital = mongoose.model('Hospital', hospitalSchema);

        console.log('\n📋 PATIENT CREDENTIALS:');
        console.log('========================');
        const patients = await Patient.find({}, 'username name email role').limit(5);
        for (const patient of patients) {
            console.log(`Username: ${patient.username}`);
            console.log(`Name: ${patient.name}`);
            console.log(`Email: ${patient.email}`);
            console.log(`Role: ${patient.role}`);
            
            // Test password verification
            const patientWithPassword = await Patient.findOne({ username: patient.username });
            const isValidPassword = await bcrypt.compare('patient123', patientWithPassword.password);
            console.log(`Password Hash Test: ${isValidPassword ? '✅ VALID' : '❌ INVALID'}`);
            console.log('---');
        }

        console.log('\n👨‍⚕️ DOCTOR CREDENTIALS:');
        console.log('========================');
        const doctors = await Doctor.find({}, 'username name email specialization role').limit(5);
        for (const doctor of doctors) {
            console.log(`Username: ${doctor.username}`);
            console.log(`Name: ${doctor.name}`);
            console.log(`Email: ${doctor.email}`);
            console.log(`Specialization: ${doctor.specialization}`);
            console.log(`Role: ${doctor.role}`);
            
            // Test password verification
            const doctorWithPassword = await Doctor.findOne({ username: doctor.username });
            const isValidPassword = await bcrypt.compare('doctor123', doctorWithPassword.password);
            console.log(`Password Hash Test: ${isValidPassword ? '✅ VALID' : '❌ INVALID'}`);
            console.log('---');
        }

        console.log('\n🏥 HOSPITAL ADMIN CREDENTIALS:');
        console.log('==============================');
        const hospitals = await Hospital.find({}, 'username name email role').limit(5);
        for (const hospital of hospitals) {
            console.log(`Username: ${hospital.username}`);
            console.log(`Name: ${hospital.name}`);
            console.log(`Email: ${hospital.email}`);
            console.log(`Role: ${hospital.role}`);
            
            // Test password verification
            const hospitalWithPassword = await Hospital.findOne({ username: hospital.username });
            const isValidPassword = await bcrypt.compare('hospital123', hospitalWithPassword.password);
            console.log(`Password Hash Test: ${isValidPassword ? '✅ VALID' : '❌ INVALID'}`);
            console.log('---');
        }

        console.log('\n🧪 MANUAL LOGIN TEST:');
        console.log('======================');
        
        // Test patient login
        console.log('Testing patient login: rajesh_kumar_90 / patient123');
        const testPatient = await Patient.findOne({ username: 'rajesh_kumar_90' });
        if (testPatient) {
            const isValidPatient = await bcrypt.compare('patient123', testPatient.password);
            console.log(`Patient Login Result: ${isValidPatient ? '✅ SUCCESS' : '❌ FAILED'}`);
        } else {
            console.log('❌ Patient not found in database');
        }

        // Test doctor login
        console.log('Testing doctor login: dr.sharma_cardio / doctor123');
        const testDoctor = await Doctor.findOne({ username: 'dr.sharma_cardio' });
        if (testDoctor) {
            const isValidDoctor = await bcrypt.compare('doctor123', testDoctor.password);
            console.log(`Doctor Login Result: ${isValidDoctor ? '✅ SUCCESS' : '❌ FAILED'}`);
        } else {
            console.log('❌ Doctor not found in database');
        }

        // Test hospital admin login
        console.log('Testing hospital admin login: apollo_admin / hospital123');
        const testHospital = await Hospital.findOne({ username: 'apollo_admin' });
        if (testHospital) {
            const isValidHospital = await bcrypt.compare('hospital123', testHospital.password);
            console.log(`Hospital Admin Login Result: ${isValidHospital ? '✅ SUCCESS' : '❌ FAILED'}`);
        } else {
            console.log('❌ Hospital admin not found in database');
        }

    } catch (error) {
        console.error('❌ Database verification error:', error.message);
    } finally {
        await mongoose.disconnect();
        console.log('\n🔚 Database verification completed');
    }
}

verifyDatabase();
