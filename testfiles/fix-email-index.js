const mongoose = require('mongoose');

async function fixEmailIndex() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/myhealth');
    console.log('✅ Connected to MongoDB');

    const db = mongoose.connection.db;
    const collection = db.collection('patients');

    // Get existing indexes
    const indexes = await collection.indexes();
    console.log('Current indexes:', indexes);

    // Check if email index exists
    const emailIndexExists = indexes.some(index => 
      index.key && index.key.email === 1
    );

    if (emailIndexExists) {
      console.log('📋 Dropping existing email index...');
      await collection.dropIndex('email_1');
      console.log('✅ Email index dropped');
    }

    // Create new sparse index for email
    console.log('📋 Creating new sparse email index...');
    await collection.createIndex(
      { email: 1 }, 
      { 
        unique: true, 
        sparse: true,
        name: 'email_1_sparse'
      }
    );
    console.log('✅ New sparse email index created');

    // Update any existing records with email: null to remove the email field
    console.log('📋 Cleaning up existing null email records...');
    const result = await collection.updateMany(
      { email: null },
      { $unset: { email: "" } }
    );
    console.log(`✅ Updated ${result.modifiedCount} records`);

    console.log('🎉 Email index fix completed successfully!');

  } catch (error) {
    console.error('❌ Error fixing email index:', error);
  } finally {
    await mongoose.disconnect();
    console.log('📋 Disconnected from MongoDB');
  }
}

// Run the fix
fixEmailIndex();
