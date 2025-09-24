const axios = require('axios');
const baseURL = 'http://localhost:3000';

async function testRHOFlow() {
  try {
    console.log('🔐 Testing RHO login...');
    const loginResponse = await axios.post(`${baseURL}/api/rho/login`, {
      rhoId: 'RHO_Pathanamthitta_001',
      password: 'password123',
      state: 'Kerala'
    });
    
    console.log('✅ Login successful:', loginResponse.data.success);
    console.log('Token received:', !!loginResponse.data.token);
    
    const token = loginResponse.data.token;
    
    console.log('\n📊 Testing RHO dashboard statistics...');
    const statsResponse = await axios.get(`${baseURL}/api/rho/my/statistics`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    console.log('✅ Statistics retrieved:', statsResponse.data.success);
    console.log('Data structure:', JSON.stringify(statsResponse.data, null, 2));
    
  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

testRHOFlow();