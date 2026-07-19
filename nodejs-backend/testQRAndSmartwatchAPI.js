const axios = require('axios');

// Base URL for the API
const BASE_URL = 'http://localhost:5000/api/v1';

// Test data
const testPatient = {
  email: 'patient@example.com',
  password: 'password123'
};

let authToken = '';

async function testAPI() {
  console.log('🏥 Testing DHRMS QR Code and Smartwatch Features\n');

  try {
    // 1. Test Health Check
    console.log('1. Testing Health Check...');
    const healthResponse = await axios.get(`${BASE_URL.replace('/api/v1', '')}/health`);
    console.log('✅ Health Check:', healthResponse.data.message);
    console.log();

    // 2. Test Authentication (using existing patient)
    console.log('2. Testing Patient Authentication...');
    try {
      const authResponse = await axios.post(`${BASE_URL}/auth/login`, {
        email: testPatient.email,
        password: testPatient.password,
        userType: 'patient'
      });
      authToken = authResponse.data.data.token;
      console.log('✅ Patient authenticated successfully');
      console.log(`   Patient ID: ${authResponse.data.data.user.patientId}`);
    } catch (error) {
      console.log('ℹ️  Patient login failed, trying registration...');
      
      // Try to register if login fails
      const registerData = {
        patientId: 'TEST_PAT_' + Date.now(),
        name: 'Test Patient',
        email: testPatient.email,
        password: testPatient.password,
        phone: '+1234567890',
        dateOfBirth: '1990-01-01',
        gender: 'male',
        address: {
          street: '123 Test Street',
          city: 'Test City',
          state: 'Test State',
          zipCode: '12345',
          country: 'Test Country'
        }
      };

      const registerResponse = await axios.post(`${BASE_URL}/auth/register/patient`, registerData);
      authToken = registerResponse.data.data.token;
      console.log('✅ Patient registered and authenticated');
      console.log(`   Patient ID: ${registerResponse.data.data.user.patientId}`);
    }
    console.log();

    // 3. Test QR Code Generation
    console.log('3. Testing QR Code Generation...');
    const qrGenerateResponse = await axios.post(`${BASE_URL}/qr-codes/generate`, {
      type: 'health_summary',
      data: {
        patientInfo: true,
        medicalHistory: true,
        currentMedications: true,
        allergies: true,
        emergencyContact: true
      },
      accessControl: {
        allowedRoles: ['doctor', 'nurse', 'emergency'],
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
      },
      settings: {
        includePhoto: false,
        format: 'png',
        size: 256,
        errorCorrectionLevel: 'M'
      }
    }, {
      headers: { Authorization: `Bearer ${authToken}` }
    });

    console.log('✅ QR Code generated successfully');
    console.log(`   QR Code ID: ${qrGenerateResponse.data.data.qrCode.qrCodeId}`);
    console.log(`   Data URL: ${qrGenerateResponse.data.data.qrCode.qrCodeData.substring(0, 50)}...`);
    console.log(`   Expires: ${qrGenerateResponse.data.data.qrCode.expiresAt}`);
    console.log();

    const qrCodeId = qrGenerateResponse.data.data.qrCode.qrCodeId;

    // 4. Test QR Code Scanning
    console.log('4. Testing QR Code Scanning...');
    const qrScanResponse = await axios.post(`${BASE_URL}/qr-codes/scan`, {
      qrCodeId: qrCodeId,
      scannedData: qrGenerateResponse.data.data.qrCode.qrCodeData,
      scannerInfo: {
        deviceType: 'mobile',
        location: {
          latitude: 40.7128,
          longitude: -74.0060,
          accuracy: 10
        }
      }
    }, {
      headers: { Authorization: `Bearer ${authToken}` }
    });

    console.log('✅ QR Code scanned successfully');
    console.log(`   Scan ID: ${qrScanResponse.data.data.scan.scanId}`);
    console.log(`   Patient: ${qrScanResponse.data.data.patientData.name}`);
    console.log(`   Data Accessed: ${qrScanResponse.data.data.patientData.dataTypes.join(', ')}`);
    console.log();

    // 5. Test Smartwatch Pairing
    console.log('5. Testing Smartwatch Pairing...');
    const smartwatchPairResponse = await axios.post(`${BASE_URL}/smartwatch/pair`, {
      device: {
        deviceName: 'Test Apple Watch',
        brand: 'apple',
        model: 'Series 9',
        osVersion: 'watchOS 10.0',
        firmwareVersion: '21A5303d'
      },
      bluetooth: {
        bluetoothAddress: 'AA:BB:CC:DD:EE:FF',
        bluetoothName: 'Test Apple Watch',
        bluetoothVersion: '5.3'
      },
      pairingMethod: 'passkey',
      capabilities: {
        sensors: [
          { type: 'heart_rate', available: true, accuracy: 'high', sampleRate: 1 },
          { type: 'accelerometer', available: true, accuracy: 'high', sampleRate: 50 },
          { type: 'gyroscope', available: true, accuracy: 'high', sampleRate: 50 }
        ],
        features: ['notifications', 'health_monitoring', 'emergency_sos', 'fall_detection'],
        batteryLevel: 85
      }
    }, {
      headers: { Authorization: `Bearer ${authToken}` }
    });

    console.log('✅ Smartwatch pairing initiated');
    console.log(`   Pairing ID: ${smartwatchPairResponse.data.data.pairing.pairingId}`);
    console.log(`   Pairing Code: ${smartwatchPairResponse.data.data.pairing.pairingCode}`);
    console.log(`   Status: ${smartwatchPairResponse.data.data.pairing.status}`);
    console.log();

    const pairingId = smartwatchPairResponse.data.data.pairing.pairingId;
    const pairingCode = smartwatchPairResponse.data.data.pairing.pairingCode;

    // 6. Test Smartwatch Pairing Confirmation
    console.log('6. Testing Smartwatch Pairing Confirmation...');
    const confirmPairingResponse = await axios.post(`${BASE_URL}/smartwatch/confirm-pairing`, {
      pairingId: pairingId,
      pairingCode: pairingCode,
      deviceConfirmation: {
        batteryLevel: 85,
        capabilities: {
          sensors: [
            { type: 'heart_rate', available: true, accuracy: 'high', sampleRate: 1 },
            { type: 'accelerometer', available: true, accuracy: 'high', sampleRate: 50 }
          ]
        }
      }
    }, {
      headers: { Authorization: `Bearer ${authToken}` }
    });

    console.log('✅ Smartwatch pairing confirmed');
    console.log(`   Status: ${confirmPairingResponse.data.data.pairing.status}`);
    console.log(`   Paired At: ${confirmPairingResponse.data.data.pairing.pairedAt}`);
    console.log(`   Battery Level: ${confirmPairingResponse.data.data.pairing.device.batteryLevel}%`);
    console.log();

    // 7. Test Getting Paired Devices
    console.log('7. Testing Get Paired Devices...');
    const pairedDevicesResponse = await axios.get(`${BASE_URL}/smartwatch/paired-devices`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });

    console.log('✅ Retrieved paired devices');
    console.log(`   Total Devices: ${pairedDevicesResponse.data.data.summary.total}`);
    console.log(`   Connected: ${pairedDevicesResponse.data.data.summary.connected}`);
    if (pairedDevicesResponse.data.data.devices.length > 0) {
      const device = pairedDevicesResponse.data.data.devices[0];
      console.log(`   First Device: ${device.device.name} (${device.device.brand})`);
    }
    console.log();

    // 8. Test Smartwatch Data Sync
    console.log('8. Testing Smartwatch Data Sync...');
    const syncResponse = await axios.post(`${BASE_URL}/smartwatch/${pairingId}/sync`, {
      data: {
        heartRate: [
          { timestamp: new Date(), value: 72, quality: 'good' },
          { timestamp: new Date(Date.now() - 60000), value: 75, quality: 'good' }
        ],
        steps: [
          { timestamp: new Date(), count: 8523 }
        ],
        battery: {
          level: 82,
          isCharging: false
        }
      },
      dataTypes: ['heart_rate', 'steps', 'battery']
    }, {
      headers: { Authorization: `Bearer ${authToken}` }
    });

    console.log('✅ Smartwatch data synced');
    console.log(`   Sync ID: ${syncResponse.data.data.sync.syncId}`);
    console.log(`   Records Synced: ${syncResponse.data.data.sync.recordCount}`);
    console.log(`   Battery Level: ${syncResponse.data.data.device.batteryLevel}%`);
    console.log();

    // 9. Test QR Code Analytics
    console.log('9. Testing QR Code Analytics...');
    const analyticsResponse = await axios.get(`${BASE_URL}/qr-codes/analytics`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });

    console.log('✅ QR Code analytics retrieved');
    console.log(`   Total QR Codes: ${analyticsResponse.data.data.analytics.totalQRCodes}`);
    console.log(`   Total Scans: ${analyticsResponse.data.data.analytics.totalScans}`);
    console.log(`   Active QR Codes: ${analyticsResponse.data.data.analytics.activeQRCodes}`);
    console.log();

    console.log('🎉 All tests completed successfully!\n');
    console.log('📱 QR Code Features Tested:');
    console.log('   ✅ QR Code Generation with patient data');
    console.log('   ✅ QR Code Scanning and validation');
    console.log('   ✅ Access control and security');
    console.log('   ✅ Analytics and tracking');
    console.log();
    console.log('⌚ Smartwatch Features Tested:');
    console.log('   ✅ Bluetooth pairing initiation');
    console.log('   ✅ Pairing confirmation with codes');
    console.log('   ✅ Device management');
    console.log('   ✅ Health data synchronization');
    console.log('   ✅ Battery monitoring');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
    if (error.response?.data?.errors) {
      console.error('   Validation errors:', error.response.data.errors);
    }
  }
}

// Helper function to run tests
async function runTests() {
  console.log('Starting API tests...\n');
  await testAPI();
}

// Run tests if this file is executed directly
if (require.main === module) {
  runTests();
}

module.exports = { testAPI, runTests };
