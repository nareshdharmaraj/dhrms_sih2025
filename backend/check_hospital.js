const mongoose = require('mongoose');
const Hospital = require('./src/models/Hospital');
require('dotenv').config();

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth')
.then(async () => {
  console.log('Connected to database');
  
  // Check current hospital data
  const hospital = await Hospital.findOne({ hospitalId: 'HOSP-001' });
  console.log('Current hospital data:', JSON.stringify(hospital, null, 2));
  
  process.exit(0);
})
.catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});