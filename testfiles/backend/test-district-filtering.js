const mongoose = require('mongoose');
require('dotenv').config();

const Zone = require('./src/models/Zone');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const StateHealthOfficer = require('./src/models/StateHealthOfficer');
const { AreaAssignmentService } = require('./src/services/areaAssignmentService');

// Connect to MongoDB
async function connectToDatabase() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
}

// Test district filtering logic
async function testDistrictFiltering() {
  try {
    console.log('🔍 Testing district filtering logic for RHO creation...\n');
    
    // Get Kerala SHO
    const sho = await StateHealthOfficer.findOne({ assignedState: 'Kerala' });
    if (!sho) {
      console.log('❌ No SHO found for Kerala');
      return;
    }
    console.log(`🏥 Using SHO: ${sho.fullName} (${sho.officerId})`);

    // Get all districts for Kerala
    let districts;
    try {
      districts = AreaAssignmentService.getDistrictsForState('Kerala');
    } catch (error) {
      console.log('❌ Error getting districts:', error.message);
      return;
    }

    console.log(`\n📊 Total districts in Kerala: ${districts.length}`);
    
    // Test the new filtering logic
    console.log('\n🔍 Testing new district filtering logic:');
    
    const availableDistricts = [];
    
    for (const district of districts) {
      const districtName = district.name;
      console.log(`\n🏘️  Checking ${districtName} (Dense: ${district.isDense})`);
      
      if (district.isDense) {
        // For dense districts, check if there are unassigned zones
        const unassignedZones = await Zone.findUnassigned('Kerala', districtName);
        console.log(`   📍 Unassigned zones: ${unassignedZones.length}`);
        
        unassignedZones.forEach(zone => {
          console.log(`     - ${zone.zoneName} (${zone.zoneId})`);
        });
        
        if (unassignedZones.length > 0) {
          // District has unassigned zones, so it's available for RHO creation
          availableDistricts.push({
            ...district,
            availabilityReason: `${unassignedZones.length} unassigned zone(s)`,
            unassignedZonesCount: unassignedZones.length
          });
          console.log(`   ✅ AVAILABLE: ${unassignedZones.length} unassigned zone(s)`);
        } else {
          console.log(`   ❌ NOT AVAILABLE: All zones assigned`);
        }
        
      } else {
        // For sparse districts, check if any RHO is assigned
        const existingRHO = await RegionalHealthOfficer.findOne({
          assignedState: 'Kerala',
          assignedDistrict: districtName,
          parentSHO: sho._id,
          isActive: true
        });
        
        if (existingRHO) {
          console.log(`   ❌ NOT AVAILABLE: RHO already assigned (${existingRHO.officerId})`);
        } else {
          availableDistricts.push({
            ...district,
            availabilityReason: 'No RHO assigned',
            unassignedZonesCount: 0
          });
          console.log(`   ✅ AVAILABLE: No RHO assigned`);
        }
      }
    }

    console.log(`\n📋 Summary:`);
    console.log(`   Total districts: ${districts.length}`);
    console.log(`   Available for RHO creation: ${availableDistricts.length}`);
    console.log(`   Dense districts with zones: ${districts.filter(d => d.isDense).length}`);
    console.log(`   Sparse districts: ${districts.filter(d => !d.isDense).length}`);
    
    console.log(`\n✅ Available districts for dropdown:`);
    availableDistricts.forEach(district => {
      console.log(`   - ${district.name}: ${district.availabilityReason}`);
    });

    // Test specific scenario: Assign all zones in Thrissur and verify it disappears
    console.log(`\n🎯 Testing Thrissur zone assignment scenario:`);
    
    const thrissurZones = await Zone.find({
      state: 'Kerala',
      district: 'Thrissur',
      isActive: true
    });
    
    console.log(`   📍 Total Thrissur zones: ${thrissurZones.length}`);
    
    const unassignedThrissurZones = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`   📍 Unassigned Thrissur zones: ${unassignedThrissurZones.length}`);
    
    if (unassignedThrissurZones.length > 0) {
      console.log(`   ✅ Thrissur should appear in dropdown (${unassignedThrissurZones.length} unassigned zones)`);
      
      // Test: Assign all zones and check again
      console.log(`   🧪 Simulating assignment of all Thrissur zones...`);
      
      for (const zone of unassignedThrissurZones) {
        await zone.assignRHO(`TEST_RHO_${Date.now()}`, 'Test RHO', sho._id);
      }
      
      const finalUnassignedZones = await Zone.findUnassigned('Kerala', 'Thrissur');
      console.log(`   📍 After assignment - Unassigned zones: ${finalUnassignedZones.length}`);
      
      if (finalUnassignedZones.length === 0) {
        console.log(`   ✅ SUCCESS: Thrissur should NOT appear in dropdown (all zones assigned)`);
      } else {
        console.log(`   ❌ FAIL: Thrissur should not appear but still has unassigned zones`);
      }
      
      // Clean up - unassign zones
      for (const zone of thrissurZones) {
        await zone.unassignRHO();
      }
      console.log(`   🧹 Cleanup: Zones unassigned`);
      
    } else {
      console.log(`   ❌ Thrissur should NOT appear in dropdown (all zones already assigned)`);
    }

  } catch (error) {
    console.error('❌ Test error:', error);
  }
}

// Main execution
async function main() {
  await connectToDatabase();
  await testDistrictFiltering();
  process.exit(0);
}

main().catch(console.error);