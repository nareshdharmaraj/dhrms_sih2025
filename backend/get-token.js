const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function getToken() {
  try {
    console.log('🔑 Getting fresh SHO token...');
    
    const loginResponse = await axios.post(`${BASE_URL}/sho-auth/login`, {
      username: 'SHO_TN_001',
      password: 'shotn1234'
    });

    if (loginResponse.data.success) {
      console.log('✅ Login successful');
      console.log('🎫 Token:', loginResponse.data.token);
      return loginResponse.data.token;
    } else {
      console.log('❌ Login failed:', loginResponse.data.message);
      return null;
    }
  } catch (error) {
    console.error('❌ Login error:', error.response?.data?.message || error.message);
    return null;
  }
}

getToken();