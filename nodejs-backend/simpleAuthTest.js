const http = require('http');

async function testLogin(username, password, role) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      username: username,
      password: password,
      role: role
    });

    const options = {
      hostname: 'localhost',
      port: 5000,
      path: '/api/v1/auth/login',
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
        console.log(`Status Code: ${res.statusCode}`);
        console.log(`Response: ${data}`);
        
        try {
          const result = JSON.parse(data);
          resolve(result);
        } catch (e) {
          resolve({ error: 'Parse error', raw: data });
        }
      });
    });

    req.on('error', (e) => {
      console.error(`Request error: ${e.message}`);
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

async function main() {
  console.log('🧪 Testing DHRMS Authentication');
  console.log('================================\n');

  // Test patient login
  console.log('1️⃣ Testing Patient Login:');
  console.log('   Username: rajesh_kumar_90');
  console.log('   Password: patient123');
  console.log('   Role: user');
  try {
    const result = await testLogin('rajesh_kumar_90', 'patient123', 'user');
    console.log('   Result:', result.success ? '✅ SUCCESS' : '❌ FAILED');
    if (result.message) console.log('   Message:', result.message);
    if (result.user) console.log('   User:', result.user.name);
  } catch (e) {
    console.log('   ❌ Error:', e.message);
  }

  console.log('\n2️⃣ Testing Doctor Login:');
  console.log('   Username: dr_rajesh_sharma');
  console.log('   Password: doctor123');
  console.log('   Role: doctor');
  try {
    const result = await testLogin('dr_rajesh_sharma', 'doctor123', 'doctor');
    console.log('   Result:', result.success ? '✅ SUCCESS' : '❌ FAILED');
    if (result.message) console.log('   Message:', result.message);
    if (result.user) console.log('   User:', result.user.name);
  } catch (e) {
    console.log('   ❌ Error:', e.message);
  }

  console.log('\n3️⃣ Testing Hospital Admin Login:');
  console.log('   Username: apollo_admin');
  console.log('   Password: apollo123');
  console.log('   Role: hospital');
  try {
    const result = await testLogin('apollo_admin', 'apollo123', 'hospital');
    console.log('   Result:', result.success ? '✅ SUCCESS' : '❌ FAILED');
    if (result.message) console.log('   Message:', result.message);
    if (result.user) console.log('   User:', result.user.name);
  } catch (e) {
    console.log('   ❌ Error:', e.message);
  }

  console.log('\n🎯 Test completed!');
}

main();
