const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017')
  .then(async () => {
    console.log('Connected to MongoDB');
    const admin = mongoose.connection.db.admin();
    const dbs = await admin.listDatabases();
    console.log('Available databases:');
    dbs.databases.forEach(db => {
      console.log(`- ${db.name} (size: ${db.sizeOnDisk})`);
    });
    mongoose.disconnect();
  })
  .catch(err => console.error('Error:', err));