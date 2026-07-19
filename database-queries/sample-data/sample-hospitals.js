/**
 * Sample Hospital Data for DHRMS
 * 
 * This file contains sample hospital records for testing and development
 */

const bcrypt = require('bcryptjs');

const sampleHospitals = [
  {
    hospitalId: "HOSP001",
    name: "All India Institute of Medical Sciences",
    type: "government",
    registrationNumber: "GOV001AIIMS",
    address: {
      street: "Sri Aurobindo Marg, Ansari Nagar",
      city: "New Delhi",
      state: "Delhi",
      pincode: "110029",
      coordinates: {
        latitude: 28.5672,
        longitude: 77.2100
      }
    },
    contactInfo: {
      phone: "+91-11-26588500",
      email: "info@aiims.edu",
      website: "https://www.aiims.edu",
      emergencyContact: "+91-11-26588700",
      fax: "+91-11-26588663"
    },
    credentials: {
      username: "aiims_delhi",
      password: bcrypt.hashSync("hospital123", 12),
      email: "admin@aiims.edu",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    facilities: [
      {
        name: "Emergency Department",
        capacity: 50,
        available: 12,
        equipment: ["Ventilators", "Defibrillators", "X-Ray", "CT Scan"],
        isActive: true
      },
      {
        name: "ICU",
        capacity: 100,
        available: 8,
        equipment: ["Ventilators", "Cardiac Monitors", "Dialysis Machines"],
        isActive: true
      },
      {
        name: "Operation Theater",
        capacity: 25,
        available: 3,
        equipment: ["Anesthesia Machines", "Surgical Instruments", "Monitors"],
        isActive: true
      }
    ],
    departments: [
      {
        name: "Cardiology",
        head: "DOC001",
        doctors: ["DOC001", "DOC004"],
        beds: 80,
        availableBeds: 5,
        services: ["Angioplasty", "Bypass Surgery", "Pacemaker Implantation"]
      },
      {
        name: "Neurology",
        head: "DOC005",
        doctors: ["DOC005", "DOC006"],
        beds: 60,
        availableBeds: 8,
        services: ["Brain Surgery", "Stroke Treatment", "Epilepsy Management"]
      }
    ],
    statistics: {
      totalDoctors: 120,
      totalPatients: 15000,
      totalBeds: 2500,
      availableBeds: 180,
      occupancyRate: 92.8,
      averageRating: 4.7,
      totalRatings: 2500
    },
    services: [
      {
        name: "Emergency Care",
        description: "24x7 Emergency medical services",
        cost: 5000,
        duration: "Immediate",
        department: "Emergency"
      },
      {
        name: "Cardiac Surgery",
        description: "Comprehensive cardiac surgical procedures",
        cost: 350000,
        duration: "4-6 hours",
        department: "Cardiology"
      }
    ],
    certification: {
      accreditation: "NABH",
      validUntil: new Date("2025-12-31"),
      isVerified: true,
      certifyingBody: "National Accreditation Board for Hospitals"
    },
    insurance: {
      acceptedProviders: ["CGHS", "ESI", "LIC Health", "Star Health"],
      cashlessAvailable: true,
      emergencyCoverage: true
    },
    operatingHours: {
      general: {
        startTime: "08:00",
        endTime: "20:00"
      },
      emergency: {
        available24x7: true,
        startTime: "00:00",
        endTime: "23:59"
      },
      pharmacy: {
        startTime: "08:00",
        endTime: "22:00",
        available24x7: false
      }
    },
    amenities: ["Parking", "Cafeteria", "WiFi", "ATM", "Pharmacy", "Blood Bank"],
    reviews: [
      {
        patientId: "PAT001",
        rating: 5,
        comment: "Excellent medical care and facilities",
        service: "Cardiology",
        date: new Date("2023-08-20"),
        verified: true
      }
    ],
    emergencyServices: {
      ambulance: true,
      traumaCenter: true,
      bloodBank: true,
      burnUnit: true,
      emergencyOT: true
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },

  {
    hospitalId: "HOSP002",
    name: "Apollo Hospital",
    type: "private",
    registrationNumber: "PVT002APOLLO",
    address: {
      street: "Sarita Vihar, Mathura Road",
      city: "New Delhi",
      state: "Delhi",
      pincode: "110076",
      coordinates: {
        latitude: 28.5355,
        longitude: 77.2839
      }
    },
    contactInfo: {
      phone: "+91-11-26925858",
      email: "info@apollohospitals.com",
      website: "https://www.apollohospitals.com",
      emergencyContact: "+91-11-26925999",
      fax: "+91-11-26925800"
    },
    credentials: {
      username: "apollo_delhi",
      password: bcrypt.hashSync("hospital456", 12),
      email: "admin@apollohospitals.com",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    facilities: [
      {
        name: "Emergency Department",
        capacity: 40,
        available: 8,
        equipment: ["Ventilators", "Defibrillators", "MRI", "CT Scan"],
        isActive: true
      },
      {
        name: "Critical Care",
        capacity: 80,
        available: 12,
        equipment: ["Ventilators", "ECMO", "Dialysis"],
        isActive: true
      }
    ],
    departments: [
      {
        name: "Cardiology",
        head: "DOC007",
        doctors: ["DOC007", "DOC008"],
        beds: 60,
        availableBeds: 10,
        services: ["Interventional Cardiology", "Cardiac Surgery", "Electrophysiology"]
      },
      {
        name: "Oncology",
        head: "DOC009",
        doctors: ["DOC009", "DOC010"],
        beds: 40,
        availableBeds: 6,
        services: ["Chemotherapy", "Radiation Therapy", "Surgical Oncology"]
      }
    ],
    statistics: {
      totalDoctors: 85,
      totalPatients: 12000,
      totalBeds: 1200,
      availableBeds: 95,
      occupancyRate: 92.1,
      averageRating: 4.6,
      totalRatings: 1800
    },
    services: [
      {
        name: "Health Checkup",
        description: "Comprehensive health screening packages",
        cost: 8000,
        duration: "4 hours",
        department: "General Medicine"
      },
      {
        name: "Robotic Surgery",
        description: "Minimally invasive robotic surgical procedures",
        cost: 500000,
        duration: "2-8 hours",
        department: "Surgery"
      }
    ],
    certification: {
      accreditation: "JCI",
      validUntil: new Date("2026-06-30"),
      isVerified: true,
      certifyingBody: "Joint Commission International"
    },
    insurance: {
      acceptedProviders: ["Star Health", "HDFC ERGO", "ICICI Lombard", "Max Bupa"],
      cashlessAvailable: true,
      emergencyCoverage: true
    },
    operatingHours: {
      general: {
        startTime: "07:00",
        endTime: "21:00"
      },
      emergency: {
        available24x7: true,
        startTime: "00:00",
        endTime: "23:59"
      },
      pharmacy: {
        startTime: "07:00",
        endTime: "23:00",
        available24x7: true
      }
    },
    amenities: ["Valet Parking", "Multi-cuisine Restaurant", "WiFi", "Gift Shop", "Pharmacy"],
    reviews: [
      {
        patientId: "PAT002",
        rating: 4,
        comment: "Good facilities but expensive",
        service: "General Medicine",
        date: new Date("2023-07-15"),
        verified: true
      }
    ],
    emergencyServices: {
      ambulance: true,
      traumaCenter: true,
      bloodBank: true,
      burnUnit: false,
      emergencyOT: true
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },

  {
    hospitalId: "HOSP003",
    name: "Fortis Hospital",
    type: "private",
    registrationNumber: "PVT003FORTIS",
    address: {
      street: "Sector 62, Phase VIII",
      city: "Mohali",
      state: "Punjab",
      pincode: "160062",
      coordinates: {
        latitude: 30.6990,
        longitude: 76.7339
      }
    },
    contactInfo: {
      phone: "+91-172-5096001",
      email: "info@fortishealthcare.com",
      website: "https://www.fortishealthcare.com",
      emergencyContact: "+91-172-5096100",
      fax: "+91-172-5096050"
    },
    credentials: {
      username: "fortis_mohali",
      password: bcrypt.hashSync("hospital789", 12),
      email: "admin@fortishealthcare.com",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    facilities: [
      {
        name: "Emergency Department",
        capacity: 30,
        available: 5,
        equipment: ["Ventilators", "Defibrillators", "Ultrasound"],
        isActive: true
      },
      {
        name: "Maternity Ward",
        capacity: 25,
        available: 8,
        equipment: ["Fetal Monitors", "Incubators", "Labor Beds"],
        isActive: true
      }
    ],
    departments: [
      {
        name: "Gynecology",
        head: "DOC002",
        doctors: ["DOC002", "DOC011"],
        beds: 35,
        availableBeds: 8,
        services: ["Normal Delivery", "C-Section", "Gynecological Surgery"]
      },
      {
        name: "Pediatrics",
        head: "DOC012",
        doctors: ["DOC012", "DOC013"],
        beds: 30,
        availableBeds: 12,
        services: ["Neonatal Care", "Pediatric Surgery", "Vaccination"]
      }
    ],
    statistics: {
      totalDoctors: 65,
      totalPatients: 8500,
      totalBeds: 800,
      availableBeds: 72,
      occupancyRate: 91.0,
      averageRating: 4.4,
      totalRatings: 1200
    },
    services: [
      {
        name: "Maternity Package",
        description: "Complete pregnancy and delivery care",
        cost: 150000,
        duration: "9 months",
        department: "Gynecology"
      },
      {
        name: "Pediatric Care",
        description: "Comprehensive child healthcare",
        cost: 3000,
        duration: "1 hour",
        department: "Pediatrics"
      }
    ],
    certification: {
      accreditation: "NABH",
      validUntil: new Date("2024-11-30"),
      isVerified: true,
      certifyingBody: "National Accreditation Board for Hospitals"
    },
    insurance: {
      acceptedProviders: ["LIC Health", "HDFC ERGO", "United India"],
      cashlessAvailable: true,
      emergencyCoverage: false
    },
    operatingHours: {
      general: {
        startTime: "08:00",
        endTime: "20:00"
      },
      emergency: {
        available24x7: true,
        startTime: "00:00",
        endTime: "23:59"
      },
      pharmacy: {
        startTime: "08:00",
        endTime: "20:00",
        available24x7: false
      }
    },
    amenities: ["Parking", "Cafeteria", "WiFi", "Pharmacy"],
    reviews: [
      {
        patientId: "PAT003",
        rating: 4,
        comment: "Good maternity services",
        service: "Gynecology",
        date: new Date("2023-06-10"),
        verified: true
      }
    ],
    emergencyServices: {
      ambulance: true,
      traumaCenter: false,
      bloodBank: true,
      burnUnit: false,
      emergencyOT: true
    },
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

module.exports = sampleHospitals;
