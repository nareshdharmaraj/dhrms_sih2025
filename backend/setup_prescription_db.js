const mongoose = require('mongoose');
require('dotenv').config();

// Import the HospitalPrescription model
const HospitalPrescription = require('./src/models/HospitalPrescription');

async function setupPrescriptionDatabase() {
  try {
    console.log('🔄 Connecting to MongoDB...');
    
    // Connect to MongoDB
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms_db';
    await mongoose.connect(mongoUri);
    
    console.log('✅ Connected to MongoDB successfully');
    
    // Check if HospitalPrescription collection exists
    const collections = await mongoose.connection.db.listCollections().toArray();
    const prescriptionCollectionExists = collections.some(col => col.name === 'hospitalprescriptions');
    
    if (prescriptionCollectionExists) {
      console.log('✅ HospitalPrescription collection already exists');
    } else {
      console.log('🔄 Creating HospitalPrescription collection...');
      
      // Create a sample document to initialize the collection and indexes
      const samplePrescription = new HospitalPrescription({
        appointmentId: new mongoose.Types.ObjectId(),
        doctorId: new mongoose.Types.ObjectId(),
        patientId: new mongoose.Types.ObjectId(),
        hospitalId: new mongoose.Types.ObjectId(),
        patientName: 'Sample Patient',
        patientUHID: 'UHID-SAMPLE-001',
        doctorName: 'Dr. Sample',
        doctorId: 'DOC-SAMPLE-001',
        hospitalName: 'Sample Hospital',
        hospitalAddress: 'Sample Address',
        hospitalContact: {
          phone: '1234567890',
          email: 'sample@hospital.com'
        },
        appointmentNumber: 'APT-SAMPLE-001',
        diseaseName: 'Sample Disease',
        diseaseType: 'not_communicable',
        medicines: [{
          type: 'tablet',
          name: 'Sample Medicine',
          power: '500mg',
          countPerDose: 1,
          timing: ['morning'],
          beforeAfterFood: 'after',
          duration: 7,
          totalCount: 7
        }],
        isConfirmed: true,
        confirmedAt: new Date()
      });

      // Save the sample document
      await samplePrescription.save();
      console.log('✅ HospitalPrescription collection created with sample data');
      
      // Delete the sample document
      await HospitalPrescription.findByIdAndDelete(samplePrescription._id);
      console.log('✅ Sample data cleaned up');
    }
    
    // Ensure indexes are created
    await HospitalPrescription.createIndexes();
    console.log('✅ Database indexes created successfully');
    
    console.log('\n🎉 Database setup completed successfully!');
    console.log('📋 Collections available:');
    
    const finalCollections = await mongoose.connection.db.listCollections().toArray();
    finalCollections.forEach(col => {
      console.log(`  - ${col.name}`);
    });
    
  } catch (error) {
    console.error('❌ Error setting up database:', error);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
}

// Run the setup
setupPrescriptionDatabase();