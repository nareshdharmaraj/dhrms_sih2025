const axios = require('axios');

async function testPrescriptionAPI() {
  try {
    console.log('🔄 Testing Prescription API...');
    
    // Test data that matches the frontend structure
    const testPrescriptionData = {
      appointmentId: "672c1234567890abcdef1234", // Mock ObjectId
      doctorId: "672c1234567890abcdef5678",      // Mock ObjectId
      patientId: "672c1234567890abcdef9012",     // Mock ObjectId  
      hospitalId: "672c1234567890abcdef3456",    // Mock ObjectId
      patientName: "Test Patient",
      patientUHID: "UHID-TEST-001",
      doctorName: "Dr. Test Doctor",
      doctorIdentifier: "DOC-TEST-001",
      hospitalName: "Test Hospital",
      hospitalAddress: "123 Test Street, Test City",
      hospitalContact: {
        phone: "1234567890",
        email: "test@hospital.com"
      },
      appointmentNumber: "APT-TEST-001",
      diseaseName: "Test Disease",
      diseaseType: "not_communicable",
      expectedRecoveryDays: 7,
      medicines: [
        {
          type: "tablet",
          name: "Test Medicine",
          power: "500mg",
          countPerDose: 1,
          timing: ["morning"],
          beforeAfterFood: "after",
          duration: 7,
          totalCount: 7
        }
      ],
      nextVisitDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
      nextVisitMandatory: false,
      isConfirmed: true
    };
    
    console.log('📋 Test prescription data:');
    console.log(JSON.stringify(testPrescriptionData, null, 2));
    
    // Test the API endpoint
    console.log('\n🌐 Making API request to http://localhost:3000/api/prescriptions');
    
    const response = await axios.post('http://localhost:3000/api/prescriptions', testPrescriptionData, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer fake-token-for-test' // This will fail auth, but we can see if it reaches the endpoint
      },
      timeout: 10000
    });
    
    console.log('✅ API Response Status:', response.status);
    console.log('📄 API Response Data:', response.data);
    
  } catch (error) {
    if (error.response) {
      // Server responded with error status
      console.log('\n📡 Server Response:');
      console.log('Status:', error.response.status);
      console.log('Headers:', error.response.headers);
      console.log('Data:', JSON.stringify(error.response.data, null, 2));
    } else if (error.request) {
      // Request was made but no response
      console.log('\n🚨 No response received:');
      console.log(error.request);
    } else {
      // Something else happened
      console.log('\n❌ Request setup error:');
      console.log(error.message);
    }
  }
}

// Run the test
testPrescriptionAPI();