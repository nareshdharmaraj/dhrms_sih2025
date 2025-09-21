const axios = require('axios');

async function debugSHOValidation() {
  console.log('🔍 Debugging SHO Validation Issues...\n');

  try {
    // Step 1: WHO Admin Login
    console.log('📋 Step 1: WHO Admin Login');
    const loginResponse = await axios.post('http://localhost:3000/api/who/login', {
      adminId: 'WHO_ADMIN_001',
      password: 'WhoAdmin@2024'
    });

    console.log('✅ WHO Login Success');
    const token = loginResponse.data.token;

    // Step 2: Test various SHO data formats to identify validation issues
    console.log('\n📋 Step 2: Testing SHO Validation\n');

    const testCases = [
      {
        name: "Basic Valid SHO",
        data: {
          officerId: "SHO_UP_001",
          fullName: "Dr. Uttar Pradesh Officer",
          email: "sho.up@health.gov.in",
          phone: "9876543220",
          assignedState: "Uttar Pradesh",
          password: "Password123"
        }
      },
      {
        name: "Different Officer ID Format",
        data: {
          officerId: "SHO_UK_001",
          fullName: "Dr. Uttarakhand Officer",
          email: "sho.uk@health.gov.in",
          phone: "9876543221",
          assignedState: "Uttarakhand",
          password: "Password123"
        }
      },
      {
        name: "With Special Characters in Name",
        data: {
          officerId: "SHO_WB_001",
          fullName: "Dr. West Bengal Officer",
          email: "sho.wb@health.gov.in",
          phone: "9876543222",
          assignedState: "West Bengal",
          password: "Password123"
        }
      },
      {
        name: "Minimal Valid Data",
        data: {
          officerId: "SHO_BR_001",
          fullName: "Dr. Test",
          email: "test@gov.in",
          phone: "9876543223",
          assignedState: "Bihar",
          password: "Pass1234"
        }
      }
    ];

    for (const testCase of testCases) {
      console.log(`🧪 Testing: ${testCase.name}`);
      console.log(`📊 Data:`, JSON.stringify(testCase.data, null, 2));
      
      try {
        const response = await axios.post('http://localhost:3000/api/sho', testCase.data, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        
        console.log(`✅ ${testCase.name} SUCCESS`);
        console.log(`📋 Created SHO: ${response.data.sho.fullName}`);
        
      } catch (error) {
        console.log(`❌ ${testCase.name} FAILED`);
        if (error.response?.data) {
          console.log(`📋 Status: ${error.response.status}`);
          console.log(`📋 Error Message: ${error.response.data.message}`);
          if (error.response.data.errors) {
            console.log('📋 Validation Errors:');
            error.response.data.errors.forEach(err => {
              console.log(`   - Field: ${err.path || err.param} | Message: ${err.msg}`);
            });
          }
        } else {
          console.log(`📋 Network Error: ${error.message}`);
        }
      }
      console.log('─'.repeat(50));
    }

    // Step 3: Test edge cases that might cause validation issues
    console.log('\n📋 Step 3: Testing Edge Cases\n');

    const edgeCases = [
      {
        name: "Empty Fields Test",
        data: {
          officerId: "",
          fullName: "",
          email: "",
          phone: "",
          assignedState: "",
          password: ""
        }
      },
      {
        name: "Invalid Officer ID",
        data: {
          officerId: "INVALID_ID",
          fullName: "Dr. Test Officer",
          email: "test@gov.in",
          phone: "9876543224",
          assignedState: "Punjab",
          password: "Password123"
        }
      },
      {
        name: "Invalid Phone Format",
        data: {
          officerId: "SHO_PB_001",
          fullName: "Dr. Punjab Officer",
          email: "sho.pb@health.gov.in",
          phone: "123456789",
          assignedState: "Punjab",
          password: "Password123"
        }
      },
      {
        name: "Invalid State",
        data: {
          officerId: "SHO_XX_001",
          fullName: "Dr. Invalid State",
          email: "sho.xx@health.gov.in",
          phone: "9876543225",
          assignedState: "Invalid State",
          password: "Password123"
        }
      },
      {
        name: "Invalid Password",
        data: {
          officerId: "SHO_RJ_001",
          fullName: "Dr. Rajasthan Officer",
          email: "sho.rj@health.gov.in",
          phone: "9876543226",
          assignedState: "Rajasthan",
          password: "simple"
        }
      }
    ];

    for (const testCase of edgeCases) {
      console.log(`🧪 Testing: ${testCase.name}`);
      
      try {
        const response = await axios.post('http://localhost:3000/api/sho', testCase.data, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        
        console.log(`⚠️  ${testCase.name} unexpectedly succeeded`);
        
      } catch (error) {
        console.log(`✅ ${testCase.name} correctly failed`);
        if (error.response?.data?.errors) {
          console.log('📋 Expected Validation Errors:');
          error.response.data.errors.forEach(err => {
            console.log(`   - Field: ${err.path || err.param} | Message: ${err.msg}`);
          });
        }
      }
      console.log('─'.repeat(30));
    }

  } catch (error) {
    console.error('❌ Test Error:', error.message);
    if (error.response?.data) {
      console.error('📋 Error Details:', error.response.data);
    }
  }
}

debugSHOValidation();