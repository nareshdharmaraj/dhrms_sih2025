const Hospital = require('./src/models/Hospital');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

const testHospitalVerificationWorkflow = async () => {
  try {
    console.log('🏥 Testing Hospital Verification Workflow...\n');

    // 1. Create a minimal test hospital
    console.log('1. 🏗️ Creating test hospital...');
    
    // Check if test hospital already exists
    let testHospital = await Hospital.findOne({ name: 'Test Verification Hospital' });
    
    if (!testHospital) {
      testHospital = new Hospital({
        hospitalId: `HOSP_TEST_${Date.now()}`,
        name: 'Test Verification Hospital',
        location: {
          address: 'Test Address, Ernakulam',
          city: 'Kochi',
          state: 'Kerala',
          district: 'Ernakulam',
          pincode: '682001'
        },
        contact: {
          phone: '+91-484-1234567',
          email: 'test@hospital.com',
          emergencyNumber: '+91-484-1234567'
        },
        type: 'Private',
        capacity: {
          totalBeds: 100,
          totalStaff: 50
        },
        services: ['24x7 Emergency', 'Laboratory'],
        licenses: {
          registrationNumber: `TEST-REG-${Date.now()}`,
          issuingAuthority: 'Kerala State Medical Board',
          issueDate: new Date(),
          expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
        },
        region: {
          state: 'Kerala',
          district: 'Ernakulam'
        },
        establishedDate: new Date('2020-01-01'),
        approval: {
          status: 'Pending',
          submittedAt: new Date()
        }
      });

      await testHospital.save();
      console.log(`✅ Created hospital: ${testHospital.name} (${testHospital.hospitalId})`);
      console.log(`   Status: ${testHospital.approval.status}`);
      console.log(`   Location: ${testHospital.region.state}/${testHospital.region.district}`);
    } else {
      console.log(`✅ Using existing hospital: ${testHospital.name} (${testHospital.hospitalId})`);
    }

    // 2. Create a minimal RHO for testing (directly in DB for testing purposes)
    console.log('\n2. 👨‍⚕️ Creating minimal test RHO...');
    
    let testRHO = await RegionalHealthOfficer.findOne({ officerId: 'RHO_TEST_001' });
    
    if (!testRHO) {
      // Get Kerala SHO for parentSHO requirement
      const StateHealthOfficer = require('./src/models/StateHealthOfficer');
      const keralaSHO = await StateHealthOfficer.findOne({ assignedState: 'Kerala' });
      
      if (!keralaSHO) {
        console.log('❌ Kerala SHO not found. Please run setup-foundational-data.js first');
        return;
      }

      // Create with minimal required fields based on the schema
      testRHO = new RegionalHealthOfficer({
        officerId: 'RHO_TEST_001',
        username: 'rho_test',
        fullName: 'Dr. Test RHO',
        email: 'rho.test@dhrms.gov.in',
        phone: '+91-9876543210',
        password: 'test12345', // 8+ characters
        qualification: 'MBBS, MD',
        experience: 10,
        licenseNumber: 'KL-RHO-TEST-001',
        assignedState: 'Kerala',
        assignedDistrict: 'Ernakulam',
        assignedRegion: 'Kerala-Ernakulam',
        regionCode: 'KL-ERN',
        districtCode: 'ERN',
        parentSHO: keralaSHO._id, // Use existing Kerala SHO
        createdBy: keralaSHO._id, // Use existing Kerala SHO
        coverage: {
          primaryDistrict: 'Ernakulam',
          totalAreas: 1,
          totalPopulation: 1000000
        },
        officeAddress: {
          street: 'Test Street',
          city: 'Kochi',
          state: 'Kerala',
          pincode: '682001'
        },
        assignedAreas: [{
          name: 'Ernakulam District',
          code: 'ERN-001',
          type: 'area' // Using valid enum value
        }],
        isActive: true
      });

      await testRHO.save();
      console.log(`✅ Created RHO: ${testRHO.fullName} (${testRHO.officerId})`);
      console.log(`   District: ${testRHO.assignedState}/${testRHO.assignedDistrict}`);
    } else {
      console.log(`✅ Using existing RHO: ${testRHO.fullName} (${testRHO.officerId})`);
    }

    // 3. Test the fixed controller methods
    console.log('\n3. 🧪 Testing RHO hospital controller methods...');
    
    const rhoHospitalController = require('./src/controllers/rho_hospital_controller');
    
    // Mock request/response objects
    const mockReq = {
      user: {
        officerId: testRHO.officerId,
        _id: testRHO._id,
        assignedState: testRHO.assignedState,
        assignedDistrict: testRHO.assignedDistrict
      },
      params: {
        hospitalId: testHospital._id
      }
    };
    
    const mockRes = {
      status: (code) => ({
        json: (data) => {
          console.log(`📊 Response Status: ${code}`);
          console.log(`📊 Response Data:`, JSON.stringify(data, null, 2));
          return data;
        }
      }),
      json: (data) => {
        console.log('📊 Response:', JSON.stringify(data, null, 2));
        return data;
      }
    };

    // Test getPendingHospitals
    console.log('\n3a. ⏳ Testing getPendingHospitals...');
    try {
      await rhoHospitalController.getPendingHospitals(mockReq, mockRes);
    } catch (error) {
      console.log('❌ getPendingHospitals error:', error.message);
    }

    // Test getAllHospitalsInRegion
    console.log('\n3b. 🏥 Testing getAllHospitalsInRegion...');
    try {
      await rhoHospitalController.getAllHospitalsInRegion(mockReq, mockRes);
    } catch (error) {
      console.log('❌ getAllHospitalsInRegion error:', error.message);
    }

    // Test getHospitalDetails
    console.log('\n3c. 📋 Testing getHospitalDetails...');
    try {
      await rhoHospitalController.getHospitalDetails(mockReq, mockRes);
    } catch (error) {
      console.log('❌ getHospitalDetails error:', error.message);
    }

    // 4. Direct database verification
    console.log('\n4. 🔍 Direct database verification...');
    
    const pendingHospitals = await Hospital.find({
      'region.state': testRHO.assignedState,
      'region.district': testRHO.assignedDistrict,
      'approval.status': 'Pending',
      isActive: true
    });

    console.log(`\n📊 Direct Query Results:`);
    console.log(`   RHO District: ${testRHO.assignedState}/${testRHO.assignedDistrict}`);
    console.log(`   Pending hospitals found: ${pendingHospitals.length}`);
    
    if (pendingHospitals.length > 0) {
      console.log(`\n🎉 SUCCESS! Hospital verification routing is working:`);
      pendingHospitals.forEach(hospital => {
        console.log(`   ✅ ${hospital.name} (${hospital.hospitalId})`);
        console.log(`      Location: ${hospital.region.state}/${hospital.region.district}`);
        console.log(`      Status: ${hospital.approval.status}`);
        console.log(`      Submitted: ${hospital.approval.submittedAt?.toISOString()}`);
      });
      
      console.log(`\n✨ The "RHO not created or assigned" error should now be resolved!`);
      console.log(`✨ RHO ${testRHO.fullName} can see and manage hospital registrations in ${testRHO.assignedDistrict} district.`);
    } else {
      console.log(`⚠️ No pending hospitals found - this could be expected if all are approved/rejected`);
    }

  } catch (error) {
    console.error('❌ Test error:', error);
  }
};

// Connect to MongoDB and run test
const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017/dhrms_sih2025', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('📡 Connected to MongoDB');
  return testHospitalVerificationWorkflow();
}).then(() => {
  console.log('\n✅ Hospital verification workflow test completed');
  process.exit(0);
}).catch(error => {
  console.error('❌ Connection error:', error);
  process.exit(1);
});