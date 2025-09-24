const axios = require('axios');

async function simpleTest() {
  try {
    console.log('🧪 Testing basic API connectivity...');
    
    // Test the diseases endpoint first
    console.log('\n📋 Testing diseases API endpoint...');
    const response = await axios.get('http://localhost:3000/api/diseases');
    console.log('✅ SUCCESS: Diseases API working!');
    console.log(`Status: ${response.status}`);
    console.log(`Found ${response.data.count} diseases`);
    console.log('First 3 diseases:', response.data.data.slice(0, 3));
    
  } catch (error) {
    console.log('❌ ERROR Details:');
    console.log('Message:', error.message);
    console.log('Code:', error.code);
    if (error.response) {
      console.log('Response Status:', error.response.status);
      console.log('Response Data:', error.response.data);
    } else {
      console.log('No response received');
      console.log('Request config:', error.config?.url);
    }
  }
}

simpleTest();