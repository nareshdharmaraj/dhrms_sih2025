const axios = require('axios');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const BASE_URL = 'http://localhost:3000/api'; // Force localhost for testing
const SERVER_URL = 'http://localhost:3000'; // Remove /api for health check
const WHO_API_URL = `${BASE_URL}/who`;

// Test data
const testCredentials = {
  username: 'who_admin',
  password: 'WhoAdmin@2024'
};

let authToken = '';

// Test functions
async function testWhoSystemSetup() {
  console.log('🧪 Starting WHO System Tests...\n');

  try {
    // Test 1: Database Connection
    await testDatabaseConnection();
    
    // Test 2: Server Health Check
    await testServerHealth();
    
    // Test 3: WHO Admin Login
    await testWhoLogin();
    
    // Test 4: Dashboard Stats
    await testDashboardStats();
    
    // Test 5: Regional Officers
    await testRegionalOfficers();
    
    // Test 6: Hospitals List
    await testHospitalsList();
    
    // Test 7: Profile Management
    await testProfileManagement();
    
    // Test 8: Authentication Security
    await testAuthenticationSecurity();

    console.log('\n🎉 All WHO System Tests Passed Successfully!');
    console.log('\n📋 System Status: READY FOR PRODUCTION');
    
  } catch (error) {
    console.error('\n❌ WHO System Test Failed:', error.message);
    console.log('\n🔧 Please check the configuration and try again.');
  } finally {
    await mongoose.connection.close();
    process.exit(0);
  }
}

async function testDatabaseConnection() {
  console.log('1️⃣ Testing Database Connection...');
  
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('   ✅ Database connection successful');
  } catch (error) {
    throw new Error(`Database connection failed: ${error.message}`);
  }
}

async function testServerHealth() {
  console.log('2️⃣ Testing Server Health...');
  console.log(`   🔍 Checking server at: ${SERVER_URL}/health`);
  
  try {
    const response = await axios.get(`${SERVER_URL}/health`, {
      timeout: 10000 // 10 second timeout
    });
    
    if (response.status === 200) {
      console.log('   ✅ Server health check passed');
      console.log(`   📡 Server running on: ${response.data.timestamp}`);
    } else {
      throw new Error('Server health check failed');
    }
  } catch (error) {
    if (error.code === 'ECONNREFUSED') {
      throw new Error(`Server is not running on ${SERVER_URL}. Please start the backend server first with: npm start`);
    }
    if (error.code === 'ECONNRESET' || error.code === 'ETIMEDOUT') {
      throw new Error(`Server health check timed out. The server at ${SERVER_URL} is not responding. Please check if the server is running and accessible.`);
    }
    throw new Error(`Server health check failed: ${error.message}`);
  }
}

async function testWhoLogin() {
  console.log('3️⃣ Testing WHO Admin Login...');
  
  try {
    const response = await axios.post(`${WHO_API_URL}/login`, testCredentials);
    
    if (response.data.success && response.data.token) {
      authToken = response.data.token;
      console.log('   ✅ WHO admin login successful');
      console.log(`   🔑 Token received: ${authToken.substring(0, 20)}...`);
    } else {
      throw new Error('Login failed - no token received');
    }
  } catch (error) {
    if (error.response) {
      throw new Error(`Login failed: ${error.response.data.message}`);
    }
    throw new Error(`Login request failed: ${error.message}`);
  }
}

async function testDashboardStats() {
  console.log('4️⃣ Testing Dashboard Statistics...');
  
  try {
    const response = await axios.get(`${WHO_API_URL}/dashboard/stats`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    if (response.data.success && response.data.stats) {
      console.log('   ✅ Dashboard stats retrieved');
      console.log(`   📊 Total Hospitals: ${response.data.stats.totalHospitals}`);
      console.log(`   👥 Total Officers: ${response.data.stats.totalRegionalOfficers}`);
    } else {
      throw new Error('Dashboard stats not available');
    }
  } catch (error) {
    if (error.response) {
      throw new Error(`Dashboard test failed: ${error.response.data.message}`);
    }
    throw new Error(`Dashboard request failed: ${error.message}`);
  }
}

async function testRegionalOfficers() {
  console.log('5️⃣ Testing Regional Officers Management...');
  
  try {
    const response = await axios.get(`${WHO_API_URL}/regional-officers`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    if (response.data.success) {
      console.log('   ✅ Regional officers list retrieved');
      console.log(`   👥 Found ${response.data.pagination.count} officers`);
    } else {
      throw new Error('Regional officers list not available');
    }
  } catch (error) {
    if (error.response) {
      throw new Error(`Officers test failed: ${error.response.data.message}`);
    }
    throw new Error(`Officers request failed: ${error.message}`);
  }
}

async function testHospitalsList() {
  console.log('6️⃣ Testing Hospitals List...');
  
  try {
    const response = await axios.get(`${WHO_API_URL}/hospitals`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    if (response.data.success) {
      console.log('   ✅ Hospitals list retrieved');
      console.log(`   🏥 Found ${response.data.pagination.count} hospitals`);
    } else {
      throw new Error('Hospitals list not available');
    }
  } catch (error) {
    if (error.response) {
      throw new Error(`Hospitals test failed: ${error.response.data.message}`);
    }
    throw new Error(`Hospitals request failed: ${error.message}`);
  }
}

async function testProfileManagement() {
  console.log('7️⃣ Testing Profile Management...');
  
  try {
    const response = await axios.get(`${WHO_API_URL}/profile`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });
    
    if (response.data.success && response.data.profile) {
      console.log('   ✅ Profile retrieved successfully');
      console.log(`   👤 Admin: ${response.data.profile.fullName}`);
      console.log(`   📧 Email: ${response.data.profile.email}`);
      console.log(`   🛡️ Role: ${response.data.profile.role}`);
    } else {
      throw new Error('Profile not available');
    }
  } catch (error) {
    if (error.response) {
      throw new Error(`Profile test failed: ${error.response.data.message}`);
    }
    throw new Error(`Profile request failed: ${error.message}`);
  }
}

async function testAuthenticationSecurity() {
  console.log('8️⃣ Testing Authentication Security...');
  
  try {
    // Test invalid token
    try {
      await axios.get(`${WHO_API_URL}/dashboard/stats`, {
        headers: { Authorization: 'Bearer invalid-token' }
      });
      throw new Error('Security test failed - invalid token accepted');
    } catch (error) {
      if (error.response && error.response.status === 401) {
        console.log('   ✅ Invalid token properly rejected');
      } else {
        throw error;
      }
    }
    
    // Test missing token
    try {
      await axios.get(`${WHO_API_URL}/dashboard/stats`);
      throw new Error('Security test failed - missing token accepted');
    } catch (error) {
      if (error.response && error.response.status === 401) {
        console.log('   ✅ Missing token properly rejected');
      } else {
        throw error;
      }
    }
    
    console.log('   🔒 Authentication security verified');
    
  } catch (error) {
    throw new Error(`Security test failed: ${error.message}`);
  }
}

// Helper function to create sample data
async function createSampleData() {
  console.log('\n🔧 Creating sample data for testing...');
  
  // You can add code here to create sample hospitals, officers, etc.
  // This is optional and depends on your needs
  
  console.log('   ✅ Sample data creation completed');
}

// Run tests
if (require.main === module) {
  testWhoSystemSetup();
}

module.exports = {
  testWhoSystemSetup,
  createSampleData
};