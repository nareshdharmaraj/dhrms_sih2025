const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const Zone = require('./src/models/Zone');

const debugRHOZoneAssignment = async () => {
  try {
    console.log('🔍 Debugging RHO-Zone Assignment Issues...\n');

    // 1. Check if there are any RHOs created recently
    console.log('1. 📋 Checking recent RHOs:');
    const recentRHOs = await RegionalHealthOfficer.find({
      assignedDistrict: 'Ernakulam'
    }).sort({ createdAt: -1 }).limit(5);

    console.log(`Found ${recentRHOs.length} RHOs for Ernakulam:`);
    recentRHOs.forEach(rho => {
      console.log(`  - ${rho.fullName} (${rho.officerId})`);
      console.log(`    Email: ${rho.email}`);
      console.log(`    Areas: ${rho.assignedAreas.map(a => a.name).join(', ')}`);
      console.log(`    Created: ${rho.createdAt}`);
      console.log('');
    });

    // 2. Check zones in Ernakulam and their RHO assignments
    console.log('2. 🏢 Checking zones in Ernakulam:');
    const zones = await Zone.find({
      state: 'Kerala',
      district: 'Ernakulam',
      isActive: true
    });

    console.log(`Found ${zones.length} zones in Kerala-Ernakulam:`);
    zones.forEach(zone => {
      console.log(`  - Zone: ${zone.zoneName} (${zone.zoneId})`);
      console.log(`    Areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
      console.log(`    RHO ID: ${zone.assignedRHO?.rhoId || 'NONE'}`);
      console.log(`    RHO Name: ${zone.assignedRHO?.rhoName || 'NONE'}`);
      console.log(`    Assigned Date: ${zone.assignedRHO?.assignedDate || 'NONE'}`);
      console.log(`    Assigned By: ${zone.assignedRHO?.assignedBy || 'NONE'}`);
      console.log('');
    });

    // 3. Check for RHO-Zone mismatches
    console.log('3. 🔍 Checking for assignment mismatches:');
    for (const rho of recentRHOs) {
      // Find zones that should be assigned to this RHO
      const zonesWithThisRHO = zones.filter(zone => 
        zone.assignedRHO?.rhoId === rho.officerId
      );
      
      console.log(`RHO ${rho.fullName} (${rho.officerId}):`);
      console.log(`  - Assigned areas in RHO record: ${rho.assignedAreas.map(a => a.name).join(', ')}`);
      console.log(`  - Zones assigned to this RHO: ${zonesWithThisRHO.length}`);
      
      if (zonesWithThisRHO.length > 0) {
        zonesWithThisRHO.forEach(zone => {
          console.log(`    * Zone: ${zone.zoneName} with areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
        });
      } else {
        console.log('    * No zones assigned to this RHO in Zone records');
      }
      console.log('');
    }

    // 4. Check subdistricts allocation
    console.log('4. 📍 Checking subdistricts allocation:');
    recentRHOs.forEach(rho => {
      console.log(`RHO ${rho.fullName}:`);
      console.log(`  - Coverage subDistricts: ${rho.coverage?.subDistricts?.join(', ') || 'NONE'}`);
      console.log(`  - AssignedAreas: ${rho.assignedAreas.map(a => `${a.name} (${a.type})`).join(', ')}`);
      console.log('');
    });

    // 5. Check if frontend mapping would work
    console.log('5. 🌐 Frontend mapping simulation:');
    zones.forEach(zone => {
      const frontendData = {
        zoneId: zone.zoneId,
        zoneName: zone.zoneName,
        assignedRHO: zone.assignedRHO,
        areas: zone.areas
      };
      console.log(`Zone ${zone.zoneName} -> Frontend mapping:`);
      console.log(`  - rhoId: ${frontendData.assignedRHO?.rhoId || 'null'}`);
      console.log(`  - rhoName: ${frontendData.assignedRHO?.rhoName || 'null'}`);
      console.log(`  - areas: ${frontendData.areas.map(a => a.areaName).join(', ')}`);
      console.log('');
    });

  } catch (error) {
    console.error('❌ Debug error:', error);
  }
};

// Connect to MongoDB and run debug
const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017/dhrms_sih2025', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('📡 Connected to MongoDB');
  return debugRHOZoneAssignment();
}).then(() => {
  console.log('✅ Debug completed');
  process.exit(0);
}).catch(error => {
  console.error('❌ Error:', error);
  process.exit(1);
});