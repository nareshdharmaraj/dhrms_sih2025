const mongoose = require('mongoose');
require('dotenv').config();

// Use the MongoDB URI from environment
const connectionString = process.env.MONGODB_URI;

async function updatePrescriptionSchema() {
  try {
    await mongoose.connect(connectionString);
    console.log('✅ Connected to MongoDB');

    const db = mongoose.connection.db;
    
    // Define the corrected schema with optional fields
    const correctedSchema = {
      $jsonSchema: {
        bsonType: "object",
        required: [
          "_id",
          "appointmentId",
          "appointmentNumber",
          "createdAt",
          "diseaseName",
          "diseaseType",
          "doctorId",
          "doctorIdentifier",
          "doctorName",
          "hospitalAddress",
          "hospitalContact",
          "hospitalId",
          "hospitalName",
          "isConfirmed",
          "medicines",
          "nextVisitMandatory",
          "patientId",
          "patientName",
          "patientUHID",
          "updatedAt"
          // Note: Removed nextVisitDate and expectedRecoveryDays from required
        ],
        properties: {
          _id: {
            bsonType: "objectId"
          },
          appointmentId: {
            bsonType: "string"
          },
          appointmentNumber: {
            bsonType: "string"
          },
          createdAt: {
            bsonType: "date"
          },
          diseaseName: {
            bsonType: "string"
          },
          diseaseType: {
            bsonType: "string"
          },
          doctorId: {
            bsonType: "string"
          },
          doctorIdentifier: {
            bsonType: "string"
          },
          doctorName: {
            bsonType: "string"
          },
          expectedRecoveryDays: {
            bsonType: ["int", "null"] // Allow null values
          },
          hospitalAddress: {
            bsonType: "string"
          },
          hospitalContact: {
            bsonType: "object",
            properties: {
              email: {
                bsonType: "string"
              },
              phone: {
                bsonType: "string"
              }
            }
            // Note: Removed required email and phone from hospitalContact
          },
          hospitalId: {
            bsonType: "string"
          },
          hospitalName: {
            bsonType: "string"
          },
          isConfirmed: {
            bsonType: "bool"
          },
          medicines: {
            bsonType: "array",
            items: {
              bsonType: "object",
              properties: {
                additionalNotes: {
                  bsonType: "string"
                },
                beforeAfterFood: {
                  bsonType: "string"
                },
                countPerDose: {
                  bsonType: "int"
                },
                dosageDetails: {
                  bsonType: "string"
                },
                duration: {
                  bsonType: "int"
                },
                frequency: {
                  bsonType: "string"
                },
                name: {
                  bsonType: "string"
                },
                power: {
                  bsonType: "string"
                },
                timing: {
                  bsonType: "array",
                  items: {
                    bsonType: "string"
                  }
                },
                totalCount: {
                  bsonType: "int"
                },
                type: {
                  bsonType: "string"
                }
              },
              required: [
                "name",
                "type"
              ]
            }
          },
          nextVisitDate: {
            bsonType: ["string", "null"] // Allow null values
          },
          nextVisitMandatory: {
            bsonType: "bool"
          },
          patientId: {
            bsonType: "string"
          },
          patientName: {
            bsonType: "string"
          },
          patientUHID: {
            bsonType: "string"
          },
          updatedAt: {
            bsonType: "date"
          },
          // Add support for diseases array
          diseases: {
            bsonType: "array",
            items: {
              bsonType: "object",
              properties: {
                name: {
                  bsonType: "string"
                },
                isCustom: {
                  bsonType: "bool"
                }
              }
            }
          }
        }
      }
    };

    // Update the collection validator
    const result = await db.command({
      collMod: "hospitalprescriptions",
      validator: correctedSchema,
      validationLevel: "strict",
      validationAction: "error"
    });

    console.log('✅ Schema updated successfully:', result);
    console.log('📋 Key changes made:');
    console.log('  - nextVisitDate is now optional');
    console.log('  - expectedRecoveryDays is now optional');
    console.log('  - hospitalContact phone/email are now optional');
    console.log('  - Added support for diseases array');

  } catch (error) {
    console.error('❌ Error updating schema:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
}

// Run the schema update
updatePrescriptionSchema();