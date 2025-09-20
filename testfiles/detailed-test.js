const axios = require('axios');

async function detailedTest() {
  console.log('🚀 Detailed Server Test...\n');

  try {
    // Test health endpoint first
    console.log('🔍 Testing health endpoint...');
    const healthResponse = await axios.get('http://localhost:3000/health');
    console.log('✅ Health check:', healthResponse.data);

    // Test WHO login
    console.log('\n📋 Testing WHO Login...');
    const loginData = {
      adminId: 'WHO_ADMIN_001',
      password: 'WhoAdmin@2024'
    };
    console.log('Login data:', loginData);

    const loginResponse = await axios.post('http://localhost:3000/api/who/login', loginData, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 10000
    });

    console.log('✅ Login Success!');
    console.log('Response:', loginResponse.data);

  } catch (error) {
    console.log('❌ Error Details:');
    if (error.code) {
      console.log('Error Code:', error.code);
    }
    if (error.response) {
      console.log('Status:', error.response.status);
      console.log('Data:', error.response.data);
      console.log('Headers:', error.response.headers);
    } else if (error.request) {
      console.log('Request was made but no response received');
      console.log('Request:', error.request);
    } else {
      console.log('Error message:', error.message);
    }
  }
}

detailedTest();