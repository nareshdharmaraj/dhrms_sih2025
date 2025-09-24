const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const Hospital = require('./src/models/Hospital');

mongoose.connect('mongodb://localhost:27017/dhrms')
  .then(async () => {
    console.log('Connected to MongoDB');
    
    // Check all RHOs
    const rhos = await RegionalHealthOfficer.find({});
    console.log('\n=== ALL RHOs ===');
    rhos.forEach(rho => {
      console.log(`ID: ${rho._id}, officerId: ${rho.officerId}, name: ${rho.fullName}`);
    });
    
    // Check hospitals with managedBy field
    const hospitals = await Hospital.find({}).populate('managedBy');
    console.log('\n=== HOSPITALS WITH MANAGED_BY ===');
    hospitals.forEach(hospital => {
      console.log(`Hospital: ${hospital.name}`);
      console.log(`  managedBy: ${hospital.managedBy}`);
      console.log(`  managedBy populated: ${hospital.managedBy ? (hospital.managedBy.fullName || 'No name') : 'NULL'}`);
    });
    
    // Check the specific hospital from the database dump
    const specificHospital = await Hospital.findById('68d383575893c3840e68c099').populate('managedBy');
    if (specificHospital) {
      console.log('\n=== SPECIFIC HOSPITAL ===');
      console.log(`Hospital: ${specificHospital.name}`);
      console.log(`managedBy: ${specificHospital.managedBy}`);
      console.log(`managedBy type: ${typeof specificHospital.managedBy}`);
      if (specificHospital.managedBy) {
        console.log(`RHO details: ${JSON.stringify(specificHospital.managedBy, null, 2)}`);
      }
    }
    
    mongoose.disconnect();
  })
  .catch(err => console.error('Error:', err));