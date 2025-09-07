const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Hospital = require('./models/Hospital');
const Doctor = require('./models/Doctor');
const Patient = require('./models/Patient');
const Prescription = require('./models/Prescription');

// Enhanced sample data with comprehensive details
const sampleHospitals = [
  {
    hospitalId: "APOLLO001",
    name: "Apollo Medical Center",
    type: "private",
    registrationNumber: "APL/2020/MH/001",
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
    contactInfo: {
      phone: "+91-11-4567-8901",
      email: "admin@apollomedical.com",
      website: "www.apollomedical.com",
      emergencyContact: "+91-11-4567-8911"
    },
    facilities: [
      { name: "Emergency Department", description: "24/7 Emergency Services", available: true },
      { name: "Intensive Care Unit", description: "Advanced ICU with ventilators", available: true },
      { name: "Operation Theater", description: "5 modern operation theaters", available: true },
      { name: "Radiology", description: "CT, MRI, X-Ray services", available: true },
      { name: "Laboratory", description: "Complete pathology lab", available: true },
      { name: "Pharmacy", description: "24/7 medical pharmacy", available: true },
      { name: "Blood Bank", description: "Licensed blood bank", available: true },
      { name: "Dialysis Center", description: "Hemodialysis services", available: true }
    ],
    departments: [
      { name: "Cardiology", bedCount: 50, availableBeds: 42 },
      { name: "Neurology", bedCount: 30, availableBeds: 25 },
      { name: "Orthopedics", bedCount: 40, availableBeds: 35 },
      { name: "Pediatrics", bedCount: 35, availableBeds: 28 },
      { name: "Gynecology", bedCount: 25, availableBeds: 20 },
      { name: "General Medicine", bedCount: 60, availableBeds: 48 },
      { name: "Surgery", bedCount: 45, availableBeds: 38 },
      { name: "Emergency", bedCount: 20, availableBeds: 15 }
    ],
    credentials: {
      username: "apollo_admin",
      password: "apollo123",
      isActive: true
    },
    statistics: {
      totalDoctors: 0,
      totalPatients: 0,
      totalBeds: 305,
      availableBeds: 251
    },
    certification: {
      accreditation: "NABH, ISO 9001:2015",
      validUntil: new Date("2026-12-31"),
      isVerified: true
    }
  },
  {
    hospitalId: "FORTIS001",
    name: "Fortis Healthcare",
    type: "private",
    registrationNumber: "FOR/2019/MH/002",
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
    contactInfo: {
      phone: "+91-22-9876-5432",
      email: "admin@fortishealthcare.com",
      website: "www.fortishealthcare.com",
      emergencyContact: "+91-22-9876-5442"
    },
    facilities: [
      { name: "Emergency Department", description: "Trauma care center", available: true },
      { name: "Intensive Care Unit", description: "NICU, PICU, MICU", available: true },
      { name: "Operation Theater", description: "8 advanced OTs", available: true },
      { name: "Radiology", description: "3T MRI, 128 slice CT", available: true },
      { name: "Laboratory", description: "NABL accredited lab", available: true },
      { name: "Pharmacy", description: "Round the clock pharmacy", available: true },
      { name: "Blood Bank", description: "Component separation facility", available: true },
      { name: "Cardiac Cathlab", description: "Interventional cardiology", available: true },
      { name: "Oncology Center", description: "Cancer treatment center", available: true }
    ],
    departments: [
      { name: "Cardiology", bedCount: 80, availableBeds: 65 },
      { name: "Oncology", bedCount: 60, availableBeds: 45 },
      { name: "Neurology", bedCount: 45, availableBeds: 38 },
      { name: "Orthopedics", bedCount: 55, availableBeds: 48 },
      { name: "Pediatrics", bedCount: 40, availableBeds: 32 },
      { name: "General Medicine", bedCount: 70, availableBeds: 58 },
      { name: "Surgery", bedCount: 50, availableBeds: 42 },
      { name: "Gastroenterology", bedCount: 35, availableBeds: 28 }
    ],
    credentials: {
      username: "fortis_admin",
      password: "fortis123",
      isActive: true
    },
    statistics: {
      totalDoctors: 0,
      totalPatients: 0,
      totalBeds: 435,
      availableBeds: 356
    },
    certification: {
      accreditation: "NABH, JCI, ISO 9001:2015",
      validUntil: new Date("2027-06-30"),
      isVerified: true
    }
  },
  {
    hospitalId: "AIIMS001",
    name: "All India Institute of Medical Sciences",
    type: "government",
    registrationNumber: "AIIMS/1956/DL/001",
    address: {
      street: "Ansari Nagar",
      city: "New Delhi",
      state: "Delhi",
      pincode: "110029",
      coordinates: {
        latitude: 28.5672,
        longitude: 77.2100
      }
    },
    contactInfo: {
      phone: "+91-11-2658-8500",
      email: "admin@aiims.edu",
      website: "www.aiims.edu",
      emergencyContact: "+91-11-2658-8700"
    },
    facilities: [
      { name: "Emergency Department", description: "Level 1 trauma center", available: true },
      { name: "Intensive Care Unit", description: "Multi-specialty ICUs", available: true },
      { name: "Operation Theater", description: "15 operation theaters", available: true },
      { name: "Radiology", description: "Advanced imaging center", available: true },
      { name: "Laboratory", description: "Central laboratory", available: true },
      { name: "Pharmacy", description: "Hospital pharmacy", available: true },
      { name: "Blood Bank", description: "Regional blood bank", available: true },
      { name: "Trauma Center", description: "Jai Prakash Narayan Apex Trauma Center", available: true },
      { name: "Research Center", description: "Medical research facility", available: true },
      { name: "Teaching Hospital", description: "Medical education center", available: true }
    ],
    departments: [
      { name: "Cardiology", bedCount: 120, availableBeds: 95 },
      { name: "Neurology", bedCount: 100, availableBeds: 82 },
      { name: "Orthopedics", bedCount: 150, availableBeds: 125 },
      { name: "Pediatrics", bedCount: 80, availableBeds: 65 },
      { name: "Gynecology", bedCount: 70, availableBeds: 58 },
      { name: "General Medicine", bedCount: 200, availableBeds: 165 },
      { name: "Surgery", bedCount: 180, availableBeds: 150 },
      { name: "Oncology", bedCount: 90, availableBeds: 75 },
      { name: "Emergency", bedCount: 50, availableBeds: 40 }
    ],
    credentials: {
      username: "aiims_admin",
      password: "aiims123",
      isActive: true
    },
    statistics: {
      totalDoctors: 0,
      totalPatients: 0,
      totalBeds: 1040,
      availableBeds: 855
    },
    certification: {
      accreditation: "NABH, ISO 9001:2015, NAAC A++",
      validUntil: new Date("2028-03-31"),
      isVerified: true
    }
  },
  {
    hospitalId: "MAX001",
    name: "Max Super Speciality Hospital",
    type: "private",
    registrationNumber: "MAX/2018/DL/003",
    address: {
      street: "1, Press Enclave Road, Saket",
      city: "New Delhi",
      state: "Delhi",
      pincode: "110017",
      coordinates: {
        latitude: 28.5245,
        longitude: 77.2066
      }
    },
    contactInfo: {
      phone: "+91-11-2651-5050",
      email: "admin@maxhealthcare.com",
      website: "www.maxhealthcare.in",
      emergencyContact: "+91-11-2651-5151"
    },
    facilities: [
      { name: "Emergency Department", description: "24x7 emergency services", available: true },
      { name: "Intensive Care Unit", description: "State-of-the-art ICUs", available: true },
      { name: "Operation Theater", description: "Modular operation theaters", available: true },
      { name: "Radiology", description: "Digital imaging center", available: true },
      { name: "Laboratory", description: "Automated laboratory", available: true },
      { name: "Pharmacy", description: "Clinical pharmacy services", available: true },
      { name: "Robotic Surgery", description: "Da Vinci robotic surgery", available: true },
      { name: "Transplant Center", description: "Organ transplant facility", available: true }
    ],
    departments: [
      { name: "Cardiology", bedCount: 60, availableBeds: 48 },
      { name: "Neurology", bedCount: 40, availableBeds: 32 },
      { name: "Orthopedics", bedCount: 50, availableBeds: 42 },
      { name: "Oncology", bedCount: 45, availableBeds: 38 },
      { name: "Gastroenterology", bedCount: 30, availableBeds: 25 },
      { name: "General Medicine", bedCount: 80, availableBeds: 68 }
    ],
    credentials: {
      username: "max_admin",
      password: "max123",
      isActive: true
    },
    statistics: {
      totalDoctors: 0,
      totalPatients: 0,
      totalBeds: 305,
      availableBeds: 253
    },
    certification: {
      accreditation: "NABH, JCI",
      validUntil: new Date("2026-08-31"),
      isVerified: true
    }
  },
  {
    hospitalId: "MEDANTA001",
    name: "Medanta - The Medicity",
    type: "private",
    registrationNumber: "MED/2009/HR/004",
    address: {
      street: "Sector 38, Gurgaon",
      city: "Gurugram",
      state: "Haryana",
      pincode: "122001",
      coordinates: {
        latitude: 28.4211,
        longitude: 77.0444
      }
    },
    contactInfo: {
      phone: "+91-124-4141-414",
      email: "admin@medanta.org",
      website: "www.medanta.org",
      emergencyContact: "+91-124-4141-500"
    },
    facilities: [
      { name: "Emergency Department", description: "Multi-specialty emergency", available: true },
      { name: "Intensive Care Unit", description: "Critical care units", available: true },
      { name: "Operation Theater", description: "Advanced surgical suites", available: true },
      { name: "Heart Institute", description: "Cardiac surgery center", available: true },
      { name: "Cancer Institute", description: "Comprehensive cancer care", available: true },
      { name: "Neuroscience Institute", description: "Brain and spine center", available: true }
    ],
    departments: [
      { name: "Cardiology", bedCount: 100, availableBeds: 82 },
      { name: "Oncology", bedCount: 80, availableBeds: 65 },
      { name: "Neurology", bedCount: 70, availableBeds: 58 },
      { name: "Orthopedics", bedCount: 60, availableBeds: 50 }
    ],
    credentials: {
      username: "medanta_admin",
      password: "medanta123",
      isActive: true
    },
    statistics: {
      totalDoctors: 0,
      totalPatients: 0,
      totalBeds: 310,
      availableBeds: 255
    },
    certification: {
      accreditation: "NABH, JCI",
      validUntil: new Date("2027-12-31"),
      isVerified: true
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
        street: "A-45, Green Park",
        city: "Delhi",
        state: "Delhi",
        pincode: "110016"
      }
    },
    professionalInfo: {
      medicalLicenseNumber: "DMC/2010/54321",
      specialization: ["Interventional Cardiology", "Cardiac Surgery"],
      qualification: [
        { degree: "MBBS", institution: "AIIMS Delhi", year: 2003 },
        { degree: "MD Cardiology", institution: "AIIMS Delhi", year: 2008 },
        { degree: "DM Interventional Cardiology", institution: "AIIMS Delhi", year: 2011 }
      ],
      experience: 15,
      department: "Cardiology",
      position: "senior"
    },
    credentials: {
      username: "dr_rajesh_sharma",
      password: "doctor123",
      isActive: true,
      isVerified: true
    },
    schedule: {
      monday: { start: "09:00", end: "17:00", available: true },
      tuesday: { start: "09:00", end: "17:00", available: true },
      wednesday: { start: "09:00", end: "17:00", available: true },
      thursday: { start: "09:00", end: "17:00", available: true },
      friday: { start: "09:00", end: "17:00", available: true },
      saturday: { start: "09:00", end: "13:00", available: true },
      sunday: { start: "", end: "", available: false }
    },
    consultationFee: 1500,
    languages: ["Hindi", "English"],
    awards: ["Best Cardiologist 2022", "Excellence in Patient Care 2023"],
    availability: {
      isAvailable: true,
      nextAvailableSlot: new Date(Date.now() + 24 * 60 * 60 * 1000)
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
        street: "B-12, Bandra West",
        city: "Mumbai",
        state: "Maharashtra",
        pincode: "400050"
      }
    },
    professionalInfo: {
      medicalLicenseNumber: "MMC/2015/12345",
      specialization: ["Neurosurgery", "Spine Surgery"],
      qualification: [
        { degree: "MBBS", institution: "Grant Medical College", year: 2010 },
        { degree: "MS General Surgery", institution: "KEM Hospital", year: 2014 },
        { degree: "MCh Neurosurgery", institution: "Bombay Hospital", year: 2017 }
      ],
      experience: 8,
      department: "Neurology",
      position: "senior"
    },
    credentials: {
      username: "dr_priya_nair",
      password: "doctor123",
      isActive: true,
      isVerified: true
    },
    schedule: {
      monday: { start: "10:00", end: "18:00", available: true },
      tuesday: { start: "10:00", end: "18:00", available: true },
      wednesday: { start: "10:00", end: "18:00", available: true },
      thursday: { start: "10:00", end: "18:00", available: true },
      friday: { start: "10:00", end: "18:00", available: true },
      saturday: { start: "", end: "", available: false },
      sunday: { start: "", end: "", available: false }
    },
    consultationFee: 2000,
    languages: ["Hindi", "English", "Marathi"],
    awards: ["Outstanding Neurosurgeon 2023"],
    availability: {
      isAvailable: true,
      nextAvailableSlot: new Date(Date.now() + 48 * 60 * 60 * 1000)
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
        street: "C-56, Malviya Nagar",
        city: "New Delhi",
        state: "Delhi",
        pincode: "110017"
      }
    },
    professionalInfo: {
      medicalLicenseNumber: "DMC/2008/98765",
      specialization: ["Joint Replacement", "Sports Medicine", "Arthroscopy"],
      qualification: [
        { degree: "MBBS", institution: "MAMC Delhi", year: 2005 },
        { degree: "MS Orthopedics", institution: "AIIMS Delhi", year: 2009 },
        { degree: "Fellowship in Joint Replacement", institution: "Mayo Clinic", year: 2012 }
      ],
      experience: 16,
      department: "Orthopedics",
      position: "senior"
    },
    credentials: {
      username: "dr_amit_gupta",
      password: "doctor123",
      isActive: true,
      isVerified: true
    },
    schedule: {
      monday: { start: "08:00", end: "16:00", available: true },
      tuesday: { start: "08:00", end: "16:00", available: true },
      wednesday: { start: "08:00", end: "16:00", available: true },
      thursday: { start: "08:00", end: "16:00", available: true },
      friday: { start: "08:00", end: "16:00", available: true },
      saturday: { start: "08:00", end: "12:00", available: true },
      sunday: { start: "", end: "", available: false }
    },
    consultationFee: 1200,
    languages: ["Hindi", "English"],
    awards: ["Excellence in Orthopedic Surgery 2022", "Patient Choice Award 2023"],
    availability: {
      isAvailable: true,
      nextAvailableSlot: new Date(Date.now() + 12 * 60 * 60 * 1000)
    }
  },
  {
    doctorId: "DOC004",
    personalInfo: {
      firstName: "Dr. Sunita",
      lastName: "Agarwal",
      email: "sunita.agarwal@maxhealthcare.com",
      phone: "+91-98765-11111",
      dateOfBirth: new Date("1982-03-18"),
      gender: "female",
      address: {
        street: "D-24, Defence Colony",
        city: "New Delhi",
        state: "Delhi",
        pincode: "110024"
      }
    },
    professionalInfo: {
      medicalLicenseNumber: "DMC/2012/11111",
      specialization: ["Gynecologic Oncology", "Laparoscopic Surgery"],
      qualification: [
        { degree: "MBBS", institution: "Lady Hardinge Medical College", year: 2007 },
        { degree: "MS Gynecology", institution: "AIIMS Delhi", year: 2012 },
        { degree: "Fellowship in Gynecologic Oncology", institution: "Tata Memorial Hospital", year: 2015 }
      ],
      experience: 12,
      department: "Gynecology",
      position: "senior"
    },
    credentials: {
      username: "dr_sunita_agarwal",
      password: "doctor123",
      isActive: true,
      isVerified: true
    },
    schedule: {
      monday: { start: "09:00", end: "17:00", available: true },
      tuesday: { start: "09:00", end: "17:00", available: true },
      wednesday: { start: "09:00", end: "17:00", available: true },
      thursday: { start: "09:00", end: "17:00", available: true },
      friday: { start: "09:00", end: "17:00", available: true },
      saturday: { start: "09:00", end: "13:00", available: true },
      sunday: { start: "", end: "", available: false }
    },
    consultationFee: 1800,
    languages: ["Hindi", "English"],
    awards: ["Women's Health Champion 2023"],
    availability: {
      isAvailable: true,
      nextAvailableSlot: new Date(Date.now() + 36 * 60 * 60 * 1000)
    }
  },
  {
    doctorId: "DOC005",
    personalInfo: {
      firstName: "Dr. Vikram",
      lastName: "Singh",
      email: "vikram.singh@medanta.org",
      phone: "+91-98765-22222",
      dateOfBirth: new Date("1975-07-25"),
      gender: "male",
      address: {
        street: "E-45, Sector 14",
        city: "Gurugram",
        state: "Haryana",
        pincode: "122001"
      }
    },
    professionalInfo: {
      medicalLicenseNumber: "HMC/2005/22222",
      specialization: ["Pediatric Cardiology", "Congenital Heart Surgery"],
      qualification: [
        { degree: "MBBS", institution: "PGIMER Chandigarh", year: 2000 },
        { degree: "MD Pediatrics", institution: "PGIMER Chandigarh", year: 2004 },
        { degree: "DM Pediatric Cardiology", institution: "AIIMS Delhi", year: 2007 }
      ],
      experience: 20,
      department: "Pediatrics",
      position: "senior"
    },
    credentials: {
      username: "dr_vikram_singh",
      password: "doctor123",
      isActive: true,
      isVerified: true
    },
    schedule: {
      monday: { start: "08:00", end: "16:00", available: true },
      tuesday: { start: "08:00", end: "16:00", available: true },
      wednesday: { start: "08:00", end: "16:00", available: true },
      thursday: { start: "08:00", end: "16:00", available: true },
      friday: { start: "08:00", end: "16:00", available: true },
      saturday: { start: "08:00", end: "12:00", available: true },
      sunday: { start: "", end: "", available: false }
    },
    consultationFee: 2500,
    languages: ["Hindi", "English", "Punjabi"],
    awards: ["Best Pediatric Cardiologist 2022", "Lifetime Achievement Award 2023"],
    availability: {
      isAvailable: true,
      nextAvailableSlot: new Date(Date.now() + 72 * 60 * 60 * 1000)
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
        street: "123, MG Road",
        city: "Delhi",
        state: "Delhi",
        pincode: "110001"
      }
    },
    credentials: {
      username: "rajesh_kumar_90",
      password: "patient123",
      isActive: true,
      isVerified: true
    },
    emergencyContact: {
      name: "Sunita Kumar",
      relationship: "spouse",
      phone: "+91-98765-12346",
      email: "sunita.kumar@gmail.com"
    },
    medicalHistory: {
      allergies: [
        { 
          allergen: "Penicillin", 
          severity: "moderate", 
          description: "Skin rash and itching when administered",
          diagnosedDate: new Date("2018-06-15")
        },
        { 
          allergen: "Peanuts", 
          severity: "mild", 
          description: "Mild digestive discomfort",
          diagnosedDate: new Date("2020-02-10")
        }
      ],
      chronicConditions: [
        { 
          condition: "Hypertension", 
          diagnosedDate: new Date("2020-01-15"), 
          status: "controlled",
          medication: "Amlodipine 5mg daily"
        },
        { 
          condition: "Type 2 Diabetes", 
          diagnosedDate: new Date("2022-03-20"), 
          status: "controlled",
          medication: "Metformin 500mg twice daily"
        }
      ],
      surgicalHistory: [
        { 
          surgery: "Appendectomy", 
          date: new Date("2015-08-10"), 
          hospital: "Apollo Medical Center", 
          surgeon: "Dr. Ramesh Sharma",
          complications: "None"
        }
      ],
      familyHistory: [
        { relation: "father", condition: "Diabetes Type 2", ageOfOnset: 55 },
        { relation: "mother", condition: "Hypertension", ageOfOnset: 52 },
        { relation: "grandfather", condition: "Heart Disease", ageOfOnset: 68 }
      ],
      vaccinations: [
        { vaccine: "COVID-19", date: new Date("2021-06-15"), booster: true },
        { vaccine: "Hepatitis B", date: new Date("2019-04-20"), booster: false },
        { vaccine: "Tetanus", date: new Date("2020-12-05"), booster: false }
      ]
    },
    insurance: {
      provider: "LIC Health Plus",
      policyNumber: "LIC123456789",
      coverage: 500000,
      validUntil: new Date("2025-12-31"),
      isActive: true
    },
    lifestyle: {
      smoking: "never",
      alcohol: "occasionally",
      exercise: "moderate",
      diet: "vegetarian"
    },
    vitalSigns: {
      height: 175,
      weight: 78,
      bmi: 25.4,
      bloodPressure: { systolic: 130, diastolic: 85 },
      heartRate: 72,
      temperature: 98.6,
      lastUpdated: new Date()
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
        street: "456, Brigade Road",
        city: "Mumbai",
        state: "Maharashtra",
        pincode: "400080"
      }
    },
    credentials: {
      username: "meera_nair_85",
      password: "patient123",
      isActive: true,
      isVerified: true
    },
    emergencyContact: {
      name: "Suresh Nair",
      relationship: "spouse",
      phone: "+91-87654-32110",
      email: "suresh.nair@gmail.com"
    },
    medicalHistory: {
      allergies: [
        { 
          allergen: "Sulfa drugs", 
          severity: "severe", 
          description: "Difficulty breathing and swelling",
          diagnosedDate: new Date("2010-05-20")
        }
      ],
      chronicConditions: [
        { 
          condition: "Diabetes Type 2", 
          diagnosedDate: new Date("2018-03-20"), 
          status: "controlled",
          medication: "Metformin 500mg + Glimepiride 2mg"
        },
        { 
          condition: "Hypothyroidism", 
          diagnosedDate: new Date("2019-08-15"), 
          status: "controlled",
          medication: "Levothyroxine 50mcg daily"
        }
      ],
      surgicalHistory: [
        { 
          surgery: "Appendectomy", 
          date: new Date("2015-08-10"), 
          hospital: "Fortis Healthcare", 
          surgeon: "Dr. Ramesh Kothari",
          complications: "None"
        },
        { 
          surgery: "Cesarean Section", 
          date: new Date("2020-02-14"), 
          hospital: "Fortis Healthcare", 
          surgeon: "Dr. Priya Sharma",
          complications: "None"
        }
      ],
      familyHistory: [
        { relation: "mother", condition: "Diabetes Type 2", ageOfOnset: 50 },
        { relation: "sister", condition: "Thyroid", ageOfOnset: 35 },
        { relation: "grandmother", condition: "Hypertension", ageOfOnset: 60 }
      ],
      vaccinations: [
        { vaccine: "COVID-19", date: new Date("2021-07-10"), booster: true },
        { vaccine: "Influenza", date: new Date("2023-10-15"), booster: true },
        { vaccine: "HPV", date: new Date("2019-06-20"), booster: false }
      ]
    },
    insurance: {
      provider: "Star Health Insurance",
      policyNumber: "STAR987654321",
      coverage: 300000,
      validUntil: new Date("2025-09-30"),
      isActive: true
    },
    lifestyle: {
      smoking: "never",
      alcohol: "never",
      exercise: "regular",
      diet: "vegetarian"
    },
    vitalSigns: {
      height: 162,
      weight: 65,
      bmi: 24.8,
      bloodPressure: { systolic: 118, diastolic: 78 },
      heartRate: 68,
      temperature: 98.4,
      lastUpdated: new Date()
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
        street: "789, Residency Road",
        city: "Bangalore",
        state: "Karnataka",
        pincode: "560025"
      }
    },
    credentials: {
      username: "arun_pillai_75",
      password: "patient123",
      isActive: true,
      isVerified: true
    },
    emergencyContact: {
      name: "Lakshmi Pillai",
      relationship: "spouse",
      phone: "+91-76543-21099",
      email: "lakshmi.pillai@gmail.com"
    },
    medicalHistory: {
      allergies: [],
      chronicConditions: [
        { 
          condition: "Osteoarthritis - Knee", 
          diagnosedDate: new Date("2015-11-05"), 
          status: "active",
          medication: "Diclofenac 50mg as needed"
        },
        { 
          condition: "High Cholesterol", 
          diagnosedDate: new Date("2021-04-12"), 
          status: "controlled",
          medication: "Atorvastatin 20mg daily"
        }
      ],
      surgicalHistory: [
        { 
          surgery: "Right Knee Replacement", 
          date: new Date("2020-06-15"), 
          hospital: "AIIMS Delhi", 
          surgeon: "Dr. Amit Gupta",
          complications: "None"
        },
        { 
          surgery: "Cataract Surgery - Left Eye", 
          date: new Date("2022-01-20"), 
          hospital: "Local Eye Hospital", 
          surgeon: "Dr. Ravi Kumar",
          complications: "None"
        }
      ],
      familyHistory: [
        { relation: "father", condition: "Arthritis", ageOfOnset: 60 },
        { relation: "mother", condition: "Hypertension", ageOfOnset: 58 },
        { relation: "brother", condition: "Diabetes", ageOfOnset: 45 }
      ],
      vaccinations: [
        { vaccine: "COVID-19", date: new Date("2021-05-25"), booster: true },
        { vaccine: "Pneumonia", date: new Date("2022-11-10"), booster: false },
        { vaccine: "Tetanus", date: new Date("2021-08-15"), booster: false }
      ]
    },
    insurance: {
      provider: "New India Assurance",
      policyNumber: "NIA456789123",
      coverage: 200000,
      validUntil: new Date("2025-11-30"),
      isActive: true
    },
    lifestyle: {
      smoking: "former",
      alcohol: "occasionally",
      exercise: "light",
      diet: "non-vegetarian"
    },
    vitalSigns: {
      height: 170,
      weight: 82,
      bmi: 28.4,
      bloodPressure: { systolic: 140, diastolic: 90 },
      heartRate: 75,
      temperature: 98.5,
      lastUpdated: new Date()
    }
  },
  {
    patientId: "PAT004",
    uhi: "UHI004SS2024",
    personalInfo: {
      firstName: "Sita",
      lastName: "Sharma",
      email: "sita.sharma@gmail.com",
      phone: "+91-99887-66554",
      aadhaarNumber: "456789012345",
      dateOfBirth: new Date("1992-05-12"),
      gender: "female",
      bloodGroup: "AB+",
      address: {
        street: "101, Sector 15",
        city: "Noida",
        state: "Uttar Pradesh",
        pincode: "201301"
      }
    },
    credentials: {
      username: "sita_sharma_92",
      password: "patient123",
      isActive: true,
      isVerified: true
    },
    emergencyContact: {
      name: "Ramesh Sharma",
      relationship: "spouse",
      phone: "+91-99887-66555",
      email: "ramesh.sharma@gmail.com"
    },
    medicalHistory: {
      allergies: [
        { 
          allergen: "Latex", 
          severity: "mild", 
          description: "Skin irritation with latex gloves",
          diagnosedDate: new Date("2019-03-10")
        }
      ],
      chronicConditions: [
        { 
          condition: "Migraine", 
          diagnosedDate: new Date("2017-09-20"), 
          status: "active",
          medication: "Sumatriptan as needed"
        }
      ],
      surgicalHistory: [],
      familyHistory: [
        { relation: "mother", condition: "Migraine", ageOfOnset: 25 },
        { relation: "father", condition: "High Blood Pressure", ageOfOnset: 45 }
      ],
      vaccinations: [
        { vaccine: "COVID-19", date: new Date("2021-08-20"), booster: true },
        { vaccine: "HPV", date: new Date("2020-01-15"), booster: false }
      ]
    },
    insurance: {
      provider: "HDFC ERGO Health",
      policyNumber: "HDFC112233445",
      coverage: 750000,
      validUntil: new Date("2026-01-31"),
      isActive: true
    },
    lifestyle: {
      smoking: "never",
      alcohol: "never",
      exercise: "regular",
      diet: "vegetarian"
    },
    vitalSigns: {
      height: 158,
      weight: 55,
      bmi: 22.0,
      bloodPressure: { systolic: 110, diastolic: 70 },
      heartRate: 65,
      temperature: 98.2,
      lastUpdated: new Date()
    }
  },
  {
    patientId: "PAT005",
    uhi: "UHI005AK2024",
    personalInfo: {
      firstName: "Arjun",
      lastName: "Kumar",
      email: "arjun.kumar@gmail.com",
      phone: "+91-88776-65543",
      aadhaarNumber: "567890123456",
      dateOfBirth: new Date("1988-09-30"),
      gender: "male",
      bloodGroup: "O-",
      address: {
        street: "202, Park Street",
        city: "Kolkata",
        state: "West Bengal",
        pincode: "700016"
      }
    },
    credentials: {
      username: "arjun_kumar_88",
      password: "patient123",
      isActive: true,
      isVerified: true
    },
    emergencyContact: {
      name: "Priya Kumar",
      relationship: "spouse",
      phone: "+91-88776-65544",
      email: "priya.kumar@gmail.com"
    },
    medicalHistory: {
      allergies: [
        { 
          allergen: "Dust mites", 
          severity: "moderate", 
          description: "Respiratory symptoms and sneezing",
          diagnosedDate: new Date("2015-04-25")
        }
      ],
      chronicConditions: [
        { 
          condition: "Asthma", 
          diagnosedDate: new Date("2010-06-18"), 
          status: "controlled",
          medication: "Salbutamol inhaler as needed"
        }
      ],
      surgicalHistory: [
        { 
          surgery: "Hernia Repair", 
          date: new Date("2019-11-25"), 
          hospital: "Apollo Kolkata", 
          surgeon: "Dr. Subrata Das",
          complications: "None"
        }
      ],
      familyHistory: [
        { relation: "mother", condition: "Asthma", ageOfOnset: 30 },
        { relation: "uncle", condition: "Heart Disease", ageOfOnset: 55 }
      ],
      vaccinations: [
        { vaccine: "COVID-19", date: new Date("2021-06-05"), booster: true },
        { vaccine: "Influenza", date: new Date("2023-09-15"), booster: true }
      ]
    },
    insurance: {
      provider: "Bajaj Allianz Health",
      policyNumber: "BAH998877665",
      coverage: 400000,
      validUntil: new Date("2025-10-31"),
      isActive: true
    },
    lifestyle: {
      smoking: "never",
      alcohol: "socially",
      exercise: "moderate",
      diet: "non-vegetarian"
    },
    vitalSigns: {
      height: 180,
      weight: 75,
      bmi: 23.1,
      bloodPressure: { systolic: 120, diastolic: 80 },
      heartRate: 70,
      temperature: 98.6,
      lastUpdated: new Date()
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
    console.log('🍃 Connected to MongoDB for enhanced seeding');
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    process.exit(1);
  }
};

// Enhanced seed function with comprehensive data
const seedDatabase = async () => {
  try {
    console.log('🚀 Starting enhanced database seeding...');

    // Clear existing data
    console.log('🧹 Clearing existing data...');
    await Promise.all([
      Hospital.deleteMany({}),
      Doctor.deleteMany({}),
      Patient.deleteMany({}),
      Prescription.deleteMany({})
    ]);
    console.log('✅ Existing data cleared');

    // Insert hospitals
    console.log('🏥 Creating hospitals with comprehensive data...');
    const hospitals = await Hospital.insertMany(sampleHospitals);
    console.log(`✅ Created ${hospitals.length} hospitals with detailed information`);

    // Link doctors to hospitals and insert
    console.log('👨‍⚕️ Creating doctors with professional profiles...');
    sampleDoctors[0].hospital = hospitals[0]._id; // Apollo
    sampleDoctors[1].hospital = hospitals[1]._id; // Fortis
    sampleDoctors[2].hospital = hospitals[2]._id; // AIIMS
    sampleDoctors[3].hospital = hospitals[3]._id; // Max
    sampleDoctors[4].hospital = hospitals[4]._id; // Medanta

    const doctors = await Doctor.insertMany(sampleDoctors);
    console.log(`✅ Created ${doctors.length} doctors with complete profiles`);

    // Update hospital doctor counts
    await Promise.all(hospitals.map((hospital, index) => 
      Hospital.findByIdAndUpdate(hospital._id, { 
        $inc: { 'statistics.totalDoctors': index < doctors.length ? 1 : 0 } 
      })
    ));

    // Insert patients individually to trigger password hashing middleware
    console.log('🏃‍♂️ Creating patients with comprehensive medical histories...');
    const patients = [];
    for (const patientData of samplePatients) {
      const patient = new Patient(patientData);
      await patient.save(); // This will trigger the pre-save middleware for password hashing
      patients.push(patient);
    }
    console.log(`✅ Created ${patients.length} patients with detailed medical records`);

    // Create comprehensive prescriptions
    console.log('💊 Creating detailed prescriptions...');
    const comprehensivePrescriptions = [
      {
        prescriptionId: "RX001",
        patient: patients[0]._id,
        doctor: doctors[0]._id,
        hospital: hospitals[0]._id,
        consultation: {
          date: new Date(),
          symptoms: ["Chest discomfort", "Shortness of breath", "Palpitations"],
          diagnosis: {
            primary: "Hypertensive Heart Disease",
            secondary: ["Type 2 Diabetes Mellitus"],
            icdCode: "I11.9"
          },
          notes: "Patient shows good compliance with medications. Blood pressure well controlled. Continue current regimen with lifestyle modifications.",
          followUpDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
        },
        medications: [
          {
            name: "Amlodipine",
            genericName: "Amlodipine Besylate",
            dosage: "5mg",
            frequency: "once daily",
            duration: { value: 30, unit: "days" },
            instructions: {
              afterFood: true,
              timing: ["morning"],
              specialInstructions: "Take with breakfast. Monitor blood pressure weekly."
            },
            quantity: { prescribed: 30, unit: "tablets" }
          },
          {
            name: "Metformin",
            genericName: "Metformin Hydrochloride",
            dosage: "500mg",
            frequency: "twice daily",
            duration: { value: 30, unit: "days" },
            instructions: {
              afterFood: true,
              timing: ["morning", "evening"],
              specialInstructions: "Take with meals to reduce stomach upset."
            },
            quantity: { prescribed: 60, unit: "tablets" }
          }
        ],
        tests: [
          {
            testName: "HbA1c",
            instructions: "Fasting not required",
            urgency: "routine",
            estimatedCost: 500
          },
          {
            testName: "Lipid Profile",
            instructions: "12-hour fasting required",
            urgency: "routine",
            estimatedCost: 800
          }
        ],
        status: "active",
        billing: {
          consultationFee: 1500,
          medicationCost: 450,
          testCost: 1300,
          totalAmount: 3250
        }
      },
      {
        prescriptionId: "RX002",
        patient: patients[1]._id,
        doctor: doctors[1]._id,
        hospital: hospitals[1]._id,
        consultation: {
          date: new Date(),
          symptoms: ["Severe headaches", "Visual disturbances", "Neck stiffness"],
          diagnosis: {
            primary: "Migraine with Aura",
            secondary: ["Cervical Spondylosis"],
            icdCode: "G43.1"
          },
          notes: "Patient experiencing frequent migraine episodes. MRI shows mild cervical spine changes. Prescribing preventive medication.",
          followUpDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
        },
        medications: [
          {
            name: "Sumatriptan",
            genericName: "Sumatriptan Succinate",
            dosage: "50mg",
            frequency: "as needed",
            duration: { value: 30, unit: "days" },
            instructions: {
              beforeFood: false,
              timing: ["when needed"],
              specialInstructions: "Take at onset of migraine. Maximum 2 tablets in 24 hours."
            },
            quantity: { prescribed: 10, unit: "tablets" }
          },
          {
            name: "Propranolol",
            genericName: "Propranolol Hydrochloride",
            dosage: "40mg",
            frequency: "twice daily",
            duration: { value: 30, unit: "days" },
            instructions: {
              afterFood: true,
              timing: ["morning", "evening"],
              specialInstructions: "For migraine prevention. Do not stop suddenly."
            },
            quantity: { prescribed: 60, unit: "tablets" }
          }
        ],
        tests: [
          {
            testName: "MRI Brain",
            instructions: "Remove all metal objects",
            urgency: "routine",
            estimatedCost: 8000
          }
        ],
        status: "active",
        billing: {
          consultationFee: 2000,
          medicationCost: 650,
          testCost: 8000,
          totalAmount: 10650
        }
      },
      {
        prescriptionId: "RX003",
        patient: patients[2]._id,
        doctor: doctors[2]._id,
        hospital: hospitals[2]._id,
        consultation: {
          date: new Date(),
          symptoms: ["Knee pain", "Morning stiffness", "Difficulty walking"],
          diagnosis: {
            primary: "Osteoarthritis - Bilateral Knee",
            secondary: ["Post-surgical follow-up"],
            icdCode: "M17.0"
          },
          notes: "Post-operative recovery progressing well. Knee replacement healing properly. Continue physiotherapy and pain management.",
          followUpDate: new Date(Date.now() + 21 * 24 * 60 * 60 * 1000)
        },
        medications: [
          {
            name: "Diclofenac",
            genericName: "Diclofenac Sodium",
            dosage: "50mg",
            frequency: "twice daily",
            duration: { value: 14, unit: "days" },
            instructions: {
              afterFood: true,
              timing: ["morning", "evening"],
              specialInstructions: "Take with food. Apply ice after physiotherapy."
            },
            quantity: { prescribed: 28, unit: "tablets" }
          },
          {
            name: "Calcium + Vitamin D3",
            genericName: "Calcium Carbonate + Cholecalciferol",
            dosage: "500mg + 250 IU",
            frequency: "once daily",
            duration: { value: 90, unit: "days" },
            instructions: {
              afterFood: true,
              timing: ["evening"],
              specialInstructions: "Take with dinner for better absorption."
            },
            quantity: { prescribed: 90, unit: "tablets" }
          }
        ],
        tests: [
          {
            testName: "X-Ray Knee",
            instructions: "Weight bearing views",
            urgency: "routine",
            estimatedCost: 1200
          }
        ],
        status: "active",
        billing: {
          consultationFee: 1200,
          medicationCost: 380,
          testCost: 1200,
          totalAmount: 2780
        }
      }
    ];

    const prescriptions = await Prescription.insertMany(comprehensivePrescriptions);
    console.log(`✅ Created ${prescriptions.length} detailed prescriptions`);

    // Add patients to doctors' patient lists with comprehensive data
    console.log('🔗 Linking patients to doctors with consultation history...');
    await Promise.all([
      Doctor.findByIdAndUpdate(doctors[0]._id, {
        $push: { 
          patients: { 
            patient: patients[0]._id, 
            firstConsultation: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000),
            lastConsultation: new Date(),
            status: 'active',
            totalConsultations: 5
          }
        },
        $inc: { 'statistics.totalPatients': 1, 'statistics.totalConsultations': 5 }
      }),
      Doctor.findByIdAndUpdate(doctors[1]._id, {
        $push: { 
          patients: { 
            patient: patients[1]._id, 
            firstConsultation: new Date(Date.now() - 60 * 24 * 60 * 60 * 1000),
            lastConsultation: new Date(),
            status: 'active',
            totalConsultations: 3
          }
        },
        $inc: { 'statistics.totalPatients': 1, 'statistics.totalConsultations': 3 }
      }),
      Doctor.findByIdAndUpdate(doctors[2]._id, {
        $push: { 
          patients: { 
            patient: patients[2]._id, 
            firstConsultation: new Date(Date.now() - 120 * 24 * 60 * 60 * 1000),
            lastConsultation: new Date(),
            status: 'active',
            totalConsultations: 8
          }
        },
        $inc: { 'statistics.totalPatients': 1, 'statistics.totalConsultations': 8 }
      })
    ]);

    // Update hospital patient counts
    await Promise.all([
      Hospital.findByIdAndUpdate(hospitals[0]._id, { $inc: { 'statistics.totalPatients': 1 } }),
      Hospital.findByIdAndUpdate(hospitals[1]._id, { $inc: { 'statistics.totalPatients': 1 } }),
      Hospital.findByIdAndUpdate(hospitals[2]._id, { $inc: { 'statistics.totalPatients': 1 } })
    ]);

    console.log('🎉 Enhanced database seeding completed successfully!');
    console.log('\n📊 Comprehensive Database Summary:');
    console.log(`   🏥 Hospitals: ${hospitals.length} (with complete facility information)`);
    console.log(`   👨‍⚕️ Doctors: ${doctors.length} (with professional profiles & schedules)`);
    console.log(`   🏃‍♂️ Patients: ${patients.length} (with detailed medical histories)`);
    console.log(`   💊 Prescriptions: ${prescriptions.length} (with medications & billing)`);
    
    console.log('\n🔑 Enhanced Login Credentials:');
    console.log('   🏥 Hospital Admins:');
    console.log('     - apollo_admin / apollo123 (Apollo Medical Center)');
    console.log('     - fortis_admin / fortis123 (Fortis Healthcare)');
    console.log('     - aiims_admin / aiims123 (AIIMS Delhi)');
    console.log('     - max_admin / max123 (Max Super Speciality)');
    console.log('     - medanta_admin / medanta123 (Medanta)');
    
    console.log('   👨‍⚕️ Doctors:');
    console.log('     - dr_rajesh_sharma / doctor123 (Cardiologist)');
    console.log('     - dr_priya_nair / doctor123 (Neurosurgeon)');
    console.log('     - dr_amit_gupta / doctor123 (Orthopedist)');
    console.log('     - dr_sunita_agarwal / doctor123 (Gynecologist)');
    console.log('     - dr_vikram_singh / doctor123 (Pediatric Cardiologist)');
    
    console.log('   🏃‍♂️ Patients:');
    console.log('     - rajesh_kumar_90 / patient123 (Hypertension + Diabetes)');
    console.log('     - meera_nair_85 / patient123 (Diabetes + Thyroid)');
    console.log('     - arun_pillai_75 / patient123 (Arthritis post-surgery)');
    console.log('     - sita_sharma_92 / patient123 (Migraine)');
    console.log('     - arjun_kumar_88 / patient123 (Asthma)');

    console.log('\n🌟 New Features Added:');
    console.log('   ✅ Comprehensive hospital facilities & departments');
    console.log('   ✅ Doctor professional profiles with qualifications');
    console.log('   ✅ Patient medical histories with allergies & surgeries');
    console.log('   ✅ Detailed prescription with billing information');
    console.log('   ✅ Vital signs and lifestyle information');
    console.log('   ✅ Insurance details and emergency contacts');
    console.log('   ✅ Vaccination records and family history');

  } catch (error) {
    console.error('❌ Error seeding enhanced database:', error);
    process.exit(1);
  }
};

// Run enhanced seeding
const runEnhancedSeeder = async () => {
  await connectDB();
  await seedDatabase();
  await mongoose.connection.close();
  console.log('\n👋 Database connection closed');
  console.log('🚀 Enhanced DHRMS database is ready for production use!');
  process.exit(0);
};

// Run if called directly
if (require.main === module) {
  runEnhancedSeeder();
}

module.exports = { seedDatabase, connectDB };
