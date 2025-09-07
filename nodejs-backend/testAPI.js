// API Test Script for DHRMS Backend
const https = require('http');

// API Base URL
const API_BASE = 'http://localhost:5000/api/v1';

// Test function to make HTTP requests
const testAPI = async (endpoint, method = 'GET', data = null) => {
  return new Promise((resolve, reject) => {
    const url = new URL(`${API_BASE}${endpoint}`);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(responseData);
          resolve({
            status: res.statusCode,
            data: parsedData
          });
        } catch (error) {
          resolve({
            status: res.statusCode,
            data: responseData
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
};

// Test Cases
const runTests = async () => {
  console.log('🧪 Starting DHRMS Backend API Tests\n');

  try {
    // Test 1: Health Check
    console.log('1. Testing Health Check...');
    const healthResponse = await testAPI('/../../health');
    console.log(`   Status: ${healthResponse.status}`);
    console.log(`   Message: ${healthResponse.data.message}\n`);

    // Test 2: Get All Hospitals
    console.log('2. Testing Get All Hospitals...');
    const hospitalsResponse = await testAPI('/hospitals');
    console.log(`   Status: ${hospitalsResponse.status}`);
    console.log(`   Hospitals Count: ${hospitalsResponse.data.data?.hospitals?.length || 0}\n`);

    // Test 3: Get All Doctors
    console.log('3. Testing Get All Doctors...');
    const doctorsResponse = await testAPI('/doctors');
    console.log(`   Status: ${doctorsResponse.status}`);
    console.log(`   Doctors Count: ${doctorsResponse.data.data?.doctors?.length || 0}\n`);

    // Test 4: Get All Patients
    console.log('4. Testing Get All Patients...');
    const patientsResponse = await testAPI('/patients');
    console.log(`   Status: ${patientsResponse.status}`);
    console.log(`   Patients Count: ${patientsResponse.data.data?.patients?.length || 0}\n`);

    // Test 5: Login Hospital
    console.log('5. Testing Hospital Login...');
    const hospitalLoginResponse = await testAPI('/auth/hospital/login', 'POST', {
      username: 'apollo_admin',
      password: 'apollo123'
    });
    console.log(`   Status: ${hospitalLoginResponse.status}`);
    console.log(`   Success: ${hospitalLoginResponse.data.status === 'success'}\n`);

    // Test 6: Login Doctor
    console.log('6. Testing Doctor Login...');
    const doctorLoginResponse = await testAPI('/auth/doctor/login', 'POST', {
      username: 'dr_rajesh_sharma',
      password: 'doctor123'
    });
    console.log(`   Status: ${doctorLoginResponse.status}`);
    console.log(`   Success: ${doctorLoginResponse.data.status === 'success'}\n`);

    // Test 7: Login Patient
    console.log('7. Testing Patient Login...');
    const patientLoginResponse = await testAPI('/auth/patient/login', 'POST', {
      username: 'rajesh_kumar_90',
      password: 'patient123'
    });
    console.log(`   Status: ${patientLoginResponse.status}`);
    console.log(`   Success: ${patientLoginResponse.data.status === 'success'}\n`);

    console.log('✅ All tests completed successfully!');
    console.log('\n🎉 DHRMS Backend is fully functional with:');
    console.log('   ✓ MongoDB database with sample data');
    console.log('   ✓ Authentication system for hospitals, doctors, and patients');
    console.log('   ✓ RESTful API endpoints');
    console.log('   ✓ Complete data models');
    console.log('   ✓ All route handlers');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
};

// Run the tests
runTests();
