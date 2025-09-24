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

// Test zone assignment during RHO creation
async function testZoneAssignment() {
  try {
    // Get an unassigned zone
    const unassignedZone = await Zone.findOne({
      state: 'Kerala',
      district: 'Thrissur',
      $or: [
        { 'assignedRHO.rhoId': { $exists: false } },
        { 'assignedRHO.rhoId': null },
        { 'assignedRHO.rhoId': '' }
      ],
      isActive: true
    });

    if (!unassignedZone) {
      console.log('❌ No unassigned zones found for testing');
      return;
    }

    console.log(`🎯 Testing with zone: ${unassignedZone.zoneName} (ID: ${unassignedZone.zoneId})`);

    // Get SHO for Kerala
    const sho = await StateHealthOfficer.findOne({ assignedState: 'Kerala' });
    if (!sho) {
      console.log('❌ No SHO found for Kerala');
      return;
    }

    console.log(`🏥 Using SHO: ${sho.fullName} (${sho.officerId})`);

    // Simulate the request body that would come from frontend after fix
    const testRHOData = {
      fullName: 'Dr. Test Zone Assignment',
      email: 'test.zone.assignment@test.gov.in',
      phone: '+91-9999999999',
      password: 'TestPassword@123',
      assignedDistrict: 'Thrissur',
      qualification: 'MBBS, MD',
      experience: 5,
      licenseNumber: 'TEST_LIC_001',
      assignToZone: true,  // The fix: this flag was missing
      zoneId: unassignedZone.zoneId,  // The fix: this was not being sent
      assignedZone: unassignedZone.zoneName  // For reference
    };

    console.log('📝 Test RHO data prepared with zone assignment parameters:');
    console.log(`   - assignToZone: ${testRHOData.assignToZone}`);
    console.log(`   - zoneId: ${testRHOData.zoneId}`);
    console.log(`   - assignedZone: ${testRHOData.assignedZone}`);

    // Test the zone assignment logic directly
    console.log('\n🔄 Testing zone assignment logic...');
    
    if (testRHOData.assignToZone && testRHOData.zoneId) {
      const targetZone = await Zone.findOne({ 
        zoneId: testRHOData.zoneId, 
        state: 'Kerala',
        district: 'Thrissur',
        isActive: true 
      });
      
      if (targetZone && (!targetZone.assignedRHO || !targetZone.assignedRHO.rhoId)) {
        console.log('✅ Zone found and is unassigned - assignment would proceed');
        console.log(`   - Zone: ${targetZone.zoneName}`);
        console.log(`   - Areas: ${targetZone.areas.map(a => a.areaName).join(', ')}`);
        
        // Simulate assignment
        console.log('\n🎯 Simulating RHO assignment to zone...');
        await targetZone.assignRHO('TEST_RHO_ID', testRHOData.fullName, sho._id);
        
        console.log('✅ Zone assignment successful!');
        
        // Verify assignment
        const updatedZone = await Zone.findOne({ zoneId: testRHOData.zoneId });
        console.log('🔍 Verification:');
        console.log(`   - Assigned RHO ID: ${updatedZone.assignedRHO?.rhoId}`);
        console.log(`   - Assigned RHO Name: ${updatedZone.assignedRHO?.rhoName}`);
        console.log(`   - Assignment Date: ${updatedZone.assignedRHO?.assignedAt}`);
        
        // Check unassigned zones after assignment
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
        
        console.log(`\n📊 Unassigned zones remaining: ${remainingUnassigned.length}`);
        remainingUnassigned.forEach(zone => {
          console.log(`   - ${zone.zoneName} (${zone.zoneId})`);
        });
        
        // Clean up - unassign for next test
        await targetZone.unassignRHO();
        console.log('\n🧹 Cleaned up - zone unassigned for next test');
        
      } else {
        console.log('❌ Zone not found or already assigned');
      }
    } else {
      console.log('❌ Missing assignment parameters');
    }

  } catch (error) {
    console.error('❌ Test error:', error);
  }
}

// Main execution
async function main() {
  await connectToDatabase();
  await testZoneAssignment();
  process.exit(0);
}

main().catch(console.error);