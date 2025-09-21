const http = require('http');

// Test the RHO listing endpoint
async function testRHOListing() {
  try {
    // Get auth token
    const token = await loginSHO();
    if (!token) {
      console.log('❌ Failed to get auth token');
      return;
    }

    // Test GET /api/rho/ endpoint
    console.log('\n📋 Testing RHO listing endpoint...');
    await testGetRHOs(token);

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

function testGetRHOs(token) {
  return new Promise((resolve) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/rho/',
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    };

    console.log('🔍 Testing GET /api/rho/ endpoint...');

    const req = http.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => responseData += chunk);
      res.on('end', () => {
        try {
          const parsedResponse = JSON.parse(responseData);
          console.log(`🔍 Response Status: ${res.statusCode}`);
          
          if (parsedResponse.success) {
            console.log('✅ RHO listing successful');
            console.log('📋 Response structure:');
            console.log(`  - Total RHOs: ${parsedResponse.rhos?.length || 0}`);
            console.log(`  - Statistics: ${JSON.stringify(parsedResponse.statistics)}`);
            console.log(`  - Pagination: ${JSON.stringify(parsedResponse.pagination)}`);
            
            if (parsedResponse.rhos && parsedResponse.rhos.length > 0) {
              console.log('📋 Sample RHO data:');
              const sampleRHO = parsedResponse.rhos[0];
              console.log(`  - Officer ID: ${sampleRHO.officerId}`);
              console.log(`  - Full Name: ${sampleRHO.fullName}`);
              console.log(`  - Email: ${sampleRHO.email}`);
              console.log(`  - District: ${sampleRHO.assignedDistrict}`);
              console.log(`  - Active: ${sampleRHO.isActive}`);
            } else {
              console.log('📋 No RHOs found for this SHO');
            }
          } else {
            console.log('❌ RHO listing failed:', parsedResponse.message);
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

    req.end();
  });
}

// Run the test
testRHOListing();