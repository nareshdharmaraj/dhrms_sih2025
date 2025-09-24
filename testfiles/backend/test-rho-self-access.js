const axios = require('axios');

async function testRHOSelfAccess() {
  try {
    // First login to get token
    console.log('🔐 Logging in as RHO...');
    const loginResponse = await axios.post('http://localhost:3000/api/rho/login', {
      rhoId: 'RHO_Pathanamthitta_001',
      password: 'password123',
      state: 'Kerala'
    });

    if (loginResponse.data.success) {
      const token = loginResponse.data.token;
      console.log('✅ Login successful!');
      console.log('Token:', token.substring(0, 50) + '...');

      // Test accessing RHO's own statistics
      console.log('\n🔍 Testing RHO self-statistics access...');
      try {
        const statsResponse = await axios.get('http://localhost:3000/api/rho/my/statistics', {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        console.log('✅ RHO self-statistics access successful!');
        console.log('Response:', statsResponse.data);
      } catch (statsError) {
        console.log('❌ RHO self-statistics access failed');
        console.log('Status:', statsError.response?.status);
        console.log('Error:', statsError.response?.data);
      }

      // Test accessing RHO's own profile
      console.log('\n🔍 Testing RHO self-profile access...');
      try {
        const profileResponse = await axios.get('http://localhost:3000/api/rho/my/profile', {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        console.log('✅ RHO self-profile access successful!');
        console.log('Profile:', {
          officerId: profileResponse.data.rho?.officerId,
          fullName: profileResponse.data.rho?.fullName,
          state: profileResponse.data.rho?.assignedState,
          district: profileResponse.data.rho?.assignedDistrict
        });
      } catch (profileError) {
        console.log('❌ RHO self-profile access failed');
        console.log('Status:', profileError.response?.status);
        console.log('Error:', profileError.response?.data);
      }

    } else {
      console.log('❌ Login failed:', loginResponse.data);
    }

  } catch (error) {
    console.log('❌ Test failed:', error.message);
  }
}

testRHOSelfAccess();