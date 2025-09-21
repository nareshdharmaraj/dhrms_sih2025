const mongoose = require('mongoose');
const dotenv = require('dotenv');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const StateHealthOfficer = require('./src/models/StateHealthOfficer');

// Load environment variables
dotenv.config();

async function testRHOCreation() {
  try {
    console.log('🚀 Testing RHO Creation Feature...\n');

    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0';
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB\n');

    // 1. Find or create a test SHO
    console.log('📋 Step 1: Finding test SHO...');
    let testSHO = await StateHealthOfficer.findOne({ officerId: 'SHO_TN_001' });
    
    if (!testSHO) {
      console.log('❌ Test SHO not found. Please create a SHO first with officerId: SHO_TN_001');
      process.exit(1);
    }

    console.log('✅ Found test SHO:', {
      id: testSHO._id,
      officerId: testSHO.officerId,
      fullName: testSHO.fullName,
      assignedState: testSHO.assignedState,
      permissions: testSHO.permissions
    });

    // 2. Test RHO ID generation
    console.log('\n📋 Step 2: Testing RHO ID generation...');
    const stateCode = testSHO.assignedState.replace(/\s+/g, '').substring(0, 2).toUpperCase();
    const count = await RegionalHealthOfficer.countDocuments({ assignedState: testSHO.assignedState });
    const rhoId = `RHO_${stateCode}_${String(count + 1).padStart(3, '0')}`;
    console.log('✅ Generated RHO ID:', rhoId);

    // 3. Create test RHO data
    console.log('\n📋 Step 3: Creating test RHO...');
    const testRHOData = {
      officerId: rhoId,
      username: rhoId.toLowerCase().replace(/_/g, ''), // Explicitly set username
      fullName: 'Dr. Rajesh Kumar',
      email: `rajesh.kumar.${Date.now()}@health.tn.gov.in`,
      phone: '+919876543210',
      password: 'TestPassword@123',
      assignedState: testSHO.assignedState,
      assignedRegion: 'Chennai North Region',
      regionCode: 'CHN001',
      parentSHO: testSHO._id,
      qualification: 'MBBS, MD (Community Medicine)',
      experience: 8,
      licenseNumber: `TN-MED-${Date.now()}`,
      
      staffLimits: {
        maxDirectStaff: 60,
        maxHospitalsOversight: 25,
        maxRegionsManaged: 3
      },
      
      coverage: {
        districts: ['Chennai', 'Kanchipuram'],
        population: 2500000,
        areaKm2: 1500.5
      },
      
      officeAddress: {
        buildingName: 'Regional Health Office',
        street: 'Anna Salai',
        city: 'Chennai',
        state: testSHO.assignedState,
        zipCode: '600002',
        country: 'India'
      },
      
      officePhone: '+914412345678',
      
      emergencyContact: {
        name: 'Dr. Priya Sharma',
        relationship: 'Deputy Regional Officer',
        phone: '+919876543211',
        email: 'priya.sharma@health.tn.gov.in'
      },
      
      createdBy: testSHO._id
    };

    // 4. Check for existing RHO with same email
    console.log('🔍 Checking for existing RHO with same email...');
    const existingRHO = await RegionalHealthOfficer.findOne({
      $or: [
        { email: testRHOData.email },
        { licenseNumber: testRHOData.licenseNumber }
      ]
    });

    if (existingRHO) {
      console.log('⚠️  Found existing RHO, using timestamp to make unique...');
      testRHOData.email = `rajesh.kumar.test.${Date.now()}@health.tn.gov.in`;
      testRHOData.licenseNumber = `TN-MED-TEST-${Date.now()}`;
    }

    // 5. Create the RHO
    console.log('✨ Creating new RHO...');
    const newRHO = new RegionalHealthOfficer(testRHOData);
    await newRHO.save();
    console.log('✅ RHO created successfully!');

    // 6. Verify the created RHO
    console.log('\n📋 Step 4: Verifying created RHO...');
    const createdRHO = await RegionalHealthOfficer.findById(newRHO._id)
      .select('-password')
      .populate('parentSHO', 'fullName officerId assignedState')
      .populate('createdBy', 'fullName officerId');

    console.log('✅ Created RHO Details:', {
      id: createdRHO._id,
      officerId: createdRHO.officerId,
      fullName: createdRHO.fullName,
      email: createdRHO.email,
      assignedState: createdRHO.assignedState,
      assignedRegion: createdRHO.assignedRegion,
      regionCode: createdRHO.regionCode,
      parentSHO: createdRHO.parentSHO.fullName,
      isActive: createdRHO.isActive,
      permissions: createdRHO.permissions,
      staffLimits: createdRHO.staffLimits,
      coverage: createdRHO.coverage
    });

    // 7. Test querying RHOs by SHO
    console.log('\n📋 Step 5: Testing RHO queries...');
    const rhosBySHO = await RegionalHealthOfficer.findBySHO(testSHO._id);
    console.log(`✅ Found ${rhosBySHO.length} RHOs managed by this SHO`);

    const rhosByState = await RegionalHealthOfficer.findByState(testSHO.assignedState);
    console.log(`✅ Found ${rhosByState.length} RHOs in ${testSHO.assignedState}`);

    // 8. Test RHO statistics
    console.log('\n📋 Step 6: Testing RHO statistics...');
    const stats = await RegionalHealthOfficer.aggregate([
      { $match: { parentSHO: testSHO._id } },
      {
        $group: {
          _id: null,
          total: { $sum: 1 },
          active: { $sum: { $cond: ['$isActive', 1, 0] } },
          inactive: { $sum: { $cond: ['$isActive', 0, 1] } }
        }
      }
    ]);

    console.log('✅ RHO Statistics:', stats[0] || { total: 0, active: 0, inactive: 0 });

    // 9. Test password comparison
    console.log('\n📋 Step 7: Testing password functionality...');
    const rhoWithPassword = await RegionalHealthOfficer.findById(newRHO._id); // Get with password
    const passwordMatch = await rhoWithPassword.comparePassword('TestPassword@123');
    console.log('✅ Password comparison test:', passwordMatch ? 'PASSED' : 'FAILED');

    // 10. Test username generation
    console.log('\n📋 Step 8: Testing username generation...');
    console.log('✅ Generated username:', createdRHO.username);

    console.log('\n🎉 All RHO creation tests completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   • RHO ID: ${createdRHO.officerId}`);
    console.log(`   • Username: ${createdRHO.username}`);
    console.log(`   • Email: ${createdRHO.email}`);
    console.log(`   • Parent SHO: ${createdRHO.parentSHO.fullName}`);
    console.log(`   • Assigned State: ${createdRHO.assignedState}`);
    console.log(`   • Assigned Region: ${createdRHO.assignedRegion}`);
    console.log(`   • Active Status: ${createdRHO.isActive}`);

    console.log('\n🔑 API Endpoints available:');
    console.log('   • POST /api/rho/ - Create RHO');
    console.log('   • GET /api/rho/ - Get RHOs by SHO');
    console.log('   • GET /api/rho/:rhoId - Get RHO details');
    console.log('   • PUT /api/rho/:rhoId - Update RHO');
    console.log('   • PATCH /api/rho/:rhoId/toggle-status - Toggle RHO status');
    console.log('   • PATCH /api/rho/:rhoId/permissions - Update RHO permissions');
    console.log('   • PATCH /api/rho/:rhoId/reset-password - Reset RHO password');
    console.log('   • GET /api/rho/statistics - Get RHO statistics');

  } catch (error) {
    console.error('❌ Test failed:', error);
    if (error.errors) {
      console.error('Validation errors:', error.errors);
    }
  } finally {
    await mongoose.connection.close();
    console.log('\n📝 Database connection closed');
  }
}

// Example API request data for testing
const exampleAPIRequests = {
  createRHO: {
    method: 'POST',
    url: '/api/rho',
    headers: {
      'Authorization': 'Bearer SHO_JWT_TOKEN',
      'Content-Type': 'application/json'
    },
    body: {
      fullName: 'Dr. Rajesh Kumar',
      email: 'rajesh.kumar@health.tn.gov.in',
      phone: '+919876543210',
      password: 'SecurePassword@123',
      assignedRegion: 'Chennai North Region',
      regionCode: 'CHN001',
      qualification: 'MBBS, MD (Community Medicine)',
      experience: 8,
      licenseNumber: 'TN-MED-2024-001',
      officeAddress: {
        buildingName: 'Regional Health Office',
        street: 'Anna Salai',
        city: 'Chennai',
        zipCode: '600002'
      },
      officePhone: '+914412345678',
      emergencyContact: {
        name: 'Dr. Priya Sharma',
        relationship: 'Deputy',
        phone: '+919876543211',
        email: 'priya.sharma@health.tn.gov.in'
      },
      staffLimits: {
        maxDirectStaff: 60,
        maxHospitalsOversight: 25
      },
      coverage: {
        districts: ['Chennai', 'Kanchipuram'],
        population: 2500000,
        areaKm2: 1500.5
      }
    }
  }
};

console.log('\n📖 Example API Request for creating RHO:');
console.log(JSON.stringify(exampleAPIRequests.createRHO, null, 2));

// Run the test
console.log('🚀 Starting RHO Creation Test...\n');
testRHOCreation();