const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');

async function checkRHO() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth');
    
    const rho = await RegionalHealthOfficer.findOne({ officerId: 'RHO_Pathanamthitta_001' });
    
    if (rho) {
      console.log('RHO found:');
      console.log('Officer ID:', rho.officerId);
      console.log('Full Name:', rho.fullName);
      console.log('Email:', rho.email);
      console.log('State:', rho.assignedState);
      console.log('District:', rho.assignedDistrict);
      console.log('Is Active:', rho.isActive);
      console.log('Password Hash Length:', rho.password?.length);
      console.log('Permissions:', JSON.stringify(rho.permissions, null, 2));
      console.log('Statistics:', JSON.stringify(rho.statistics, null, 2));
    } else {
      console.log('RHO not found');
    }
    
    await mongoose.disconnect();
  } catch (error) {
    console.error('Error:', error);
  }
}

checkRHO();