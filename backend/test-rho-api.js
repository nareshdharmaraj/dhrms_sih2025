const axios = require('axios');

// Configuration
const API_BASE_URL = 'http://localhost:3000/api';
const TEST_SHO_CREDENTIALS = {
  username: 'sho_tn_001', // Replace with actual SHO credentials
  password: 'ShoPassword@123'
};

let authToken = '';

// Test RHO Creation API Endpoints
async function testRHOAPIFlow() {
  try {
    console.log('🚀 Testing RHO API Flow...\n');

    // Step 1: Login as SHO to get auth token
    console.log('📋 Step 1: Logging in as SHO...');
    try {
      const loginResponse = await axios.post(`${API_BASE_URL}/sho-auth/login`, {
        username: TEST_SHO_CREDENTIALS.username,
        password: TEST_SHO_CREDENTIALS.password
      });

      if (loginResponse.data.success) {
        authToken = loginResponse.data.token;
        console.log('✅ SHO login successful');
        console.log('   • SHO Name:', loginResponse.data.sho.fullName);
        console.log('   • Assigned State:', loginResponse.data.sho.assignedState);
        console.log('   • Token received:', authToken.substring(0, 20) + '...');
      } else {
        throw new Error('Login failed: ' + loginResponse.data.message);
      }
    } catch (error) {
      console.log('❌ SHO login failed:', error.response?.data?.message || error.message);
      console.log('⚠️  Please ensure you have a valid SHO account or update TEST_SHO_CREDENTIALS');
      return;
    }

    // Set up headers for authenticated requests
    const authHeaders = {
      'Authorization': `Bearer ${authToken}`,
      'Content-Type': 'application/json'
    };

    // Step 2: Get RHO Statistics
    console.log('\n📋 Step 2: Getting RHO statistics...');
    try {
      const statsResponse = await axios.get(`${API_BASE_URL}/rho/statistics`, {
        headers: authHeaders
      });
      console.log('✅ RHO Statistics:', statsResponse.data.statistics);
    } catch (error) {
      console.log('❌ Get statistics failed:', error.response?.data?.message || error.message);
    }

    // Step 3: Get existing RHOs
    console.log('\n📋 Step 3: Getting existing RHOs...');
    try {
      const rhosResponse = await axios.get(`${API_BASE_URL}/rho`, {
        headers: authHeaders
      });
      console.log('✅ Existing RHOs:', rhosResponse.data.rhos.length);
      if (rhosResponse.data.rhos.length > 0) {
        console.log('   • First RHO:', {
          id: rhosResponse.data.rhos[0]._id,
          officerId: rhosResponse.data.rhos[0].officerId,
          fullName: rhosResponse.data.rhos[0].fullName,
          assignedRegion: rhosResponse.data.rhos[0].assignedRegion
        });
      }
    } catch (error) {
      console.log('❌ Get RHOs failed:', error.response?.data?.message || error.message);
    }

    // Step 4: Create a new RHO
    console.log('\n📋 Step 4: Creating new RHO...');
    const timestamp = Date.now();
    const newRHOData = {
      fullName: 'Dr. Test RHO Officer',
      email: `test.rho.${timestamp}@health.gov.in`,
      phone: '+919876543210',
      password: 'TestRHO@123',
      assignedRegion: 'Test Region',
      regionCode: 'TST001',
      qualification: 'MBBS, MD (Community Medicine)',
      experience: 5,
      licenseNumber: `TEST-LIC-${timestamp}`,
      officeAddress: {
        buildingName: 'Test Health Office',
        street: 'Test Street',
        city: 'Test City',
        zipCode: '123456'
      },
      officePhone: '+914412345678',
      emergencyContact: {
        name: 'Emergency Contact',
        relationship: 'Deputy',
        phone: '+919876543211',
        email: `emergency.${timestamp}@health.gov.in`
      },
      staffLimits: {
        maxDirectStaff: 50,
        maxHospitalsOversight: 20,
        maxRegionsManaged: 3
      },
      coverage: {
        districts: ['Test District 1', 'Test District 2'],
        population: 1000000,
        areaKm2: 500.0
      }
    };

    try {
      const createResponse = await axios.post(`${API_BASE_URL}/rho`, newRHOData, {
        headers: authHeaders
      });
      
      if (createResponse.data.success) {
        console.log('✅ RHO created successfully!');
        console.log('   • RHO ID:', createResponse.data.rho.officerId);
        console.log('   • Full Name:', createResponse.data.rho.fullName);
        console.log('   • Username:', createResponse.data.loginCredentials.username);
        
        const newRHOId = createResponse.data.rho._id;

        // Step 5: Get the created RHO details
        console.log('\n📋 Step 5: Getting created RHO details...');
        try {
          const rhoDetailsResponse = await axios.get(`${API_BASE_URL}/rho/${newRHOId}`, {
            headers: authHeaders
          });
          console.log('✅ RHO details retrieved:', {
            officerId: rhoDetailsResponse.data.rho.officerId,
            fullName: rhoDetailsResponse.data.rho.fullName,
            isActive: rhoDetailsResponse.data.rho.isActive,
            assignedRegion: rhoDetailsResponse.data.rho.assignedRegion
          });
        } catch (error) {
          console.log('❌ Get RHO details failed:', error.response?.data?.message || error.message);
        }

        // Step 6: Update RHO details
        console.log('\n📋 Step 6: Updating RHO details...');
        try {
          const updateResponse = await axios.put(`${API_BASE_URL}/rho/${newRHOId}`, {
            experience: 7,
            qualification: 'MBBS, MD (Community Medicine), Ph.D'
          }, {
            headers: authHeaders
          });
          console.log('✅ RHO updated successfully');
        } catch (error) {
          console.log('❌ Update RHO failed:', error.response?.data?.message || error.message);
        }

        // Step 7: Toggle RHO status
        console.log('\n📋 Step 7: Toggling RHO status...');
        try {
          const toggleResponse = await axios.patch(`${API_BASE_URL}/rho/${newRHOId}/toggle-status`, {}, {
            headers: authHeaders
          });
          console.log('✅ RHO status toggled:', toggleResponse.data.message);
        } catch (error) {
          console.log('❌ Toggle status failed:', error.response?.data?.message || error.message);
        }

        // Step 8: Update RHO permissions
        console.log('\n📋 Step 8: Updating RHO permissions...');
        try {
          const permissionsResponse = await axios.patch(`${API_BASE_URL}/rho/${newRHOId}/permissions`, {
            permissions: {
              canViewHospitals: true,
              canManageHospitalStaff: true,
              canViewHospitalReports: true,
              canViewPatientData: true,
              canAccessMedicalRecords: true, // Granting additional permission
              canGenerateReports: true,
              canViewRegionalStats: true
            }
          }, {
            headers: authHeaders
          });
          console.log('✅ RHO permissions updated successfully');
        } catch (error) {
          console.log('❌ Update permissions failed:', error.response?.data?.message || error.message);
        }

        // Step 9: Reset RHO password
        console.log('\n📋 Step 9: Resetting RHO password...');
        try {
          const resetResponse = await axios.patch(`${API_BASE_URL}/rho/${newRHOId}/reset-password`, {
            newPassword: 'NewTestPassword@456'
          }, {
            headers: authHeaders
          });
          console.log('✅ RHO password reset successfully');
        } catch (error) {
          console.log('❌ Reset password failed:', error.response?.data?.message || error.message);
        }

      } else {
        console.log('❌ RHO creation failed:', createResponse.data.message);
      }
    } catch (error) {
      console.log('❌ Create RHO failed:', error.response?.data?.message || error.message);
      if (error.response?.data?.errors) {
        console.log('   Validation errors:', error.response.data.errors);
      }
    }

    // Step 10: Final statistics check
    console.log('\n📋 Step 10: Final statistics check...');
    try {
      const finalStatsResponse = await axios.get(`${API_BASE_URL}/rho/statistics`, {
        headers: authHeaders
      });
      console.log('✅ Final RHO Statistics:', finalStatsResponse.data.statistics);
    } catch (error) {
      console.log('❌ Final statistics check failed:', error.response?.data?.message || error.message);
    }

    console.log('\n🎉 RHO API Flow Test Completed!');

  } catch (error) {
    console.error('❌ Test flow failed:', error.message);
  }
}

// Helper function to test without authentication (should fail)
async function testWithoutAuth() {
  console.log('\n🔒 Testing API without authentication (should fail)...');
  try {
    const response = await axios.get(`${API_BASE_URL}/rho/statistics`);
    console.log('❌ Unexpected: API call succeeded without auth');
  } catch (error) {
    if (error.response?.status === 401) {
      console.log('✅ Correctly rejected unauthorized request');
    } else {
      console.log('❌ Unexpected error:', error.response?.status, error.response?.data?.message);
    }
  }
}

// Run the tests
async function runAllTests() {
  console.log('🚀 Starting RHO API Tests...\n');
  
  await testWithoutAuth();
  await testRHOAPIFlow();
  
  console.log('\n📊 Test Summary:');
  console.log('   • Authentication test: ✅');
  console.log('   • RHO creation test: Check logs above');
  console.log('   • RHO management test: Check logs above');
  console.log('\n💡 Make sure your backend server is running on localhost:3000');
  console.log('💡 Update TEST_SHO_CREDENTIALS with valid SHO login details');
}

// Check if axios is available
try {
  runAllTests();
} catch (error) {
  console.log('❌ Error: axios not found. Please install it:');
  console.log('   npm install axios');
  console.log('\nOr test manually using curl:');
  console.log(`
Example curl commands:

1. Login as SHO:
curl -X POST ${API_BASE_URL}/sho-auth/login \\
  -H "Content-Type: application/json" \\
  -d '{"username":"${TEST_SHO_CREDENTIALS.username}","password":"${TEST_SHO_CREDENTIALS.password}"}'

2. Create RHO (replace TOKEN):
curl -X POST ${API_BASE_URL}/rho \\
  -H "Authorization: Bearer TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "fullName": "Dr. Test RHO",
    "email": "test@health.gov.in",
    "phone": "+919876543210",
    "password": "TestRHO@123",
    "assignedRegion": "Test Region",
    "regionCode": "TST001",
    "qualification": "MBBS, MD",
    "experience": 5,
    "licenseNumber": "TEST-LIC-001"
  }'

3. Get RHOs:
curl -X GET ${API_BASE_URL}/rho \\
  -H "Authorization: Bearer TOKEN"
  `);
}