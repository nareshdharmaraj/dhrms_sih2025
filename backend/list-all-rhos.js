const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB and list all RHOs
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth')
  .then(() => {
    console.log('✅ Connected to MongoDB');
    listAllRHOs();
  })
  .catch(error => {
    console.error('❌ MongoDB connection error:', error);
  });

async function listAllRHOs() {
  try {
    const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
    const StateHealthOfficer = require('./src/models/StateHealthOfficer');
    
    // Find all RHOs
    const rhos = await RegionalHealthOfficer.find({})
      .select('officerId fullName email assignedDistrict assignedState createdAt isActive parentSHO')
      .populate('parentSHO', 'fullName officerId')
      .sort({ createdAt: -1 });
    
    console.log(`📋 Total RHOs in database: ${rhos.length}`);
    console.log('\n📋 All RHOs:');
    
    rhos.forEach((rho, index) => {
      console.log(`\n${index + 1}. ${rho.officerId}`);
      console.log(`   Name: ${rho.fullName}`);
      console.log(`   Email: ${rho.email}`);
      console.log(`   District: ${rho.assignedDistrict}`);
      console.log(`   State: ${rho.assignedState}`);
      console.log(`   Active: ${rho.isActive}`);
      console.log(`   Created: ${rho.createdAt}`);
      console.log(`   Parent SHO: ${rho.parentSHO?.fullName} (${rho.parentSHO?.officerId})`);
    });
    
    // Find the SHO to see what their ID is
    const sho = await StateHealthOfficer.findOne({ email: 'sho.tn@myhealth.gov.in' });
    console.log(`\n🔍 Current SHO ID: ${sho?._id}`);
    console.log(`🔍 RHOs belonging to this SHO: ${rhos.filter(rho => rho.parentSHO?._id?.toString() === sho?._id?.toString()).length}`);
    
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}