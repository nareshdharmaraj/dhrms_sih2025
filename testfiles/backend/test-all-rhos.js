const http = require('http');

// Test the updated RHO listing endpoint to see all RHOs
async function testAllRHOs() {
  try {
    // Get auth token
    const token = await loginSHO();
    if (!token) {
      console.log('❌ Failed to get auth token');
      return;
    }

    // Test GET /api/rho/ endpoint with detailed output
    console.log('\n📋 Testing updated RHO listing endpoint...');
    await testGetAllRHOs(token);

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

function testGetAllRHOs(token) {
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

    console.log('🔍 Testing GET /api/rho/ endpoint for ALL RHOs in state...');

    const req = http.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => responseData += chunk);
      res.on('end', () => {
        try {
          const parsedResponse = JSON.parse(responseData);
          console.log(`🔍 Response Status: ${res.statusCode}`);
          
          if (parsedResponse.success) {
            console.log('✅ RHO listing successful');
            console.log(`📋 Total RHOs returned: ${parsedResponse.rhos?.length || 0}`);
            console.log(`📋 Statistics: ${JSON.stringify(parsedResponse.statistics)}`);
            
            if (parsedResponse.rhos && parsedResponse.rhos.length > 0) {
              console.log('\n📋 All RHOs in Tamil Nadu state:');
              parsedResponse.rhos.forEach((rho, index) => {
                console.log(`${index + 1}. ${rho.officerId}`);
                console.log(`   Name: ${rho.fullName}`);
                console.log(`   District: ${rho.assignedDistrict}`);
                console.log(`   State: ${rho.assignedState}`);
                console.log(`   Created by: ${rho.parentSHO?.fullName || 'Unknown'}`);
                console.log(`   Active: ${rho.isActive}`);
                console.log('');
              });
            } else {
              console.log('📋 No RHOs found');
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
testAllRHOs();