const mongoose = require('mongoose');
const Hospital = require('./src/models/Hospital');
require('dotenv').config();

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth')
.then(async () => {
  console.log('Connected to database');
  
  // Add hospitalName field as alias for name
  const updatedHospital = await Hospital.findOneAndUpdate(
    { hospitalId: 'HOSP-001' },
    {
      $set: {
        hospitalName: 'Apollo Main Hospital' // Add this field explicitly
      }
    },
    { new: true }
  );
  
  console.log('✅ Added hospitalName field');
  console.log('Hospital name:', updatedHospital.name);
  console.log('Hospital hospitalName:', updatedHospital.hospitalName);
  
  process.exit(0);
})
.catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});