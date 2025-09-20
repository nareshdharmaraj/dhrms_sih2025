const axios = require('axios');

async function quickSHOTest() {
  console.log('🚀 Quick SHO Creation Test...\n');

  try {
    // Test server connectivity first
    console.log('🔍 Testing server connectivity...');
    
    // Simple test data that should pass all validations
    const testData = {
      officerId: 'SHO_TN_001',
      fullName: 'Dr. Tamil Nadu Officer',
      email: 'sho.tn@health.gov.in',
      phone: '9876543210',
      assignedState: 'Tamil Nadu',
      password: 'Password123'
    };

    // Step 1: Login
    console.log('📋 Step 1: WHO Admin Login');
    const loginResponse = await axios.post('http://localhost:3000/api/who/login', {
      adminId: 'WHO_ADMIN_001',
      password: 'WhoAdmin@2024'
    });

    console.log('✅ Login Success');
    const token = loginResponse.data.token;

    // Step 2: Create SHO
    console.log('📋 Step 2: Creating SHO');
    console.log('Data:', JSON.stringify(testData, null, 2));

    const response = await axios.post('http://localhost:3000/api/sho', testData, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    console.log('✅ SHO Creation Success!');
    console.log('Response:', response.data);

  } catch (error) {
    console.log('❌ Error occurred:');
    if (error.response) {
      console.log('Status:', error.response.status);
      console.log('Error Data:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.log('Network Error:', error.message);
    }
  }
}

quickSHOTest();