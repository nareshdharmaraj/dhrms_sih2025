const StateHealthOfficer = require('./src/models/StateHealthOfficer');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const Zone = require('./src/models/Zone');
const Hospital = require('./src/models/Hospital');
const bcrypt = require('bcryptjs');

const testCompleteWorkflow = async () => {
  try {
    console.log('🔄 Testing complete RHO-Hospital workflow...\n');

    // 1. Get Kerala SHO
    console.log('1. 👤 Finding Kerala SHO...');
    const keralaSHO = await StateHealthOfficer.findOne({ 
      assignedState: 'Kerala' 
    });
    
    if (!keralaSHO) {
      console.log('❌ No Kerala SHO found! Please run setup-foundational-data.js first');
      return;
    }
    console.log(`✅ Found SHO: ${keralaSHO.fullName} (${keralaSHO.officerId})`);

    // 2. Create RHO for Ernakulam if doesn't exist
    console.log('\n2. 🏥 Creating/Finding RHO for Ernakulam...');
    let ernakulamRHO = await RegionalHealthOfficer.findOne({
      assignedState: 'Kerala',
      assignedDistrict: 'Ernakulam'
    });

    if (!ernakulamRHO) {
      // Get an available zone in Ernakulam
      const availableZone = await Zone.findOne({
        'location.district': 'Ernakulam',
        $or: [
          { assignedRHO: { $exists: false } },
          { assignedRHO: null }
        ]
      });

      console.log('Available zones check:', await Zone.find({'location.district': 'Ernakulam'}).select('name location assignedRHO'));

      if (!availableZone) {
        console.log('❌ No available zones found for Ernakulam. Creating RHO without zone assignment...');
        
        ernakulamRHO = new RegionalHealthOfficer({
          officerId: 'RHO_Ernakulam_001',
          fullName: 'Dr. Anil Kumar RHO',
          email: 'rho.ernakulam@dhrms.gov.in',
          phone: '+91-9876543211',
          password: await bcrypt.hash('rho123', 10),
          assignedState: 'Kerala',
          assignedDistrict: 'Ernakulam',
          assignedAreas: [{
            name: 'Ernakulam District',
            type: 'District'
          }],
          supervisedBy: keralaSHO._id,
          isActive: true
        });

        await ernakulamRHO.save();
        console.log(`✅ Created RHO: ${ernakulamRHO.fullName} (${ernakulamRHO.officerId})`);
        console.log(`   Assigned to entire district: Ernakulam`);
      } else {
        ernakulamRHO = new RegionalHealthOfficer({
          officerId: 'RHO_Ernakulam_001',
          fullName: 'Dr. Anil Kumar RHO',
          email: 'rho.ernakulam@dhrms.gov.in',
          phone: '+91-9876543211',
          password: await bcrypt.hash('rho123', 10),
          assignedState: 'Kerala',
          assignedDistrict: 'Ernakulam',
          assignedAreas: [{
            name: availableZone.areas[0].name,
            type: 'Zone',
            zoneId: availableZone._id
          }],
          supervisedBy: keralaSHO._id,
          isActive: true
        });

        await ernakulamRHO.save();
        
        // Update zone with RHO assignment
        availableZone.assignedRHO = ernakulamRHO._id;
        await availableZone.save();
        
        console.log(`✅ Created RHO: ${ernakulamRHO.fullName} (${ernakulamRHO.officerId})`);
        console.log(`   Assigned to zone: ${availableZone.name}`);
      }
    } else {
      console.log(`✅ Found existing RHO: ${ernakulamRHO.fullName} (${ernakulamRHO.officerId})`);
    }

    // 3. Create test hospital if none exist
    console.log('\n3. 🏥 Creating test hospital...');
    const existingHospital = await Hospital.findOne({
      'region.state': 'Kerala',
      'region.district': 'Ernakulam'
    });

    let testHospital;
    if (!existingHospital) {
      testHospital = new Hospital({
        hospitalId: `HOSP_KL_${Date.now()}`,
        name: 'Kochi General Hospital',
        location: {
          address: 'MG Road, Ernakulam',
          city: 'Kochi',
          state: 'Kerala',
          district: 'Ernakulam',
          pincode: '682016'
        },
        contact: {
          phone: '+91-484-2345678',
          email: 'info@kochigeneral.com',
          emergencyNumber: '+91-484-2345679'
        },
        type: 'Private',
        capacity: {
          totalBeds: 150,
          totalStaff: 80
        },
        services: ['24x7 Emergency', 'Laboratory', 'Radiology'],
        licenses: {
          registrationNumber: `KL-ERN-${Date.now()}`,
          issuingAuthority: 'Kerala State Medical Board',
          issueDate: new Date(),
          expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
        },
        region: {
          state: 'Kerala',
          district: 'Ernakulam'
        },
        establishedDate: new Date('2018-03-15'),
        approval: {
          status: 'Pending',
          submittedAt: new Date()
        }
      });

      await testHospital.save();
      console.log(`✅ Created hospital: ${testHospital.name} (${testHospital.hospitalId})`);
    } else {
      testHospital = existingHospital;
      console.log(`✅ Using existing hospital: ${testHospital.name} (${testHospital.hospitalId})`);
    }

    // 4. Test RHO controller methods
    console.log('\n4. 🧪 Testing RHO hospital controller methods...');
    
    // Import and test controller methods
    const rhoHospitalController = require('./src/controllers/rho_hospital_controller');
    
    // Mock request/response objects
    const mockReq = {
      user: {
        officerId: ernakulamRHO.officerId,
        _id: ernakulamRHO._id
      },
      params: {
        hospitalId: testHospital._id
      }
    };
    
    const mockRes = {
      status: (code) => ({
        json: (data) => {
          console.log(`📡 Response (${code}):`, JSON.stringify(data, null, 2));
          return data;
        }
      }),
      json: (data) => {
        console.log('📡 Response:', JSON.stringify(data, null, 2));
        return data;
      }
    };

    // Test getPendingHospitals
    console.log('\n4a. Testing getPendingHospitals...');
    try {
      await rhoHospitalController.getPendingHospitals(mockReq, mockRes);
    } catch (error) {
      console.log('❌ getPendingHospitals error:', error.message);
    }

    // Test getAllHospitalsInRegion
    console.log('\n4b. Testing getAllHospitalsInRegion...');
    try {
      await rhoHospitalController.getAllHospitalsInRegion(mockReq, mockRes);
    } catch (error) {
      console.log('❌ getAllHospitalsInRegion error:', error.message);
    }

    // Test getHospitalDetails
    console.log('\n4c. Testing getHospitalDetails...');
    try {
      await rhoHospitalController.getHospitalDetails(mockReq, mockRes);
    } catch (error) {
      console.log('❌ getHospitalDetails error:', error.message);
    }

    // 5. Test direct database queries
    console.log('\n5. 🔍 Testing direct database queries...');
    
    const pendingHospitals = await Hospital.find({
      'region.state': ernakulamRHO.assignedState,
      'region.district': ernakulamRHO.assignedDistrict,
      'approval.status': 'Pending',
      isActive: true
    });

    console.log(`📊 Direct query results:`);
    console.log(`   - RHO district: ${ernakulamRHO.assignedState}/${ernakulamRHO.assignedDistrict}`);
    console.log(`   - Pending hospitals found: ${pendingHospitals.length}`);
    
    if (pendingHospitals.length > 0) {
      console.log(`\n🎉 SUCCESS! RHO can see pending hospitals:`);
      pendingHospitals.forEach(hospital => {
        console.log(`   ✅ ${hospital.name} (${hospital.hospitalId})`);
        console.log(`      Location: ${hospital.region.state}/${hospital.region.district}`);
        console.log(`      Status: ${hospital.approval.status}`);
        console.log(`      Submitted: ${hospital.approval.submittedAt}`);
      });
    } else {
      console.log(`⚠️ No pending hospitals found for RHO verification`);
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
  return testCompleteWorkflow();
}).then(() => {
  console.log('\n✅ Complete workflow test finished');
  process.exit(0);
}).catch(error => {
  console.error('❌ Error:', error);
  process.exit(1);
});