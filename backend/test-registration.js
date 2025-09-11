const axios = require('axios');

async function testPatientRegistration() {
  try {
    const patientData = {
      firstName: "John",
      lastName: "Doe",
      aadhaarNumber: "123456789012",
      phone: "9876543210",
      password: "password123",
      address: {
        street: "123 Main St",
        city: "Mumbai",
        state: "Maharashtra",
        zipCode: "400001"
      },
      dateOfBirth: "1990-01-01",
      gender: "male",
      bloodGroup: "O+",
      emergencyContact: {
        name: "Jane Doe",
        relationship: "wife",
        phone: "9876543211"
      },
      homeState: "Maharashtra"
    };

    console.log('Testing patient registration...');
    const response = await axios.post('http://localhost:3000/api/patients/register', patientData);
    
    console.log('✅ Registration successful!');
    console.log('UHID:', response.data.patient.uhid);
    console.log('Username:', response.data.patient.username);
    console.log('Full Name:', response.data.patient.fullName);
    
    // Test digital card retrieval
    console.log('\nTesting digital card retrieval...');
    const cardResponse = await axios.get(`http://localhost:3000/api/patients/digital-card/${response.data.patient.uhid}`);
    
    console.log('✅ Digital card retrieved successfully!');
    console.log('QR Code generated:', cardResponse.data.digitalCard.qrCode ? 'Yes' : 'No');
    
  } catch (error) {
    console.error('❌ Error occurred:');
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', error.response.data);
      console.error('Headers:', error.response.headers);
    } else if (error.request) {
      console.error('Request made but no response received:', error.request);
    } else {
      console.error('Error message:', error.message);
    }
    console.error('Full error:', error);
  }
}

testPatientRegistration();
