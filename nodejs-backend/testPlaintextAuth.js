// Test script to verify plaintext authentication is working
const http = require('http');

const baseURL = 'localhost';
const port = 5000;

function makeRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => {
        body += chunk;
      });
      res.on('end', () => {
        try {
          const parsedBody = JSON.parse(body);
          resolve({ statusCode: res.statusCode, data: parsedBody });
        } catch (error) {
          resolve({ statusCode: res.statusCode, data: body });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function testPlaintextAuth() {
  console.log('🧪 Testing Plaintext Authentication System...\n');

  try {
    // Test 1: Login with existing user
    console.log('1️⃣ Testing login with existing user...');
    const loginOptions = {
      hostname: baseURL,
      port: port,
      path: '/api/v1/auth/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const loginData = {
      username: 'rajesh_kumar_90',
      password: 'patient123',
      role: 'user'
    };

    const loginResponse = await makeRequest(loginOptions, loginData);

    if (loginResponse.data.success) {
      console.log('✅ Login successful! Plaintext authentication is working.');
      console.log('User ID:', loginResponse.data.userId);
      console.log('Role:', loginResponse.data.role);
      console.log('User:', loginResponse.data.user.name);
    } else {
      console.log('❌ Login failed:', loginResponse.data.message);
    }

  } catch (error) {
    console.log('❌ Login error:', error.message);
  }

  try {
    // Test 2: Health endpoint
    console.log('\n2️⃣ Testing health endpoint...');
    const healthOptions = {
      hostname: baseURL,
      port: port,
      path: '/health',
      method: 'GET'
    };

    const healthResponse = await makeRequest(healthOptions);
    console.log('✅ Health check:', healthResponse.data.message || healthResponse.data);
  } catch (error) {
    console.log('❌ Health check failed:', error.message);
  }

  console.log('\n🎯 Authentication test completed!');
}

testPlaintextAuth();
