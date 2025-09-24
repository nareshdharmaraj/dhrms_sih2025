const axios = require('axios');

async function testLogin() {
  try {
    console.log('🔐 Testing exact RHO login credentials...');
    
    const response = await axios.post('http://localhost:3000/api/rho/login', {
      rhoId: 'RHO_Pathanamthitta_001',
      password: 'password123',
      state: 'Kerala'
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log('✅ Login successful!');
    console.log('Token:', response.data.token);
    console.log('RHO Data:', response.data.rho);

  } catch (error) {
    if (error.response) {
      console.log('❌ Login failed');
      console.log('Status:', error.response.status);
      console.log('Response:', error.response.data);
      
      // Let's also test without state to see if that's the issue
      console.log('\n🔐 Testing without state parameter...');
      try {
        const response2 = await axios.post('http://localhost:3000/api/rho/login', {
          rhoId: 'RHO_Pathanamthitta_001',
          password: 'password123'
        });
        console.log('✅ Login successful without state!');
        console.log('Response:', response2.data);
      } catch (error2) {
        console.log('❌ Still failed without state');
        console.log('Response:', error2.response?.data);
      }
    } else {
      console.log('❌ Network error:', error.message);
    }
  }
}

testLogin();