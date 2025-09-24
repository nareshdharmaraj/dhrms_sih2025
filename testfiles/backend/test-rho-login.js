const axios = require('axios');

async function testRHOLogin() {
  try {
    console.log('🔐 Testing RHO login...');
    
    const response = await axios.post('http://localhost:3000/api/rho/login', {
      rhoId: 'RHO_Pathanamthitta_001',
      password: 'TestPassword@123', // Try the password from creation script
      state: 'Kerala'
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log('✅ Login successful!');
    console.log('Response:', response.data);

  } catch (error) {
    console.log('❌ Login failed');
    if (error.response) {
      console.log('Status:', error.response.status);
      console.log('Response:', error.response.data);
    } else {
      console.log('Error:', error.message);
    }
    
    // Try with different passwords
    const commonPasswords = ['password123', 'Password123', 'admin123', '123456', 'test123', 'password', 'TempPassword@2024'];
    
    for (const pwd of commonPasswords) {
      try {
        console.log(`\n🔐 Trying password: ${pwd}`);
        const response = await axios.post('http://localhost:3000/api/rho/login', {
          rhoId: 'RHO_Pathanamthitta_001',
          password: pwd,
          state: 'Kerala'
        });
        console.log('✅ Success with password:', pwd);
        break;
      } catch (err) {
        console.log('❌ Failed with password:', pwd);
      }
    }
  }
}

testRHOLogin();