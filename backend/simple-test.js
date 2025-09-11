const axios = require('axios');

async function simpleTest() {
  try {
    console.log('🧪 Testing UHID generation...');
    
    const response = await axios.post('http://localhost:3000/api/patients/register', {
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
    });

    console.log('✅ SUCCESS!');
    console.log('UHID:', response.data.patient.uhid);
    console.log('Username:', response.data.patient.username);
    console.log('Full Name:', response.data.patient.fullName);
    console.log('Are UHID and Username same?', response.data.patient.uhid === response.data.patient.username);
    console.log('UHID Length:', response.data.patient.uhid.length);
    
  } catch (error) {
    if (error.response) {
      console.log('❌ API Error:', error.response.data.message);
    } else {
      console.log('❌ Network Error:', error.message);
    }
  }
}

simpleTest();
