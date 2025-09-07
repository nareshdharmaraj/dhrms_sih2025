const http = require('http');

async function testDebugLogin(username, password, role) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({
      username: username,
      password: password,
      role: role
    });

    const options = {
      hostname: 'localhost',
      port: 5000,
      path: '/api/v1/auth/debug-login',
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
        console.log(`\n📊 Response Status: ${res.statusCode}`);
        console.log(`📄 Response Body: ${data}`);
        
        try {
          const result = JSON.parse(data);
          resolve(result);
        } catch (e) {
          resolve({ error: 'Parse error', raw: data });
        }
      });
    });

    req.on('error', (e) => {
      console.error(`❌ Request error: ${e.message}`);
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

async function main() {
  console.log('🧪 Testing DHRMS Debug Authentication');
  console.log('====================================');

  console.log('\n🔍 Testing Patient Login (Debug Mode):');
  try {
    await testDebugLogin('rajesh_kumar_90', 'patient123', 'user');
  } catch (e) {
    console.log('❌ Error:', e.message);
  }
}

main();
