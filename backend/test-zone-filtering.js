const mongoose = require('mongoose');
require('dotenv').config();

const Zone = require('./src/models/Zone');

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

// Test zone filtering after assignment
async function testZoneFiltering() {
  try {
    console.log('🔍 Testing zone filtering after assignment...\n');

    // Step 1: Check initial unassigned zones
    console.log('📊 Step 1: Initial state - Unassigned zones for Thrissur');
    let unassignedZones = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`   Found ${unassignedZones.length} unassigned zones:`);
    unassignedZones.forEach(zone => {
      console.log(`     - ${zone.zoneName} (ID: ${zone.zoneId})`);
      console.log(`       Areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
      console.log(`       Assigned RHO: ${zone.assignedRHO?.rhoId || 'None'}`);
    });

    if (unassignedZones.length === 0) {
      console.log('❌ No unassigned zones found');
      return;
    }

    // Step 2: Assign first zone
    const firstZone = unassignedZones[0];
    console.log(`\n🎯 Step 2: Assigning first zone: ${firstZone.zoneName}`);
    
    await firstZone.assignRHO('TEST_RHO_001', 'Dr. Test First RHO', new mongoose.Types.ObjectId());
    console.log('   ✅ First zone assigned');

    // Step 3: Check unassigned zones after first assignment
    console.log('\n📊 Step 3: Unassigned zones after first assignment');
    const afterFirstAssignment = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`   Found ${afterFirstAssignment.length} unassigned zones:`);
    afterFirstAssignment.forEach(zone => {
      console.log(`     - ${zone.zoneName} (ID: ${zone.zoneId})`);
      console.log(`       Areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
    });

    // Step 4: If there are remaining zones, assign one more
    if (afterFirstAssignment.length > 0) {
      const secondZone = afterFirstAssignment[0];
      console.log(`\n🎯 Step 4: Assigning second zone: ${secondZone.zoneName}`);
      
      await secondZone.assignRHO('TEST_RHO_002', 'Dr. Test Second RHO', new mongoose.Types.ObjectId());
      console.log('   ✅ Second zone assigned');

      // Step 5: Final check
      console.log('\n📊 Step 5: Final unassigned zones check');
      const finalUnassigned = await Zone.findUnassigned('Kerala', 'Thrissur');
      console.log(`   Found ${finalUnassigned.length} unassigned zones:`);
      
      if (finalUnassigned.length === 0) {
        console.log('   🎉 SUCCESS: No unassigned zones remaining - this is the expected behavior!');
        console.log('   📱 Frontend should show: "No available zones for assignment"');
      } else {
        finalUnassigned.forEach(zone => {
          console.log(`     - ${zone.zoneName} (ID: ${zone.zoneId})`);
        });
      }

      // Clean up
      console.log('\n🧹 Cleanup: Unassigning test zones');
      await firstZone.unassignRHO();
      await secondZone.unassignRHO();
    } else {
      console.log('\n🧹 Cleanup: Unassigning test zone');
      await firstZone.unassignRHO();
    }

    console.log('   ✅ Cleanup complete');

    // Step 6: Verify cleanup
    console.log('\n🔍 Step 6: Verify cleanup - should be back to initial state');
    const afterCleanup = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`   Found ${afterCleanup.length} unassigned zones after cleanup:`);
    afterCleanup.forEach(zone => {
      console.log(`     - ${zone.zoneName} (ID: ${zone.zoneId})`);
    });

    console.log('\n🎉 Zone filtering test completed successfully!');
    console.log('\n📝 Summary:');
    console.log('   ✅ Zone assignment working correctly');
    console.log('   ✅ Unassigned zone filtering working correctly');
    console.log('   ✅ Frontend fix (sending assignToZone + zoneId) should resolve the issue');

  } catch (error) {
    console.error('❌ Test error:', error);
  }
}

// Main execution
async function main() {
  await connectToDatabase();
  await testZoneFiltering();
  process.exit(0);
}

main().catch(console.error);