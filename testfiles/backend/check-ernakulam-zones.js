// Script to check and create zones for Ernakulam district
const mongoose = require('mongoose');
require('dotenv').config();

const Zone = require('./src/models/Zone');

async function checkErnakulamZones() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    console.log('\n🔍 CHECKING ERNAKULAM ZONES');
    console.log('==========================================');

    // Check existing zones for Ernakulam
    const existingZones = await Zone.find({
      state: 'Kerala',
      district: 'Ernakulam',
      isActive: true
    });

    console.log(`📊 Found ${existingZones.length} zones for Ernakulam district`);

    if (existingZones.length === 0) {
      console.log('❌ No zones found for Ernakulam! This is why Create RHO is not working.');
      console.log('\n🛠️  CREATING SAMPLE ZONES FOR ERNAKULAM');
      
      // Create sample zones for Ernakulam (dense district)
      const ernakulamZones = [
        {
          zoneId: 'ZONE_ERNAKULAM_001',
          zoneName: 'Kochi Central Zone',
          state: 'Kerala',
          district: 'Ernakulam',
          areas: [
            {
              areaName: 'Ernakulam',
              areaCode: 'ERN_001',
              population: 150000,
              areaKm2: 45.2,
              isDenselyPopulated: true
            },
            {
              areaName: 'Fort Kochi',
              areaCode: 'FTK_001', 
              population: 85000,
              areaKm2: 25.8,
              isDenselyPopulated: true
            }
          ],
          zoneType: 'urban',
          priority: 1,
          isActive: true,
          createdBy: 'system',
          metadata: {
            description: 'Central Kochi urban zone covering main commercial areas',
            specialRequirements: ['high_density_coverage', 'commercial_focus']
          }
        },
        {
          zoneId: 'ZONE_ERNAKULAM_002',
          zoneName: 'Kakkanad IT Zone',
          state: 'Kerala', 
          district: 'Ernakulam',
          areas: [
            {
              areaName: 'Kakkanad',
              areaCode: 'KKD_001',
              population: 120000,
              areaKm2: 35.4,
              isDenselyPopulated: true
            },
            {
              areaName: 'Infopark',
              areaCode: 'INF_001',
              population: 45000,
              areaKm2: 12.6,
              isDenselyPopulated: true
            }
          ],
          zoneType: 'mixed',
          priority: 2,
          isActive: true,
          createdBy: 'system',
          metadata: {
            description: 'IT corridor zone covering tech parks and residential areas',
            specialRequirements: ['tech_worker_focus', 'modern_facilities']
          }
        },
        {
          zoneId: 'ZONE_ERNAKULAM_003',
          zoneName: 'Aluva Suburban Zone',
          state: 'Kerala',
          district: 'Ernakulam',
          areas: [
            {
              areaName: 'Aluva',
              areaCode: 'ALV_001',
              population: 95000,
              areaKm2: 42.1,
              isDenselyPopulated: false
            },
            {
              areaName: 'Perumbavoor',
              areaCode: 'PRB_001',
              population: 75000,
              areaKm2: 38.7,
              isDenselyPopulated: false
            }
          ],
          zoneType: 'suburban',
          priority: 3,
          isActive: true,
          createdBy: 'system',
          metadata: {
            description: 'Suburban zone covering residential and semi-urban areas',
            specialRequirements: ['family_healthcare', 'suburban_access']
          }
        }
      ];

      // Insert the zones
      for (const zoneData of ernakulamZones) {
        try {
          const zone = new Zone(zoneData);
          await zone.save();
          console.log(`✅ Created zone: ${zone.zoneName} (${zone.zoneId})`);
          console.log(`   📍 Areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
        } catch (error) {
          console.error(`❌ Error creating zone ${zoneData.zoneName}:`, error.message);
        }
      }

    } else {
      console.log('\n📋 Existing zones:');
      existingZones.forEach((zone, index) => {
        console.log(`${index + 1}. ${zone.zoneName} (${zone.zoneId})`);
        console.log(`   📍 Areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
        console.log(`   👥 RHO: ${zone.assignedRHO?.rhoName || 'Unassigned'}`);
      });
    }

    // Check unassigned zones after creation
    console.log('\n🔍 CHECKING UNASSIGNED ZONES');
    console.log('==========================================');
    
    const unassignedZones = await Zone.findUnassigned('Kerala', 'Ernakulam');
    console.log(`📊 Unassigned zones: ${unassignedZones.length}`);
    
    if (unassignedZones.length > 0) {
      console.log('✅ Create RHO should now work! Available zones:');
      unassignedZones.forEach((zone, index) => {
        console.log(`${index + 1}. ${zone.zoneName} (${zone.zoneId})`);
        console.log(`   📍 Areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
      });
    } else {
      console.log('⚠️  No unassigned zones available. All zones may already have RHOs assigned.');
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n✅ Disconnected from MongoDB');
  }
}

checkErnakulamZones();