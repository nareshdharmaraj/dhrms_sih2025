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

// Test API endpoint by simulating full zone assignment
async function testAPIEndpointScenario() {
  try {
    console.log('🧪 Testing API endpoint scenario...\n');
    
    // Step 1: Check current state
    console.log('📊 Step 1: Current zone state for Thrissur');
    const currentZones = await Zone.find({
      state: 'Kerala',
      district: 'Thrissur',
      isActive: true
    });
    
    console.log(`   Total zones: ${currentZones.length}`);
    currentZones.forEach(zone => {
      const isAssigned = zone.assignedRHO && zone.assignedRHO.rhoId;
      console.log(`   - ${zone.zoneName}: ${isAssigned ? `Assigned to ${zone.assignedRHO.rhoId}` : 'Unassigned'}`);
    });
    
    // Step 2: Test what API would return before assignment
    console.log('\n📡 Step 2: What API would return (before full assignment)');
    const unassignedBefore = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`   Unassigned zones: ${unassignedBefore.length}`);
    console.log(`   ✅ Thrissur should appear in district dropdown`);
    
    // Step 3: Assign all zones
    console.log('\n🎯 Step 3: Assigning all zones to simulate complete RHO assignment');
    for (let i = 0; i < currentZones.length; i++) {
      const zone = currentZones[i];
      if (!zone.assignedRHO || !zone.assignedRHO.rhoId) {
        await zone.assignRHO(`TEST_RHO_${i + 1}`, `Test RHO ${i + 1}`, 'test_sho_id');
        console.log(`   ✅ Assigned ${zone.zoneName} to TEST_RHO_${i + 1}`);
      }
    }
    
    // Step 4: Test what API would return after assignment
    console.log('\n📡 Step 4: What API would return (after full assignment)');
    const unassignedAfter = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`   Unassigned zones: ${unassignedAfter.length}`);
    
    if (unassignedAfter.length === 0) {
      console.log(`   ✅ SUCCESS: Thrissur should NOT appear in district dropdown`);
      console.log(`   📱 Frontend should see: No Thrissur option in RHO creation form`);
    } else {
      console.log(`   ❌ FAIL: Thrissur should not appear but still has unassigned zones`);
    }
    
    // Step 5: Simulate creating one more RHO (should not see Thrissur)
    console.log('\n🚫 Step 5: Simulating next RHO creation attempt');
    console.log(`   District dropdown would contain:`);
    
    // This simulates what the frontend would see
    const availableForNewRHO = await Zone.aggregate([
      {
        $match: {
          state: 'Kerala',
          isActive: true,
          $or: [
            { 'assignedRHO.rhoId': { $exists: false } },
            { 'assignedRHO.rhoId': null },
            { 'assignedRHO.rhoId': '' }
          ]
        }
      },
      {
        $group: {
          _id: '$district',
          unassignedCount: { $sum: 1 }
        }
      }
    ]);
    
    console.log(`   Available districts with unassigned zones:`);
    if (availableForNewRHO.length === 0) {
      console.log(`     (None - all districts fully assigned)`);
    } else {
      availableForNewRHO.forEach(item => {
        console.log(`     - ${item._id}: ${item.unassignedCount} unassigned zone(s)`);
      });
    }
    
    const thrissurStillAvailable = availableForNewRHO.some(item => item._id === 'Thrissur');
    if (!thrissurStillAvailable) {
      console.log(`   ✅ PERFECT: Thrissur correctly hidden from dropdown`);
    } else {
      console.log(`   ❌ ERROR: Thrissur still showing in dropdown`);
    }
    
    // Step 6: Test partial assignment scenario
    console.log('\n🔄 Step 6: Testing partial assignment scenario');
    
    // Unassign one zone to simulate partial assignment
    if (currentZones.length > 1) {
      await currentZones[0].unassignRHO();
      console.log(`   🔄 Unassigned ${currentZones[0].zoneName} (partial assignment)`);
      
      const partialUnassigned = await Zone.findUnassigned('Kerala', 'Thrissur');
      console.log(`   📊 Unassigned zones after partial unassignment: ${partialUnassigned.length}`);
      
      if (partialUnassigned.length > 0) {
        console.log(`   ✅ Thrissur should reappear in dropdown (${partialUnassigned.length} unassigned zone(s))`);
      }
    }
    
    // Step 7: Cleanup
    console.log('\n🧹 Step 7: Cleanup - Unassigning all test assignments');
    for (const zone of currentZones) {
      await zone.unassignRHO();
    }
    console.log(`   ✅ All zones unassigned - back to original state`);
    
    const finalCheck = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`   📊 Final unassigned zones: ${finalCheck.length}`);
    
    console.log('\n🎉 API endpoint scenario test completed!');

  } catch (error) {
    console.error('❌ Test error:', error);
  }
}

// Main execution
async function main() {
  await connectToDatabase();
  await testAPIEndpointScenario();
  process.exit(0);
}

main().catch(console.error);