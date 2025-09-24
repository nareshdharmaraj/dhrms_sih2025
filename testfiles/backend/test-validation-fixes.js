const http = require('http');

// First login to get a valid token
async function loginAndTestRHO() {
  try {
    // Get auth token
    const token = await loginSHO();
    if (!token) {
      console.log('❌ Failed to get auth token');
      return;
    }

    // Test with VALID data (should work)
    console.log('\n📋 Testing with VALID data...');
    await testRHOCreate(token, {
      "fullName": "Dr. John Smith",  // Valid: only letters, spaces, dots
      "email": "john.smith@example.com",
      "phone": "9876543210",
      "password": "MyPass123!",  // Valid: has uppercase, lowercase, number, special char
      "assignedDistrict": "Salem",
      "assignedAreas": ["Salem Zone 1"],
      "qualification": "MBBS",
      "experience": 5,
      "licenseNumber": "TN987654"
    });

    // Test with INVALID data (should fail with validation errors)
    console.log('\n📋 Testing with INVALID data (to verify validation)...');
    await testRHOCreate(token, {
      "fullName": "RHO_INVALID_NAME",  // Invalid: contains underscores
      "email": "invalid@example.com",
      "phone": "9876543210",
      "password": "InvalidPass123",  // Invalid: no special characters
      "assignedDistrict": "Salem",
      "assignedAreas": ["Salem Zone 1"],
      "qualification": "MBBS",
      "experience": 5,
      "licenseNumber": "TN987655"
    });

  } catch (error) {
    console.error('❌ Test error:', error);
  }
}

function loginSHO() {
  return new Promise((resolve) => {
    const loginData = JSON.stringify({
      "email": "sho.tn@myhealth.gov.in",
      "password": "TestPassword@123"
    });

    const loginOptions = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/sho-auth/login',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    };

    const loginReq = http.request(loginOptions, (res) => {
      let responseData = '';
      res.on('data', (chunk) => responseData += chunk);
      res.on('end', () => {
        try {
          const parsedResponse = JSON.parse(responseData);
          if (parsedResponse.success && parsedResponse.token) {
            console.log('✅ SHO login successful');
            resolve(parsedResponse.token);
          } else {
            console.log('❌ SHO login failed:', parsedResponse.message);
            resolve(null);
          }
        } catch (e) {
          console.log('❌ Failed to parse login response');
          resolve(null);
        }
      });
    });

    loginReq.on('error', (e) => {
      console.error('❌ Login request error:', e.message);
      resolve(null);
    });

    loginReq.write(loginData);
    loginReq.end();
  });
}

function testRHOCreate(token, rhoData) {
  return new Promise((resolve) => {
    const data = JSON.stringify(rhoData);

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/rho/create',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    };

    console.log('🔍 Testing RHO creation with data:', {
      fullName: rhoData.fullName,
      password: rhoData.password,
      email: rhoData.email
    });

    const req = http.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => responseData += chunk);
      res.on('end', () => {
        try {
          const parsedResponse = JSON.parse(responseData);
          console.log(`🔍 Response Status: ${res.statusCode}`);
          
          if (parsedResponse.success) {
            console.log('✅ RHO creation successful');
            console.log('📋 Created RHO:', {
              officerId: parsedResponse.rho?.officerId,
              fullName: parsedResponse.rho?.fullName,
              email: parsedResponse.rho?.email
            });
          } else {
            console.log('❌ RHO creation failed:', parsedResponse.message);
            if (parsedResponse.errors) {
              console.log('📋 Validation errors:');
              parsedResponse.errors.forEach(error => {
                console.log(`  - ${error.path}: ${error.msg}`);
              });
            }
          }
        } catch (e) {
          console.log('❌ Failed to parse response:', responseData);
        }
        resolve();
      });
    });

    req.on('error', (e) => {
      console.error('❌ Request error:', e.message);
      resolve();
    });

    req.write(data);
    req.end();
  });
}

// Run the test
loginAndTestRHO();