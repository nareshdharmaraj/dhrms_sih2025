const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function addSampleAreaData() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth');
    
    const rho = await RegionalHealthOfficer.findOne({ officerId: 'RHO_Pathanamthitta_001' });
    
    if (rho) {
      // Add sample assigned areas for Pathanamthitta district
      rho.assignedAreas = [
        {
          name: 'Adoor',
          code: 'ADR',
          type: 'area',
          population: 45000,
          areaKm2: 120.5
        },
        {
          name: 'Konni',
          code: 'KNI',
          type: 'area', 
          population: 32000,
          areaKm2: 85.2
        },
        {
          name: 'Mallappally',
          code: 'MLP',
          type: 'area',
          population: 38000,
          areaKm2: 95.8
        },
        {
          name: 'Ranni',
          code: 'RNI',
          type: 'area',
          population: 28000,
          areaKm2: 110.3
        }
      ];

      // Update coverage details
      rho.coverage = {
        primaryDistrict: 'Pathanamthitta',
        subDistricts: ['Adoor', 'Konni', 'Mallappally', 'Ranni', 'Thiruvalla'],
        blocks: ['Adoor Block', 'Konni Block', 'Mallappally Block', 'Ranni Block'],
        villages: ['Adoor Town', 'Konni Village', 'Mallappally East', 'Mallappally West', 'Ranni Town', 'Kozhencherry'],
        primaryHealthCenters: ['Adoor PHC', 'Konni PHC', 'Mallappally PHC', 'Ranni PHC'],
        communityHealthCenters: ['Adoor CHC', 'Mallappally CHC'],
        population: 143000,
        areaKm2: 411.8,
        ruralPopulation: 95000,
        urbanPopulation: 48000
      };

      // Update statistics
      rho.statistics = {
        totalStaffManaged: 45,
        hospitalsOverseen: 8,
        patientsServed: 2350,
        emergencyResponsesHandled: 125,
        reportsGenerated: 15,
        lastReportDate: new Date(),
        performanceRating: 4.2
      };

      await rho.save();
      console.log('✅ Sample area data added successfully');
      console.log('Assigned Areas:', rho.assignedAreas.length);
      console.log('Coverage Population:', rho.coverage.population);
      
    } else {
      console.log('❌ RHO not found');
    }
    
    await mongoose.disconnect();
  } catch (error) {
    console.error('Error:', error);
  }
}

addSampleAreaData();