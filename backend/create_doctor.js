const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const HospitalDoctor = require('./src/models/HospitalDoctor');
const Hospital = require('./src/models/Hospital');

// MongoDB connection
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/dhrms', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
};

// Generate doctor ID
const generateDoctorId = (hospitalId, doctorName) => {
  const namePart = doctorName.replace(/\s+/g, '').substring(0, 3).toUpperCase();
  const timestamp = Date.now().toString().slice(-6);
  return `DR${namePart}${timestamp}`;
};

// Department mapping based on specialization
const departmentMapping = {
  'General Medicine': 'Internal Medicine',
  'Cardiology': 'Cardiology',
  'Neurology': 'Neurology', 
  'Orthopedics': 'Orthopedics',
  'Pediatrics': 'Pediatrics',
  'Gynecology': 'Obstetrics & Gynecology',
  'Dermatology': 'Dermatology',
  'Psychiatry': 'Psychiatry',
  'Surgery': 'General Surgery',
  'ENT': 'ENT',
  'Ophthalmology': 'Ophthalmology',
  'Emergency Medicine': 'Emergency',
  'Anesthesia': 'Anesthesiology',
  'Radiology': 'Radiology',
  'Pathology': 'Pathology',
  'Urology': 'Urology',
  'Oncology': 'Oncology',
  'Nephrology': 'Nephrology',
  'Gastroenterology': 'Gastroenterology',
  'Pulmonology': 'Pulmonology',
  'Endocrinology': 'Endocrinology',
  'Rheumatology': 'Rheumatology',
  'Hematology': 'Hematology',
  'Infectious Disease': 'Infectious Disease',
  'Family Medicine': 'Family Medicine',
  'Internal Medicine': 'Internal Medicine',
  'Critical Care': 'ICU'
};

// Create doctor with enhanced fields
const createDoctor = async (doctorData) => {
  try {
    const {
      hospitalId,
      name,
      gender,
      dateOfBirth,
      specializations,
      department,
      contactNumber,
      email,
      qualification,
      experienceYears = 0,
      availableTimings,
      consultationFee = 0,
      password,
      // Legacy support
      doctorName,
      username,
      specialization
    } = doctorData;

    // Use new fields or fall back to legacy
    const finalName = name || doctorName;
    const finalSpecializations = specializations || [specialization];
    const finalDepartment = department || departmentMapping[finalSpecializations[0]];

    // Check if hospital exists
    const hospital = await Hospital.findOne({ hospitalId });
    if (!hospital) {
      throw new Error(`Hospital with ID ${hospitalId} not found`);
    }

    // Generate doctor ID
    const doctorId = username || generateDoctorId(hospitalId, finalName);

    // Check if doctor already exists
    const existingDoctor = await HospitalDoctor.findOne({
      $or: [
        { doctorId },
        { username: doctorId },
        { email }
      ]
    });

    if (existingDoctor) {
      throw new Error('Doctor with this ID or email already exists');
    }

    // Validate age if dateOfBirth is provided
    if (dateOfBirth) {
      const age = new Date().getFullYear() - new Date(dateOfBirth).getFullYear();
      if (age < 18 || age > 100) {
        throw new Error('Doctor age must be between 18 and 100 years');
      }
      
      // Validate experience vs age
      if (experienceYears > (age - 22)) {
        throw new Error(`Experience (${experienceYears} years) cannot exceed ${age - 22} years based on age`);
      }
    }

    // Create doctor
    const doctor = new HospitalDoctor({
      doctorId,
      hospitalId,
      username: doctorId,
      password, // Plain text as per project requirements
      name: finalName,
      doctorName: finalName, // Backwards compatibility
      gender,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : undefined,
      specializations: finalSpecializations,
      specialization: finalSpecializations[0], // Backwards compatibility
      department: finalDepartment,
      email,
      contactNumber,
      qualification,
      experienceYears,
      availableTimings: availableTimings || '9:00 AM - 12:00 PM',
      consultationFee,
      registrationNumber: `REG${Date.now()}`,
      isActive: true,
      createdAt: new Date()
    });

    await doctor.save();

    console.log('✅ Doctor created successfully!');
    console.log('Doctor Details:');
    console.log('- Doctor ID:', doctorId);
    console.log('- Name:', finalName);
    console.log('- Gender:', gender);
    console.log('- Specializations:', finalSpecializations.join(', '));
    console.log('- Department:', finalDepartment);
    console.log('- Email:', email);
    console.log('- Contact:', contactNumber);
    console.log('- Experience:', experienceYears, 'years');
    console.log('- Consultation Fee: ₹', consultationFee);
    console.log('- Available Timings:', availableTimings);
    console.log('- Username:', doctorId);
    console.log('- Password:', password);

    return doctor;

  } catch (error) {
    console.error('❌ Error creating doctor:', error.message);
    throw error;
  }
};

// Main execution function
const main = async () => {
  console.log('👨‍⚕️ Creating Hospital Doctor...\n');

  await connectDB();

  // Example enhanced doctor data - modify as needed
  const doctorData = {
    hospitalId: 'HOSP-001', // Make sure this hospital exists
    name: 'Dr. Sarah Johnson',
    gender: 'Female',
    dateOfBirth: '1985-05-15',
    specializations: ['Cardiology', 'Internal Medicine'],
    contactNumber: '9876543210',
    email: 'sarah.johnson@hospital.com',
    qualification: 'MD Cardiology',
    experienceYears: 8,
    availableTimings: '9:00 AM - 12:00 PM',
    consultationFee: 1500,
    password: 'doctor123'
  };

  try {
    await createDoctor(doctorData);
    console.log('\n🎉 Doctor creation completed successfully!');
  } catch (error) {
    console.error('\n💥 Doctor creation failed:', error.message);
  }

  mongoose.connection.close();
};

// Run if this file is executed directly
if (require.main === module) {
  main();
}

module.exports = { createDoctor, generateDoctorId, departmentMapping };
