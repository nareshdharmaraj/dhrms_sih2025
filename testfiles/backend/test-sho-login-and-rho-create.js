const http = require('http');

// Test the SHO login endpoint to get a valid token
// Using actual SHO data from database: 
// email: "sho.tn@myhealth.gov.in"
// officerId: "SHO_TN_001"
// fullName: "Dr. Tamil Nadu SHO"
const loginData = JSON.stringify({
  "email": "sho.tn@myhealth.gov.in",
  "password": "TestPassword@123"
});

const loginOptions = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/sho-auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  }
};

console.log('🔍 Testing SHO login endpoint...');
console.log('🔍 Login request options:', loginOptions);
console.log('🔍 Login request data:', loginData);

const loginReq = http.request(loginOptions, (res) => {
  console.log(`🔍 Login Status Code: ${res.statusCode}`);

  let responseData = '';
  res.on('data', (chunk) => {
    responseData += chunk;
  });

  res.on('end', () => {
    console.log('🔍 Login Response Body:', responseData);
    try {
      const parsedResponse = JSON.parse(responseData);
      console.log('🔍 Login Parsed Response:', JSON.stringify(parsedResponse, null, 2));
      
      if (parsedResponse.success && parsedResponse.token) {
        console.log('✅ Got valid token, now testing RHO create...');
        testRHOCreate(parsedResponse.token);
      } else {
        console.log('❌ Login failed, cannot test RHO create');
      }
    } catch (e) {
      console.log('🔍 Failed to parse login response as JSON');
    }
  });
});

loginReq.on('error', (e) => {
  console.error(`🔍 Login Request Error: ${e.message}`);
});

loginReq.write(loginData);
loginReq.end();

function testRHOCreate(validToken) {
  const data = JSON.stringify({
    "fullName": "Test RHO",
    "email": "test@example.com",
    "phone": "1234567890",
    "password": "TestPass123!",
    "assignedDistrict": "Salem",
    "assignedAreas": ["Salem Zone 1"],
    "qualification": "MBBS",
    "experience": 5,
    "licenseNumber": "TN123456"
  });

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/rho/create',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${validToken}`
    }
  };

  console.log('🔍 Testing RHO create with valid token...');

  const req = http.request(options, (res) => {
    console.log(`🔍 RHO Create Status Code: ${res.statusCode}`);

    let responseData = '';
    res.on('data', (chunk) => {
      responseData += chunk;
    });

    res.on('end', () => {
      console.log('🔍 RHO Create Response Body:', responseData);
      try {
        const parsedResponse = JSON.parse(responseData);
        console.log('🔍 RHO Create Parsed Response:', JSON.stringify(parsedResponse, null, 2));
      } catch (e) {
        console.log('🔍 Failed to parse RHO create response as JSON');
      }
    });
  });

  req.on('error', (e) => {
    console.error(`🔍 RHO Create Request Error: ${e.message}`);
  });

  req.write(data);
  req.end();
}