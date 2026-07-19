/**
 * Simple Registration Test
 * 
 * Test the registration endpoint with correct data structure
 */

const http = require('http');

async function testRegistrationEndpoint() {
  const registrationData = {
    username: "testuser123",
    password: "password123", 
    email: "test123@example.com",
    role: "user",
    firstName: "Test",
    lastName: "User",
    phone: "1234567890"
  };

  console.log('🧪 Testing registration endpoint...');
  console.log('📤 Sending data:', JSON.stringify(registrationData, null, 2));

  const postData = JSON.stringify(registrationData);

  const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/api/v1/auth/register',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        console.log('\n📥 Response Status:', res.statusCode);
        console.log('📥 Response Headers:', res.headers);
        console.log('📥 Response Data:', data);
        
        try {
          const responseData = JSON.parse(data);
          console.log('📥 Parsed Response:', JSON.stringify(responseData, null, 2));
          
          if (res.statusCode === 201) {
            console.log('✅ Registration successful!');
            resolve(responseData);
          } else {
            console.log('❌ Registration failed!');
            reject(new Error(`Registration failed with status ${res.statusCode}: ${data}`));
          }
        } catch (parseError) {
          console.log('❌ Failed to parse response:', parseError.message);
          console.log('Raw response:', data);
          reject(parseError);
        }
      });
    });

    req.on('error', (e) => {
      console.error('❌ Request error:', e.message);
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

// Run the test
if (require.main === module) {
  testRegistrationEndpoint()
    .then((result) => {
      console.log('\n🎉 Test completed successfully!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('\n💥 Test failed:', error.message);
      process.exit(1);
    });
}

module.exports = { testRegistrationEndpoint };
