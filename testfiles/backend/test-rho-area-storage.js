const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function testRHOAreaStorage() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('🔗 Connected to MongoDB - Database: myhealth');

    // Find a recently created RHO to check area storage
    const recentRHO = await RegionalHealthOfficer.findOne({
      assignedState: 'Kerala',
      assignedDistrict: 'Ernakulam'
    }).sort({ createdAt: -1 });

    if (!recentRHO) {
      console.log('⚠️ No RHO found for Kerala/Ernakulam');
      return;
    }

    console.log('\n🔍 RHO Area Storage Analysis:');
    console.log('=======================================');
    console.log(`👤 RHO: ${recentRHO.fullName} (${recentRHO.officerId})`);
    console.log(`📍 Location: ${recentRHO.assignedState} > ${recentRHO.assignedDistrict}`);
    
    console.log('\n📋 Assigned Areas in Database:');
    if (recentRHO.assignedAreas && recentRHO.assignedAreas.length > 0) {
      recentRHO.assignedAreas.forEach((area, index) => {
        console.log(`   ${index + 1}. ${area.name} (${area.code})`);
        console.log(`      - Type: ${area.type}`);
        console.log(`      - Population: ${area.population}`);
        console.log(`      - Area: ${area.areaKm2} km²`);
      });
      console.log(`✅ Total areas stored: ${recentRHO.assignedAreas.length}`);
    } else {
      console.log('❌ No assigned areas found in database!');
    }

    console.log('\n📋 Coverage Sub-districts:');
    if (recentRHO.coverage && recentRHO.coverage.subDistricts && recentRHO.coverage.subDistricts.length > 0) {
      recentRHO.coverage.subDistricts.forEach((subDistrict, index) => {
        console.log(`   ${index + 1}. ${subDistrict}`);
      });
      console.log(`✅ Total sub-districts: ${recentRHO.coverage.subDistricts.length}`);
    } else {
      console.log('❌ No sub-districts found in coverage!');
    }

    // Test if area names match sub-districts
    if (recentRHO.assignedAreas && recentRHO.coverage && recentRHO.coverage.subDistricts) {
      const areaNames = recentRHO.assignedAreas.map(area => area.name);
      const subDistrictNames = recentRHO.coverage.subDistricts;
      
      console.log('\n🔗 Area-SubDistrict Mapping:');
      const matches = areaNames.filter(name => subDistrictNames.includes(name));
      console.log(`   - Matching entries: ${matches.length}`);
      if (matches.length > 0) {
        console.log(`   - Matches: ${matches.join(', ')}`);
      }
    }

    console.log('\n✅ RHO area storage analysis completed!');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run the test
testRHOAreaStorage().catch(console.error);