const fetch = require('node-fetch');

// Configuration
const BASE_URL = 'http://localhost:3000/api';

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

function log(color, message) {
  console.log(`${color}${message}${colors.reset}`);
}

async function testEndpoint(method, url, data = null, expectedStatus = 200) {
  try {
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (data) {
      options.body = JSON.stringify(data);
    }

    log(colors.cyan, `\n${method} ${url}`);
    if (data) {
      log(colors.yellow, `Request Body: ${JSON.stringify(data, null, 2)}`);
    }

    const response = await fetch(url, options);
    const responseData = await response.text();
    
    let parsedData;
    try {
      parsedData = JSON.parse(responseData);
    } catch (e) {
      parsedData = responseData;
    }

    if (response.status === expectedStatus) {
      log(colors.green, `✅ SUCCESS (${response.status})`);
      log(colors.blue, `Response: ${JSON.stringify(parsedData, null, 2)}`);
      return { success: true, data: parsedData };
    } else {
      log(colors.red, `❌ FAILED (${response.status}, expected ${expectedStatus})`);
      log(colors.red, `Response: ${JSON.stringify(parsedData, null, 2)}`);
      return { success: false, data: parsedData };
    }
  } catch (error) {
    log(colors.red, `❌ ERROR: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function runTests() {
  log(colors.blue, '🧪 Testing Appointment System API Endpoints\n');
  log(colors.yellow, '='.repeat(50));

  // Test 1: Health Check
  log(colors.blue, '\n📋 Test 1: Health Check');
  await testEndpoint('GET', `${BASE_URL.replace('/api', '')}/health`);

  // Test 2: Get Hospitals
  log(colors.blue, '\n📋 Test 2: Get Hospitals');
  const hospitalsResult = await testEndpoint('GET', `${BASE_URL}/hospital/list`);
  
  let hospitalId = null;
  if (hospitalsResult.success && hospitalsResult.data && hospitalsResult.data.length > 0) {
    hospitalId = hospitalsResult.data[0].hospitalId || hospitalsResult.data[0]._id;
    log(colors.green, `Found hospital ID: ${hospitalId}`);
  }

  // Test 3: Get Doctors for Hospital
  if (hospitalId) {
    log(colors.blue, '\n📋 Test 3: Get Doctors for Hospital');
    const doctorsResult = await testEndpoint('GET', `${BASE_URL}/appointments/hospitals/${hospitalId}/doctors`);
    
    let doctorId = null;
    if (doctorsResult.success && doctorsResult.data && doctorsResult.data.length > 0) {
      doctorId = doctorsResult.data[0].doctorId || doctorsResult.data[0]._id;
      log(colors.green, `Found doctor ID: ${doctorId}`);
    }

    // Test 4: Create Appointment
    if (doctorId) {
      log(colors.blue, '\n📋 Test 4: Create Appointment');
      const appointmentData = {
        appointmentId: `APT${Date.now()}`,
        patientId: 'TEST_PATIENT_001',
        patientName: 'Test Patient',
        patientUhid: 'UHID001',
        patientGender: 'Male',
        patientAge: 30,
        patientState: 'Test State',
        doctorId: doctorId,
        doctorName: 'Test Doctor',
        hospitalId: hospitalId,
        hospitalName: 'Test Hospital',
        appointmentDate: new Date().toISOString().split('T')[0],
        appointmentTime: '10:00 AM',
        reason: 'Regular checkup',
        consultationFee: 500,
        status: 'pending'
      };

      const createResult = await testEndpoint('POST', `${BASE_URL}/appointments`, appointmentData, 201);
      
      if (createResult.success) {
        const appointmentId = appointmentData.appointmentId;

        // Test 5: Get Specific Appointment
        log(colors.blue, '\n📋 Test 5: Get Specific Appointment');
        await testEndpoint('GET', `${BASE_URL}/appointments/${appointmentId}`);

        // Test 6: Get Doctor's Appointments
        log(colors.blue, '\n📋 Test 6: Get Doctor\'s Appointments');
        await testEndpoint('GET', `${BASE_URL}/appointments/doctor/${doctorId}`);

        // Test 7: Get Patient's Appointments
        log(colors.blue, '\n📋 Test 7: Get Patient\'s Appointments');
        await testEndpoint('GET', `${BASE_URL}/appointments/patient/TEST_PATIENT_001`);

        // Test 8: Update Appointment Status
        log(colors.blue, '\n📋 Test 8: Update Appointment Status');
        await testEndpoint('PUT', `${BASE_URL}/appointments/${appointmentId}/status`, { status: 'approved' });

        // Test 9: Update to Completed
        log(colors.blue, '\n📋 Test 9: Update to Completed');
        await testEndpoint('PUT', `${BASE_URL}/appointments/${appointmentId}/status`, { status: 'completed' });

        // Test 10: Try Invalid Status
        log(colors.blue, '\n📋 Test 10: Try Invalid Status (Should Fail)');
        await testEndpoint('PUT', `${BASE_URL}/appointments/${appointmentId}/status`, { status: 'invalid' }, 400);
      }
    } else {
      log(colors.yellow, '⚠️  No doctors found, skipping appointment tests');
    }
  } else {
    log(colors.yellow, '⚠️  No hospitals found, skipping doctor and appointment tests');
  }

  log(colors.blue, '\n🏁 Test Suite Complete!');
  log(colors.yellow, '='.repeat(50));
}

// Check if server is running first
async function checkServer() {
  try {
    const response = await fetch(`${BASE_URL.replace('/api', '')}/health`);
    if (response.status === 200) {
      log(colors.green, '✅ Server is running, starting tests...');
      await runTests();
    } else {
      log(colors.red, '❌ Server health check failed');
    }
  } catch (error) {
    log(colors.red, '❌ Server is not running. Please start the server first:');
    log(colors.yellow, '   cd backend && npm start');
    log(colors.red, `   Error: ${error.message}`);
  }
}

checkServer();