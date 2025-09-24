const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function checkAllRHOs() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('🔗 Connected to MongoDB - Database: myhealth');

    // Find all RHOs
    const allRHOs = await RegionalHealthOfficer.find({}).sort({ createdAt: -1 });

    console.log(`\n📊 Total RHOs in database: ${allRHOs.length}`);
    
    if (allRHOs.length === 0) {
      console.log('❌ No RHOs found in database!');
      console.log('\n💡 To test the area storage fix:');
      console.log('   1. Start the backend server: npm start');
      console.log('   2. Create an RHO through the SHO frontend');
      console.log('   3. Run this test again');
      return;
    }

    console.log('\n🔍 RHO Summary:');
    console.log('=======================================');
    
    allRHOs.forEach((rho, index) => {
      console.log(`\n${index + 1}. ${rho.fullName} (${rho.officerId})`);
      console.log(`   📍 Location: ${rho.assignedState} > ${rho.assignedDistrict}`);
      console.log(`   📅 Created: ${rho.createdAt.toLocaleString()}`);
      
      if (rho.assignedAreas && rho.assignedAreas.length > 0) {
        console.log(`   📋 Areas (${rho.assignedAreas.length}): ${rho.assignedAreas.map(a => a.name).join(', ')}`);
      } else {
        console.log(`   ❌ No assigned areas stored`);
      }
      
      if (rho.coverage && rho.coverage.subDistricts && rho.coverage.subDistricts.length > 0) {
        console.log(`   🏘️ Sub-districts (${rho.coverage.subDistricts.length}): ${rho.coverage.subDistricts.join(', ')}`);
      } else {
        console.log(`   ❌ No sub-districts in coverage`);
      }
    });

    console.log('\n✅ RHO database analysis completed!');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run the test
checkAllRHOs().catch(console.error);