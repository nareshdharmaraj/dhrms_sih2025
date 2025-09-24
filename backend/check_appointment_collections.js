const mongoose = require('mongoose');

async function checkCollections() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');

    // Get database
    const db = mongoose.connection.db;
    
    // List all collections
    const collections = await db.listCollections().toArray();
    console.log('\n📋 All collections in database:');
    collections.forEach(collection => {
      console.log(`- ${collection.name}`);
    });

    // Check appointment-related collections
    const appointmentCollections = collections.filter(c => 
      c.name.toLowerCase().includes('appointment')
    );
    
    console.log('\n📅 Appointment-related collections:');
    appointmentCollections.forEach(collection => {
      console.log(`- ${collection.name}`);
    });

    // Check documents in each appointment collection
    for (const collection of appointmentCollections) {
      const count = await db.collection(collection.name).countDocuments();
      console.log(`\n📊 Collection '${collection.name}' has ${count} documents`);
      
      if (count > 0) {
        const sample = await db.collection(collection.name).findOne();
        console.log('Sample document structure:');
        console.log(Object.keys(sample));
      }
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkCollections();