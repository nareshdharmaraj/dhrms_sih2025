/**
 * DHRMS Database Creation and Setup Script
 * 
 * This script creates the MongoDB database for DHRMS and sets up all required collections
 * with proper indexes and validation rules.
 * 
 * Usage: node create-database.js
 */

const { MongoClient } = require('mongodb');

// Database configuration
const DB_NAME = 'dhrms_database';
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';

// Collection names
const COLLECTIONS = {
  PATIENTS: 'patients',
  DOCTORS: 'doctors',
  HOSPITALS: 'hospitals',
  APPOINTMENTS: 'appointments',
  MEDICAL_RECORDS: 'medicalrecords',
  PRESCRIPTIONS: 'prescriptions',
  TELEMEDICINE: 'telemedicinesessions',
  WEARABLE_DATA: 'wearabledata',
  ANALYTICS: 'analytics'
};

async function createDatabase() {
  let client;
  
  try {
    console.log('🔗 Connecting to MongoDB...');
    client = new MongoClient(MONGO_URI);
    await client.connect();
    
    const db = client.db(DB_NAME);
    console.log(`📊 Connected to database: ${DB_NAME}`);
    
    // Create collections with validation schemas
    await createCollections(db);
    
    // Create indexes for performance
    await createIndexes(db);
    
    console.log('✅ Database setup completed successfully!');
    
  } catch (error) {
    console.error('❌ Database setup failed:', error);
    throw error;
  } finally {
    if (client) {
      await client.close();
      console.log('🔐 Database connection closed');
    }
  }
}

async function createCollections(db) {
  console.log('📋 Creating collections...');
  
  // Patients Collection
  await createPatientsCollection(db);
  
  // Doctors Collection
  await createDoctorsCollection(db);
  
  // Hospitals Collection
  await createHospitalsCollection(db);
  
  // Appointments Collection
  await createAppointmentsCollection(db);
  
  // Medical Records Collection
  await createMedicalRecordsCollection(db);
  
  // Prescriptions Collection
  await createPrescriptionsCollection(db);
  
  // Telemedicine Sessions Collection
  await createTelemedicineCollection(db);
  
  // Wearable Data Collection
  await createWearableDataCollection(db);
  
  // Analytics Collection
  await createAnalyticsCollection(db);
}

async function createPatientsCollection(db) {
  const collection = COLLECTIONS.PATIENTS;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["patientId", "uhi", "personalInfo", "credentials"],
          properties: {
            patientId: {
              bsonType: "string",
              description: "Unique patient identifier"
            },
            uhi: {
              bsonType: "string", 
              description: "Universal Health Identifier"
            },
            personalInfo: {
              bsonType: "object",
              required: ["firstName", "lastName", "dateOfBirth", "gender", "phone"],
              properties: {
                firstName: { bsonType: "string" },
                lastName: { bsonType: "string" },
                email: { bsonType: "string" },
                phone: { bsonType: "string" },
                dateOfBirth: { bsonType: "date" },
                gender: { 
                  bsonType: "string",
                  enum: ["male", "female", "other"]
                }
              }
            },
            credentials: {
              bsonType: "object",
              required: ["username", "password"],
              properties: {
                username: { bsonType: "string" },
                password: { bsonType: "string" },
                email: { bsonType: "string" }
              }
            }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createDoctorsCollection(db) {
  const collection = COLLECTIONS.DOCTORS;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["doctorId", "personalInfo", "professionalInfo", "credentials"],
          properties: {
            doctorId: {
              bsonType: "string",
              description: "Unique doctor identifier"
            },
            personalInfo: {
              bsonType: "object",
              required: ["firstName", "lastName", "phone"],
              properties: {
                firstName: { bsonType: "string" },
                lastName: { bsonType: "string" },
                email: { bsonType: "string" },
                phone: { bsonType: "string" }
              }
            },
            professionalInfo: {
              bsonType: "object",
              required: ["specialization", "licenseNumber"],
              properties: {
                specialization: { bsonType: "string" },
                qualification: { bsonType: "string" },
                licenseNumber: { bsonType: "string" },
                experience: { bsonType: "number" }
              }
            },
            credentials: {
              bsonType: "object",
              required: ["username", "password"],
              properties: {
                username: { bsonType: "string" },
                password: { bsonType: "string" },
                email: { bsonType: "string" }
              }
            }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createHospitalsCollection(db) {
  const collection = COLLECTIONS.HOSPITALS;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["hospitalId", "name", "type", "contactInfo", "credentials"],
          properties: {
            hospitalId: {
              bsonType: "string",
              description: "Unique hospital identifier"
            },
            name: { bsonType: "string" },
            type: { 
              bsonType: "string",
              enum: ["government", "private", "charitable", "corporate"]
            },
            contactInfo: {
              bsonType: "object",
              required: ["phone", "email"],
              properties: {
                phone: { bsonType: "string" },
                email: { bsonType: "string" },
                website: { bsonType: "string" }
              }
            },
            credentials: {
              bsonType: "object",
              required: ["username", "password"],
              properties: {
                username: { bsonType: "string" },
                password: { bsonType: "string" },
                email: { bsonType: "string" }
              }
            }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createAppointmentsCollection(db) {
  const collection = COLLECTIONS.APPOINTMENTS;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["appointmentId", "patientId", "doctorId", "scheduledDate", "status"],
          properties: {
            appointmentId: { bsonType: "string" },
            patientId: { bsonType: "string" },
            doctorId: { bsonType: "string" },
            hospitalId: { bsonType: "string" },
            scheduledDate: { bsonType: "date" },
            status: {
              bsonType: "string",
              enum: ["scheduled", "confirmed", "in-progress", "completed", "cancelled", "no-show"]
            },
            type: {
              bsonType: "string",
              enum: ["regular", "emergency", "follow-up", "telemedicine"]
            }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createMedicalRecordsCollection(db) {
  const collection = COLLECTIONS.MEDICAL_RECORDS;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["recordId", "patientId", "doctorId", "date", "type"],
          properties: {
            recordId: { bsonType: "string" },
            patientId: { bsonType: "string" },
            doctorId: { bsonType: "string" },
            hospitalId: { bsonType: "string" },
            date: { bsonType: "date" },
            type: {
              bsonType: "string",
              enum: ["consultation", "diagnosis", "treatment", "surgery", "lab-result", "imaging"]
            }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createPrescriptionsCollection(db) {
  const collection = COLLECTIONS.PRESCRIPTIONS;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["prescriptionId", "patientId", "doctorId", "medications", "date"],
          properties: {
            prescriptionId: { bsonType: "string" },
            patientId: { bsonType: "string" },
            doctorId: { bsonType: "string" },
            date: { bsonType: "date" },
            medications: {
              bsonType: "array",
              items: {
                bsonType: "object",
                required: ["name", "dosage", "frequency", "duration"],
                properties: {
                  name: { bsonType: "string" },
                  dosage: { bsonType: "string" },
                  frequency: { bsonType: "string" },
                  duration: { bsonType: "string" }
                }
              }
            }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createTelemedicineCollection(db) {
  const collection = COLLECTIONS.TELEMEDICINE;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["sessionId", "patientId", "doctorId", "scheduledTime", "status"],
          properties: {
            sessionId: { bsonType: "string" },
            patientId: { bsonType: "string" },
            doctorId: { bsonType: "string" },
            scheduledTime: { bsonType: "date" },
            status: {
              bsonType: "string",
              enum: ["scheduled", "active", "completed", "cancelled"]
            },
            platform: {
              bsonType: "string",
              enum: ["zoom", "google-meet", "teams", "custom"]
            }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createWearableDataCollection(db) {
  const collection = COLLECTIONS.WEARABLE_DATA;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["dataId", "patientId", "deviceType", "timestamp", "metrics"],
          properties: {
            dataId: { bsonType: "string" },
            patientId: { bsonType: "string" },
            deviceType: {
              bsonType: "string",
              enum: ["smartwatch", "fitness-tracker", "heart-monitor", "glucose-meter", "blood-pressure-monitor"]
            },
            timestamp: { bsonType: "date" },
            metrics: { bsonType: "object" }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createAnalyticsCollection(db) {
  const collection = COLLECTIONS.ANALYTICS;
  
  try {
    await db.createCollection(collection, {
      validator: {
        $jsonSchema: {
          bsonType: "object",
          required: ["analyticsId", "type", "date", "data"],
          properties: {
            analyticsId: { bsonType: "string" },
            type: {
              bsonType: "string",
              enum: ["patient-trends", "hospital-stats", "doctor-performance", "health-insights"]
            },
            date: { bsonType: "date" },
            data: { bsonType: "object" }
          }
        }
      }
    });
    console.log(`✅ Created collection: ${collection}`);
  } catch (error) {
    if (error.code === 48) {
      console.log(`⚠️  Collection ${collection} already exists`);
    } else {
      throw error;
    }
  }
}

async function createIndexes(db) {
  console.log('🔍 Creating database indexes...');
  
  // Patient indexes
  await db.collection(COLLECTIONS.PATIENTS).createIndex({ "patientId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.PATIENTS).createIndex({ "uhi": 1 }, { unique: true });
  await db.collection(COLLECTIONS.PATIENTS).createIndex({ "credentials.username": 1 }, { unique: true });
  await db.collection(COLLECTIONS.PATIENTS).createIndex({ "credentials.email": 1 });
  await db.collection(COLLECTIONS.PATIENTS).createIndex({ "personalInfo.phone": 1 });
  
  // Doctor indexes
  await db.collection(COLLECTIONS.DOCTORS).createIndex({ "doctorId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.DOCTORS).createIndex({ "credentials.username": 1 }, { unique: true });
  await db.collection(COLLECTIONS.DOCTORS).createIndex({ "professionalInfo.licenseNumber": 1 }, { unique: true });
  await db.collection(COLLECTIONS.DOCTORS).createIndex({ "professionalInfo.specialization": 1 });
  
  // Hospital indexes
  await db.collection(COLLECTIONS.HOSPITALS).createIndex({ "hospitalId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.HOSPITALS).createIndex({ "credentials.username": 1 }, { unique: true });
  await db.collection(COLLECTIONS.HOSPITALS).createIndex({ "name": 1 });
  await db.collection(COLLECTIONS.HOSPITALS).createIndex({ "type": 1 });
  
  // Appointment indexes
  await db.collection(COLLECTIONS.APPOINTMENTS).createIndex({ "appointmentId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.APPOINTMENTS).createIndex({ "patientId": 1 });
  await db.collection(COLLECTIONS.APPOINTMENTS).createIndex({ "doctorId": 1 });
  await db.collection(COLLECTIONS.APPOINTMENTS).createIndex({ "scheduledDate": 1 });
  await db.collection(COLLECTIONS.APPOINTMENTS).createIndex({ "status": 1 });
  
  // Medical Records indexes
  await db.collection(COLLECTIONS.MEDICAL_RECORDS).createIndex({ "recordId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.MEDICAL_RECORDS).createIndex({ "patientId": 1 });
  await db.collection(COLLECTIONS.MEDICAL_RECORDS).createIndex({ "doctorId": 1 });
  await db.collection(COLLECTIONS.MEDICAL_RECORDS).createIndex({ "date": -1 });
  
  // Prescription indexes
  await db.collection(COLLECTIONS.PRESCRIPTIONS).createIndex({ "prescriptionId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.PRESCRIPTIONS).createIndex({ "patientId": 1 });
  await db.collection(COLLECTIONS.PRESCRIPTIONS).createIndex({ "doctorId": 1 });
  await db.collection(COLLECTIONS.PRESCRIPTIONS).createIndex({ "date": -1 });
  
  // Telemedicine indexes
  await db.collection(COLLECTIONS.TELEMEDICINE).createIndex({ "sessionId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.TELEMEDICINE).createIndex({ "patientId": 1 });
  await db.collection(COLLECTIONS.TELEMEDICINE).createIndex({ "doctorId": 1 });
  await db.collection(COLLECTIONS.TELEMEDICINE).createIndex({ "scheduledTime": 1 });
  
  // Wearable Data indexes
  await db.collection(COLLECTIONS.WEARABLE_DATA).createIndex({ "dataId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.WEARABLE_DATA).createIndex({ "patientId": 1 });
  await db.collection(COLLECTIONS.WEARABLE_DATA).createIndex({ "timestamp": -1 });
  await db.collection(COLLECTIONS.WEARABLE_DATA).createIndex({ "deviceType": 1 });
  
  // Analytics indexes
  await db.collection(COLLECTIONS.ANALYTICS).createIndex({ "analyticsId": 1 }, { unique: true });
  await db.collection(COLLECTIONS.ANALYTICS).createIndex({ "type": 1 });
  await db.collection(COLLECTIONS.ANALYTICS).createIndex({ "date": -1 });
  
  console.log('✅ Database indexes created successfully!');
}

// Run the database setup
if (require.main === module) {
  createDatabase()
    .then(() => {
      console.log('🎉 Database setup completed!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('💥 Database setup failed:', error);
      process.exit(1);
    });
}

module.exports = {
  createDatabase,
  COLLECTIONS,
  DB_NAME
};
