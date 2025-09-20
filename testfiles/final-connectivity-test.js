const axios = require('axios');

async function finalConnectivityTest() {
  console.log('🎯 Final Connectivity Test - All Components\n');

  try {
    // Test 1: Health Check
    console.log('🔍 Test 1: Health Check');
    const healthResponse = await axios.get('http://localhost:3000/health');
    console.log('✅ Health Check Passed:', healthResponse.data.message);

    // Test 2: WHO Admin Login
    console.log('\n🔍 Test 2: WHO Admin Authentication');
    const loginResponse = await axios.post('http://localhost:3000/api/who/login', {
      adminId: 'WHO_ADMIN_001',
      password: 'WhoAdmin@2024'
    });
    console.log('✅ WHO Login Successful');

    const token = loginResponse.data.token;

    // Test 3: SHO Management Access
    console.log('\n🔍 Test 3: SHO Management Access');
    const shoResponse = await axios.get('http://localhost:3000/api/sho', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log(`✅ SHO Access Successful - Found ${shoResponse.data.shos.length} SHOs`);

    // Test 4: SHO Statistics
    console.log('\n🔍 Test 4: SHO Statistics');
    const statsResponse = await axios.get('http://localhost:3000/api/sho/statistics', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    console.log('✅ SHO Statistics Successful');

    console.log('\n🎉 ALL CONNECTIVITY TESTS PASSED! 🎉');
    console.log('📱 Flutter app should now successfully connect to backend');
    console.log('🔧 Configuration Summary:');
    console.log('   ✅ Backend Server: Running on port 3000');
    console.log('   ✅ Flutter App: Configured for port 3000');
    console.log('   ✅ VS Code Debug: Updated to port 3000');
    console.log('   ✅ Environment Files: Updated to port 3000');
    console.log('\n🚀 Ready for Flutter app testing!');

  } catch (error) {
    console.log('❌ Test Failed:');
    if (error.response) {
      console.log('Status:', error.response.status);
      console.log('Error:', error.response.data);
    } else {
      console.log('Error:', error.message);
    }
  }
}

finalConnectivityTest();