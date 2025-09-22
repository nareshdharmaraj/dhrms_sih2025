const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const HospitalAssistant = require('./src/models/HospitalAssistant');
const Hospital = require('./src/models/Hospital');
const HospitalDoctor = require('./src/models/HospitalDoctor');

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

// Generate assistant ID
const generateAssistantId = (hospitalId, assistantName) => {
  const namePart = assistantName.replace(/\s+/g, '').substring(0, 3).toUpperCase();
  const timestamp = Date.now().toString().slice(-6);
  return `AST${namePart}${timestamp}`;
};

// Create hospital assistant
const createAssistant = async (assistantData) => {
  try {
    const {
      hospitalId,
      assistantName,
      username,
      password,
      email,
      contactNumber,
      assignedDoctorId,
      assignedDoctorName,
      assignedDepartment,
      qualification,
      qualificationUniversity,
      qualificationYear,
      designation,
      experienceYears = 0,
      workingShift = 'Morning',
      workingDays,
      permissions = {
        canUpdatePatientInfo: true,
        canScheduleAppointments: true,
        canAccessPatientRecords: true,
        canManageInventory: false,
        canProcessPayments: false
      }
    } = assistantData;

    // Check if hospital exists
    const hospital = await Hospital.findOne({ hospitalId });
    if (!hospital) {
      throw new Error(`Hospital with ID ${hospitalId} not found`);
    }

    // Check if assigned doctor exists (if provided)
    if (assignedDoctorId) {
      const doctor = await HospitalDoctor.findOne({ doctorId: assignedDoctorId });
      if (!doctor) {
        throw new Error(`Doctor with ID ${assignedDoctorId} not found`);
      }
    }

    // Generate assistant ID
    const assistantId = username || generateAssistantId(hospitalId, assistantName);

    // Check if assistant already exists
    const existingAssistant = await HospitalAssistant.findOne({
      $or: [
        { assistantId },
        { username: assistantId },
        { email }
      ]
    });

    if (existingAssistant) {
      throw new Error('Assistant with this ID or email already exists');
    }

    // Create assistant
    const assistant = new HospitalAssistant({
      assistantId,
      hospitalId,
      assistantName,
      username: assistantId,
      password, // Plain text as per project requirements
      email,
      contactNumber,
      assignedDepartment: assignedDepartment || 'Administration',
      assignedDoctor: assignedDoctorId ? {
        doctorId: assignedDoctorId,
        doctorName: assignedDoctorName || 'Unknown'
      } : undefined,
      qualification: {
        degree: qualification || 'Diploma in Medical Assistant',
        university: qualificationUniversity || 'Local University',
        yearOfPassing: qualificationYear || 2020
      },
      designation: designation || 'Medical Assistant',
      dutySchedule: {
        shift: workingShift || 'Morning',
        workingDays: workingDays || ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        workingHours: {
          start: '09:00',
          end: '17:00'
        }
      },
      experience: {
        totalYears: experienceYears || 0
      },
      permissions,
      isActive: true,
      createdAt: new Date()
    });

    await assistant.save();

    console.log('✅ Hospital Assistant created successfully!');
    console.log('Assistant Details:');
    console.log('- Assistant ID:', assistantId);
    console.log('- Name:', assistantName);
    console.log('- Username:', assistantId);
    console.log('- Email:', email);
    console.log('- Contact:', contactNumber);
    console.log('- Hospital ID:', hospitalId);
    console.log('- Hospital Name:', hospital.name);
    console.log('- Assigned Department:', assignedDepartment);
    console.log('- Assigned Doctor:', assignedDoctorId || 'Not assigned');
    console.log('- Qualification Degree:', qualification);
    console.log('- Designation:', designation);
    console.log('- Experience:', experienceYears, 'years');
    console.log('- Working Shift:', workingShift);
    console.log('- Password:', password);

    return assistant;

  } catch (error) {
    console.error('❌ Error creating assistant:', error.message);
    throw error;
  }
};

// Main execution function
const main = async () => {
  console.log('👩‍⚕️ Creating Hospital Assistant...\n');

  await connectDB();

  // Example assistant data - modify as needed
  const assistantData = {
    hospitalId: 'HOSP-001', // Make sure this hospital exists
    assistantName: 'Ms. Priya Sharma',
    email: 'priya.sharma@hospital.com',
    contactNumber: '9876543211',
    assignedDoctorId: null, // Optional - assign to specific doctor
    assignedDoctorName: null,
    assignedDepartment: 'Administration', // Required field
    qualification: 'Diploma in Medical Assistant', // Will be used as degree
    qualificationUniversity: 'Local Medical College',
    qualificationYear: 2020,
    designation: 'Medical Assistant',
    experienceYears: 3,
    workingShift: 'Morning',
    workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    password: 'assistant123'
  };

  try {
    await createAssistant(assistantData);
    console.log('\n🎉 Assistant creation completed successfully!');
  } catch (error) {
    console.error('\n💥 Assistant creation failed:', error.message);
  }

  mongoose.connection.close();
};

// Run if this file is executed directly
if (require.main === module) {
  main();
}

module.exports = { createAssistant, generateAssistantId };
