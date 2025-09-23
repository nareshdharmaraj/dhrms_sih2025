const http = require('http');

// Test creating RHO with zone assignment for Ernakulam (dense district)
const testCreateRHOWithZone = async () => {
  const rhoData = {
    fullName: 'Test RHO with Zone',
    email: 'test.rho.zone@example.com',
    phone: '9876543210',
    password: 'TestPassword123',
    assignedDistrict: 'Ernakulam',
    qualification: 'MBBS, MD',
    experience: 5,
    licenseNumber: 'TEST-ZONE-2024',
    assignToZone: true,
    zoneId: 'ERN-NORTH-001', // North zone from our earlier check
    assignedZone: 'Ernakulam North Zone'
  };

  const data = JSON.stringify(rhoData);

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/rho/create',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzaG9JZCI6IjY3Mzk1NjJiMTI1YWQyNmEzNzUyYjQzNCIsInVzZXJuYW1lIjoiU0hPUzAwMSIsInJvbGUiOiJzaG8iLCJpYXQiOjE3MzE5MTYzNDAsImV4cCI6MTczMjAwMjc0MH0.oFtFVRz6d8oF2EqF3nWN9_hOOq1X6YwpZ9nv8Hd5eMI',
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      console.log(`Status: ${res.statusCode}`);
      console.log(`Headers:`, res.headers);

      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        try {
          const parsedData = JSON.parse(responseData);
          console.log('\n📊 Create RHO with Zone Response:');
          console.log(JSON.stringify(parsedData, null, 2));
          resolve(parsedData);
        } catch (error) {
          console.log('\n📊 Raw Response (not JSON):');
          console.log(responseData);
          resolve({ statusCode: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', (error) => {
      console.error('❌ Request failed:', error);
      reject(error);
    });

    req.write(data);
    req.end();
  });
};

testCreateRHOWithZone().catch(console.error);