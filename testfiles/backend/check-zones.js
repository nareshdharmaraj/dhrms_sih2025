const mongoose = require('mongoose');
const Zone = require('./src/models/Zone');

async function checkZones() {
  try {
    await mongoose.connect('mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');
    
    // Check all zones
    const allZones = await Zone.find({});
    console.log(`📊 Total zones in database: ${allZones.length}`);
    
    if (allZones.length > 0) {
      console.log('\n📋 All zones:');
      allZones.forEach(zone => {
        console.log(`- ${zone.zoneName} (${zone.state}, ${zone.district}) - RHO: ${zone.assignedRHO?.rhoId || 'unassigned'} - Active: ${zone.isActive}`);
      });
    }
    
    // Check zones for Kerala specifically
    const keralaZones = await Zone.find({ state: 'Kerala', isActive: true });
    console.log(`\n🌴 Kerala zones: ${keralaZones.length}`);
    
    // Check unassigned zones for Thrissur
    const thrissurUnassigned = await Zone.findUnassigned('Kerala', 'Thrissur');
    console.log(`\n🔍 Thrissur unassigned zones: ${thrissurUnassigned.length}`);
    
    if (thrissurUnassigned.length > 0) {
      thrissurUnassigned.forEach(zone => {
        console.log(`  - ${zone.zoneName}: ${zone.areas.map(a => a.areaName).join(', ')}`);
      });
    }
    
    // Check unassigned zones for Thiruvananthapuram
    const tvmUnassigned = await Zone.findUnassigned('Kerala', 'Thiruvananthapuram');
    console.log(`\n🔍 Thiruvananthapuram unassigned zones: ${tvmUnassigned.length}`);
    
    if (tvmUnassigned.length > 0) {
      tvmUnassigned.forEach(zone => {
        console.log(`  - ${zone.zoneName}: ${zone.areas.map(a => a.areaName).join(', ')}`);
      });
    }
    
    await mongoose.disconnect();
    console.log('✅ Database check complete');
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

checkZones();