const mongoose = require('mongoose');
const Hospital = require('./src/models/Hospital');
require('dotenv').config();

mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth')
.then(async () => {
  console.log('Connected to database');
  
  // Update the existing hospital with proper fields
  const updatedHospital = await Hospital.findOneAndUpdate(
    { hospitalId: 'HOSP-001' },
    {
      $set: {
        name: 'Apollo Main Hospital',
        hospitalName: 'Apollo Main Hospital', // Add this for frontend compatibility
        location: {
          address: '123 Health Street',
          city: 'Bangalore',
          state: 'Karnataka',
          district: 'Bangalore Urban',
          pincode: '560001'
        },
        contactInfo: {
          phone: '080-12345678',
          email: 'info@apollo-main.com',
          website: 'www.apollo-main.com'
        },
        hospitalType: 'multi_specialty',
        facilities: ['emergency', 'icu', 'cardiology', 'orthopedics', 'neurology'],
        isActive: true,
        status: 'active'
      }
    },
    { new: true, upsert: false }
  );
  
  if (updatedHospital) {
    console.log('✅ Hospital updated successfully:', updatedHospital.name);
    console.log('Hospital ID:', updatedHospital.hospitalId);
  } else {
    console.log('❌ Hospital not found');
  }
  
  process.exit(0);
})
.catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});