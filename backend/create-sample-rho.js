const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const StateHealthOfficer = require('./src/models/StateHealthOfficer');

async function createSampleRHO() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth');
    
    // First, find or create a SHO to link to
    let sho = await StateHealthOfficer.findOne({ assignedState: 'Kerala' });
    if (!sho) {
      console.log('Creating sample SHO...');
      sho = new StateHealthOfficer({
        officerId: 'SHO_Kerala_001',
        username: 'sho_kerala',
        password: 'password123', // This will be hashed by pre-save middleware
        fullName: 'Dr. Kerala SHO',
        email: 'sho.kerala@health.gov.in',
        phone: '+91-9876543210',
        assignedState: 'Kerala',
        qualifications: ['MBBS', 'MD'],
        experience: 15,
        licenseNumber: 'KER001'
      });
      await sho.save();
    }

    // Create RHO record
    const rho = new RegionalHealthOfficer({
      officerId: 'RHO_Pathanamthitta_001',
      username: 'rho_pathanamthitta',
      password: 'password123', // This will be hashed by pre-save middleware
      fullName: 'DR Jhon',
      email: 'rho.pathanamthitta@health.gov.in',
      phone: '+91-9876543211',
      assignedState: 'Kerala',
      assignedDistrict: 'Pathanamthitta',
      assignedRegion: 'Southern Kerala',
      parentSHO: sho._id,
      
      // Sample assigned areas
      assignedAreas: [
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
      ],

      // Coverage details
      coverage: {
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
      },

      // Statistics
      statistics: {
        totalStaffManaged: 45,
        hospitalsOverseen: 8,
        patientsServed: 2350,
        emergencyResponsesHandled: 125,
        reportsGenerated: 15,
        lastReportDate: new Date(),
        performanceRating: 4.2
      },

      // Office details
      officeAddress: {
        city: 'Pathanamthitta',
        state: 'Kerala',
        zipCode: '689645'
      },
      
      qualifications: ['MBBS', 'MD'],
      experience: 12,
      licenseNumber: 'KER-RHO-001'
    });

    await rho.save();
    console.log('✅ Sample RHO created successfully');
    console.log('Officer ID:', rho.officerId);
    console.log('Assigned Areas:', rho.assignedAreas.length);
    console.log('Coverage Population:', rho.coverage.population);
    
    await mongoose.disconnect();
  } catch (error) {
    console.error('Error:', error);
  }
}

createSampleRHO();