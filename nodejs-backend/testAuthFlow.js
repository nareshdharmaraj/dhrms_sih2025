const { spawn } = require('child_process');

console.log('🧪 Testing DHRMS Authentication Flow');
console.log('====================================');

const testCases = [
  {
    name: 'Patient Login',
    username: 'rajesh_kumar_90',
    password: 'patient123',
    role: 'user'
  },
  {
    name: 'Doctor Login',
    username: 'dr_rajesh_sharma',
    password: 'doctor123',
    role: 'doctor'
  },
  {
    name: 'Hospital Admin Login',
    username: 'apollo_admin',
    password: 'apollo123',
    role: 'hospital'
  }
];

async function testAuthentication(testCase) {
  return new Promise((resolve, reject) => {
    const curlCommand = `curl -X POST http://localhost:5000/api/v1/auth/login -H "Content-Type: application/json" -d "{\\"username\\":\\"${testCase.username}\\",\\"password\\":\\"${testCase.password}\\",\\"role\\":\\"${testCase.role}\\"}"`;
    
    console.log(`\n🔍 Testing ${testCase.name}:`);
    console.log(`   Username: ${testCase.username}`);
    console.log(`   Password: ${testCase.password}`);
    console.log(`   Role: ${testCase.role}`);
    
    const curl = spawn('cmd', ['/c', curlCommand], { stdio: ['pipe', 'pipe', 'pipe'] });
    
    let output = '';
    let error = '';
    
    curl.stdout.on('data', (data) => {
      output += data.toString();
    });
    
    curl.stderr.on('data', (data) => {
      error += data.toString();
    });
    
    curl.on('close', (code) => {
      if (code === 0) {
        try {
          const result = JSON.parse(output);
          if (result.success) {
            console.log(`   ✅ SUCCESS: ${result.message}`);
            console.log(`   👤 User: ${result.user.name}`);
            console.log(`   🔑 Token: ${result.token.substring(0, 20)}...`);
          } else {
            console.log(`   ❌ FAILED: ${result.message}`);
          }
        } catch (e) {
          console.log(`   📄 Raw Response: ${output}`);
          console.log(`   ⚠️  Parse Error: ${e.message}`);
        }
      } else {
        console.log(`   ❌ Command failed (code ${code}): ${error}`);
      }
      resolve();
    });
  });
}

async function runTests() {
  console.log('⏰ Starting authentication tests...\n');
  
  for (const testCase of testCases) {
    await testAuthentication(testCase);
  }
  
  console.log('\n🎯 Authentication tests completed!');
  console.log('\n💡 To test in Flutter app:');
  console.log('   1. Open http://localhost:8080');
  console.log('   2. Navigate to login screen');
  console.log('   3. Use the credentials above');
  console.log('   4. Select the appropriate role');
}

runTests();
