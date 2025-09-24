const mongoose = require('mongoose');
const Hospital = require('./src/models/Hospital');

mongoose.connect('mongodb://localhost:27017/dhrms')
  .then(async () => {
    console.log('Connected to MongoDB');
    
    // Check the specific hospital structure
    const hospitals = await Hospital.find({}).populate('managedBy');
    
    console.log('\n=== HOSPITAL DATA STRUCTURE ===');
    hospitals.forEach((hospital, index) => {
      console.log(`\n${index + 1}. Hospital: ${hospital.name}`);
      console.log(`   hospitalId: ${hospital.hospitalId}`);
      
      // Check address/location field
      console.log('   ADDRESS/LOCATION:');
      if (hospital.address) {
        console.log(`     address.district: ${hospital.address.district}`);
        console.log(`     address.state: ${hospital.address.state}`);
      }
      if (hospital.location) {
        console.log(`     location.district: ${hospital.location.district}`);  
        console.log(`     location.state: ${hospital.location.state}`);
      }
      if (hospital.region) {
        console.log(`     region.district: ${hospital.region.district}`);
        console.log(`     region.state: ${hospital.region.state}`);
      }
      
      // Check approval status
      console.log('   APPROVAL:');
      if (hospital.approval) {
        console.log(`     approval.status: ${hospital.approval.status}`);
        console.log(`     approval.submittedAt: ${hospital.approval.submittedAt}`);
      }
      
      // Check RHO assignment
      console.log('   RHO ASSIGNMENT:');
      console.log(`     managedBy: ${hospital.managedBy}`);
      if (hospital.managedBy && hospital.managedBy.officerId) {
        console.log(`     RHO officerId: ${hospital.managedBy.officerId}`);
        console.log(`     RHO name: ${hospital.managedBy.fullName}`);
        console.log(`     RHO district: ${hospital.managedBy.assignedDistrict}`);
        console.log(`     RHO state: ${hospital.managedBy.assignedState}`);
      }
    });
    
    mongoose.disconnect();
  })
  .catch(err => console.error('Error:', err));