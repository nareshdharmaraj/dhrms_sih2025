const http = require('http');

// Test the RHO create endpoint
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
    'Authorization': 'Bearer fake-token-for-testing'
  }
};

console.log('🔍 Testing RHO create endpoint...');
console.log('🔍 Request options:', options);
console.log('🔍 Request data:', data);

const req = http.request(options, (res) => {
  console.log(`🔍 Status Code: ${res.statusCode}`);
  console.log(`🔍 Headers:`, res.headers);

  let responseData = '';
  res.on('data', (chunk) => {
    responseData += chunk;
  });

  res.on('end', () => {
    console.log('🔍 Response Body:', responseData);
    try {
      const parsedResponse = JSON.parse(responseData);
      console.log('🔍 Parsed Response:', JSON.stringify(parsedResponse, null, 2));
    } catch (e) {
      console.log('🔍 Failed to parse response as JSON');
    }
  });
});

req.on('error', (e) => {
  console.error(`🔍 Request Error: ${e.message}`);
});

req.write(data);
req.end();