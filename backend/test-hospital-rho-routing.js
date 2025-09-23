const Hospital = require('./src/models/Hospital');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

const testHospitalRHORouting = async () => {
  try {
    console.log('🔍 Testing hospital-RHO routing...\n');

    // 1. Check existing RHOs
    console.log('1. 📋 Checking existing RHOs:');
    const rhos = await RegionalHealthOfficer.find({});
    console.log(`Found ${rhos.length} RHOs:`);
    rhos.forEach(rho => {
      console.log(`  - ${rho.fullName} (${rho.officerId})`);
      console.log(`    District: ${rho.assignedState}/${rho.assignedDistrict}`);
      console.log(`    Areas: ${rho.assignedAreas.map(a => a.name).join(', ')}`);
      console.log('');
    });

    // 2. Check existing hospitals
    console.log('2. 🏥 Checking existing hospitals:');
    const hospitals = await Hospital.find({});
    console.log(`Found ${hospitals.length} hospitals:`);
    hospitals.forEach(hospital => {
      console.log(`  - ${hospital.name} (${hospital.hospitalId})`);
      console.log(`    Location: ${hospital.region.state}/${hospital.region.district}`);
      console.log(`    Address: ${hospital.location.address}, ${hospital.location.city}`);
      console.log(`    Status: ${hospital.approval.status}`);
      console.log(`    Managed by: ${hospital.managedBy || 'None'}`);
      console.log('');
    });

    // 3. Test RHO query for Ernakulam hospitals
    if (rhos.length > 0) {
      const ernakulamRHO = rhos.find(rho => 
        rho.assignedState === 'Kerala' && rho.assignedDistrict === 'Ernakulam'
      );

      if (ernakulamRHO) {
        console.log('3. 🎯 Testing RHO query for Ernakulam hospitals:');
        console.log(`Using RHO: ${ernakulamRHO.fullName} (${ernakulamRHO.officerId})`);
        
        const pendingHospitals = await Hospital.find({
          'region.state': ernakulamRHO.assignedState,
          'region.district': ernakulamRHO.assignedDistrict,
          'approval.status': 'Pending',
          isActive: true
        });

        console.log(`Found ${pendingHospitals.length} pending hospitals in ${ernakulamRHO.assignedState}/${ernakulamRHO.assignedDistrict}:`);
        pendingHospitals.forEach(hospital => {
          console.log(`  - ${hospital.name} (${hospital.hospitalId})`);
          console.log(`    Status: ${hospital.approval.status}`);
          console.log(`    Submitted: ${hospital.approval.submittedAt}`);
        });

        // 4. Test what should appear in RHO dashboard
        console.log('\n4. 📊 RHO Dashboard Preview:');
        if (pendingHospitals.length > 0) {
          console.log(`✅ RHO ${ernakulamRHO.fullName} should see ${pendingHospitals.length} hospital(s) for verification`);
          pendingHospitals.forEach(hospital => {
            console.log(`  ✳️ ${hospital.name} - ${hospital.location.city} (Needs approval)`);
          });
        } else {
          console.log(`ℹ️ No pending hospitals found for RHO ${ernakulamRHO.fullName}`);
          console.log('  - This might be because no hospitals have been registered for Ernakulam');
          console.log('  - Or all hospitals have already been approved/rejected');
        }
      } else {
        console.log('❌ No RHO found for Kerala/Ernakulam');
      }
    }

    // 5. Create a test hospital if none exist for Ernakulam
    const ernakulamHospitals = await Hospital.find({
      'region.state': 'Kerala',
      'region.district': 'Ernakulam'
    });

    if (ernakulamHospitals.length === 0) {
      console.log('\n5. 🏗️ Creating test hospital for Ernakulam:');
      
      const testHospital = new Hospital({
        hospitalId: `HOSP_KL_${Date.now()}`,
        name: 'Test Kochi Medical Center',
        location: {
          address: 'MG Road, Kochi',
          city: 'Kochi',
          state: 'Kerala',
          district: 'Ernakulam',
          pincode: '682016'
        },
        region: {
          state: 'Kerala',
          district: 'Ernakulam'
        },
        contact: {
          phone: '+91-484-1234567',
          email: 'info@testkochimedical.com',
          emergencyNumber: '+91-484-1234567'
        },
        licenses: {
          registrationNumber: 'KL-ERN-TEST-001',
          issuingAuthority: 'Kerala State Medical Board',
          issueDate: new Date(),
          expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000)
        },
        type: 'Private',
        services: ['Health Checkup', 'Laboratory', '24x7 Emergency'],
        capacity: {
          totalBeds: 100,
          totalStaff: 60
        },
        establishedDate: new Date('2020-01-01'),
        approval: {
          status: 'Pending',
          submittedAt: new Date()
        }
      });

      await testHospital.save();
      console.log(`✅ Created test hospital: ${testHospital.name} (${testHospital.hospitalId})`);
      console.log(`   Status: ${testHospital.approval.status}`);
      console.log(`   Location: ${testHospital.region.state}/${testHospital.region.district}`);
      
      // Re-run the RHO query
      const ernakulamRHO = rhos.find(rho => 
        rho.assignedState === 'Kerala' && rho.assignedDistrict === 'Ernakulam'
      );
      
      if (ernakulamRHO) {
        const pendingAfterCreation = await Hospital.find({
          'region.state': ernakulamRHO.assignedState,
          'region.district': ernakulamRHO.assignedDistrict,
          'approval.status': 'Pending',
          isActive: true
        });
        
        console.log(`\n🎯 After creation: RHO should now see ${pendingAfterCreation.length} pending hospital(s)`);
      }
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
  return testHospitalRHORouting();
}).then(() => {
  console.log('\n✅ Test completed');
  process.exit(0);
}).catch(error => {
  console.error('❌ Error:', error);
  process.exit(1);
});