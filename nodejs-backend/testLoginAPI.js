// Test the actual login API endpoint
const http = require('http');

function testLogin(username, password, role, description) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      username: username,
      password: password,
      role: role
    });

    const options = {
      hostname: 'localhost',
      port: 5000,
      path: '/api/v1/auth/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log(`\n${description}:`);
          console.log(`Status: ${res.statusCode}`);
          console.log(`Response:`, response);
          resolve(response);
        } catch (error) {
          console.log(`\n${description} - Parse Error:`);
          console.log(`Status: ${res.statusCode}`);
          console.log(`Raw Response:`, data);
          resolve({ error: 'Parse error', raw: data });
        }
      });
    });

    req.on('error', (error) => {
      console.log(`\n${description} - Request Error:`, error.message);
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}

async function testAllLogins() {
  console.log('🧪 Testing Login API Endpoints...');
  
  try {
    // Test patient login
    await testLogin('rajesh_kumar_90', 'patient123', 'user', '👤 Patient Login Test');
    
    // Test hospital login
    await testLogin('apollo_admin', 'apollo123', 'hospital', '🏥 Hospital Login Test');
    
    // Test doctor login
    await testLogin('dr_rajesh_sharma', 'doctor123', 'doctor', '👨‍⚕️ Doctor Login Test');
    
    // Test regional login
    await testLogin('regional.admin', 'regional@123', 'regional', '🏛️ Regional Login Test');
    
    // Test wrong credentials
    await testLogin('rajesh_kumar_90', 'wrongpassword', 'user', '❌ Wrong Password Test');
    
  } catch (error) {
    console.error('Test error:', error);
  }
  
  console.log('\n🎯 Login API tests completed!');
}

testAllLogins();
