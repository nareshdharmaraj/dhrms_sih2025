const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function listRHOs() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth');
    
    const rhos = await RegionalHealthOfficer.find({}).select('officerId fullName assignedState assignedDistrict');
    
    console.log('Found RHOs:');
    rhos.forEach(rho => {
      console.log(`- ${rho.officerId}: ${rho.fullName} (${rho.assignedState}, ${rho.assignedDistrict})`);
    });
    
    if (rhos.length === 0) {
      console.log('No RHO records found in database');
    }
    
    await mongoose.disconnect();
  } catch (error) {
    console.error('Error:', error);
  }
}

listRHOs();