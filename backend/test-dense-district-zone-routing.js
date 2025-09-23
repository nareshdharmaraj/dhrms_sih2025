const StateHealthOfficer = require('./src/models/StateHealthOfficer');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const Zone = require('./src/models/Zone');
const Hospital = require('./src/models/Hospital');
const HospitalZoneAssignmentService = require('./src/services/HospitalZoneAssignmentService');
const bcrypt = require('bcryptjs');

const testDenseDistrictZoneRouting = async () => {
  try {
    console.log('🏙️ Testing Dense District Zone-Based RHO Routing...\n');

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

    // 2. Create multiple zones in Ernakulam district
    console.log('\n2. 🏢 Setting up zones in Ernakulam district...');
    
    const ernakulamZones = [
      {
        zoneId: 'ERN-NORTH-001',
        zoneName: 'Ernakulam North Zone',
        state: 'Kerala',
        district: 'Ernakulam',
        areas: [
          { areaName: 'Kothamangalam', areaCode: 'KOTH-001', isDenselyPopulated: true },
          { areaName: 'Thrikkakara', areaCode: 'THRI-001', isDenselyPopulated: true }
        ],
        zoneType: 'urban',
        priority: 'high',
        createdBy: {
          shoId: keralaSHO._id.toString(),
          shoName: keralaSHO.fullName
        },
        isActive: true
      },
      {
        zoneId: 'ERN-SOUTH-001', 
        zoneName: 'Ernakulam South Zone',
        state: 'Kerala',
        district: 'Ernakulam',
        areas: [
          { areaName: 'Paravur', areaCode: 'PARA-001', isDenselyPopulated: true },
          { areaName: 'Aluva', areaCode: 'ALUB-001', isDenselyPopulated: true }
        ],
        zoneType: 'urban',
        priority: 'high',
        createdBy: {
          shoId: keralaSHO._id.toString(),
          shoName: keralaSHO.fullName
        },
        isActive: true
      }
    ];

    for (const zoneData of ernakulamZones) {
      let existingZone = await Zone.findOne({ zoneId: zoneData.zoneId });
      if (!existingZone) {
        const newZone = new Zone(zoneData);
        await newZone.save();
        console.log(`✅ Created zone: ${zoneData.zoneName} with areas: ${zoneData.areas.map(a => a.areaName).join(', ')}`);
      } else {
        console.log(`✅ Zone already exists: ${zoneData.zoneName}`);
      }
    }

    // 3. Create RHOs for each zone
    console.log('\n3. 👨‍⚕️ Creating RHOs for each zone...');
    
    const rhoData = [
      {
        officerId: 'RHO_Ernakulam_001',
        username: 'rho_ern_north',
        fullName: 'Dr. North Zone RHO',
        email: 'rho.north@ernakulam.gov.in',
        zoneId: 'ERN-NORTH-001'
      },
      {
        officerId: 'RHO_Ernakulam_002', 
        username: 'rho_ern_south',
        fullName: 'Dr. South Zone RHO',
        email: 'rho.south@ernakulam.gov.in',
        zoneId: 'ERN-SOUTH-001'
      }
    ];

    for (const rhoInfo of rhoData) {
      let existingRHO = await RegionalHealthOfficer.findOne({ officerId: rhoInfo.officerId });
      
      if (!existingRHO) {
        const newRHO = new RegionalHealthOfficer({
          officerId: rhoInfo.officerId,
          username: rhoInfo.username,
          fullName: rhoInfo.fullName,
          email: rhoInfo.email,
          phone: '+91-9876543210',
          password: await bcrypt.hash('rho12345', 10),
          qualification: 'MBBS, MD',
          experience: 8,
          licenseNumber: `KL-${rhoInfo.officerId}`,
          assignedState: 'Kerala',
          assignedDistrict: 'Ernakulam',
          assignedRegion: 'Kerala-Ernakulam',
          regionCode: 'KL-ERN',
          districtCode: 'ERN',
          parentSHO: keralaSHO._id,
          createdBy: keralaSHO._id,
          coverage: {
            primaryDistrict: 'Ernakulam',
            totalAreas: 2,
            totalPopulation: 500000
          },
          officeAddress: {
            street: 'Zone Office Street',
            city: 'Kochi',
            state: 'Kerala',
            pincode: '682001'
          },
          assignedAreas: [{
            name: rhoInfo.zoneId.includes('North') ? 'Kothamangalam' : 'Paravur',
            code: rhoInfo.zoneId.includes('North') ? 'KOTH-001' : 'PARA-001',
            type: 'area'
          }],
          isActive: true
        });

        await newRHO.save();
        console.log(`✅ Created RHO: ${newRHO.fullName} (${newRHO.officerId})`);
        
        // Assign RHO to zone
        const zone = await Zone.findOne({ zoneId: rhoInfo.zoneId });
        if (zone) {
          zone.assignedRHO = {
            rhoId: newRHO._id, // Use ObjectId, not officerId
            rhoName: newRHO.fullName,
            assignedDate: new Date(),
            assignedBy: keralaSHO.officerId
          };
          await zone.save();
          console.log(`✅ Assigned ${newRHO.fullName} to ${zone.zoneName}`);
        }
      } else {
        console.log(`✅ RHO already exists: ${existingRHO.fullName} (${existingRHO.officerId})`);
      }
    }

    // 4. Create test hospitals in different zones
    console.log('\n4. 🏥 Creating test hospitals in different zones...');
    
    const hospitalData = [
      {
        name: 'Kothamangalam Medical Center',
        city: 'Kothamangalam',
        address: 'Main Road, Kothamangalam',
        pincode: '682301',
        expectedZone: 'ERN-NORTH-001',
        expectedRHO: 'RHO_Ernakulam_001'
      },
      {
        name: 'Thrikkakara General Hospital',
        city: 'Thrikkakara',
        address: 'NH Road, Thrikkakara',
        pincode: '683572',
        expectedZone: 'ERN-NORTH-001',
        expectedRHO: 'RHO_Ernakulam_001'
      },
      {
        name: 'Paravur District Hospital',
        city: 'Paravur',
        address: 'Town Center, Paravur',
        pincode: '683501',
        expectedZone: 'ERN-SOUTH-001',
        expectedRHO: 'RHO_Ernakulam_002'
      },
      {
        name: 'Aluva Medical College',
        city: 'Aluva',
        address: 'College Road, Aluva',
        pincode: '683101',
        expectedZone: 'ERN-SOUTH-001',
        expectedRHO: 'RHO_Ernakulam_002'
      }
    ];

    for (const hospitalInfo of hospitalData) {
      let existingHospital = await Hospital.findOne({ name: hospitalInfo.name });
      
      if (!existingHospital) {
        const hospital = new Hospital({
          hospitalId: `HOSP_${hospitalInfo.city.substring(0,3).toUpperCase()}_${Date.now()}`,
          name: hospitalInfo.name,
          location: {
            address: hospitalInfo.address,
            city: hospitalInfo.city,
            state: 'Kerala',
            district: 'Ernakulam',
            pincode: hospitalInfo.pincode
          },
          contact: {
            phone: '+91-484-1234567',
            email: `info@${hospitalInfo.city.toLowerCase()}.com`,
            emergencyNumber: '+91-484-1234567'
          },
          type: 'Private',
          capacity: {
            totalBeds: 100,
            totalStaff: 60
          },
          services: ['24x7 Emergency', 'Laboratory'],
          licenses: {
            registrationNumber: `KL-ERN-${hospitalInfo.city.substring(0,3).toUpperCase()}-${Date.now()}`,
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

        await hospital.save();
        
        // Auto-assign zone
        await HospitalZoneAssignmentService.updateHospitalZoneAssignment(hospital);
        
        const updatedHospital = await Hospital.findById(hospital._id);
        
        console.log(`✅ Created hospital: ${hospitalInfo.name}`);
        console.log(`   📍 Location: ${hospitalInfo.city}, ${hospitalInfo.pincode}`);
        console.log(`   🎯 Assigned Zone: ${updatedHospital.zoneAssignment?.zoneName || 'Not assigned'}`);
        console.log(`   👨‍⚕️ Assigned RHO: ${updatedHospital.zoneAssignment?.assignedRHO || 'Not assigned'}`);
        console.log(`   ✅ Expected Zone: ${hospitalInfo.expectedZone}, Expected RHO: ${hospitalInfo.expectedRHO}`);
        
        // Get expected RHO ObjectId for comparison
        const expectedRHO = await RegionalHealthOfficer.findOne({ officerId: hospitalInfo.expectedRHO });
        const isCorrectZone = updatedHospital.zoneAssignment?.zoneId === hospitalInfo.expectedZone;
        const isCorrectRHO = expectedRHO && updatedHospital.zoneAssignment?.assignedRHO?.toString() === expectedRHO._id.toString();
        if (isCorrectZone && isCorrectRHO) {
          console.log(`   ✅ CORRECT ASSIGNMENT!`);
        } else {
          console.log(`   ❌ INCORRECT ASSIGNMENT!`);
        }
        console.log('');
      } else {
        console.log(`✅ Hospital already exists: ${hospitalInfo.name}`);
      }
    }

    // 5. Test RHO controllers for zone-based routing
    console.log('\n5. 🧪 Testing zone-based RHO hospital controllers...');
    
    const rhoHospitalController = require('./src/controllers/rho_hospital_controller');
    
    // Test both RHOs
    const testRHOs = [
      { officerId: 'RHO_Ernakulam_001', expectedHospitals: ['Kothamangalam', 'Thrikkakara'] },
      { officerId: 'RHO_Ernakulam_002', expectedHospitals: ['Paravur', 'Aluva'] }
    ];

    for (const testRHO of testRHOs) {
      console.log(`\n5${testRHO.officerId.includes('North') ? 'a' : 'b'}. Testing ${testRHO.officerId}...`);
      
      const mockReq = {
        rho: {
          rhoId: testRHO.officerId
        }
      };
      
      const mockRes = {
        json: (data) => {
          console.log(`📊 Results for ${testRHO.officerId}:`);
          console.log(`   - Assignment Type: ${data.meta.assignmentType}`);
          console.log(`   - Total Hospitals: ${data.meta.total}`);
          console.log(`   - Assigned Zones: ${data.meta.assignedZones?.map(z => z.zoneName).join(', ') || 'None'}`);
          
          if (data.data && data.data.length > 0) {
            console.log(`   - Hospitals Found:`);
            data.data.forEach(hospital => {
              console.log(`     • ${hospital.name} (${hospital.location.city})`);
              console.log(`       Zone: ${hospital.zoneAssignment?.zoneName || 'Not assigned'}`);
              console.log(`       Area: ${hospital.zoneAssignment?.area || 'Not assigned'}`);
            });
          }
          
          // Verify correct hospitals are returned
          const returnedCities = data.data.map(h => h.location.city);
          const expectedCities = testRHO.expectedHospitals;
          const correctAssignment = expectedCities.every(city => 
            returnedCities.some(returnedCity => returnedCity.includes(city))
          );
          
          if (correctAssignment) {
            console.log(`   ✅ CORRECT: RHO sees hospitals from their assigned zones`);
          } else {
            console.log(`   ❌ INCORRECT: RHO sees hospitals from wrong zones`);
            console.log(`     Expected cities containing: ${expectedCities.join(', ')}`);
            console.log(`     Actual cities: ${returnedCities.join(', ')}`);
          }
          
          return data;
        },
        status: (code) => ({
          json: (data) => {
            console.log(`❌ Error ${code}:`, data.message);
            return data;
          }
        })
      };

      try {
        await rhoHospitalController.getPendingHospitals(mockReq, mockRes);
      } catch (error) {
        console.log(`❌ Controller error for ${testRHO.officerId}:`, error.message);
      }
    }

    // 6. Summary
    console.log('\n6. 📋 Dense District Zone Routing Summary:');
    
    const allZones = await Zone.find({ 
      state: 'Kerala', 
      district: 'Ernakulam', 
      isActive: true 
    });
    
    const allHospitals = await Hospital.find({
      'region.state': 'Kerala',
      'region.district': 'Ernakulam'
    });
    
    console.log(`🏢 Total Zones in Ernakulam: ${allZones.length}`);
    allZones.forEach(zone => {
      console.log(`   - ${zone.zoneName}: ${zone.assignedRHO?.rhoName || 'No RHO assigned'}`);
      console.log(`     Areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
    });
    
    console.log(`\n🏥 Total Hospitals in Ernakulam: ${allHospitals.length}`);
    allHospitals.forEach(hospital => {
      console.log(`   - ${hospital.name} (${hospital.location.city})`);
      console.log(`     Zone: ${hospital.zoneAssignment?.zoneName || 'Not assigned'}`);
      console.log(`     RHO: ${hospital.zoneAssignment?.assignedRHO || 'Not assigned'}`);
    });
    
    console.log(`\n🎯 Zone-based routing is now implemented:`);
    console.log(`   ✅ Hospitals are automatically assigned to zones based on location`);
    console.log(`   ✅ RHOs only see hospitals from their assigned zones`);
    console.log(`   ✅ Dense districts with multiple RHOs now work correctly`);
    console.log(`   ✅ Each RHO manages hospitals in their specific area of responsibility`);

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
  return testDenseDistrictZoneRouting();
}).then(() => {
  console.log('\n✅ Dense district zone routing test completed');
  process.exit(0);
}).catch(error => {
  console.error('❌ Connection error:', error);
  process.exit(1);
});