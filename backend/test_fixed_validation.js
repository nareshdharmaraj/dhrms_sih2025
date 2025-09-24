const axios = require('axios');

// Test data with all required fields according to actual DB schema
const testDataComplete = {
  appointmentId: "507f1f77bcf86cd799439011",
  doctorId: "507f1f77bcf86cd799439012",
  patientId: "507f1f77bcf86cd799439013",
  hospitalId: "507f1f77bcf86cd799439014",
  patientName: "John Doe",
  patientUHID: "UH123456",
  doctorName: "Dr. Smith",
  doctorIdentifier: "DOC001",
  hospitalName: "Test Hospital",
  hospitalAddress: "123 Test Street, Test City, Test State",
  hospitalContact: {
    phone: "1234567890",
    email: "contact@testhospital.com"
  },
  appointmentNumber: "APT001",
  diseases: [
    {
      name: "Influenza (Flu)",
      isCustom: false
    },
    {
      name: "Fever",
      isCustom: true
    }
  ], // New diseases array field
  diseaseType: "communicable",
  expectedRecoveryDays: 7,
  medicines: [
    {
      type: "tablet",
      name: "Paracetamol",
      power: "500mg",
      countPerDose: 1,
      timing: ["morning", "evening"],
      beforeAfterFood: "after",
      duration: 5
    }
  ],
  nextVisitDate: "2024-01-01",
  nextVisitMandatory: false,
  isConfirmed: true
};

// Test data missing hospitalContact email
const testDataMissingContactEmail = {
  ...testDataComplete,
  hospitalContact: {
    phone: "1234567890"
    // missing email
  }
};

// Test data missing diseases
const testDataMissingDiseases = {
  ...testDataComplete,
  diseases: []
};

async function testValidation() {
  try {
    console.log('\n🧪 Testing API validation fixes...\n');
    
    // Test 1: Should fail without hospitalContact email
    console.log('📋 Test 1: Missing hospitalContact.email (should fail)...');
    try {
      const response1 = await axios.post('http://localhost:3000/api/prescriptions', testDataMissingContactEmail, {
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NzVlNGU5NjAzNTMzNGZmODUzMzc3M2YiLCJyb2xlIjoiZG9jdG9yIiwiaWF0IjoxNzM0MzU0MjQ2LCJleHAiOjE3MzQzNTc4NDZ9.EhWMUAjBnKebgb5nCp3h6uW-wKwtjhJfkjuY4zWGCAI',
          'Content-Type': 'application/json'
        }
      });
      console.log('❌ UNEXPECTED: Request succeeded when it should have failed!');
    } catch (error) {
      if (error.response && error.response.status === 400) {
        console.log('✅ CORRECT: Request failed with validation error');
        console.log('Error message:', error.response.data.message);
      } else {
        console.log('❌ UNEXPECTED error:', error.response?.data || error.message);
      }
    }
    
    // Test 2: Should fail with empty diseases array
    console.log('\n📋 Test 2: Empty diseases array (should fail)...');
    try {
      const response2 = await axios.post('http://localhost:3000/api/prescriptions', testDataMissingDiseases, {
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NzVlNGU5NjAzNTMzNGZmODUzMzc3M2YiLCJyb2xlIjoiZG9jdG9yIiwiaWF0IjoxNzM0MzU0MjQ2LCJleHAiOjE3MzQzNTc4NDZ9.EhWMUAjBnKebgb5nCp3h6uW-wKwtjhJfkjuY4zWGCAI',
          'Content-Type': 'application/json'
        }
      });
      console.log('❌ UNEXPECTED: Request succeeded when it should have failed!');
    } catch (error) {
      if (error.response && error.response.status === 400) {
        console.log('✅ CORRECT: Request failed with validation error');
        console.log('Error message:', error.response.data.message);
      } else {
        console.log('❌ UNEXPECTED error:', error.response?.data || error.message);
      }
    }
    
    // Test 3: Should succeed with all correct data
    console.log('\n📋 Test 3: Complete valid data with diseases (should succeed)...');
    try {
      const response3 = await axios.post('http://localhost:3000/api/prescriptions', testDataComplete, {
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NzVlNGU5NjAzNTMzNGZmODUzMzc3M2YiLCJyb2xlIjoiZG9jdG9yIiwiaWF0IjoxNzM0MzU0MjQ2LCJleHAiOjE3MzQzNTc4NDZ9.EhWMUAjBnKebgb5nCp3h6uW-wKwtjhJfkjuY4zWGCAI',
          'Content-Type': 'application/json'
        }
      });
      console.log('✅ SUCCESS: Prescription saved successfully!');
      console.log('Response:', response3.data);
      console.log('Generated diseaseName:', response3.data.data?.diseaseName);
    } catch (error) {
      console.log('❌ ERROR: Request failed unexpectedly');
      console.log('Error:', error.response?.data || error.message);
      console.log('Status:', error.response?.status);
    }
    
    // Test 4: Test diseases API endpoint
    console.log('\n📋 Test 4: Diseases API endpoint...');
    try {
      const diseasesResponse = await axios.get('http://localhost:3000/api/diseases');
      console.log('✅ SUCCESS: Diseases API working!');
      console.log(`Found ${diseasesResponse.data.count} diseases`);
      console.log('First few diseases:', diseasesResponse.data.data.slice(0, 3));
    } catch (error) {
      console.log('❌ ERROR: Diseases API failed');
      console.log('Error:', error.response?.data || error.message);
    }
    
    // Test 5: Test diseases search API
    console.log('\n📋 Test 5: Diseases search API...');
    try {
      const searchResponse = await axios.get('http://localhost:3000/api/diseases/search?query=flu');
      console.log('✅ SUCCESS: Diseases search working!');
      console.log(`Found ${searchResponse.data.count} matches for "flu"`);
      console.log('Search results:', searchResponse.data.data);
    } catch (error) {
      console.log('❌ ERROR: Diseases search API failed');
      console.log('Error:', error.response?.data || error.message);
    }
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
  }
}

testValidation();