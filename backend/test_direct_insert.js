require('dotenv').config();
const mongoose = require('mongoose');

async function testCloudMongoDB() {
    try {
        const MONGODB_URI = process.env.MONGODB_URI;
        console.log('🔌 Connecting to MongoDB Atlas...');
        console.log('URI:', MONGODB_URI.replace(/mongodb\+srv:\/\/.*:.*@/, 'mongodb+srv://***:***@'));
        
        await mongoose.connect(MONGODB_URI);
        console.log('✅ Connected to MongoDB Atlas successfully');
        
        // Import models
        const Hospital = require('./src/models/Hospital');
        const HospitalAdmin = require('./src/models/HospitalAdmin');
        const HospitalDoctor = require('./src/models/HospitalDoctor');
        const HospitalAssistant = require('./src/models/HospitalAssistant');
        
        console.log('\n🏥 Creating test hospital...');
        
        // Generate unique IDs for this test
        const timestamp = Date.now();
        const hospitalId = `HOSP${timestamp}`;
        const adminId = `ADM${timestamp}`;
        
        // Create hospital
        const hospital = new Hospital({
            hospitalId: hospitalId,
            name: 'Test General Hospital',
            location: {
                address: '123 Test Street',
                city: 'Mumbai',
                state: 'Maharashtra',
                district: 'Mumbai',
                pincode: '400001'
            },
            contact: {
                phone: '9876543210',
                emergencyNumber: '9876543210'
            },
            type: 'Private',
            capacity: {
                totalBeds: 100,
                totalStaff: 50
            },
            licenses: {
                registrationNumber: `REG${timestamp}`,
                issuingAuthority: 'State Health Department',
                issueDate: new Date('2020-01-01'),
                expiryDate: new Date('2030-01-01')
            },
            managedBy: 'Hospital Administration',
            establishedDate: new Date('2020-01-01'),
            specialties: ['General Medicine', 'Cardiology'],
            emergencyServices: true,
            ambulanceServices: true
        });
        
        const savedHospital = await hospital.save();
        console.log('✅ Hospital created:', savedHospital.hospitalId);
        
        // Create admin with hashed password
        const bcrypt = require('bcryptjs');
        const hashedPassword = await bcrypt.hash('password123', 10);
        
        const admin = new HospitalAdmin({
            adminId: adminId,
            hospitalId: savedHospital.hospitalId,
            hospital: savedHospital._id,
            username: `admin${timestamp}`,
            password: hashedPassword,
            adminName: 'Test Admin',
            adminEmail: 'admin@test.com',
            adminPhone: '9876543211'
        });
        
        const savedAdmin = await admin.save();
        console.log('✅ Admin created:', savedAdmin.adminId);
        
        console.log('\n👨‍⚕️ Creating test doctor...');
        
        const doctorId = `DOC${timestamp}`;
        const doctor = new HospitalDoctor({
            doctorId: doctorId,
            hospitalId: savedHospital.hospitalId,
            hospital: savedHospital._id,
            username: `doctor${timestamp}`,
            password: hashedPassword,
            doctorName: 'Dr. Test Doctor',
            email: 'doctor@test.com',
            contactNumber: '9876543212',
            specialization: 'Cardiology',
            licenseNumber: `DLIC${timestamp}`,
            qualification: 'MBBS, MD',
            experienceYears: 5
        });
        
        const savedDoctor = await doctor.save();
        console.log('✅ Doctor created:', savedDoctor.doctorId);
        
        console.log('\n👩‍💼 Creating test assistant...');
        
        const assistantId = `AST${timestamp}`;
        const assistant = new HospitalAssistant({
            assistantId: assistantId,
            hospitalId: savedHospital.hospitalId,
            hospital: savedHospital._id,
            username: `assistant${timestamp}`,
            password: hashedPassword,
            assistantName: 'Test Assistant',
            email: 'assistant@test.com',
            contactNumber: '9876543213',
            department: 'Cardiology',
            qualification: 'BSc Nursing',
            experienceYears: 3,
            assignedDoctor: savedDoctor._id
        });
        
        const savedAssistant = await assistant.save();
        console.log('✅ Assistant created:', savedAssistant.assistantId);
        
        // Verify data by querying
        console.log('\n🔍 Verifying data...');
        
        const hospitalCount = await Hospital.countDocuments({ hospitalId: savedHospital.hospitalId });
        const adminCount = await HospitalAdmin.countDocuments({ hospitalId: savedHospital.hospitalId });
        const doctorCount = await HospitalDoctor.countDocuments({ hospitalId: savedHospital.hospitalId });
        const assistantCount = await HospitalAssistant.countDocuments({ hospitalId: savedHospital.hospitalId });
        
        console.log(`✅ Data verification complete:`);
        console.log(`   Hospitals: ${hospitalCount}`);
        console.log(`   Admins: ${adminCount}`);
        console.log(`   Doctors: ${doctorCount}`);
        console.log(`   Assistants: ${assistantCount}`);
        
        // Test relationships
        console.log('\n🔗 Testing relationships...');
        
        const doctorWithAssistants = await HospitalDoctor.findById(savedDoctor._id);
        const assistantWithDoctor = await HospitalAssistant.findById(savedAssistant._id).populate('assignedDoctor');
        
        console.log('✅ Doctor found:', doctorWithAssistants.doctorName);
        console.log('✅ Assistant found with assigned doctor:', assistantWithDoctor.assignedDoctor.doctorName);
        
        console.log('\n🎉 All database operations successful!');
        console.log('\n📋 Summary:');
        console.log(`Hospital: ${savedHospital.name} (${savedHospital.hospitalId})`);
        console.log(`Admin: ${savedAdmin.adminName} (${savedAdmin.adminId})`);
        console.log(`Doctor: ${savedDoctor.doctorName} (${savedDoctor.doctorId})`);
        console.log(`Assistant: ${savedAssistant.assistantName} (${savedAssistant.assistantId})`);
        
        console.log('\n📝 Test data has been inserted into the database successfully!');
        console.log('🗂️  You can now check your MongoDB Atlas dashboard to see the data.');
        
    } catch (error) {
        console.error('❌ Database test failed:', error.message);
        console.error('Full error:', error);
    } finally {
        await mongoose.disconnect();
        console.log('🔌 Disconnected from MongoDB');
    }
}

testCloudMongoDB();