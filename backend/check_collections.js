const mongoose = require('mongoose');
require('dotenv').config();

async function checkCollections() {
  try {
    console.log('🔄 Connecting to MongoDB...');
    
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms_db';
    await mongoose.connect(mongoUri);
    
    console.log('✅ Connected to MongoDB successfully');
    console.log('Database name:', mongoose.connection.db.databaseName);
    
    // List all collections
    console.log('\n📊 All collections in database:');
    const collections = await mongoose.connection.db.listCollections().toArray();
    collections.forEach(col => {
      console.log(`  - ${col.name}`);
    });
    
    // Check if hospitalprescriptions collection exists
    const prescriptionCollectionExists = collections.some(col => col.name === 'hospitalprescriptions');
    console.log(`\n💊 hospitalprescriptions collection exists: ${prescriptionCollectionExists}`);
    
    // If it exists, check how many documents are in it
    if (prescriptionCollectionExists) {
      const count = await mongoose.connection.db.collection('hospitalprescriptions').countDocuments();
      console.log(`📋 Number of documents in hospitalprescriptions: ${count}`);
      
      // Show a sample document if any exist
      if (count > 0) {
        const sample = await mongoose.connection.db.collection('hospitalprescriptions').findOne();
        console.log('📄 Sample document structure:');
        console.log(JSON.stringify(sample, null, 2));
      }
    }
    
    // Also check appointments collection for reference
    const appointmentCollectionExists = collections.some(col => col.name === 'hospitalappointments');
    console.log(`\n📅 hospitalappointments collection exists: ${appointmentCollectionExists}`);
    
    if (appointmentCollectionExists) {
      const appointmentCount = await mongoose.connection.db.collection('hospitalappointments').countDocuments();
      console.log(`📋 Number of documents in hospitalappointments: ${appointmentCount}`);
      
      // Show confirmed appointments
      const confirmedAppointments = await mongoose.connection.db.collection('hospitalappointments').find({ status: 'confirmed' }).limit(3).toArray();
      console.log(`✅ Confirmed appointments found: ${confirmedAppointments.length}`);
      
      if (confirmedAppointments.length > 0) {
        console.log('📄 Sample confirmed appointment:');
        const sample = confirmedAppointments[0];
        console.log({
          _id: sample._id,
          appointmentNumber: sample.appointmentNumber,
          patientName: sample.patientName,
          patientUhid: sample.patientUhid,
          doctorId: sample.doctorId,
          status: sample.status,
          patientId: sample.patientId
        });
      }
    }
    
  } catch (error) {
    console.error('❌ Error checking collections:', error);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
}

// Run the check
checkCollections();