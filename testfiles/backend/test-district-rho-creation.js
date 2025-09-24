const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import models
const StateHealthOfficer = require('./src/models/StateHealthOfficer');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const { 
  DISTRICT_MAPPING, 
  MOCK_RHO_DATA, 
  getDistrictsByState,
  getRegionByDistrict,
  generateDistrictCode,
  generateRegionCode 
} = require('./src/services/districtMockDataService');

// Test district-wise RHO creation
async function testDistrictWiseRHOCreation() {
  try {
    console.log('🚀 Testing District-wise RHO Creation...\n');

    // Connect to database
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth';
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    // Test 1: District Data Retrieval
    console.log('\n📋 Test 1: District Data Retrieval');
    console.log('Available states:', Object.keys(DISTRICT_MAPPING));
    
    const testState = 'Tamil Nadu';
    const districts = getDistrictsByState(testState);
    console.log(`Districts in ${testState}:`, districts.slice(0, 5), '... (showing first 5)');
    
    const testDistrict = 'Chennai';
    const region = getRegionByDistrict(testState, testDistrict);
    console.log(`Region for ${testDistrict}:`, region);
    
    const districtCode = generateDistrictCode(testDistrict);
    const regionCode = generateRegionCode(testState, region);
    console.log(`Generated codes - District: ${districtCode}, Region: ${regionCode}`);

    // Test 2: Mock Data Validation
    console.log('\n📋 Test 2: Mock Data Validation');
    const mockRHOs = MOCK_RHO_DATA[testState] || [];
    console.log(`Mock RHOs available for ${testState}:`, mockRHOs.length);
    
    if (mockRHOs.length > 0) {
      console.log('Sample mock RHO:', {
        name: mockRHOs[0].fullName,
        district: mockRHOs[0].assignedDistrict,
        region: mockRHOs[0].assignedRegion,
        population: mockRHOs[0].coverage.population
      });
    }

    // Test 3: Create Test SHO
    console.log('\n📋 Test 3: Creating Test SHO');
    
    // Clean up existing test data
    await StateHealthOfficer.deleteMany({ email: 'test.sho@tn.gov.in' });
    await RegionalHealthOfficer.deleteMany({ email: /test\.rho.*@.*\.gov\.in/ });
    
    const testSHO = new StateHealthOfficer({
      officerId: 'SHO_TN_999', // Use valid SHO format
      fullName: 'Dr. Test SHO Tamil Nadu',
      email: 'test.sho@tn.gov.in',
      phone: '+91-9000000001',
      password: 'TestPassword@123',
      assignedState: testState,
      permissions: {
        canManageRegionalOfficers: true,
        canViewRegionalOfficers: true,
        canManageHospitals: true,
        canViewHospitals: true,
        canManageUsers: true,
        canViewUsers: true,
        canGenerateReports: true,
        canExportData: true,
        canViewAnalytics: true
      },
      createdBy: new mongoose.Types.ObjectId(), // Dummy WHO admin ID
      isActive: true
    });

    await testSHO.save();
    console.log('✅ Test SHO created:', testSHO.officerId);

    // Test 4: Create District-wise RHO
    console.log('\n📋 Test 4: Creating District-wise RHO');
    
    const testRHOData = {
      fullName: 'Dr. Test RHO Chennai',
      email: 'test.rho@chennai.gov.in',
      phone: '+91-9000000002',
      password: 'TestRHOPassword@123',
      assignedDistrict: 'Chennai',
      assignedRegion: 'Northern Tamil Nadu',
      regionCode: 'TN-N',
      districtCode: 'CHE',
      qualification: 'MBBS, MD (Community Medicine)',
      experience: 10,
      licenseNumber: 'TEST-RHO-2024-001',
      
      coverage: {
        primaryDistrict: 'Chennai',
        subDistricts: ['Ambattur', 'Alandur', 'Sholinganallur'],
        blocks: ['Tambaram', 'Pallavaram'],
        villages: ['Perungudi', 'Thoraipakkam'],
        primaryHealthCenters: ['CHC-001', 'CHC-002'],
        communityHealthCenters: ['PHC-001', 'PHC-002', 'PHC-003'],
        population: 4646732,
        areaKm2: 426,
        ruralPopulation: 200000,
        urbanPopulation: 4446732
      },
      
      staffLimits: {
        maxDirectStaff: 75,
        maxHospitalsOversight: 25,
        maxRegionsManaged: 3
      },
      
      officeAddress: {
        buildingName: 'District Health Office',
        street: 'Government Complex, Anna Salai',
        city: 'Chennai',
        state: testState,
        zipCode: '600001',
        country: 'India'
      },
      
      emergencyContact: {
        name: 'Dr. Emergency Contact',
        relationship: 'Colleague',
        phone: '+91-9000000003',
        email: 'emergency@chennai.gov.in'
      }
    };

    // Generate unique RHO ID with full district name
    const rhoCount = await RegionalHealthOfficer.countDocuments({ assignedState: testState });
    const rhoOfficerId = `RHO_${testRHOData.assignedDistrict}_${String(rhoCount + 1).padStart(3, '0')}`;

    const testRHO = new RegionalHealthOfficer({
      officerId: rhoOfficerId,
      username: rhoOfficerId.toLowerCase().replace(/_/g, ''),
      fullName: testRHOData.fullName,
      email: testRHOData.email,
      phone: testRHOData.phone,
      password: testRHOData.password,
      assignedState: testState,
      assignedDistrict: testRHOData.assignedDistrict,
      assignedRegion: testRHOData.assignedRegion,
      regionCode: testRHOData.regionCode,
      districtCode: testRHOData.districtCode,
      parentSHO: testSHO._id,
      qualification: testRHOData.qualification,
      experience: testRHOData.experience,
      licenseNumber: testRHOData.licenseNumber,
      coverage: testRHOData.coverage,
      staffLimits: testRHOData.staffLimits,
      officeAddress: testRHOData.officeAddress,
      officePhone: testRHOData.phone,
      emergencyContact: testRHOData.emergencyContact,
      createdBy: testSHO._id,
      
      permissions: {
        canViewHospitals: true,
        canManageHospitalStaff: true,
        canViewHospitalReports: true,
        canViewPatientData: true,
        canAccessMedicalRecords: false,
        canGenerateReports: true,
        canViewRegionalStats: true,
        canInitiateEmergencyResponse: true,
        canAccessEmergencyContacts: true,
        canManageProfile: true,
        canChangePassword: true
      }
    });

    await testRHO.save();
    console.log('✅ Test RHO created:', testRHO.officerId);

    // Test 5: Verify RHO Creation and Relationships
    console.log('\n📋 Test 5: Verifying RHO Creation and Relationships');
    
    const createdRHO = await RegionalHealthOfficer.findById(testRHO._id)
      .populate('parentSHO', 'fullName officerId assignedState');
    
    console.log('RHO Details:');
    console.log('- Officer ID:', createdRHO.officerId);
    console.log('- Name:', createdRHO.fullName);
    console.log('- Assigned District:', createdRHO.assignedDistrict);
    console.log('- Assigned Region:', createdRHO.assignedRegion);
    console.log('- District Code:', createdRHO.districtCode);
    console.log('- Region Code:', createdRHO.regionCode);
    console.log('- Parent SHO:', createdRHO.parentSHO.fullName);
    console.log('- Coverage Population:', createdRHO.coverage.population);
    console.log('- Sub-districts:', createdRHO.coverage.subDistricts);
    console.log('- Active:', createdRHO.isActive);

    // Test 6: Test District Availability Check
    console.log('\n📋 Test 6: Testing District Availability');
    
    const allDistricts = getDistrictsByState(testState);
    const assignedDistricts = await RegionalHealthOfficer.find({
      assignedState: testState,
      parentSHO: testSHO._id,
      isActive: true
    }).distinct('assignedDistrict');
    
    const availableDistricts = allDistricts.filter(district => !assignedDistricts.includes(district));
    
    console.log(`Total districts in ${testState}:`, allDistricts.length);
    console.log('Assigned districts:', assignedDistricts);
    console.log('Available districts:', availableDistricts.length);

    // Test 7: Test Mock Data Integration
    console.log('\n📋 Test 7: Testing Mock Data Integration');
    
    if (mockRHOs.length > 1) {
      const mockRHO = mockRHOs[1]; // Use second mock RHO
      console.log('Creating RHO from mock data:', mockRHO.fullName);
      
      // Generate ID with full district name (consistent with controller)
      const rhoCountForDistrict = await RegionalHealthOfficer.countDocuments({ 
        assignedState: testState,
        assignedDistrict: mockRHO.assignedDistrict 
      });
      const mockRHOId = `RHO_${mockRHO.assignedDistrict}_${String(rhoCountForDistrict + 1).padStart(3, '0')}`;

      const mockBasedRHO = new RegionalHealthOfficer({
        officerId: mockRHOId,
        username: mockRHOId.toLowerCase().replace(/_/g, ''),
        fullName: mockRHO.fullName,
        email: mockRHO.email.replace('@tn.gov.in', `@test${Date.now()}.tn.gov.in`), // Unique email with timestamp
        phone: mockRHO.phone,
        password: 'TestMockPassword@123',
        assignedState: testState,
        assignedDistrict: mockRHO.assignedDistrict,
        assignedRegion: mockRHO.assignedRegion,
        regionCode: mockRHO.regionCode,
        districtCode: mockRHO.districtCode,
        parentSHO: testSHO._id,
        qualification: mockRHO.qualification,
        experience: mockRHO.experience,
        licenseNumber: mockRHO.licenseNumber.replace('TN-MED', `TEST-MED-${Date.now()}`),
        
        coverage: {
          primaryDistrict: mockRHO.coverage.primaryDistrict,
          subDistricts: mockRHO.coverage.subDistricts || [],
          blocks: mockRHO.coverage.blocks || [],
          villages: [],
          primaryHealthCenters: [],
          communityHealthCenters: [],
          population: mockRHO.coverage.population,
          areaKm2: mockRHO.coverage.areaKm2,
          ruralPopulation: mockRHO.coverage.ruralPopulation,
          urbanPopulation: mockRHO.coverage.urbanPopulation
        },
        
        staffLimits: { maxDirectStaff: 50, maxHospitalsOversight: 20, maxRegionsManaged: 5 },
        officeAddress: {
          buildingName: 'District Health Office',
          street: 'Government Complex',
          city: mockRHO.assignedDistrict,
          state: testState,
          zipCode: '000000',
          country: 'India'
        },
        
        createdBy: testSHO._id,
        permissions: {
          canViewHospitals: true,
          canManageHospitalStaff: true,
          canViewHospitalReports: true,
          canViewPatientData: true,
          canAccessMedicalRecords: false,
          canGenerateReports: true,
          canViewRegionalStats: true,
          canInitiateEmergencyResponse: true,
          canAccessEmergencyContacts: true,
          canManageProfile: true,
          canChangePassword: true
        }
      });
      
      await mockBasedRHO.save();
      console.log('✅ Mock-based RHO created:', mockBasedRHO.officerId);
    }

    // Test 8: Final Statistics
    console.log('\n📋 Test 8: Final Statistics');
    
    const totalRHOs = await RegionalHealthOfficer.countDocuments({
      assignedState: testState,
      parentSHO: testSHO._id
    });
    
    const activeRHOs = await RegionalHealthOfficer.countDocuments({
      assignedState: testState,
      parentSHO: testSHO._id,
      isActive: true
    });
    
    const rhosByDistrict = await RegionalHealthOfficer.aggregate([
      { 
        $match: { 
          assignedState: testState, 
          parentSHO: testSHO._id, 
          isActive: true 
        } 
      },
      { 
        $group: { 
          _id: '$assignedDistrict', 
          count: { $sum: 1 },
          officers: { $push: '$fullName' }
        } 
      },
      { $sort: { _id: 1 } }
    ]);
    
    console.log(`Total RHOs created: ${totalRHOs}`);
    console.log(`Active RHOs: ${activeRHOs}`);
    console.log('RHOs by district:', rhosByDistrict);

    console.log('\n🎉 District-wise RHO Creation Test Completed Successfully!');
    
    // Display API endpoints that can be tested
    console.log('\n📋 Available API Endpoints for Testing:');
    console.log('1. GET /api/rho/districts - Get available districts');
    console.log('2. GET /api/rho/mock-data - Get mock RHO data');
    console.log('3. POST /api/rho/create-from-mock - Create RHO from mock data');
    console.log('4. POST /api/rho - Create custom RHO');
    console.log('5. GET /api/rho - Get all RHOs for SHO');
    console.log('6. GET /api/rho/statistics - Get RHO statistics');

    return {
      success: true,
      testSHO: testSHO,
      testRHOs: [testRHO],
      mockData: mockRHOs,
      districts: allDistricts,
      statistics: {
        totalRHOs,
        activeRHOs,
        rhosByDistrict
      }
    };

  } catch (error) {
    console.error('❌ District-wise RHO Creation Test Error:', error);
    return { success: false, error: error.message };
  } finally {
    await mongoose.connection.close();
    console.log('📝 Database connection closed');
  }
}

// Run the test
if (require.main === module) {
  testDistrictWiseRHOCreation()
    .then(result => {
      if (result.success) {
        console.log('\n✅ All tests passed!');
        process.exit(0);
      } else {
        console.log('\n❌ Tests failed:', result.error);
        process.exit(1);
      }
    })
    .catch(error => {
      console.error('❌ Test execution error:', error);
      process.exit(1);
    });
}

module.exports = testDistrictWiseRHOCreation;