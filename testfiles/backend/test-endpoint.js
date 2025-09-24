const axios = require('axios');

async function testEndpoint() {
  try {
    console.log('🔍 Testing if RHO login endpoint exists...');
    
    // Test with invalid data to see if endpoint responds
    const response = await axios.post('http://localhost:3000/api/rho/login', {
      rhoId: 'test',
      password: 'test'
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log('✅ Endpoint responds!');
    console.log('Status:', response.status);
    console.log('Response:', response.data);

  } catch (error) {
    if (error.response) {
      console.log('✅ Endpoint exists and responds with error (as expected)');
      console.log('Status:', error.response.status);
      console.log('Response:', error.response.data);
    } else if (error.code === 'ECONNREFUSED') {
      console.log('❌ Server is not running on localhost:3000');
    } else {
      console.log('❌ Error:', error.message);
    }
  }

  // Test health endpoint
  try {
    console.log('\n🔍 Testing health endpoint...');
    const response = await axios.get('http://localhost:3000/health');
    console.log('✅ Health endpoint works!');
    console.log('Response:', response.data);
  } catch (error) {
    console.log('❌ Health endpoint failed:', error.message);
  }
}

testEndpoint();