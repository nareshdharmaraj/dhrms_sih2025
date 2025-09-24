const mongoose = require('mongoose');
require('dotenv').config();

const DB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth';

async function testPrescriptionCreationWithRealData() {
    try {
        console.log('\n🧪 TESTING PRESCRIPTION CREATION WITH REAL FRONTEND DATA');
        console.log('=' .repeat(70));
        
        await mongoose.connect(DB_URI);
        console.log('✅ Connected to MongoDB:', DB_URI);
        
        // This is the exact data structure from the frontend request
        const realFrontendData = {
            "appointmentId": "68d29fdc8cd6da1fca2c18d0",
            "doctorId": "68cfb6f6fd481e8dcf67744c",
            "patientId": "NARE523407",
            "hospitalId": "HOSP-001",
            "patientName": "NARESHD NARESHD",
            "patientUHID": "NARE523407",
            "doctorName": "Dr. A John Smith",
            "doctorIdentifier": "DOC-001",
            "hospitalName": "Apollo Main Hospital",
            "hospitalAddress": "",
            "hospitalContact": {
                "phone": "",
                "email": ""
            },
            "appointmentNumber": "APT-12345", // Adding this as it was missing
            "diseaseName": "malarial disease",
            "diseaseType": "communicable",
            "expectedRecoveryDays": 7,
            "medicines": [
                {
                    "type": "tablet",
                    "name": "dolo",
                    "power": "650",
                    "countPerDose": 1,
                    "timing": [
                        "morning",
                        "night"
                    ],
                    "beforeAfterFood": "after",
                    "duration": 7,
                    "totalCount": 14
                },
                {
                    "type": "injection",
                    "name": "anti malarial",
                    "dosageDetails": "5 ml",
                    "frequency": "1",
                    "additionalNotes": "saves from spreading"
                }
            ],
            "nextVisitDate": "2025-09-30T00:00:00.000",
            "nextVisitMandatory": true,
            "isConfirmed": true
        };
        
        console.log('\n📋 Frontend Data Structure:');
        console.log(JSON.stringify(realFrontendData, null, 2));
        
        // Test 1: Direct Database Insertion
        console.log('\n🔵 TEST 1: DIRECT DATABASE INSERTION');
        console.log('=' .repeat(50));
        
        const prescriptionsCollection = mongoose.connection.db.collection('hospitalprescriptions');
        
        // Add timestamp and format for database
        const dbPrescriptionData = {
            ...realFrontendData,
            createdAt: new Date(),
            updatedAt: new Date()
        };
        
        try {
            const insertResult = await prescriptionsCollection.insertOne(dbPrescriptionData);
            console.log('✅ Direct database insertion successful!');
            console.log('📄 Inserted document ID:', insertResult.insertedId);
            
            // Verify the insertion
            const insertedDoc = await prescriptionsCollection.findOne({_id: insertResult.insertedId});
            console.log('✅ Verification: Document found in database');
            console.log('📋 Patient Name:', insertedDoc.patientName);
            console.log('📋 Doctor Name:', insertedDoc.doctorName);
            console.log('📋 Medicines Count:', insertedDoc.medicines.length);
            
        } catch (directInsertError) {
            console.error('❌ Direct database insertion failed:', directInsertError);
        }
        
        // Test 2: Using Mongoose Schema
        console.log('\n🔵 TEST 2: USING MONGOOSE SCHEMA');
        console.log('=' .repeat(50));
        
        // Import the HospitalPrescription model
        const HospitalPrescription = require('./src/models/HospitalPrescription');
        
        try {
            const newPrescription = new HospitalPrescription(realFrontendData);
            const savedPrescription = await newPrescription.save();
            
            console.log('✅ Mongoose schema save successful!');
            console.log('📄 Saved document ID:', savedPrescription._id);
            console.log('📋 Patient Name:', savedPrescription.patientName);
            console.log('📋 Doctor Name:', savedPrescription.doctorName);
            console.log('📋 Medicines Count:', savedPrescription.medicines.length);
            
        } catch (mongooseError) {
            console.error('❌ Mongoose schema save failed:', mongooseError);
            console.error('🔍 Error details:', mongooseError.message);
            if (mongooseError.errors) {
                console.error('🔍 Validation errors:', mongooseError.errors);
            }
        }
        
        // Test 3: Check final database state
        console.log('\n🔵 TEST 3: FINAL DATABASE STATE');
        console.log('=' .repeat(50));
        
        const allPrescriptions = await prescriptionsCollection.find({}).toArray();
        console.log(`📊 Total prescriptions in database: ${allPrescriptions.length}`);
        
        allPrescriptions.forEach((prescription, index) => {
            console.log(`\nPrescription ${index + 1}:`);
            console.log('- ID:', prescription._id);
            console.log('- Patient:', prescription.patientName);
            console.log('- Doctor:', prescription.doctorName);
            console.log('- Hospital:', prescription.hospitalName);
            console.log('- Medicines:', prescription.medicines?.length || 0);
            console.log('- Created:', prescription.createdAt);
        });
        
    } catch (error) {
        console.error('\n❌ Test failed:', error);
        console.error('🔍 Stack trace:', error.stack);
    } finally {
        await mongoose.disconnect();
        console.log('\n🔌 Disconnected from MongoDB');
    }
}

testPrescriptionCreationWithRealData();