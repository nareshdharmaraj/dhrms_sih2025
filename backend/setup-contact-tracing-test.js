// Test setup for Contact Tracing System
// This script creates test data for proximity alert testing

const mongoose = require('mongoose');
const { ContactTracing } = require('./src/models/ContactTracing');
require('dotenv').config();

async function setupTestData() {
  try {
    console.log('🧪 Setting up Contact Tracing test data...');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms_sih2025');
    console.log('✅ Connected to MongoDB');

    // Clear existing contact tracing data
    await ContactTracing.deleteMany({});
    console.log('🧹 Cleared existing contact tracing data');

    // Create test infected device (using existing patient UHID: NARE523407)
    const infectedDevice1 = new ContactTracing({
      deviceId: 'DHRMS_CT_TEST_INFECTED_001',
      patientId: new mongoose.Types.ObjectId(),
      uhid: 'NARE523407',
      isInfected: true,
      infectionStatus: 'infected',
      communicableDiseases: [{
        diseaseName: 'malarial disease',
        diagnosisDate: new Date('2024-09-17'),
        expectedRecoveryDate: new Date('2024-09-24'),
        isActive: true
      }],
      metadata: {
        deviceInfo: {
          platform: 'android',
          version: '13',
          model: 'Test Device 1'
        },
        location: {
          state: 'Tamil Nadu',
          district: 'Chennai'
        }
      }
    });

    // Create another infected device for testing
    const infectedDevice2 = new ContactTracing({
      deviceId: 'DHRMS_CT_TEST_INFECTED_002',
      patientId: new mongoose.Types.ObjectId(),
      uhid: 'TEST123456',
      isInfected: true,
      infectionStatus: 'infected',
      communicableDiseases: [{
        diseaseName: 'tuberculosis',
        diagnosisDate: new Date(),
        expectedRecoveryDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
        isActive: true
      }],
      metadata: {
        deviceInfo: {
          platform: 'ios',
          version: '17',
          model: 'Test Device 2'
        },
        location: {
          state: 'Tamil Nadu',
          district: 'Chennai'
        }
      }
    });

    // Create a healthy device for testing (should not trigger alerts)
    const healthyDevice = new ContactTracing({
      deviceId: 'DHRMS_CT_TEST_HEALTHY_001',
      patientId: new mongoose.Types.ObjectId(),
      uhid: 'HEALTHY123',
      isInfected: false,
      infectionStatus: 'healthy',
      communicableDiseases: [],
      metadata: {
        deviceInfo: {
          platform: 'android',
          version: '14',
          model: 'Test Healthy Device'
        },
        location: {
          state: 'Tamil Nadu',
          district: 'Chennai'
        }
      }
    });

    // Save all test devices
    await infectedDevice1.save();
    await infectedDevice2.save();
    await healthyDevice.save();

    console.log('✅ Test data created successfully:');
    console.log('  - Infected Device 1: DHRMS_CT_TEST_INFECTED_001 (UHID: NARE523407, Disease: malarial disease)');
    console.log('  - Infected Device 2: DHRMS_CT_TEST_INFECTED_002 (UHID: TEST123456, Disease: tuberculosis)');
    console.log('  - Healthy Device: DHRMS_CT_TEST_HEALTHY_001 (UHID: HEALTHY123)');

    // Test infected devices API endpoint
    console.log('\n🔍 Testing infected devices API...');
    const infectedDevices = await ContactTracing.find(
      { 
        isInfected: true,
        infectionStatus: { $in: ['infected', 'quarantined'] },
        'communicableDiseases.isActive': true
      },
      { 
        deviceId: 1,
        communicableDiseases: 1,
        uhid: 1,
        _id: 0
      }
    ).lean();

    console.log(`📡 Found ${infectedDevices.length} infected devices:`);
    infectedDevices.forEach((device, i) => {
      console.log(`  ${i + 1}. Device ID: ${device.deviceId}`);
      console.log(`     UHID: ${device.uhid}`);
      console.log(`     Diseases: ${device.communicableDiseases.filter(d => d.isActive).map(d => d.diseaseName).join(', ')}`);
    });

    console.log('\n🎯 TESTING INSTRUCTIONS:');
    console.log('1. Start the backend server: npm start');
    console.log('2. Test infected devices endpoint: GET /api/contact-tracing/infected-devices');
    console.log('3. Use Flutter app to start proximity monitoring');
    console.log('4. The app will detect infected devices: DHRMS_CT_TEST_INFECTED_001 and DHRMS_CT_TEST_INFECTED_002');
    console.log('5. Mock BLE proximity by simulating these device IDs in BLE scan results');

    console.log('\n🧪 Test data setup complete!');
    
  } catch (error) {
    console.error('❌ Error setting up test data:', error);
  } finally {
    await mongoose.disconnect();
    console.log('📋 Disconnected from MongoDB');
  }
}

// Run the setup
if (require.main === module) {
  setupTestData();
}

module.exports = { setupTestData };
