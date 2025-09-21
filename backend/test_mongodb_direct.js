const mongoose = require('mongoose');

// MongoDB connection string (adjust if needed)
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth';

async function testMongoDB() {
    try {
        console.log('🔌 Connecting to MongoDB...');
        await mongoose.connect(MONGODB_URI);
        console.log('✅ Connected to MongoDB successfully');
        
        // Test creating a simple document
        const TestSchema = new mongoose.Schema({
            name: String,
            timestamp: { type: Date, default: Date.now }
        });
        
        const TestModel = mongoose.model('TestData', TestSchema);
        
        console.log('📝 Creating test document...');
        const testDoc = new TestModel({
            name: 'Hospital System Test'
        });
        
        const savedDoc = await testDoc.save();
        console.log('✅ Test document created:', savedDoc._id);
        
        // Test querying
        console.log('🔍 Querying test documents...');
        const allDocs = await TestModel.find();
        console.log(`✅ Found ${allDocs.length} test documents`);
        
        // Clean up
        console.log('🧹 Cleaning up test data...');
        await TestModel.deleteMany({});
        console.log('✅ Test data cleaned up');
        
        // Test Hospital model creation
        console.log('\n🏥 Testing Hospital model...');
        
        // Import the actual Hospital model
        const Hospital = require('./src/models/Hospital');
        const HospitalAdmin = require('./src/models/HospitalAdmin');
        
        // Create a test hospital
        const testHospital = new Hospital({
            hospitalName: 'Direct Test Hospital',
            hospitalId: 'HOSP001',
            address: {
                street: '123 Test St',
                city: 'Mumbai',
                state: 'Maharashtra',
                district: 'Mumbai',
                pincode: '400001'
            },
            contactNumber: '9876543210',
            email: 'test@hospital.com',
            registrationNumber: 'REG001',
            licenseId: 'LIC001',
            hospitalType: 'Private',
            specialties: ['General Medicine'],
            totalBeds: 50
        });
        
        const savedHospital = await testHospital.save();
        console.log('✅ Hospital created directly:', savedHospital.hospitalId);
        
        // Create a test admin
        const testAdmin = new HospitalAdmin({
            adminId: 'ADM001',
            hospitalId: savedHospital.hospitalId,
            hospital: savedHospital._id,
            username: 'testadmin',
            password: 'hashedpassword123', // In real app, this would be hashed
            adminName: 'Test Admin',
            adminEmail: 'admin@hospital.com',
            adminPhone: '9876543211'
        });
        
        const savedAdmin = await testAdmin.save();
        console.log('✅ Admin created directly:', savedAdmin.adminId);
        
        // Clean up hospital data
        console.log('🧹 Cleaning up hospital test data...');
        await HospitalAdmin.deleteMany({ hospitalId: savedHospital.hospitalId });
        await Hospital.deleteMany({ hospitalId: savedHospital.hospitalId });
        console.log('✅ Hospital test data cleaned up');
        
        console.log('\n🎉 All MongoDB tests passed! Database is working correctly.');
        
    } catch (error) {
        console.error('❌ MongoDB test failed:', error.message);
        console.error('Full error:', error);
    } finally {
        await mongoose.disconnect();
        console.log('🔌 Disconnected from MongoDB');
    }
}

testMongoDB();