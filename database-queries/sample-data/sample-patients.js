/**
 * Sample Patient Data for DHRMS
 * 
 * This file contains sample patient records for testing and development
 */

const bcrypt = require('bcryptjs');

const samplePatients = [
  {
    patientId: "PAT001",
    uhi: "UHI001",
    personalInfo: {
      firstName: "Rajesh",
      lastName: "Kumar",
      email: "rajesh.kumar@email.com",
      phone: "+91-9876543210",
      aadhaarNumber: "123456789012",
      dateOfBirth: new Date("1985-06-15"),
      gender: "male",
      bloodGroup: "B+",
      address: {
        street: "123 MG Road",
        city: "Delhi",
        state: "Delhi",
        pincode: "110001",
        country: "India"
      },
      emergencyContact: {
        name: "Priya Kumar",
        relationship: "Wife",
        phone: "+91-9876543211"
      },
      uniqueHealthId: "UHI001"
    },
    credentials: {
      username: "rajesh_kumar_90",
      password: bcrypt.hashSync("patient123", 12),
      email: "rajesh.kumar@email.com",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    medicalInfo: {
      bloodGroup: "B+",
      allergies: ["Peanuts", "Dust"],
      chronicConditions: ["Hypertension"],
      medications: [{
        name: "Amlodipine",
        dosage: "5mg",
        frequency: "Once daily",
        startDate: new Date("2023-01-15"),
        endDate: null
      }],
      surgicalHistory: [],
      familyHistory: [{
        condition: "Diabetes",
        relation: "Father"
      }],
      vaccinations: [{
        vaccine: "COVID-19",
        date: new Date("2023-03-15"),
        nextDue: new Date("2024-03-15")
      }]
    },
    insuranceInfo: {
      provider: "LIC Health",
      policyNumber: "LIC12345",
      validUntil: new Date("2024-12-31"),
      coverageAmount: 500000
    },
    vitalSigns: {
      height: 175,
      weight: 75,
      bmi: 24.5,
      bloodPressure: {
        systolic: 130,
        diastolic: 85
      },
      heartRate: 72,
      temperature: 98.6,
      respiratoryRate: 16,
      oxygenSaturation: 98
    },
    preferences: {
      language: "Hindi",
      notifications: {
        email: true,
        sms: true,
        push: true
      },
      shareDataWithResearch: false
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },
  
  {
    patientId: "PAT002",
    uhi: "UHI002",
    personalInfo: {
      firstName: "Anita",
      lastName: "Sharma",
      email: "anita.sharma@email.com",
      phone: "+91-9876543212",
      aadhaarNumber: "123456789013",
      dateOfBirth: new Date("1990-03-22"),
      gender: "female",
      bloodGroup: "A+",
      address: {
        street: "456 Park Street",
        city: "Mumbai",
        state: "Maharashtra",
        pincode: "400001",
        country: "India"
      },
      emergencyContact: {
        name: "Vikash Sharma",
        relationship: "Husband",
        phone: "+91-9876543213"
      },
      uniqueHealthId: "UHI002"
    },
    credentials: {
      username: "anita_sharma_90",
      password: bcrypt.hashSync("patient456", 12),
      email: "anita.sharma@email.com",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    medicalInfo: {
      bloodGroup: "A+",
      allergies: ["Shellfish"],
      chronicConditions: [],
      medications: [],
      surgicalHistory: [{
        procedure: "Appendectomy",
        date: new Date("2020-05-10"),
        hospital: "Apollo Hospital",
        doctor: "Dr. Mehta"
      }],
      familyHistory: [{
        condition: "Heart Disease",
        relation: "Mother"
      }],
      vaccinations: [{
        vaccine: "COVID-19",
        date: new Date("2023-02-20"),
        nextDue: new Date("2024-02-20")
      }]
    },
    insuranceInfo: {
      provider: "HDFC ERGO",
      policyNumber: "HDFC67890",
      validUntil: new Date("2024-10-31"),
      coverageAmount: 300000
    },
    vitalSigns: {
      height: 162,
      weight: 58,
      bmi: 22.1,
      bloodPressure: {
        systolic: 120,
        diastolic: 80
      },
      heartRate: 68,
      temperature: 98.4,
      respiratoryRate: 14,
      oxygenSaturation: 99
    },
    preferences: {
      language: "English",
      notifications: {
        email: true,
        sms: false,
        push: true
      },
      shareDataWithResearch: true
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },

  {
    patientId: "PAT003",
    uhi: "UHI003",
    personalInfo: {
      firstName: "Mohammed",
      lastName: "Ali",
      email: "mohammed.ali@email.com",
      phone: "+91-9876543214",
      aadhaarNumber: "123456789014",
      dateOfBirth: new Date("1978-11-08"),
      gender: "male",
      bloodGroup: "O+",
      address: {
        street: "789 Brigade Road",
        city: "Bangalore",
        state: "Karnataka",
        pincode: "560001",
        country: "India"
      },
      emergencyContact: {
        name: "Fatima Ali",
        relationship: "Wife",
        phone: "+91-9876543215"
      },
      uniqueHealthId: "UHI003"
    },
    credentials: {
      username: "mohammed_ali_78",
      password: bcrypt.hashSync("patient789", 12),
      email: "mohammed.ali@email.com",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    medicalInfo: {
      bloodGroup: "O+",
      allergies: ["Latex"],
      chronicConditions: ["Diabetes Type 2"],
      medications: [{
        name: "Metformin",
        dosage: "500mg",
        frequency: "Twice daily",
        startDate: new Date("2022-08-20"),
        endDate: null
      }],
      surgicalHistory: [],
      familyHistory: [{
        condition: "Diabetes",
        relation: "Father"
      }, {
        condition: "Hypertension",
        relation: "Mother"
      }],
      vaccinations: [{
        vaccine: "COVID-19",
        date: new Date("2023-01-10"),
        nextDue: new Date("2024-01-10")
      }]
    },
    insuranceInfo: {
      provider: "Star Health",
      policyNumber: "STAR11111",
      validUntil: new Date("2024-08-31"),
      coverageAmount: 1000000
    },
    vitalSigns: {
      height: 170,
      weight: 80,
      bmi: 27.7,
      bloodPressure: {
        systolic: 140,
        diastolic: 90
      },
      heartRate: 76,
      temperature: 98.8,
      respiratoryRate: 18,
      oxygenSaturation: 97
    },
    preferences: {
      language: "Urdu",
      notifications: {
        email: true,
        sms: true,
        push: false
      },
      shareDataWithResearch: false
    },
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

module.exports = samplePatients;
