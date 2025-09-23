const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const Zone = require('./src/models/Zone');
const StateHealthOfficer = require('./src/models/StateHealthOfficer');

const checkDatabaseState = async () => {
  try {
    console.log('🔍 Checking overall database state...\n');

    // 1. Check all RHOs
    console.log('1. 📋 All RHOs in database:');
    const allRHOs = await RegionalHealthOfficer.find({}).limit(10);
    console.log(`Found ${allRHOs.length} RHOs total:`);
    allRHOs.forEach(rho => {
      console.log(`  - ${rho.fullName} (${rho.officerId}) - ${rho.assignedState}/${rho.assignedDistrict}`);
    });
    console.log('');

    // 2. Check all zones
    console.log('2. 🏢 All zones in database:');
    const allZones = await Zone.find({}).limit(10);
    console.log(`Found ${allZones.length} zones total:`);
    allZones.forEach(zone => {
      console.log(`  - ${zone.zoneName} (${zone.zoneId}) - ${zone.state}/${zone.district}`);
      console.log(`    RHO: ${zone.assignedRHO?.rhoName || 'None'}`);
    });
    console.log('');

    // 3. Check all SHOs
    console.log('3. 👤 All SHOs in database:');
    const allSHOs = await StateHealthOfficer.find({}).limit(5);
    console.log(`Found ${allSHOs.length} SHOs total:`);
    allSHOs.forEach(sho => {
      console.log(`  - ${sho.fullName} (${sho.officerId}) - ${sho.assignedState}`);
    });
    console.log('');

    // 4. Check for Kerala specifically
    console.log('4. 🌴 Kerala-specific data:');
    const keralaRHOs = await RegionalHealthOfficer.find({ assignedState: 'Kerala' });
    const keralaZones = await Zone.find({ state: 'Kerala' });
    const keralaSHOs = await StateHealthOfficer.find({ assignedState: 'Kerala' });
    
    console.log(`Kerala RHOs: ${keralaRHOs.length}`);
    console.log(`Kerala Zones: ${keralaZones.length}`);
    console.log(`Kerala SHOs: ${keralaSHOs.length}`);

    if (keralaSHOs.length > 0) {
      console.log('Kerala SHO details:');
      keralaSHOs.forEach(sho => {
        console.log(`  - ${sho.fullName} (${sho.officerId})`);
        console.log(`    Email: ${sho.email}`);
        console.log(`    Active: ${sho.isActive}`);
      });
    }

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
  return checkDatabaseState();
}).then(() => {
  console.log('✅ Debug completed');
  process.exit(0);
}).catch(error => {
  console.error('❌ Error:', error);
  process.exit(1);
});