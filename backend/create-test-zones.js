const mongoose = require('mongoose');
const Zone = require('./src/models/Zone');

async function createTestZones() {
  try {
    await mongoose.connect('mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');
    
    // Create a zone for Thiruvananthapuram
    const tvmZone = new Zone({
      zoneId: 'ZONE_KERALA_THIRUVANANTHAPURAM_TEST_' + Date.now(),
      zoneName: 'Test Thiruvananthapuram Zone',
      state: 'Kerala',
      district: 'Thiruvananthapuram',
      areas: [
        {
          areaName: 'Thiruvananthapuram',
          areaCode: 'TVM_001',
          isDenselyPopulated: true
        },
        {
          areaName: 'Neyyattinkara',
          areaCode: 'NYK_001',
          isDenselyPopulated: true
        }
      ],
      zoneType: 'urban',
      priority: 'high',
      createdBy: {
        shoId: 'test_sho_id',
        shoName: 'Test SHO'
      },
      isActive: true
    });
    
    console.log('📝 Creating zone for Thiruvananthapuram...');
    const savedTvmZone = await tvmZone.save();
    console.log('✅ Thiruvananthapuram zone created:', savedTvmZone.zoneId);
    
    // Create another zone for Thrissur with different areas
    const thrissurZone2 = new Zone({
      zoneId: 'ZONE_KERALA_THRISSUR_TEST2_' + Date.now(),
      zoneName: 'Test Thrissur Zone 2',
      state: 'Kerala',
      district: 'Thrissur',
      areas: [
        {
          areaName: 'Chavakkad',
          areaCode: 'CHV_001',
          isDenselyPopulated: true
        },
        {
          areaName: 'Kodungallur',
          areaCode: 'KDG_001',
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
    
    console.log('📝 Creating second zone for Thrissur...');
    const savedThrissurZone2 = await thrissurZone2.save();
    console.log('✅ Second Thrissur zone created:', savedThrissurZone2.zoneId);
    
    // Verify all zones
    const allZones = await Zone.find({ state: 'Kerala', isActive: true });
    console.log(`\n📊 Total Kerala zones: ${allZones.length}`);
    
    allZones.forEach(zone => {
      console.log(`- ${zone.zoneName} (${zone.district}): ${zone.areas.map(a => a.areaName).join(', ')}`);
    });
    
    await mongoose.disconnect();
    console.log('✅ Test zones created successfully');
  } catch (error) {
    console.error('❌ Error:', error);
    await mongoose.disconnect();
  }
}

createTestZones();