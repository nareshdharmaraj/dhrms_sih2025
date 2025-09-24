const mongoose = require('mongoose');
const RegionalHealthOfficer = require('./src/models/RegionalHealthOfficer');
const Hospital = require('./src/models/Hospital');

mongoose.connect('mongodb://localhost:27017/dhrms')
  .then(async () => {
    console.log('Connected to MongoDB');
    
    // Check existing RHOs for Alappuzha
    console.log('\n=== CHECKING EXISTING RHOs ===');
    const allRhos = await RegionalHealthOfficer.find({});
    console.log(`Total RHOs in database: ${allRhos.length}`);
    
    allRhos.forEach((rho, index) => {
      console.log(`${index + 1}. ${rho.fullName} (${rho.officerId}) - ${rho.assignedState}/${rho.assignedDistrict}`);
    });
    
    // Find RHO for Alappuzha specifically
    const alappuzhaRhos = await RegionalHealthOfficer.find({
      assignedDistrict: 'Alappuzha',
      assignedState: 'Kerala'
    });
    
    console.log(`\n=== ALAPPUZHA RHOs ===`);
    if (alappuzhaRhos.length > 0) {
      alappuzhaRhos.forEach(rho => {
        console.log(`✅ Found existing Alappuzha RHO:`);
        console.log(`   ID: ${rho._id}`);
        console.log(`   officerId: ${rho.officerId}`);
        console.log(`   Name: ${rho.fullName}`);
        console.log(`   Email: ${rho.email}`);
        console.log(`   Phone: ${rho.phoneNumber}`);
        console.log(`   Active: ${rho.isActive}`);
      });
      
      // Fix hospital assignment with existing RHO
      const hospital = await Hospital.findById('68d383575893c3840e68c099');
      if (hospital && alappuzhaRhos[0]) {
        console.log(`\n=== FIXING HOSPITAL ASSIGNMENT ===`);
        console.log(`Hospital: ${hospital.name}`);
        console.log(`Current managedBy: ${hospital.managedBy}`);
        
        hospital.managedBy = alappuzhaRhos[0]._id;
        await hospital.save();
        console.log(`✅ Updated hospital to be managed by: ${alappuzhaRhos[0].fullName}`);
        
        // Verify the fix
        const updatedHospital = await Hospital.findById('68d383575893c3840e68c099').populate('managedBy');
        console.log('\n🔍 VERIFICATION:');
        console.log(`  Hospital: ${updatedHospital.name}`);
        console.log(`  ManagedBy ID: ${updatedHospital.managedBy._id}`);
        console.log(`  RHO Name: ${updatedHospital.managedBy.fullName}`);
        console.log(`  RHO officerId: ${updatedHospital.managedBy.officerId}`);
      }
    } else {
      console.log('❌ No existing RHO found for Alappuzha, Kerala');
    }
    
    mongoose.disconnect();
  })
  .catch(err => console.error('Error:', err));