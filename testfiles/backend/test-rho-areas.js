// Test script to demonstrate RHO area data retrieval for dashboard
const mongoose = require('mongoose');
require('dotenv').config();

const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function testRHOAreaRetrieval() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    // Find all RHOs with assigned areas
    const rhosWithAreas = await RegionalHealthOfficer.find({
      isActive: true,
      'assignedAreas.0': { $exists: true } // Has at least one assigned area
    }).select('officerId fullName assignedState assignedDistrict assignedAreas assignedRegion')
    .limit(5);

    console.log('\n📊 RHO AREA DATA ANALYSIS:');
    console.log('==========================================');

    if (rhosWithAreas.length === 0) {
      console.log('❌ No RHOs found with assigned areas');
      return;
    }

    for (const rho of rhosWithAreas) {
      console.log(`\n🏥 RHO: ${rho.fullName} (${rho.officerId})`);
      console.log(`📍 Location: ${rho.assignedDistrict}, ${rho.assignedState}`);
      console.log(`🗺️  Region: ${rho.assignedRegion}`);
      console.log(`📋 Assigned Areas (${rho.assignedAreas.length}):`);
      
      let totalPopulation = 0;
      let totalArea = 0;
      let denseAreas = 0;
      
      rho.assignedAreas.forEach((area, index) => {
        console.log(`   ${index + 1}. ${area.name} (${area.code})`);
        console.log(`      • Type: ${area.type}`);
        console.log(`      • Population: ${area.population.toLocaleString()}`);
        console.log(`      • Area: ${area.areaKm2} km²`);
        console.log(`      • Dense: ${area.isDenselyPopulated ? 'Yes' : 'No'}`);
        
        if (area.zoneAreaId) {
          console.log(`      • Zone Area ID: ${area.zoneAreaId}`);
        }
        
        if (area.areaKm2 > 0) {
          const density = Math.round(area.population / area.areaKm2);
          console.log(`      • Density: ${density} people/km²`);
        }
        
        totalPopulation += area.population;
        totalArea += area.areaKm2;
        if (area.isDenselyPopulated) denseAreas++;
      });
      
      console.log(`\n   📊 SUMMARY:`);
      console.log(`   • Total Population: ${totalPopulation.toLocaleString()}`);
      console.log(`   • Total Area: ${totalArea.toFixed(2)} km²`);
      console.log(`   • Dense Areas: ${denseAreas}/${rho.assignedAreas.length}`);
      
      if (totalArea > 0) {
        const avgDensity = Math.round(totalPopulation / totalArea);
        console.log(`   • Average Density: ${avgDensity} people/km²`);
      }
      
      console.log('------------------------------------------');
    }

    // Dashboard data format example
    console.log('\n📱 DASHBOARD DATA FORMAT EXAMPLE:');
    console.log('==========================================');
    
    const sampleRho = rhosWithAreas[0];
    const dashboardData = {
      rhoInfo: {
        id: sampleRho._id,
        officerId: sampleRho.officerId,
        fullName: sampleRho.fullName,
        assignedState: sampleRho.assignedState,
        assignedDistrict: sampleRho.assignedDistrict,
        assignedRegion: sampleRho.assignedRegion
      },
      areaAssignments: sampleRho.assignedAreas.map(area => ({
        name: area.name,
        code: area.code,
        type: area.type,
        population: area.population,
        areaKm2: area.areaKm2,
        isDenselyPopulated: area.isDenselyPopulated,
        zoneAreaId: area.zoneAreaId,
        populationDensity: area.areaKm2 > 0 ? Math.round(area.population / area.areaKm2) : 0,
        healthFacilities: {
          primaryHealthCenters: Math.floor(area.population / 20000) || 1,
          communityHealthCenters: Math.floor(area.population / 80000) || 1,
          hospitals: Math.floor(area.population / 100000) || 1
        }
      })),
      summary: {
        totalAreas: sampleRho.assignedAreas.length,
        totalPopulation: sampleRho.assignedAreas.reduce((sum, area) => sum + area.population, 0),
        totalAreaKm2: sampleRho.assignedAreas.reduce((sum, area) => sum + area.areaKm2, 0),
        denseAreas: sampleRho.assignedAreas.filter(area => area.isDenselyPopulated).length,
        assignmentType: sampleRho.assignedAreas.some(area => area.type === 'area') ? 'area-specific' : 'full-district'
      }
    };
    
    console.log(JSON.stringify(dashboardData, null, 2));

  } catch (error) {
    console.error('❌ Error testing RHO area retrieval:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n✅ Disconnected from MongoDB');
  }
}

// Run the test
testRHOAreaRetrieval();