const http = require('http');

async function testRegistration() {
  try {
    const registrationData = {
      username: 'testuser123',
      password: 'password123',
      email: 'test123@example.com',
      role: 'user',
      firstName: 'Test',
      lastName: 'User',
      phone: '1234567890',
      dateOfBirth: '1990-01-01',
      gender: 'male',
      address: {
        street: 'Test Street',
        city: 'Test City',
        state: 'Test State',
        pincode: '123456'
      }
    };

    console.log('Testing registration with data:', JSON.stringify(registrationData, null, 2));

    const postData = JSON.stringify(registrationData);

    const options = {
      hostname: 'localhost',
      port: 5000,
      path: '/api/v1/auth/register',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        console.log('Status Code:', res.statusCode);
        console.log('Response:', data);
        
        if (res.statusCode === 201) {
          console.log('Registration successful!');
        } else {
          console.log('Registration failed!');
        }
      });
    });

    req.on('error', (e) => {
      console.error('Error making request:', e.message);
    });

    req.write(postData);
    req.end();
    
  } catch (error) {
    console.error('Registration test failed:', error.message);
  }
}

testRegistration();
