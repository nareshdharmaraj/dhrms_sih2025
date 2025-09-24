const axios = require('axios');

async function testNoAuthAPI() {
  try {
    console.log('🔄 Testing No-Auth Prescription API...');
    
    // Simple test data
    const testData = {
      patientName: "Test Patient",
      patientUHID: "TEST-001", 
      doctorName: "Dr. Test",
      doctorIdentifier: "DOC-001",
      hospitalName: "Test Hospital",
      appointmentNumber: "APT-001",
      diseaseName: "Test Disease",
      diseaseType: "not_communicable",
      medicines: [{
        type: "tablet",
        name: "Test Medicine"
      }],
      isConfirmed: true
    };
    
    console.log('📋 Sending test data:', JSON.stringify(testData, null, 2));
    
    const response = await axios.post('http://localhost:3000/api/test-prescriptions/test-no-auth', testData, {
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 10000
    });
    
    console.log('✅ Success! Status:', response.status);
    console.log('📄 Response:', JSON.stringify(response.data, null, 2));
    
  } catch (error) {
    if (error.response) {
      console.log('❌ Server Error:');
      console.log('Status:', error.response.status);
      console.log('Data:', JSON.stringify(error.response.data, null, 2));
    } else {
      console.log('❌ Request Error:', error.message);
    }
  }
}

// Run the test
testNoAuthAPI();