/**
 * Load Sample Data into DHRMS Database
 * 
 * This script loads all sample data (patients, doctors, hospitals) into the database
 * 
 * Usage: node load-sample-data.js
 */

const { MongoClient } = require('mongodb');
const samplePatients = require('./sample-patients');
const sampleDoctors = require('./sample-doctors');
const sampleHospitals = require('./sample-hospitals');

// Database configuration
const DB_NAME = 'dhrms_database';
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';

// Collection names
const COLLECTIONS = {
  PATIENTS: 'patients',
  DOCTORS: 'doctors',
  HOSPITALS: 'hospitals'
};

async function loadSampleData() {
  let client;
  
  try {
    console.log('🔗 Connecting to MongoDB...');
    client = new MongoClient(MONGO_URI);
    await client.connect();
    
    const db = client.db(DB_NAME);
    console.log(`📊 Connected to database: ${DB_NAME}`);
    
    // Clear existing data (optional - comment out in production)
    console.log('🗑️  Clearing existing sample data...');
    await clearExistingData(db);
    
    // Load sample data
    await loadPatients(db);
    await loadDoctors(db);
    await loadHospitals(db);
    
    console.log('✅ Sample data loaded successfully!');
    
  } catch (error) {
    console.error('❌ Sample data loading failed:', error);
    throw error;
  } finally {
    if (client) {
      await client.close();
      console.log('🔐 Database connection closed');
    }
  }
}

async function clearExistingData(db) {
  try {
    // Only clear sample data by checking specific IDs
    await db.collection(COLLECTIONS.PATIENTS).deleteMany({ 
      patientId: { $in: ['PAT001', 'PAT002', 'PAT003'] } 
    });
    await db.collection(COLLECTIONS.DOCTORS).deleteMany({ 
      doctorId: { $in: ['DOC001', 'DOC002', 'DOC003'] } 
    });
    await db.collection(COLLECTIONS.HOSPITALS).deleteMany({ 
      hospitalId: { $in: ['HOSP001', 'HOSP002', 'HOSP003'] } 
    });
    console.log('✅ Existing sample data cleared');
  } catch (error) {
    console.log('⚠️  No existing sample data to clear');
  }
}

async function loadPatients(db) {
  try {
    console.log('👥 Loading sample patients...');
    const result = await db.collection(COLLECTIONS.PATIENTS).insertMany(samplePatients);
    console.log(`✅ Inserted ${result.insertedCount} patients`);
    
    // Log patient details
    samplePatients.forEach(patient => {
      console.log(`   📋 ${patient.personalInfo.firstName} ${patient.personalInfo.lastName} (${patient.patientId})`);
    });
    
  } catch (error) {
    if (error.code === 11000) {
      console.log('⚠️  Some patients already exist (duplicate key error)');
    } else {
      throw error;
    }
  }
}

async function loadDoctors(db) {
  try {
    console.log('👨‍⚕️ Loading sample doctors...');
    const result = await db.collection(COLLECTIONS.DOCTORS).insertMany(sampleDoctors);
    console.log(`✅ Inserted ${result.insertedCount} doctors`);
    
    // Log doctor details
    sampleDoctors.forEach(doctor => {
      console.log(`   🩺 ${doctor.personalInfo.firstName} ${doctor.personalInfo.lastName} - ${doctor.professionalInfo.specialization} (${doctor.doctorId})`);
    });
    
  } catch (error) {
    if (error.code === 11000) {
      console.log('⚠️  Some doctors already exist (duplicate key error)');
    } else {
      throw error;
    }
  }
}

async function loadHospitals(db) {
  try {
    console.log('🏥 Loading sample hospitals...');
    const result = await db.collection(COLLECTIONS.HOSPITALS).insertMany(sampleHospitals);
    console.log(`✅ Inserted ${result.insertedCount} hospitals`);
    
    // Log hospital details
    sampleHospitals.forEach(hospital => {
      console.log(`   🏥 ${hospital.name} - ${hospital.type} (${hospital.hospitalId})`);
    });
    
  } catch (error) {
    if (error.code === 11000) {
      console.log('⚠️  Some hospitals already exist (duplicate key error)');
    } else {
      throw error;
    }
  }
}

async function generateAppointments(db) {
  try {
    console.log('📅 Generating sample appointments...');
    
    const appointments = [
      {
        appointmentId: "APT001",
        patientId: "PAT001",
        doctorId: "DOC001",
        hospitalId: "HOSP001",
        scheduledDate: new Date("2023-09-15T10:00:00Z"),
        status: "confirmed",
        type: "regular",
        reason: "Routine checkup for hypertension",
        notes: "Follow-up appointment",
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        appointmentId: "APT002",
        patientId: "PAT002",
        doctorId: "DOC002",
        hospitalId: "HOSP003",
        scheduledDate: new Date("2023-09-20T14:30:00Z"),
        status: "scheduled",
        type: "regular",
        reason: "Annual gynecological checkup",
        notes: "First visit to this hospital",
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        appointmentId: "APT003",
        patientId: "PAT003",
        doctorId: "DOC003",
        hospitalId: "HOSP004",
        scheduledDate: new Date("2023-09-18T16:00:00Z"),
        status: "completed",
        type: "follow-up",
        reason: "Post-surgery follow-up",
        notes: "Knee surgery recovery check",
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
    
    const result = await db.collection('appointments').insertMany(appointments);
    console.log(`✅ Inserted ${result.insertedCount} appointments`);
    
  } catch (error) {
    if (error.code === 11000) {
      console.log('⚠️  Some appointments already exist');
    } else {
      console.error('❌ Error creating appointments:', error);
    }
  }
}

async function generateMedicalRecords(db) {
  try {
    console.log('📋 Generating sample medical records...');
    
    const medicalRecords = [
      {
        recordId: "MR001",
        patientId: "PAT001",
        doctorId: "DOC001",
        hospitalId: "HOSP001",
        date: new Date("2023-09-01"),
        type: "consultation",
        diagnosis: "Hypertension Stage 1",
        symptoms: ["Headache", "Dizziness"],
        treatment: "Prescribed Amlodipine 5mg",
        followUpRequired: true,
        followUpDate: new Date("2023-10-01"),
        notes: "Patient responding well to medication",
        vitals: {
          bloodPressure: "140/90",
          heartRate: 78,
          temperature: 98.6,
          weight: 75
        },
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        recordId: "MR002",
        patientId: "PAT002",
        doctorId: "DOC002",
        hospitalId: "HOSP003",
        date: new Date("2023-08-15"),
        type: "diagnosis",
        diagnosis: "Normal prenatal checkup",
        symptoms: [],
        treatment: "Prenatal vitamins prescribed",
        followUpRequired: true,
        followUpDate: new Date("2023-09-15"),
        notes: "Pregnancy progressing normally",
        vitals: {
          bloodPressure: "120/80",
          heartRate: 72,
          temperature: 98.4,
          weight: 58
        },
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ];
    
    const result = await db.collection('medicalrecords').insertMany(medicalRecords);
    console.log(`✅ Inserted ${result.insertedCount} medical records`);
    
  } catch (error) {
    if (error.code === 11000) {
      console.log('⚠️  Some medical records already exist');
    } else {
      console.error('❌ Error creating medical records:', error);
    }
  }
}

// Run the sample data loading
if (require.main === module) {
  loadSampleData()
    .then(async () => {
      // Also generate related data
      const client = new MongoClient(MONGO_URI);
      await client.connect();
      const db = client.db(DB_NAME);
      
      await generateAppointments(db);
      await generateMedicalRecords(db);
      
      await client.close();
      
      console.log('🎉 All sample data loaded successfully!');
      console.log('\n📊 Summary:');
      console.log('   👥 Patients: 3');
      console.log('   👨‍⚕️ Doctors: 3');  
      console.log('   🏥 Hospitals: 3');
      console.log('   📅 Appointments: 3');
      console.log('   📋 Medical Records: 2');
      console.log('\n🔑 Test Credentials:');
      console.log('   Patient: rajesh_kumar_90 / patient123');
      console.log('   Doctor: dr_rajesh_patel / doctor123');
      console.log('   Hospital: aiims_delhi / hospital123');
      
      process.exit(0);
    })
    .catch((error) => {
      console.error('💥 Sample data loading failed:', error);
      process.exit(1);
    });
}

module.exports = {
  loadSampleData,
  clearExistingData
};
