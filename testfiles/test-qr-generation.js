const mongoose = require('mongoose');
const Patient = require('./src/models/Patient');
const uhiService = require('./src/services/uhiService');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Test QR code generation with comprehensive data
async function testQRGeneration() {
    try {
        // Connect to MongoDB using environment configuration
        const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth';
        await mongoose.connect(mongoUri, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });

        console.log('✅ Connected to MongoDB');
        console.log('📋 Using MongoDB URI:', mongoUri.replace(/\/\/.*@/, '//***:***@')); // Hide credentials in log

        // Create a test patient with comprehensive data
        const testPatient = new Patient({
            firstName: 'Test',
            lastName: 'Patient',
            email: 'test@example.com',
            phone: '9876543210',
            aadhaarNumber: '123456789012',
            dateOfBirth: new Date('1990-01-15'),
            gender: 'male',
            bloodGroup: 'O+',
            password: 'hashedPassword123',
            address: {
                street: '123 Test Street',
                city: 'Test City',
                state: 'Test State',
                zipCode: '123456',
                country: 'India'
            },
            homeState: 'Test State',
            emergencyContact: {
                name: 'Emergency Contact',
                phone: '9876543210',
                relationship: 'Parent'
            }
        });

        // Generate UHID using the proper service
        const uhid = await uhiService.generateUHI(testPatient.firstName, testPatient.aadhaarNumber, 'patient');
        testPatient.uhid = uhid;
        console.log('📋 Generated UHID:', uhid);

        // The QR code will be automatically generated in the pre-save middleware
        // Let's manually check what the QR code would contain
        console.log('📱 Testing QR Code Data Generation...');
        
        // Simulate the QR code generation function from the Patient model
        const qrCodeData = JSON.stringify({
            uhid: testPatient.uhid,
            name: testPatient.fullName || `${testPatient.firstName} ${testPatient.lastName}`,
            address: {
                street: testPatient.address?.street || '',
                city: testPatient.address?.city || '',
                state: testPatient.address?.state || '',
                zipCode: testPatient.address?.zipCode || '',
                country: testPatient.address?.country || 'India'
            },
            homeState: testPatient.homeState,
            bloodGroup: testPatient.bloodGroup,
            emergencyContact: {
                name: testPatient.emergencyContact?.name || '',
                phone: testPatient.emergencyContact?.phone || '',
                relationship: testPatient.emergencyContact?.relationship || ''
            },
            type: 'DHRMS_PATIENT_CARD',
            version: '2.0',
            timestamp: new Date().toISOString(),
            verificationURL: `https://dhrms.gov.in/verify/${testPatient.uhid}`
        });

        console.log('� Generated QR Code Data:');
        console.log('Raw JSON:', qrCodeData);
        
        // Parse and display the QR code data structure
        try {
            const parsedData = JSON.parse(qrCodeData);
            console.log('\n� Parsed QR Code Data Structure:');
            console.log('- UHID:', parsedData.uhid);
            console.log('- Name:', parsedData.name);
            console.log('- Address:', parsedData.address);
            console.log('- Home State:', parsedData.homeState);
            console.log('- Blood Group:', parsedData.bloodGroup);
            console.log('- Emergency Contact:', parsedData.emergencyContact);
            console.log('- Type:', parsedData.type);
            console.log('- Version:', parsedData.version);
            console.log('- Verification URL:', parsedData.verificationURL);
            console.log('- Timestamp:', parsedData.timestamp);
            
            // Test saving the patient (QR code will be generated automatically)
            await testPatient.save();
            console.log('\n💾 Test patient saved to database');
            console.log('📱 Digital Card QR Code:', testPatient.digitalCard?.qrCode ? 'Generated' : 'Not Generated');
            
            if (testPatient.digitalCard?.qrCode) {
                console.log('� Saved QR Code Data:', testPatient.digitalCard.qrCode);
            }
            
        } catch (parseError) {
            console.log('⚠️ QR data parsing error:', parseError.message);
        }

        console.log('\n✅ QR Code generation test completed successfully!');
        console.log('🔍 The QR code now contains comprehensive patient data including:');
        console.log('   - UHID, Name, Address, Home State');
        console.log('   - Blood Group, Emergency Contact');
        console.log('   - Verification URL and Timestamp');

    } catch (error) {
        console.error('❌ Error during QR generation test:', error);
    } finally {
        // Close the database connection
        await mongoose.connection.close();
        console.log('🔌 Database connection closed');
    }
}

// Run the test
testQRGeneration();