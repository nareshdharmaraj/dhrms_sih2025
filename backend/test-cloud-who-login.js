const https = require('https');

function testWhoLogin() {
  const postData = JSON.stringify({
    adminId: 'WHO_ADMIN_001',
    password: 'WhoAdmi@2024'
  });

  const options = {
    hostname: 'dhrms-sih2025.onrender.com',
    port: 443,
    path: '/api/who/login',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  console.log('🔍 Testing WHO login endpoint...');
  console.log('URL: https://dhrms-sih2025.onrender.com/api/who/login');
  console.log('Payload:', postData);
  console.log('');

  const req = https.request(options, (res) => {
    console.log(`📊 Status Code: ${res.statusCode}`);
    console.log(`📋 Headers:`, res.headers);
    console.log('');

    let data = '';
    res.on('data', (chunk) => {
      data += chunk;
    });

    res.on('end', () => {
      console.log('📥 Response Body:', data);
      console.log('');
      
      if (res.statusCode === 200) {
        console.log('✅ SUCCESS: WHO login endpoint is working!');
        try {
          const response = JSON.parse(data);
          if (response.success) {
            console.log('🎉 Login successful!');
            console.log('Admin:', response.admin?.username);
            console.log('Token received:', response.token ? 'Yes' : 'No');
          } else {
            console.log('❌ Login failed:', response.message);
          }
        } catch (e) {
          console.log('⚠️  Response is not valid JSON');
        }
      } else if (res.statusCode === 404) {
        console.log('❌ ERROR: Route still not found - deployment issue');
        console.log('🔧 Action needed: Redeploy your Render service with latest code');
      } else {
        console.log(`⚠️  Unexpected status code: ${res.statusCode}`);
      }
    });
  });

  req.on('error', (error) => {
    console.error('❌ Request error:', error.message);
  });

  req.write(postData);
  req.end();
}

// Test the endpoint
testWhoLogin();