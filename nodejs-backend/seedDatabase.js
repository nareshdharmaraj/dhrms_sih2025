const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Hospital = require('./models/Hospital');
const Doctor = require('./models/Doctor');
const Patient = require('./models/Patient');
const Prescription = require('./models/Prescription');

// Sample data
const sampleHospitals = [
  {
    name: "Apollo Medical Center",
    hospitalId: "APOLLO001",
    type: "private",
    registrationNumber: "REG/APOLLO/2010/001",
    credentials: {
      username: "apollo_admin",
      password: "apollo123"
    },
    contactInfo: {
      phone: "+91-11-4567-8901",
      email: "admin@apollomedical.com",
      website: "www.apollomedical.com"
    },
    address: {
      street: "Sector 26, Ring Road",
      city: "Delhi",
      state: "Delhi",
      pincode: "110001",
      coordinates: {
        latitude: 28.6139,
        longitude: 77.2090
      }
    },
    facilities: [
      { name: "Emergency", description: "24/7 Emergency Services", available: true },
      { name: "ICU", description: "Intensive Care Unit", available: true },
      { name: "Operation Theater", description: "Modern Operation Theaters", available: true },
      { name: "Radiology", description: "Digital X-Ray, CT, MRI", available: true },
      { name: "Laboratory", description: "Full Service Laboratory", available: true },
      { name: "Pharmacy", description: "24/7 Pharmacy", available: true }
    ],
    departments: [
      { name: "Cardiology", bedCount: 50, availableBeds: 45 },
      { name: "Neurology", bedCount: 30, availableBeds: 28 },
      { name: "Orthopedics", bedCount: 40, availableBeds: 35 },
      { name: "Pediatrics", bedCount: 35, availableBeds: 30 },
      { name: "Gynecology", bedCount: 25, availableBeds: 20 },
      { name: "General Medicine", bedCount: 60, availableBeds: 55 }
    ],
    certification: {
      accreditation: "NABH, ISO 9001:2015",
      validUntil: new Date("2025-12-31"),
      isVerified: true
    },
    statistics: {
      totalDoctors: 0,
      totalPatients: 0,
      totalBeds: 500,
      availableBeds: 450
    }
  },
  {
    name: "Fortis Healthcare",
    hospitalId: "FORTIS001",
    type: "private",
    registrationNumber: "REG/FORTIS/2008/001",
    credentials: {
      username: "fortis_admin",
      password: "fortis123"
    },
    contactInfo: {
      phone: "+91-22-9876-5432",
      email: "admin@fortishealthcare.com",
      website: "www.fortishealthcare.com"
    },
    address: {
      street: "Mulund-Goregaon Link Road",
      city: "Mumbai",
      state: "Maharashtra",
      pincode: "400080",
      coordinates: {
        latitude: 19.0760,
        longitude: 72.8777
      }
    },
    facilities: [
      { name: "Emergency", description: "24/7 Emergency Services", available: true },
      { name: "ICU", description: "Intensive Care Unit", available: true },
      { name: "Operation Theater", description: "Advanced Operation Theaters", available: true },
      { name: "Radiology", description: "Digital Imaging Services", available: true },
      { name: "Laboratory", description: "NABL Accredited Lab", available: true },
      { name: "Pharmacy", description: "24/7 Pharmacy", available: true },
      { name: "Blood Bank", description: "Licensed Blood Bank", available: true }
    ],
    departments: [
      { name: "Cardiology", bedCount: 75, availableBeds: 65 },
      { name: "Oncology", bedCount: 50, availableBeds: 45 },
      { name: "Neurology", bedCount: 40, availableBeds: 35 },
      { name: "Orthopedics", bedCount: 60, availableBeds: 50 },
      { name: "Pediatrics", bedCount: 45, availableBeds: 40 },
      { name: "General Medicine", bedCount: 80, availableBeds: 70 }
    ],
    certification: {
      accreditation: "NABH, JCI, ISO 9001:2015",
      validUntil: new Date("2026-06-30"),
      isVerified: true
    },
    statistics: {
      totalDoctors: 0,
      totalPatients: 0,
      totalBeds: 750,
      availableBeds: 600
    }
  },
  {
    name: "AIIMS Delhi",
    hospitalId: "AIIMS001",
    type: "government",
    registrationNumber: "REG/AIIMS/1956/001",
    credentials: {
      username: "aiims_admin",
      password: "aiims123"
    },
    contactInfo: {
      phone: "+91-11-2658-8500",
      email: "admin@aiims.edu",
      website: "www.aiims.edu"
    },
    address: {
      street: "Ansari Nagar",
      city: "New Delhi",
      state: "Delhi",
      pincode: "110029",
      coordinates: {
        latitude: 28.5675,
        longitude: 77.2070
      }
    },
    facilities: [
      { name: "Emergency", description: "24/7 Emergency & Trauma Center", available: true },
      { name: "ICU", description: "Multi-specialty ICU", available: true },
      { name: "Operation Theater", description: "State-of-art Operation Theaters", available: true },
      { name: "Radiology", description: "Advanced Imaging Center", available: true },
      { name: "Laboratory", description: "Research Grade Laboratory", available: true },
      { name: "Pharmacy", description: "Central Pharmacy", available: true },
      { name: "Blood Bank", description: "Central Blood Bank", available: true },
      { name: "Trauma Center", description: "Level 1 Trauma Center", available: true }
    ],
    departments: [
      { name: "Cardiology", bedCount: 200, availableBeds: 180 },
      { name: "Neurology", bedCount: 150, availableBeds: 130 },
      { name: "Orthopedics", bedCount: 180, availableBeds: 160 },
      { name: "Pediatrics", bedCount: 120, availableBeds: 100 },
      { name: "Gynecology", bedCount: 100, availableBeds: 85 },
      { name: "General Medicine", bedCount: 300, availableBeds: 250 },
      { name: "Surgery", bedCount: 250, availableBeds: 200 },
      { name: "Oncology", bedCount: 150, availableBeds: 120 }
    ],
    certification: {
      accreditation: "NABH, ISO 9001:2015",
      validUntil: new Date("2027-03-31"),
      isVerified: true
    },
    statistics: {
      totalDoctors: 0,
      totalPatients: 0,
      totalBeds: 2500,
      availableBeds: 2000
    }
  }
];

const sampleDoctors = [
  {
    doctorId: "DOC001",
    personalInfo: {
      firstName: "Dr. Rajesh",
      lastName: "Sharma",
      email: "rajesh.sharma@apollomedical.com",
      phone: "+91-98765-43210",
      dateOfBirth: new Date("1978-05-15"),
      gender: "male",
      address: {
        street: "Park Avenue",
        city: "Delhi",
        state: "Delhi",
        pincode: "110001"
      }
    },
    professionalInfo: {
      medicalLicenseNumber: "DMC/2010/54321",
      specialization: ["Cardiology", "Internal Medicine"],
      qualification: [
        { degree: "MBBS", institution: "AIIMS Delhi", year: 2003 },
        { degree: "MD Cardiology", institution: "AIIMS Delhi", year: 2008 }
      ],
      experience: 15,
      department: "Cardiology",
      position: "senior"
    },
    credentials: {
      username: "dr_rajesh_sharma",
      password: "doctor123"
    },
    schedule: {
      monday: { start: "09:00", end: "17:00", available: true },
      tuesday: { start: "09:00", end: "17:00", available: true },
      wednesday: { start: "09:00", end: "17:00", available: true },
      thursday: { start: "09:00", end: "17:00", available: true },
      friday: { start: "09:00", end: "17:00", available: true },
      saturday: { start: "09:00", end: "13:00", available: true },
      sunday: { start: "", end: "", available: false }
    }
  },
  {
    doctorId: "DOC002",
    personalInfo: {
      firstName: "Dr. Priya",
      lastName: "Nair",
      email: "priya.nair@fortishealthcare.com",
      phone: "+91-87654-32109",
      dateOfBirth: new Date("1985-08-22"),
      gender: "female",
      address: {
        street: "Linking Road",
        city: "Mumbai",
        state: "Maharashtra",
        pincode: "400080"
      }
    },
    professionalInfo: {
      medicalLicenseNumber: "MMC/2015/12345",
      specialization: ["Neurology", "Neurosurgery"],
      qualification: [
        { degree: "MBBS", institution: "Grant Medical College", year: 2010 },
        { degree: "MS Neurology", institution: "KEM Hospital", year: 2014 },
        { degree: "MCh Neurosurgery", institution: "Bombay Hospital", year: 2016 }
      ],
      experience: 8,
      department: "Neurology",
      position: "senior"
    },
    credentials: {
      username: "dr_priya_nair",
      password: "doctor123"
    },
    schedule: {
      monday: { start: "10:00", end: "18:00", available: true },
      tuesday: { start: "10:00", end: "18:00", available: true },
      wednesday: { start: "10:00", end: "18:00", available: true },
      thursday: { start: "10:00", end: "18:00", available: true },
      friday: { start: "10:00", end: "18:00", available: true },
      saturday: { start: "", end: "", available: false },
      sunday: { start: "", end: "", available: false }
    }
  },
  {
    doctorId: "DOC003",
    personalInfo: {
      firstName: "Dr. Amit",
      lastName: "Gupta",
      email: "amit.gupta@aiims.edu",
      phone: "+91-76543-21098",
      dateOfBirth: new Date("1980-12-10"),
      gender: "male",
      address: {
        street: "Ansari Nagar",
        city: "New Delhi",
        state: "Delhi",
        pincode: "110029"
      }
    },
    professionalInfo: {
      medicalLicenseNumber: "DMC/2008/98765",
      specialization: ["Orthopedics", "Sports Medicine"],
      qualification: [
        { degree: "MBBS", institution: "MAMC Delhi", year: 2005 },
        { degree: "MS Orthopedics", institution: "AIIMS Delhi", year: 2009 }
      ],
      experience: 16,
      department: "Orthopedics",
      position: "senior"
    },
    credentials: {
      username: "dr_amit_gupta",
      password: "doctor123"
    },
    schedule: {
      monday: { start: "08:00", end: "16:00", available: true },
      tuesday: { start: "08:00", end: "16:00", available: true },
      wednesday: { start: "08:00", end: "16:00", available: true },
      thursday: { start: "08:00", end: "16:00", available: true },
      friday: { start: "08:00", end: "16:00", available: true },
      saturday: { start: "08:00", end: "12:00", available: true },
      sunday: { start: "", end: "", available: false }
    }
  }
];

const samplePatients = [
  {
    patientId: "PAT001",
    uhi: "UHI001RK2024",
    personalInfo: {
      firstName: "Rajesh",
      lastName: "Kumar",
      email: "rajesh.kumar@gmail.com",
      phone: "+91-98765-12345",
      aadhaarNumber: "123456789012",
      dateOfBirth: new Date("1990-03-15"),
      gender: "male",
      bloodGroup: "B+",
      address: {
        street: "MG Road",
        city: "Delhi",
        state: "Delhi",
        pincode: "110001"
      }
    },
    credentials: {
      username: "rajesh_kumar_90",
      password: "patient123"
    },
    emergencyContact: {
      name: "Sunita Kumar",
      relationship: "spouse",
      phone: "+91-98765-12346"
    },
    medicalHistory: {
      allergies: [
        { allergen: "Penicillin", severity: "moderate", description: "Skin rash and itching" }
      ],
      chronicConditions: [
        { condition: "Hypertension", diagnosedDate: new Date("2020-01-15"), status: "controlled" }
      ],
      surgicalHistory: [],
      familyHistory: [
        { relation: "father", condition: "Diabetes", ageOfOnset: 55 },
        { relation: "grandfather", condition: "Heart Disease", ageOfOnset: 68 }
      ]
    },
    insurance: {
      provider: "LIC Health Plus",
      policyNumber: "LIC123456789",
      coverage: 500000
    }
  },
  {
    patientId: "PAT002",
    uhi: "UHI002MN2024",
    personalInfo: {
      firstName: "Meera",
      lastName: "Nair",
      email: "meera.nair@gmail.com",
      phone: "+91-87654-32109",
      aadhaarNumber: "234567890123",
      dateOfBirth: new Date("1985-07-22"),
      gender: "female",
      bloodGroup: "A+",
      address: {
        street: "Brigade Road",
        city: "Mumbai",
        state: "Maharashtra",
        pincode: "400080"
      }
    },
    credentials: {
      username: "meera_nair_85",
      password: "patient123"
    },
    emergencyContact: {
      name: "Suresh Nair",
      relationship: "spouse",
      phone: "+91-87654-32110"
    },
    medicalHistory: {
      allergies: [
        { allergen: "Sulfa drugs", severity: "severe", description: "Difficulty breathing and swelling" }
      ],
      chronicConditions: [
        { condition: "Diabetes Type 2", diagnosedDate: new Date("2018-03-20"), status: "controlled" }
      ],
      surgicalHistory: [
        { surgery: "Appendectomy", date: new Date("2015-08-10"), hospital: "Fortis Healthcare", surgeon: "Dr. Ramesh" }
      ],
      familyHistory: [
        { relation: "mother", condition: "Diabetes", ageOfOnset: 50 },
        { relation: "sister", condition: "Thyroid", ageOfOnset: 35 }
      ]
    },
    insurance: {
      provider: "Star Health Insurance",
      policyNumber: "STAR987654321",
      coverage: 300000
    }
  },
  {
    patientId: "PAT003",
    uhi: "UHI003AP2024",
    personalInfo: {
      firstName: "Arun",
      lastName: "Pillai",
      email: "arun.pillai@gmail.com",
      phone: "+91-76543-21098",
      aadhaarNumber: "345678901234",
      dateOfBirth: new Date("1975-11-08"),
      gender: "male",
      bloodGroup: "O+",
      address: {
        street: "Residency Road",
        city: "Bangalore",
        state: "Karnataka",
        pincode: "560025"
      }
    },
    credentials: {
      username: "arun_pillai_75",
      password: "patient123"
    },
    emergencyContact: {
      name: "Lakshmi Pillai",
      relationship: "spouse",
      phone: "+91-76543-21099"
    },
    medicalHistory: {
      allergies: [],
      chronicConditions: [
        { condition: "Arthritis", diagnosedDate: new Date("2015-11-05"), status: "active" }
      ],
      surgicalHistory: [
        { surgery: "Knee Replacement", date: new Date("2020-06-15"), hospital: "AIIMS Delhi", surgeon: "Dr. Amit Gupta" }
      ],
      familyHistory: [
        { relation: "father", condition: "Arthritis", ageOfOnset: 60 },
        { relation: "mother", condition: "Hypertension", ageOfOnset: 58 }
      ]
    },
    insurance: {
      provider: "New India Assurance",
      policyNumber: "NIA456789123",
      coverage: 200000
    }
  }
];

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('🍃 Connected to MongoDB for seeding');
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    process.exit(1);
  }
};

// Seed function
const seedDatabase = async () => {
  try {
    console.log('🚀 Starting database seeding...');

    // Clear existing data
    console.log('🧹 Clearing existing data...');
    await Promise.all([
      Hospital.deleteMany({}),
      Doctor.deleteMany({}),
      Patient.deleteMany({}),
      Prescription.deleteMany({})
    ]);

    // Insert hospitals
    console.log('🏥 Creating hospitals...');
    const hospitals = await Hospital.insertMany(sampleHospitals);
    console.log(`✅ Created ${hospitals.length} hospitals`);

    // Link doctors to hospitals and insert
    console.log('👨‍⚕️ Creating doctors...');
    sampleDoctors[0].hospital = hospitals[0]._id; // Apollo
    sampleDoctors[1].hospital = hospitals[1]._id; // Fortis
    sampleDoctors[2].hospital = hospitals[2]._id; // AIIMS

    const doctors = await Doctor.insertMany(sampleDoctors);
    console.log(`✅ Created ${doctors.length} doctors`);

    // Update hospital doctor counts
    await Promise.all([
      Hospital.findByIdAndUpdate(hospitals[0]._id, { $inc: { 'statistics.totalDoctors': 1 } }),
      Hospital.findByIdAndUpdate(hospitals[1]._id, { $inc: { 'statistics.totalDoctors': 1 } }),
      Hospital.findByIdAndUpdate(hospitals[2]._id, { $inc: { 'statistics.totalDoctors': 1 } })
    ]);

    // Insert patients
    console.log('🏃‍♂️ Creating patients...');
    const patients = await Patient.insertMany(samplePatients);
    console.log(`✅ Created ${patients.length} patients`);

    // Create sample prescriptions
    console.log('💊 Creating prescriptions...');
    const samplePrescriptions = [
      {
        prescriptionId: "RX001",
        patient: patients[0]._id,
        doctor: doctors[0]._id,
        hospital: hospitals[0]._id,
        consultation: {
          date: new Date(),
          symptoms: ["High blood pressure", "Occasional headaches"],
          diagnosis: {
            primary: "Hypertension",
            secondary: ["Stress-related headaches"],
            icdCode: "I10"
          },
          notes: "Patient responding well to treatment. Continue current medications.",
          followUpDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
        },
        medications: [
          {
            name: "Amlodipine",
            genericName: "Amlodipine Besylate",
            dosage: "5mg",
            frequency: "once daily",
            duration: {
              value: 30,
              unit: "days"
            },
            instructions: {
              afterFood: true,
              timing: ["morning"],
              specialInstructions: "Take in the morning with food"
            },
            quantity: {
              prescribed: 30,
              unit: "tablets"
            }
          },
          {
            name: "Metoprolol",
            genericName: "Metoprolol Tartrate",
            dosage: "25mg",
            frequency: "twice daily",
            duration: {
              value: 30,
              unit: "days"
            },
            instructions: {
              afterFood: true,
              timing: ["morning", "evening"],
              specialInstructions: "Take with meals"
            },
            quantity: {
              prescribed: 60,
              unit: "tablets"
            }
          }
        ],
        status: "active"
      },
      {
        prescriptionId: "RX002",
        patient: patients[1]._id,
        doctor: doctors[1]._id,
        hospital: hospitals[1]._id,
        consultation: {
          date: new Date(),
          symptoms: ["Increased thirst", "Frequent urination", "Fatigue"],
          diagnosis: {
            primary: "Type 2 Diabetes Mellitus",
            secondary: [],
            icdCode: "E11"
          },
          notes: "Blood sugar levels improving. Continue current regimen and monitor glucose levels.",
          followUpDate: new Date(Date.now() + 60 * 24 * 60 * 60 * 1000)
        },
        medications: [
          {
            name: "Metformin",
            genericName: "Metformin Hydrochloride",
            dosage: "500mg",
            frequency: "twice daily",
            duration: {
              value: 60,
              unit: "days"
            },
            instructions: {
              afterFood: true,
              timing: ["morning", "evening"],
              specialInstructions: "Take with meals to reduce stomach upset"
            },
            quantity: {
              prescribed: 120,
              unit: "tablets"
            }
          },
          {
            name: "Glimepiride",
            genericName: "Glimepiride",
            dosage: "2mg",
            frequency: "once daily",
            duration: {
              value: 60,
              unit: "days"
            },
            instructions: {
              beforeFood: true,
              timing: ["morning"],
              specialInstructions: "Take before breakfast"
            },
            quantity: {
              prescribed: 60,
              unit: "tablets"
            }
          }
        ],
        status: "active"
      },
      {
        prescriptionId: "RX003",
        patient: patients[2]._id,
        doctor: doctors[2]._id,
        hospital: hospitals[2]._id,
        consultation: {
          date: new Date(),
          symptoms: ["Knee pain", "Stiffness", "Reduced mobility"],
          diagnosis: {
            primary: "Osteoarthritis - Knee",
            secondary: ["Post-operative follow-up"],
            icdCode: "M17.9"
          },
          notes: "Post-operative follow-up. Healing well. Continue physiotherapy.",
          followUpDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
        },
        medications: [
          {
            name: "Diclofenac",
            genericName: "Diclofenac Sodium",
            dosage: "50mg",
            frequency: "twice daily",
            duration: {
              value: 14,
              unit: "days"
            },
            instructions: {
              afterFood: true,
              timing: ["morning", "evening"],
              specialInstructions: "Take with food. Apply ice to affected area."
            },
            quantity: {
              prescribed: 28,
              unit: "tablets"
            }
          },
          {
            name: "Calcium + Vitamin D3",
            genericName: "Calcium Carbonate + Cholecalciferol",
            dosage: "500mg + 250 IU",
            frequency: "once daily",
            duration: {
              value: 90,
              unit: "days"
            },
            instructions: {
              afterFood: true,
              timing: ["evening"],
              specialInstructions: "Take with dinner"
            },
            quantity: {
              prescribed: 90,
              unit: "tablets"
            }
          }
        ],
        status: "active"
      }
    ];

    const prescriptions = await Prescription.insertMany(samplePrescriptions);
    console.log(`✅ Created ${prescriptions.length} prescriptions`);

    // Add patients to doctors' patient lists
    console.log('🔗 Linking patients to doctors...');
    await Promise.all([
      Doctor.findByIdAndUpdate(doctors[0]._id, {
        $push: { 
          patients: { 
            patient: patients[0]._id, 
            firstConsultation: new Date(),
            status: 'active'
          }
        },
        $inc: { 'statistics.totalPatients': 1, 'statistics.totalConsultations': 1 }
      }),
      Doctor.findByIdAndUpdate(doctors[1]._id, {
        $push: { 
          patients: { 
            patient: patients[1]._id, 
            firstConsultation: new Date(),
            status: 'active'
          }
        },
        $inc: { 'statistics.totalPatients': 1, 'statistics.totalConsultations': 1 }
      }),
      Doctor.findByIdAndUpdate(doctors[2]._id, {
        $push: { 
          patients: { 
            patient: patients[2]._id, 
            firstConsultation: new Date(),
            status: 'active'
          }
        },
        $inc: { 'statistics.totalPatients': 1, 'statistics.totalConsultations': 1 }
      })
    ]);

    // Update hospital patient counts
    await Promise.all([
      Hospital.findByIdAndUpdate(hospitals[0]._id, { $inc: { 'statistics.totalPatients': 1 } }),
      Hospital.findByIdAndUpdate(hospitals[1]._id, { $inc: { 'statistics.totalPatients': 1 } }),
      Hospital.findByIdAndUpdate(hospitals[2]._id, { $inc: { 'statistics.totalPatients': 1 } })
    ]);

    console.log('🎉 Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   Hospitals: ${hospitals.length}`);
    console.log(`   Doctors: ${doctors.length}`);
    console.log(`   Patients: ${patients.length}`);
    console.log(`   Prescriptions: ${prescriptions.length}`);
    console.log('\n🔑 Sample Login Credentials:');
    console.log('   Hospitals:');
    console.log('     - Username: apollo_admin, Password: apollo123');
    console.log('     - Username: fortis_admin, Password: fortis123');
    console.log('     - Username: aiims_admin, Password: aiims123');
    console.log('   Doctors:');
    console.log('     - Username: dr_rajesh_sharma, Password: doctor123');
    console.log('     - Username: dr_priya_nair, Password: doctor123');
    console.log('     - Username: dr_amit_gupta, Password: doctor123');
    console.log('   Patients:');
    console.log('     - Username: rajesh_kumar_90, Password: patient123');
    console.log('     - Username: meera_nair_85, Password: patient123');
    console.log('     - Username: arun_pillai_75, Password: patient123');

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
};

// Run seeding
const runSeeder = async () => {
  await connectDB();
  await seedDatabase();
  await mongoose.connection.close();
  console.log('👋 Database connection closed');
  process.exit(0);
};

// Run if called directly
if (require.main === module) {
  runSeeder();
}

module.exports = { seedDatabase, connectDB };
