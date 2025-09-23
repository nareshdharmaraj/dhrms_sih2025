const http = require('http');

// First login as SHO to get valid token
const loginSHO = async () => {
  const loginData = {
    shoId: 'SHOS001',
    password: 'admin123'
  };

  const data = JSON.stringify(loginData);

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/sho/login',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        try {
          const parsedData = JSON.parse(responseData);
          console.log('🔐 SHO Login Response:', parsedData);
          resolve(parsedData);
        } catch (error) {
          console.log('Raw Response:', responseData);
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.write(data);
    req.end();
  });
};

// Test creating RHO with zone assignment for Ernakulam (dense district)
const testCreateRHOWithZone = async (token) => {
  const rhoData = {
    fullName: 'Test RHO with Zone',
    email: 'test.rho.zone@example.com',
    phone: '9876543210',
    password: 'TestPassword123',
    assignedDistrict: 'Ernakulam',
    qualification: 'MBBS, MD',
    experience: 5,
    licenseNumber: 'TEST-ZONE-2024',
    assignToZone: true,
    zoneId: 'ERN-NORTH-001', // North zone from our earlier check
    assignedZone: 'Ernakulam North Zone'
  };

  const data = JSON.stringify(rhoData);

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/rho/create',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      console.log(`Status: ${res.statusCode}`);

      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        try {
          const parsedData = JSON.parse(responseData);
          console.log('\n📊 Create RHO with Zone Response:');
          console.log(JSON.stringify(parsedData, null, 2));
          resolve(parsedData);
        } catch (error) {
          console.log('\n📊 Raw Response (not JSON):');
          console.log(responseData);
          resolve({ statusCode: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ Request failed:', error);
      reject(error);
    });

    req.write(data);
    req.end();
  });
};

// Run the test
const runTest = async () => {
  try {
    const loginResult = await loginSHO();
    if (loginResult.success && loginResult.token) {
      await testCreateRHOWithZone(loginResult.token);
    } else {
      console.error('Failed to get SHO token');
    }
  } catch (error) {
    console.error('Test failed:', error);
  }
};

runTest();