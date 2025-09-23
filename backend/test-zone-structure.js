// Test script to verify zone area structure and RHO assignment for dense districts
const mongoose = require('mongoose');
require('dotenv').config();

const Zone = require('./src/models/Zone');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function testZoneAreaStructure() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    console.log('\n🔍 TESTING ZONE AREA STRUCTURE');
    console.log('==========================================');

    // Find zones with areas (especially in dense districts)
    const zonesWithAreas = await Zone.find({
      'areas.0': { $exists: true },
      isActive: true
    }).limit(5);

    if (zonesWithAreas.length === 0) {
      console.log('❌ No zones found with areas');
      return;
    }

    for (const zone of zonesWithAreas) {
      console.log(`\n🗺️  Zone: ${zone.zoneName}`);
      console.log(`📍 Location: ${zone.district}, ${zone.state}`);
      console.log(`🆔 Zone ID: ${zone.zoneId}`);
      console.log(`👥 RHO Assignment: ${zone.assignedRHO?.rhoName || 'Not Assigned'}`);
      console.log(`📋 Areas (${zone.areas.length}):`);
      
      zone.areas.forEach((area, index) => {
        console.log(`   ${index + 1}. ${area.areaName}`);
        console.log(`      • Code: ${area.areaCode || 'Not Set'}`);
        console.log(`      • Population: ${area.population || 0}`);
        console.log(`      • Area Km²: ${area.areaKm2 || 0}`);
        console.log(`      • Dense: ${area.isDenselyPopulated ? 'Yes' : 'No'}`);
        console.log(`      • ID: ${area._id}`);
      });
      
      // If this zone has an assigned RHO, check the RHO's assignedAreas
      if (zone.assignedRHO?.rhoId) {
        console.log(`\n   🔍 Checking RHO assignment...`);
        const rho = await RegionalHealthOfficer.findOne({ 
          officerId: zone.assignedRHO.rhoId 
        });
        
        if (rho) {
          console.log(`   👨‍⚕️ RHO: ${rho.fullName} (${rho.officerId})`);
          console.log(`   📋 RHO Assigned Areas (${rho.assignedAreas.length}):`);
          
          if (rho.assignedAreas.length === 0) {
            console.log(`   ❌ ERROR: RHO has no assigned areas!`);
          } else {
            rho.assignedAreas.forEach((area, idx) => {
              console.log(`      ${idx + 1}. ${area.name} (${area.type})`);
              console.log(`         • Code: ${area.code}`);
              console.log(`         • Population: ${area.population}`);
              console.log(`         • Area Km²: ${area.areaKm2}`);
              console.log(`         • Dense: ${area.isDenselyPopulated ? 'Yes' : 'No'}`);
              console.log(`         • Zone Area ID: ${area.zoneAreaId || 'Not Set'}`);
              
              // Check if this is a problematic "Full District" assignment
              if (area.type === 'full-district' && area.name === 'Full District') {
                console.log(`         ⚠️  WARNING: This appears to be a default assignment, not zone-based!`);
              }
            });
          }
        } else {
          console.log(`   ❌ RHO not found: ${zone.assignedRHO.rhoId}`);
        }
      }
      
      console.log('------------------------------------------');
    }

    // Check for problematic RHOs with "Full District" assignments in dense districts
    console.log('\n🚨 CHECKING FOR PROBLEMATIC ASSIGNMENTS');
    console.log('==========================================');
    
    const problematicRHOs = await RegionalHealthOfficer.find({
      'assignedAreas.name': 'Full District',
      'assignedAreas.type': 'full-district'
    });

    for (const rho of problematicRHOs) {
      console.log(`\n⚠️  RHO: ${rho.fullName} (${rho.officerId})`);
      console.log(`📍 District: ${rho.assignedDistrict}, ${rho.assignedState}`);
      
      // Check if this district is dense
      const AreaAssignmentService = require('./src/services/areaAssignmentService');
      try {
        const validation = await AreaAssignmentService.validateAreaAssignment(
          rho.assignedState, 
          rho.assignedDistrict, 
          []
        );
        
        if (validation.strategy.isDense) {
          console.log(`❌ CRITICAL: Dense district RHO has "Full District" assignment!`);
          console.log(`   This should be zone-based area assignments instead.`);
        } else {
          console.log(`✅ OK: Sparse district can have full district assignment`);
        }
      } catch (error) {
        console.log(`⚠️  Could not validate district type: ${error.message}`);
      }
    }

    console.log('\n📊 RECOMMENDATIONS:');
    console.log('==========================================');
    console.log('1. Dense district RHOs should NEVER have "Full District" assignments');
    console.log('2. Dense district RHOs should always have zone-based area assignments');
    console.log('3. Each zone area should have proper areaCode, population, areaKm2, and isDenselyPopulated fields');
    console.log('4. RHO assignedAreas should reference original zone area IDs via zoneAreaId field');

  } catch (error) {
    console.error('❌ Error testing zone area structure:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n✅ Disconnected from MongoDB');
  }
}

// Run the test
testZoneAreaStructure();