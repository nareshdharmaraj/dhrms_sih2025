const mongoose = require('mongoose');
require('dotenv').config();

const Zone = require('./src/models/Zone');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const StateHealthOfficer = require('./src/models/StateHealthOfficer');

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

// Test complete RHO creation and zone assignment flow
async function testCompleteRHOZoneFlow() {
  try {
    console.log('🚀 Testing complete RHO creation and zone assignment flow...\n');

    // Step 1: Check initial unassigned zones
    console.log('📊 Step 1: Initial unassigned zones check');
    let unassignedZones = await Zone.find({
      state: 'Kerala',
      district: 'Thrissur',
      $or: [
        { 'assignedRHO.rhoId': { $exists: false } },
        { 'assignedRHO.rhoId': null },
        { 'assignedRHO.rhoId': '' }
      ],
      isActive: true
    });
    console.log(`   ✅ Found ${unassignedZones.length} unassigned zones:`);
    unassignedZones.forEach(zone => {
      console.log(`     - ${zone.zoneName} (ID: ${zone.zoneId})`);
    });

    if (unassignedZones.length === 0) {
      console.log('❌ No unassigned zones found - cannot test');
      return;
    }

    const targetZone = unassignedZones[0];
    console.log(`\n🎯 Step 2: Creating RHO with zone assignment to: ${targetZone.zoneName}`);

    // Get SHO
    const sho = await StateHealthOfficer.findOne({ assignedState: 'Kerala' });
    
    // Generate unique RHO ID
    const timestamp = Date.now();
    const rhoId = `RHO_THRISSUR_TEST_${timestamp}`;
    
    // Create RHO with zone assignment
    const rhoData = {
      officerId: rhoId,
      fullName: `Dr. Test RHO ${timestamp}`,
      email: `test.rho.${timestamp}@test.gov.in`,
      phone: '+91-9999999999',
      passwordHash: 'hashed_password',
      assignedDistrict: 'Thrissur',
      assignedState: 'Kerala',
      parentSHO: sho._id,
      isActive: true
    };

    const newRHO = new RegionalHealthOfficer(rhoData);
    await newRHO.save();
    console.log(`   ✅ RHO created: ${newRHO.officerId}`);

    // Assign RHO to zone
    await targetZone.assignRHO(newRHO.officerId, newRHO.fullName, sho._id);
    console.log(`   ✅ Zone assignment completed`);

    // Step 3: Check unassigned zones after assignment
    console.log('\n📊 Step 3: Unassigned zones after first RHO assignment');
    const remainingUnassigned = await Zone.find({
      state: 'Kerala',
      district: 'Thrissur',
      $or: [
        { 'assignedRHO.rhoId': { $exists: false } },
        { 'assignedRHO.rhoId': null },
        { 'assignedRHO.rhoId': '' }
      ],
      isActive: true
    });
    
    console.log(`   📈 Remaining unassigned zones: ${remainingUnassigned.length}`);
    remainingUnassigned.forEach(zone => {
      console.log(`     - ${zone.zoneName} (ID: ${zone.zoneId})`);
    });

    // Step 4: Test what frontend would see when creating next RHO
    console.log('\n🔍 Step 4: Frontend zone loading simulation');
    
    // This simulates the API call: GET /api/zone-management/zones/Kerala/Thrissur/unassigned
    const frontendUnassignedZones = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`   🎯 Frontend would see ${frontendUnassignedZones.length} unassigned zones:`);
    frontendUnassignedZones.forEach(zone => {
      console.log(`     - ${zone.zoneName} (ID: ${zone.zoneId}) - Areas: ${zone.areas.map(a => a.areaName).join(', ')}`);
    });

    // Step 5: Simulate creating second RHO
    if (frontendUnassignedZones.length > 0) {
      console.log(`\n🚀 Step 5: Creating second RHO for remaining zone: ${frontendUnassignedZones[0].zoneName}`);
      
      const secondTargetZone = frontendUnassignedZones[0];
      const secondRhoId = `RHO_THRISSUR_TEST_${timestamp + 1}`;
      
      const secondRHOData = {
        officerId: secondRhoId,
        fullName: `Dr. Second Test RHO ${timestamp}`,
        email: `test.rho.second.${timestamp}@test.gov.in`,
        phone: '+91-9999999998',
        passwordHash: 'hashed_password',
        assignedDistrict: 'Thrissur',
        assignedState: 'Kerala',
        parentSHO: sho._id,
        isActive: true
      };

      const secondRHO = new RegionalHealthOfficer(secondRHOData);
      await secondRHO.save();
      console.log(`   ✅ Second RHO created: ${secondRHO.officerId}`);

      // Assign second RHO to remaining zone
      await secondTargetZone.assignRHO(secondRHO.officerId, secondRHO.fullName, sho._id);
      console.log(`   ✅ Second zone assignment completed`);

      // Step 6: Final check - should be no unassigned zones left
      console.log('\n📊 Step 6: Final unassigned zones check');
      const finalUnassigned = await Zone.findUnassigned('Kerala', 'Thrissur');
      console.log(`   📊 Final unassigned zones: ${finalUnassigned.length}`);
      
      if (finalUnassigned.length === 0) {
        console.log('   ✅ SUCCESS: All zones assigned - frontend should show "No available zones"');
      } else {
        console.log('   ⚠️ Some zones still unassigned:');
        finalUnassigned.forEach(zone => {
          console.log(`     - ${zone.zoneName}`);
        });
      }

      // Step 7: Cleanup - remove test RHOs and unassign zones
      console.log('\n🧹 Step 7: Cleanup');
      await RegionalHealthOfficer.deleteOne({ officerId: rhoId });
      await RegionalHealthOfficer.deleteOne({ officerId: secondRhoId });
      await targetZone.unassignRHO();
      await secondTargetZone.unassignRHO();
      console.log('   ✅ Test data cleaned up');

    } else {
      console.log('\n❌ No unassigned zones left for second RHO test');
      
      // Cleanup first RHO
      await RegionalHealthOfficer.deleteOne({ officerId: rhoId });
      await targetZone.unassignRHO();
      console.log('🧹 Test data cleaned up');
    }

    console.log('\n🎉 Complete RHO-Zone flow test finished!');

  } catch (error) {
    console.error('❌ Test error:', error);
  }
}

// Main execution
async function main() {
  await connectToDatabase();
  await testCompleteRHOZoneFlow();
  process.exit(0);
}

main().catch(console.error);