const mongoose = require('mongoose');
const Hospital = require('./src/models/Hospital');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

// Use the MongoDB Atlas URI from environment
const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0';

mongoose.connect(mongoUri)
  .then(async () => {
    console.log('Connected to MongoDB Atlas');
    
    console.log('\n=== TESTING HOSPITAL POPULATION ===');
    
    // First, get hospitals without population
    const hospitalsRaw = await Hospital.find({});
    console.log(`Found ${hospitalsRaw.length} hospitals (raw):`);
    
    hospitalsRaw.forEach((hospital, index) => {
      console.log(`${index + 1}. ${hospital.name}`);
      console.log(`   managedBy (raw): ${hospital.managedBy}`);
      console.log(`   managedBy type: ${typeof hospital.managedBy}`);
    });
    
    console.log('\n=== TESTING POPULATION ===');
    
    // Test population
    try {
      const hospitalsPopulated = await Hospital.find({})
        .populate('managedBy', 'officerId fullName email phoneNumber assignedDistrict assignedState');
      
      console.log(`Successfully populated ${hospitalsPopulated.length} hospitals:`);
      
      hospitalsPopulated.forEach((hospital, index) => {
        console.log(`\n${index + 1}. ${hospital.name} (${hospital.hospitalId})`);
        console.log(`   managedBy populated: ${hospital.managedBy ? 'YES' : 'NO'}`);
        
        if (hospital.managedBy) {
          console.log(`   RHO Details:`);
          console.log(`     officerId: ${hospital.managedBy.officerId}`);
          console.log(`     fullName: ${hospital.managedBy.fullName}`);
          console.log(`     assignedDistrict: ${hospital.managedBy.assignedDistrict}`);
          console.log(`     assignedState: ${hospital.managedBy.assignedState}`);
        } else {
          console.log(`   ❌ managedBy is null - population failed`);
        }
        
        // Show location for comparison
        if (hospital.location) {
          console.log(`   Hospital Location: ${hospital.location.district}, ${hospital.location.state}`);
        }
        if (hospital.region) {
          console.log(`   Hospital Region: ${hospital.region.district}, ${hospital.region.state}`);
        }
        
        // Show approval status
        if (hospital.approval) {
          console.log(`   Approval Status: ${hospital.approval.status}`);
        }
      });
      
    } catch (populateError) {
      console.error('❌ Population failed:', populateError.message);
    }
    
    mongoose.disconnect();
  })
  .catch(err => console.error('Error:', err));