const mongoose = require('mongoose');
const Zone = require('./src/models/Zone');

async function testZoneCreation() {
  try {
    await mongoose.connect('mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');
    
    // Try to create a simple zone
    const testZone = new Zone({
      zoneId: 'ZONE_KERALA_THRISSUR_TEST_' + Date.now(),
      zoneName: 'Test Thrissur Zone',
      state: 'Kerala',
      district: 'Thrissur',
      areas: [
        {
          areaName: 'Thrissur',
          areaCode: 'TSR_001',
          isDenselyPopulated: true
        }
      ],
      zoneType: 'urban',
      priority: 'medium',
      createdBy: {
        shoId: 'test_sho_id',
        shoName: 'Test SHO'
      },
      isActive: true
    });
    
    console.log('📝 Attempting to save test zone...');
    const savedZone = await testZone.save();
    console.log('✅ Zone created successfully:', savedZone.zoneId);
    
    // Verify the zone was saved
    const foundZone = await Zone.findOne({ zoneId: savedZone.zoneId });
    console.log('🔍 Zone verification:', foundZone ? 'Found' : 'Not found');
    
    // Test unassigned zones query
    const unassignedZones = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log('📊 Unassigned zones for Thrissur:', unassignedZones.length);
    
    await mongoose.disconnect();
    console.log('✅ Test complete');
  } catch (error) {
    console.error('❌ Error creating zone:', error);
    await mongoose.disconnect();
  }
}

testZoneCreation();