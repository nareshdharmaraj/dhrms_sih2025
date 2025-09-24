const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const Hospital = require('./src/models/Hospital');

// Use the MongoDB Atlas URI from environment
const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0';

mongoose.connect(mongoUri)
  .then(async () => {
    console.log('Connected to MongoDB Atlas (myhealth database)');
    
    // Check RHOs using proper model
    console.log('\n=== CHECKING RHOs ===');
    const rhos = await RegionalHealthOfficer.find({});
    console.log(`Found ${rhos.length} RHOs in database:`);
    
    rhos.forEach(rho => {
      console.log(`✅ RHO: ${rho.fullName} (${rho.officerId})`);
      console.log(`   Assigned: ${rho.assignedState}/${rho.assignedDistrict}`);
      console.log(`   ID: ${rho._id}`);
      console.log(`   Active: ${rho.isActive}`);
    });
    
    // Find Alappuzha RHO specifically
    console.log('\n=== ALAPPUZHA RHO ===');
    const alappuzhaRho = await RegionalHealthOfficer.findOne({
      assignedDistrict: 'Alappuzha',
      assignedState: 'Kerala'
    });
    
    if (alappuzhaRho) {
      console.log(`✅ Found Alappuzha RHO: ${alappuzhaRho.fullName}`);
      console.log(`   officerId: ${alappuzhaRho.officerId}`);
      console.log(`   _id: ${alappuzhaRho._id}`);
      
      // Check if any hospitals are managed by this RHO
      console.log('\n=== HOSPITALS MANAGED BY ALAPPUZHA RHO ===');
      const managedHospitals = await Hospital.find({ managedBy: alappuzhaRho._id });
      console.log(`Found ${managedHospitals.length} hospitals managed by this RHO:`);
      
      managedHospitals.forEach(hospital => {
        console.log(`  📋 ${hospital.name} (${hospital.hospitalId})`);
        console.log(`     Status: ${hospital.approval?.status}`);
        console.log(`     Location: ${hospital.location?.district}, ${hospital.location?.state}`);
      });
      
      // Check all hospitals in Alappuzha district
      console.log('\n=== ALL HOSPITALS IN ALAPPUZHA ===');
      const alappuzhaHospitals = await Hospital.find({
        $or: [
          { 'location.district': 'Alappuzha' },
          { 'region.district': 'Alappuzha' }
        ]
      }).populate('managedBy');
      
      console.log(`Found ${alappuzhaHospitals.length} hospitals in Alappuzha:`);
      alappuzhaHospitals.forEach(hospital => {
        console.log(`  🏥 ${hospital.name}`);
        console.log(`     Status: ${hospital.approval?.status}`);
        console.log(`     ManagedBy: ${hospital.managedBy ? hospital.managedBy.fullName : 'NULL'}`);
      });
    } else {
      console.log('❌ No Alappuzha RHO found!');
    }
    
    mongoose.disconnect();
  })
  .catch(err => console.error('Error:', err));