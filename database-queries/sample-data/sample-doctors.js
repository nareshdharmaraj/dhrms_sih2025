/**
 * Sample Doctor Data for DHRMS
 * 
 * This file contains sample doctor records for testing and development
 */

const bcrypt = require('bcryptjs');

const sampleDoctors = [
  {
    doctorId: "DOC001",
    personalInfo: {
      firstName: "Dr. Rajesh",
      lastName: "Patel",
      email: "dr.rajesh.patel@hospital.com",
      phone: "+91-9876543220",
      dateOfBirth: new Date("1975-04-12"),
      gender: "male",
      address: {
        street: "15 Medical Lane",
        city: "Delhi",
        state: "Delhi",
        pincode: "110002"
      }
    },
    professionalInfo: {
      specialization: "Cardiology",
      qualification: "MBBS, MD (Cardiology)",
      experience: 15,
      licenseNumber: "DLH12345",
      registrationDate: new Date("2010-06-15"),
      medicalCouncil: "Delhi Medical Council",
      currentPosition: "Senior Consultant",
      department: "Cardiology"
    },
    credentials: {
      username: "dr_rajesh_patel",
      password: bcrypt.hashSync("doctor123", 12),
      email: "dr.rajesh.patel@hospital.com",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    hospitalAffiliation: {
      primaryHospital: "HOSP001",
      otherHospitals: ["HOSP002"],
      consultationType: "full-time"
    },
    consultationFee: {
      regular: 1500,
      emergency: 2500,
      followUp: 800,
      online: 1000
    },
    availability: {
      schedule: [
        { day: "Monday", startTime: "09:00", endTime: "17:00", isAvailable: true, maxPatients: 20 },
        { day: "Tuesday", startTime: "09:00", endTime: "17:00", isAvailable: true, maxPatients: 20 },
        { day: "Wednesday", startTime: "09:00", endTime: "17:00", isAvailable: true, maxPatients: 20 },
        { day: "Thursday", startTime: "09:00", endTime: "17:00", isAvailable: true, maxPatients: 20 },
        { day: "Friday", startTime: "09:00", endTime: "17:00", isAvailable: true, maxPatients: 20 },
        { day: "Saturday", startTime: "09:00", endTime: "13:00", isAvailable: true, maxPatients: 10 },
        { day: "Sunday", startTime: "10:00", endTime: "12:00", isAvailable: false, maxPatients: 0 }
      ],
      emergencyAvailable: true,
      onlineConsultation: true,
      homeVisit: false
    },
    statistics: {
      totalPatients: 1250,
      totalConsultations: 3500,
      averageRating: 4.8,
      reviews: [{
        patientId: "PAT001",
        rating: 5,
        comment: "Excellent doctor, very caring and professional",
        date: new Date("2023-09-01")
      }]
    },
    certifications: [{
      name: "Advanced Cardiac Life Support (ACLS)",
      issuingBody: "American Heart Association",
      issueDate: new Date("2020-01-15"),
      expiryDate: new Date("2025-01-15"),
      certificateNumber: "AHA123456"
    }],
    research: [{
      title: "Novel Approaches in Cardiac Intervention",
      journal: "Indian Heart Journal",
      publicationDate: new Date("2022-03-20"),
      coAuthors: ["Dr. Sharma", "Dr. Gupta"]
    }],
    preferences: {
      language: "Hindi",
      notifications: {
        email: true,
        sms: true,
        push: true
      },
      autoAcceptAppointments: false
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },

  {
    doctorId: "DOC002", 
    personalInfo: {
      firstName: "Dr. Priya",
      lastName: "Sharma",
      email: "dr.priya.sharma@hospital.com",
      phone: "+91-9876543221",
      dateOfBirth: new Date("1980-08-25"),
      gender: "female",
      address: {
        street: "22 Health Avenue",
        city: "Mumbai",
        state: "Maharashtra",
        pincode: "400002"
      }
    },
    professionalInfo: {
      specialization: "Gynecology",
      qualification: "MBBS, MS (Gynecology)",
      experience: 12,
      licenseNumber: "MH67890",
      registrationDate: new Date("2012-07-20"),
      medicalCouncil: "Maharashtra Medical Council",
      currentPosition: "Consultant",
      department: "Obstetrics & Gynecology"
    },
    credentials: {
      username: "dr_priya_sharma",
      password: bcrypt.hashSync("doctor456", 12),
      email: "dr.priya.sharma@hospital.com",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    hospitalAffiliation: {
      primaryHospital: "HOSP003",
      otherHospitals: [],
      consultationType: "full-time"
    },
    consultationFee: {
      regular: 1200,
      emergency: 2000,
      followUp: 600,
      online: 800
    },
    availability: {
      schedule: [
        { day: "Monday", startTime: "10:00", endTime: "18:00", isAvailable: true, maxPatients: 15 },
        { day: "Tuesday", startTime: "10:00", endTime: "18:00", isAvailable: true, maxPatients: 15 },
        { day: "Wednesday", startTime: "10:00", endTime: "18:00", isAvailable: false, maxPatients: 0 },
        { day: "Thursday", startTime: "10:00", endTime: "18:00", isAvailable: true, maxPatients: 15 },
        { day: "Friday", startTime: "10:00", endTime: "18:00", isAvailable: true, maxPatients: 15 },
        { day: "Saturday", startTime: "10:00", endTime: "14:00", isAvailable: true, maxPatients: 8 },
        { day: "Sunday", startTime: "11:00", endTime: "13:00", isAvailable: false, maxPatients: 0 }
      ],
      emergencyAvailable: true,
      onlineConsultation: true,
      homeVisit: true
    },
    statistics: {
      totalPatients: 950,
      totalConsultations: 2800,
      averageRating: 4.9,
      reviews: [{
        patientId: "PAT002",
        rating: 5,
        comment: "Very compassionate and skilled doctor",
        date: new Date("2023-08-15")
      }]
    },
    certifications: [{
      name: "Laparoscopic Surgery Certification",
      issuingBody: "Association of Gynecologic Laparoscopists",
      issueDate: new Date("2019-05-10"),
      expiryDate: new Date("2024-05-10"),
      certificateNumber: "AGL789012"
    }],
    research: [{
      title: "Minimally Invasive Gynecological Procedures",
      journal: "Journal of Obstetrics and Gynaecology",
      publicationDate: new Date("2021-11-30"),
      coAuthors: ["Dr. Reddy"]
    }],
    preferences: {
      language: "English",
      notifications: {
        email: true,
        sms: false,
        push: true
      },
      autoAcceptAppointments: true
    },
    createdAt: new Date(),
    updatedAt: new Date()
  },

  {
    doctorId: "DOC003",
    personalInfo: {
      firstName: "Dr. Arjun",
      lastName: "Reddy",
      email: "dr.arjun.reddy@hospital.com",
      phone: "+91-9876543222",
      dateOfBirth: new Date("1982-12-03"),
      gender: "male",
      address: {
        street: "88 Care Street",
        city: "Bangalore",
        state: "Karnataka",
        pincode: "560003"
      }
    },
    professionalInfo: {
      specialization: "Orthopedics",
      qualification: "MBBS, MS (Orthopedics)",
      experience: 10,
      licenseNumber: "KA11111",
      registrationDate: new Date("2014-09-12"),
      medicalCouncil: "Karnataka Medical Council",
      currentPosition: "Senior Resident",
      department: "Orthopedics"
    },
    credentials: {
      username: "dr_arjun_reddy",
      password: bcrypt.hashSync("doctor789", 12),
      email: "dr.arjun.reddy@hospital.com",
      isActive: true,
      createdAt: new Date(),
      lastLogin: null
    },
    hospitalAffiliation: {
      primaryHospital: "HOSP004",
      otherHospitals: ["HOSP005"],
      consultationType: "part-time"
    },
    consultationFee: {
      regular: 1000,
      emergency: 1800,
      followUp: 500,
      online: 700
    },
    availability: {
      schedule: [
        { day: "Monday", startTime: "14:00", endTime: "20:00", isAvailable: true, maxPatients: 12 },
        { day: "Tuesday", startTime: "14:00", endTime: "20:00", isAvailable: true, maxPatients: 12 },
        { day: "Wednesday", startTime: "14:00", endTime: "20:00", isAvailable: true, maxPatients: 12 },
        { day: "Thursday", startTime: "14:00", endTime: "20:00", isAvailable: false, maxPatients: 0 },
        { day: "Friday", startTime: "14:00", endTime: "20:00", isAvailable: true, maxPatients: 12 },
        { day: "Saturday", startTime: "09:00", endTime: "15:00", isAvailable: true, maxPatients: 15 },
        { day: "Sunday", startTime: "09:00", endTime: "13:00", isAvailable: true, maxPatients: 10 }
      ],
      emergencyAvailable: false,
      onlineConsultation: false,
      homeVisit: false
    },
    statistics: {
      totalPatients: 680,
      totalConsultations: 1950,
      averageRating: 4.6,
      reviews: [{
        patientId: "PAT003",
        rating: 5,
        comment: "Great expertise in sports injuries",
        date: new Date("2023-07-20")
      }]
    },
    certifications: [{
      name: "Arthroscopic Surgery Certification",
      issuingBody: "Indian Arthroscopy Society",
      issueDate: new Date("2018-03-22"),
      expiryDate: new Date("2023-03-22"),
      certificateNumber: "IAS345678"
    }],
    research: [],
    preferences: {
      language: "Telugu",
      notifications: {
        email: true,
        sms: true,
        push: false
      },
      autoAcceptAppointments: false
    },
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

module.exports = sampleDoctors;
