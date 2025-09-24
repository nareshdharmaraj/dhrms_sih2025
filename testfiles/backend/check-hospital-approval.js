const mongoose = require('mongoose');
const Hospital = require('./src/models/Hospital');

// Use the MongoDB Atlas URI from environment
const mongoUri = process.env.MONGODB_URI || 'mongodb+srv://saravana:saravana100@cluster0.52eru2s.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0';

mongoose.connect(mongoUri)
  .then(async () => {
    console.log('Connected to MongoDB Atlas');
    
    console.log('\n=== CHECKING HOSPITAL APPROVAL STATUS ===');
    
    // Get the Government Hospital specifically
    const govHospital = await Hospital.findOne({ 
      hospitalId: 'HOSP_KE_1758692183440' 
    }).populate('managedBy');
    
    if (govHospital) {
      console.log('✅ Found Government Hospital:');
      console.log(`   Name: ${govHospital.name}`);
      console.log(`   Hospital ID: ${govHospital.hospitalId}`);
      console.log(`   ManagedBy: ${govHospital.managedBy ? govHospital.managedBy.officerId : 'NULL'}`);
      
      console.log('\n--- APPROVAL OBJECT ---');
      console.log('Raw approval object:', JSON.stringify(govHospital.approval, null, 2));
      
      if (govHospital.approval) {
        console.log('Approval exists:');
        console.log(`   status: "${govHospital.approval.status}"`);
        console.log(`   status type: ${typeof govHospital.approval.status}`);
        console.log(`   submittedAt: ${govHospital.approval.submittedAt}`);
      } else {
        console.log('❌ No approval object found!');
      }
      
      console.log('\n--- LOCATION OBJECT ---');
      if (govHospital.location) {
        console.log('Location:', JSON.stringify(govHospital.location, null, 2));
      }
      if (govHospital.region) {
        console.log('Region:', JSON.stringify(govHospital.region, null, 2));
      }
      
      console.log('\n--- FULL HOSPITAL DOCUMENT (key fields) ---');
      console.log('Hospital document keys:', Object.keys(govHospital.toObject()));
      
    } else {
      console.log('❌ Government Hospital not found!');
    }
    
    mongoose.disconnect();
  })
  .catch(err => console.error('Error:', err));