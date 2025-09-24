const mongoose = require('mongoose');

async function verifyCleanup() {
  try {
    await mongoose.connect('mongodb://localhost:27017/dhrms_db');
    console.log('✅ Connected to MongoDB');
    
    // List all collections
    const collections = await mongoose.connection.db.listCollections().toArray();
    const collectionNames = collections.map(c => c.name);
    
    console.log('📋 Available collections:', collectionNames.join(', '));
    
    // Check if old appointments collection exists
    if (collectionNames.includes('appointments')) {
      console.log('⚠️ OLD "appointments" collection still exists');
    } else {
      console.log('✅ OLD "appointments" collection successfully removed');
    }
    
    // Check if new hospitalappointments collection exists
    if (collectionNames.includes('hospitalappointments')) {
      console.log('✅ NEW "hospitalappointments" collection exists');
      
      // Count documents in new collection
      const HospitalAppointment = require('./src/models/HospitalAppointment');
      const count = await HospitalAppointment.countDocuments();
      console.log('📊 HospitalAppointment documents:', count);
    } else {
      console.log('❌ NEW "hospitalappointments" collection not found');
    }
    
    await mongoose.disconnect();
    console.log('✅ Cleanup verification completed successfully');
    
  } catch (error) {
    console.error('❌ Error during verification:', error.message);
  }
}

verifyCleanup();