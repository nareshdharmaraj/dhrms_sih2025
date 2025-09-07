/**
 * Database Indexes for DHRMS
 * 
 * This file contains all database indexes for optimal query performance
 * 
 * Usage: node indexes.js
 */

const { MongoClient } = require('mongodb');

// Database configuration
const DB_NAME = 'dhrms_database';
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017';

async function createAllIndexes() {
  let client;
  
  try {
    console.log('🔗 Connecting to MongoDB...');
    client = new MongoClient(MONGO_URI);
    await client.connect();
    
    const db = client.db(DB_NAME);
    console.log(`📊 Connected to database: ${DB_NAME}`);
    
    console.log('🔍 Creating performance indexes...');
    
    // Patient indexes
    await createPatientIndexes(db);
    
    // Doctor indexes  
    await createDoctorIndexes(db);
    
    // Hospital indexes
    await createHospitalIndexes(db);
    
    // Appointment indexes
    await createAppointmentIndexes(db);
    
    // Medical Record indexes
    await createMedicalRecordIndexes(db);
    
    // Prescription indexes
    await createPrescriptionIndexes(db);
    
    // Telemedicine indexes
    await createTelemedicineIndexes(db);
    
    // Wearable Data indexes
    await createWearableDataIndexes(db);
    
    // Analytics indexes
    await createAnalyticsIndexes(db);
    
    console.log('✅ All indexes created successfully!');
    
  } catch (error) {
    console.error('❌ Index creation failed:', error);
    throw error;
  } finally {
    if (client) {
      await client.close();
      console.log('🔐 Database connection closed');
    }
  }
}

async function createPatientIndexes(db) {
  console.log('👥 Creating Patient indexes...');
  
  const collection = db.collection('patients');
  
  // Primary unique indexes
  await collection.createIndex({ "patientId": 1 }, { unique: true, name: "idx_patient_id" });
  await collection.createIndex({ "uhi": 1 }, { unique: true, name: "idx_patient_uhi" });
  await collection.createIndex({ "credentials.username": 1 }, { unique: true, name: "idx_patient_username" });
  await collection.createIndex({ "personalInfo.aadhaarNumber": 1 }, { unique: true, name: "idx_patient_aadhaar" });
  
  // Search indexes
  await collection.createIndex({ "credentials.email": 1 }, { name: "idx_patient_email" });
  await collection.createIndex({ "personalInfo.phone": 1 }, { name: "idx_patient_phone" });
  await collection.createIndex({ "personalInfo.firstName": 1, "personalInfo.lastName": 1 }, { name: "idx_patient_name" });
  
  // Medical indexes
  await collection.createIndex({ "medicalInfo.bloodGroup": 1 }, { name: "idx_patient_blood_group" });
  await collection.createIndex({ "medicalInfo.allergies": 1 }, { name: "idx_patient_allergies" });
  await collection.createIndex({ "medicalInfo.chronicConditions": 1 }, { name: "idx_patient_chronic" });
  
  // Location indexes
  await collection.createIndex({ "personalInfo.address.city": 1 }, { name: "idx_patient_city" });
  await collection.createIndex({ "personalInfo.address.state": 1 }, { name: "idx_patient_state" });
  await collection.createIndex({ "personalInfo.address.pincode": 1 }, { name: "idx_patient_pincode" });
  
  // Date indexes
  await collection.createIndex({ "personalInfo.dateOfBirth": 1 }, { name: "idx_patient_dob" });
  await collection.createIndex({ "createdAt": -1 }, { name: "idx_patient_created" });
  await collection.createIndex({ "credentials.lastLogin": -1 }, { name: "idx_patient_last_login" });
  
  console.log('✅ Patient indexes created');
}

async function createDoctorIndexes(db) {
  console.log('👨‍⚕️ Creating Doctor indexes...');
  
  const collection = db.collection('doctors');
  
  // Primary unique indexes
  await collection.createIndex({ "doctorId": 1 }, { unique: true, name: "idx_doctor_id" });
  await collection.createIndex({ "credentials.username": 1 }, { unique: true, name: "idx_doctor_username" });
  await collection.createIndex({ "professionalInfo.licenseNumber": 1 }, { unique: true, name: "idx_doctor_license" });
  
  // Professional indexes
  await collection.createIndex({ "professionalInfo.specialization": 1 }, { name: "idx_doctor_specialization" });
  await collection.createIndex({ "professionalInfo.qualification": 1 }, { name: "idx_doctor_qualification" });
  await collection.createIndex({ "professionalInfo.experience": 1 }, { name: "idx_doctor_experience" });
  
  // Hospital affiliation indexes
  await collection.createIndex({ "hospitalAffiliation.primaryHospital": 1 }, { name: "idx_doctor_primary_hospital" });
  await collection.createIndex({ "hospitalAffiliation.otherHospitals": 1 }, { name: "idx_doctor_other_hospitals" });
  
  // Availability indexes
  await collection.createIndex({ "availability.schedule.day": 1, "availability.schedule.isAvailable": 1 }, { name: "idx_doctor_availability" });
  await collection.createIndex({ "availability.onlineConsultation": 1 }, { name: "idx_doctor_online" });
  await collection.createIndex({ "availability.emergencyAvailable": 1 }, { name: "idx_doctor_emergency" });
  
  // Rating and statistics
  await collection.createIndex({ "statistics.averageRating": -1 }, { name: "idx_doctor_rating" });
  await collection.createIndex({ "statistics.totalPatients": -1 }, { name: "idx_doctor_patients" });
  
  // Contact indexes
  await collection.createIndex({ "personalInfo.phone": 1 }, { name: "idx_doctor_phone" });
  await collection.createIndex({ "credentials.email": 1 }, { name: "idx_doctor_email" });
  
  console.log('✅ Doctor indexes created');
}

async function createHospitalIndexes(db) {
  console.log('🏥 Creating Hospital indexes...');
  
  const collection = db.collection('hospitals');
  
  // Primary unique indexes
  await collection.createIndex({ "hospitalId": 1 }, { unique: true, name: "idx_hospital_id" });
  await collection.createIndex({ "credentials.username": 1 }, { unique: true, name: "idx_hospital_username" });
  await collection.createIndex({ "registrationNumber": 1 }, { unique: true, name: "idx_hospital_registration" });
  
  // Search indexes
  await collection.createIndex({ "name": 1 }, { name: "idx_hospital_name" });
  await collection.createIndex({ "type": 1 }, { name: "idx_hospital_type" });
  
  // Location indexes
  await collection.createIndex({ "address.city": 1 }, { name: "idx_hospital_city" });
  await collection.createIndex({ "address.state": 1 }, { name: "idx_hospital_state" });
  await collection.createIndex({ "address.pincode": 1 }, { name: "idx_hospital_pincode" });
  await collection.createIndex({ "address.coordinates": "2dsphere" }, { name: "idx_hospital_location" });
  
  // Department and facility indexes
  await collection.createIndex({ "departments.name": 1 }, { name: "idx_hospital_departments" });
  await collection.createIndex({ "departments.doctors": 1 }, { name: "idx_hospital_dept_doctors" });
  await collection.createIndex({ "facilities.name": 1 }, { name: "idx_hospital_facilities" });
  
  // Availability indexes
  await collection.createIndex({ "statistics.availableBeds": 1 }, { name: "idx_hospital_beds" });
  await collection.createIndex({ "statistics.occupancyRate": 1 }, { name: "idx_hospital_occupancy" });
  
  // Service indexes
  await collection.createIndex({ "services.name": 1 }, { name: "idx_hospital_services" });
  await collection.createIndex({ "services.department": 1 }, { name: "idx_hospital_service_dept" });
  
  // Certification and insurance
  await collection.createIndex({ "certification.accreditation": 1 }, { name: "idx_hospital_accreditation" });
  await collection.createIndex({ "insurance.acceptedProviders": 1 }, { name: "idx_hospital_insurance" });
  
  // Emergency services
  await collection.createIndex({ "emergencyServices.ambulance": 1 }, { name: "idx_hospital_ambulance" });
  await collection.createIndex({ "operatingHours.emergency.available24x7": 1 }, { name: "idx_hospital_24x7" });
  
  console.log('✅ Hospital indexes created');
}

async function createAppointmentIndexes(db) {
  console.log('📅 Creating Appointment indexes...');
  
  const collection = db.collection('appointments');
  
  // Primary index
  await collection.createIndex({ "appointmentId": 1 }, { unique: true, name: "idx_appointment_id" });
  
  // Relationship indexes
  await collection.createIndex({ "patientId": 1 }, { name: "idx_appointment_patient" });
  await collection.createIndex({ "doctorId": 1 }, { name: "idx_appointment_doctor" });
  await collection.createIndex({ "hospitalId": 1 }, { name: "idx_appointment_hospital" });
  
  // Date and status indexes
  await collection.createIndex({ "scheduledDate": 1 }, { name: "idx_appointment_date" });
  await collection.createIndex({ "status": 1 }, { name: "idx_appointment_status" });
  await collection.createIndex({ "type": 1 }, { name: "idx_appointment_type" });
  
  // Compound indexes for common queries
  await collection.createIndex({ "doctorId": 1, "scheduledDate": 1 }, { name: "idx_appointment_doctor_date" });
  await collection.createIndex({ "patientId": 1, "scheduledDate": -1 }, { name: "idx_appointment_patient_date" });
  await collection.createIndex({ "hospitalId": 1, "scheduledDate": 1 }, { name: "idx_appointment_hospital_date" });
  await collection.createIndex({ "status": 1, "scheduledDate": 1 }, { name: "idx_appointment_status_date" });
  
  console.log('✅ Appointment indexes created');
}

async function createMedicalRecordIndexes(db) {
  console.log('📋 Creating Medical Record indexes...');
  
  const collection = db.collection('medicalrecords');
  
  // Primary index
  await collection.createIndex({ "recordId": 1 }, { unique: true, name: "idx_record_id" });
  
  // Relationship indexes
  await collection.createIndex({ "patientId": 1 }, { name: "idx_record_patient" });
  await collection.createIndex({ "doctorId": 1 }, { name: "idx_record_doctor" });
  await collection.createIndex({ "hospitalId": 1 }, { name: "idx_record_hospital" });
  
  // Date and type indexes
  await collection.createIndex({ "date": -1 }, { name: "idx_record_date" });
  await collection.createIndex({ "type": 1 }, { name: "idx_record_type" });
  
  // Medical indexes
  await collection.createIndex({ "diagnosis": 1 }, { name: "idx_record_diagnosis" });
  await collection.createIndex({ "symptoms": 1 }, { name: "idx_record_symptoms" });
  
  // Compound indexes
  await collection.createIndex({ "patientId": 1, "date": -1 }, { name: "idx_record_patient_date" });
  await collection.createIndex({ "doctorId": 1, "date": -1 }, { name: "idx_record_doctor_date" });
  await collection.createIndex({ "type": 1, "date": -1 }, { name: "idx_record_type_date" });
  
  console.log('✅ Medical Record indexes created');
}

async function createPrescriptionIndexes(db) {
  console.log('💊 Creating Prescription indexes...');
  
  const collection = db.collection('prescriptions');
  
  // Primary index
  await collection.createIndex({ "prescriptionId": 1 }, { unique: true, name: "idx_prescription_id" });
  
  // Relationship indexes
  await collection.createIndex({ "patientId": 1 }, { name: "idx_prescription_patient" });
  await collection.createIndex({ "doctorId": 1 }, { name: "idx_prescription_doctor" });
  
  // Date indexes
  await collection.createIndex({ "date": -1 }, { name: "idx_prescription_date" });
  
  // Medication indexes
  await collection.createIndex({ "medications.name": 1 }, { name: "idx_prescription_medication" });
  
  // Compound indexes
  await collection.createIndex({ "patientId": 1, "date": -1 }, { name: "idx_prescription_patient_date" });
  
  console.log('✅ Prescription indexes created');
}

async function createTelemedicineIndexes(db) {
  console.log('💻 Creating Telemedicine indexes...');
  
  const collection = db.collection('telemedicinesessions');
  
  // Primary index
  await collection.createIndex({ "sessionId": 1 }, { unique: true, name: "idx_telemedicine_id" });
  
  // Relationship indexes
  await collection.createIndex({ "patientId": 1 }, { name: "idx_telemedicine_patient" });
  await collection.createIndex({ "doctorId": 1 }, { name: "idx_telemedicine_doctor" });
  
  // Date and status indexes
  await collection.createIndex({ "scheduledTime": 1 }, { name: "idx_telemedicine_time" });
  await collection.createIndex({ "status": 1 }, { name: "idx_telemedicine_status" });
  await collection.createIndex({ "platform": 1 }, { name: "idx_telemedicine_platform" });
  
  console.log('✅ Telemedicine indexes created');
}

async function createWearableDataIndexes(db) {
  console.log('⌚ Creating Wearable Data indexes...');
  
  const collection = db.collection('wearabledata');
  
  // Primary index
  await collection.createIndex({ "dataId": 1 }, { unique: true, name: "idx_wearable_id" });
  
  // Relationship and device indexes
  await collection.createIndex({ "patientId": 1 }, { name: "idx_wearable_patient" });
  await collection.createIndex({ "deviceType": 1 }, { name: "idx_wearable_device" });
  
  // Time series indexes
  await collection.createIndex({ "timestamp": -1 }, { name: "idx_wearable_timestamp" });
  await collection.createIndex({ "patientId": 1, "timestamp": -1 }, { name: "idx_wearable_patient_time" });
  await collection.createIndex({ "patientId": 1, "deviceType": 1, "timestamp": -1 }, { name: "idx_wearable_patient_device_time" });
  
  console.log('✅ Wearable Data indexes created');
}

async function createAnalyticsIndexes(db) {
  console.log('📊 Creating Analytics indexes...');
  
  const collection = db.collection('analytics');
  
  // Primary index
  await collection.createIndex({ "analyticsId": 1 }, { unique: true, name: "idx_analytics_id" });
  
  // Type and date indexes
  await collection.createIndex({ "type": 1 }, { name: "idx_analytics_type" });
  await collection.createIndex({ "date": -1 }, { name: "idx_analytics_date" });
  
  // Compound indexes
  await collection.createIndex({ "type": 1, "date": -1 }, { name: "idx_analytics_type_date" });
  
  console.log('✅ Analytics indexes created');
}

// Run index creation
if (require.main === module) {
  createAllIndexes()
    .then(() => {
      console.log('🎉 All database indexes created successfully!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('💥 Index creation failed:', error);
      process.exit(1);
    });
}

module.exports = {
  createAllIndexes
};
