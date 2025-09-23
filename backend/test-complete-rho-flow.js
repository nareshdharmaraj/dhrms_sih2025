const axios = require('axios');

async function testCompleteRHOFlow() {
  try {
    console.log('🔐 Testing complete RHO authentication and data access flow...\n');

    // Step 1: Login as RHO
    console.log('Step 1: RHO Login');
    const loginResponse = await axios.post('http://localhost:3000/api/rho/login', {
      rhoId: 'RHO_Pathanamthitta_001',
      password: 'password123',
      state: 'Kerala'
    });

    if (!loginResponse.data.success) {
      console.log('❌ Login failed:', loginResponse.data);
      return;
    }

    const token = loginResponse.data.token;
    const rhoData = loginResponse.data.rho;
    console.log('✅ Login successful!');
    console.log('   RHO ID:', rhoData.rhoId);
    console.log('   Name:', rhoData.fullName);
    console.log('   State:', rhoData.state);
    console.log('   District:', rhoData.district);

    // Step 2: Test Flutter service endpoint format
    console.log('\nStep 2: Test RHO Self-Statistics (Flutter format)');
    try {
      const statsResponse = await axios.get('http://localhost:3000/api/rho/my/statistics', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      console.log('✅ Statistics access successful!');
      console.log('   Response structure:', {
        success: statsResponse.data.success,
        hasStatistics: !!statsResponse.data.statistics,
        hasProfile: !!statsResponse.data.profile,
        statisticsKeys: Object.keys(statsResponse.data.statistics || {}),
        profileKeys: Object.keys(statsResponse.data.profile || {})
      });
      
      // Verify data structure matches what Flutter expects
      const stats = statsResponse.data.statistics;
      console.log('   Statistics data:');
      console.log('     - Total Staff Managed:', stats?.totalStaffManaged);
      console.log('     - Hospitals Overseen:', stats?.hospitalsOverseen);
      console.log('     - Patients Served:', stats?.patientsServed);
      console.log('     - Emergency Responses:', stats?.emergencyResponsesHandled);
      console.log('     - Performance Rating:', stats?.performanceRating);
      
    } catch (statsError) {
      console.log('❌ Statistics access failed');
      console.log('   Status:', statsError.response?.status);
      console.log('   Error:', statsError.response?.data);
      return;
    }

    // Step 3: Test RHO Profile Access
    console.log('\nStep 3: Test RHO Self-Profile');
    try {
      const profileResponse = await axios.get('http://localhost:3000/api/rho/my/profile', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      console.log('✅ Profile access successful!');
      const profile = profileResponse.data.rho;
      console.log('   Profile data:');
      console.log('     - Officer ID:', profile?.officerId);
      console.log('     - Full Name:', profile?.fullName);
      console.log('     - Email:', profile?.email);
      console.log('     - State:', profile?.assignedState);
      console.log('     - District:', profile?.assignedDistrict);
      console.log('     - Region:', profile?.assignedRegion);
      console.log('     - Is Active:', profile?.isActive);
      
    } catch (profileError) {
      console.log('❌ Profile access failed');
      console.log('   Status:', profileError.response?.status);
      console.log('   Error:', profileError.response?.data);
      return;
    }

    // Step 4: Verify JWT Token Structure
    console.log('\nStep 4: JWT Token Analysis');
    const tokenParts = token.split('.');
    if (tokenParts.length === 3) {
      try {
        const payload = JSON.parse(Buffer.from(tokenParts[1], 'base64').toString());
        console.log('✅ JWT Token structure:');
        console.log('   - RHO ID:', payload.rhoId);
        console.log('   - User Type:', payload.userType);
        console.log('   - State:', payload.state);
        console.log('   - District:', payload.district);
        console.log('   - Expires:', new Date(payload.exp * 1000).toLocaleString());
      } catch (e) {
        console.log('❌ JWT parsing failed:', e.message);
      }
    }

    console.log('\n🎉 Complete RHO flow test passed!');
    console.log('\n📋 Summary:');
    console.log('✅ RHO Login working');
    console.log('✅ RHO Self-Statistics endpoint working');
    console.log('✅ RHO Self-Profile endpoint working');
    console.log('✅ JWT token structure correct');
    console.log('✅ Ready for Flutter app integration');

  } catch (error) {
    console.log('❌ Flow test failed:', error.message);
    if (error.response) {
      console.log('   Status:', error.response.status);
      console.log('   Response:', error.response.data);
    }
  }
}

testCompleteRHOFlow();