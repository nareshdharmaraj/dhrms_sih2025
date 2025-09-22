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

// Generate unique doctor ID
const generateDoctorId = (index) => {
  const timestamp = Date.now().toString().slice(-6);
  return `DR${index}${timestamp}`;
};

// Create multiple doctors
const createMultipleDoctors = async () => {
  try {
    // Get the first hospital from database
    const hospital = await Hospital.findOne({ isActive: true });
    if (!hospital) {
      throw new Error('No active hospital found in database');
    }

    console.log(`🏥 Using Hospital: ${hospital.name} (ID: ${hospital.hospitalId})`);

    const doctorsData = [
      {
        doctorName: 'Dr. Rajesh Kumar',
        name: 'Dr. Rajesh Kumar',
        specialization: 'Cardiology',
        specializations: ['Cardiology'],
        department: 'Cardiology',
        contactNumber: '9876543210',
        email: 'rajesh.kumar@hospital.com',
        qualification: 'MBBS, MD (Cardiology)',
        experienceYears: 15,
        consultationFee: 800,
        availableTimings: '9:00 AM - 12:00 PM',
        gender: 'Male',
        dateOfBirth: '1975-05-15',
        registrationNumber: 'MH12345678'
      },
      {
        doctorName: 'Dr. Priya Sharma',
        name: 'Dr. Priya Sharma',
        specialization: 'Pediatrics',
        specializations: ['Pediatrics'],
        department: 'Pediatrics',
        contactNumber: '9876543211',
        email: 'priya.sharma@hospital.com',
        qualification: 'MBBS, MD (Pediatrics)',
        experienceYears: 12,
        consultationFee: 600,
        availableTimings: '12:00 PM - 3:00 PM',
        gender: 'Female',
        dateOfBirth: '1980-08-22',
        registrationNumber: 'MH12345679'
      },
      {
        doctorName: 'Dr. Amit Patel',
        name: 'Dr. Amit Patel',
        specialization: 'Orthopedics',
        specializations: ['Orthopedics'],
        department: 'Orthopedics',
        contactNumber: '9876543212',
        email: 'amit.patel@hospital.com',
        qualification: 'MBBS, MS (Orthopedics)',
        experienceYears: 18,
        consultationFee: 1000,
        availableTimings: '3:00 PM - 6:00 PM',
        gender: 'Male',
        dateOfBirth: '1972-12-10',
        registrationNumber: 'MH12345680'
      }
    ];

    for (let i = 0; i < doctorsData.length; i++) {
      const doctorData = doctorsData[i];
      
      // Generate unique IDs
      const doctorId = generateDoctorId(i + 1);
      const username = `doctor${i + 1}_${Date.now()}`;
      const uniqueEmail = `${doctorId.toLowerCase()}@hospital.com`;
      const uniqueRegNumber = `REG${doctorData.registrationNumber}${i + 1}`;
      
      console.log(`\n👨‍⚕️ Creating Doctor ${i + 1}: ${doctorData.doctorName}`);
      
      // Check if doctor already exists
      const existingDoctor = await HospitalDoctor.findOne({
        $or: [
          { doctorId },
          { email: uniqueEmail },
          { doctorName: doctorData.doctorName },
          { registrationNumber: uniqueRegNumber }
        ]
      });

      if (existingDoctor) {
        console.log(`⚠️  Doctor ${doctorData.doctorName} already exists, skipping...`);
        continue;
      }

      // Create the doctor
      const newDoctor = new HospitalDoctor({
        doctorId,
        username,
        password: 'doctor123', // Default password
        hospitalId: hospital.hospitalId,
        hospitalName: hospital.name,
        name: doctorData.name,
        doctorName: doctorData.doctorName,
        specialization: doctorData.specialization,
        specializations: doctorData.specializations,
        department: doctorData.department,
        designation: 'Consultant',
        contactNumber: doctorData.contactNumber,
        email: uniqueEmail,
        qualification: doctorData.qualification,
        registrationNumber: uniqueRegNumber,
        experienceYears: doctorData.experienceYears,
        consultationFee: doctorData.consultationFee,
        availableTimings: doctorData.availableTimings,
        gender: doctorData.gender,
        dateOfBirth: new Date(doctorData.dateOfBirth),
        isActive: true,
        permissions: ['view_patients', 'manage_appointments', 'update_medical_records'],
        createdAt: new Date(),
        updatedAt: new Date()
      });

      const savedDoctor = await newDoctor.save();
      
      console.log(`✅ Doctor created successfully!`);
      console.log(`   Doctor ID: ${savedDoctor.doctorId}`);
      console.log(`   Name: ${savedDoctor.doctorName}`);
      console.log(`   Specialization: ${savedDoctor.specialization}`);
      console.log(`   Email: ${savedDoctor.email}`);
      console.log(`   Consultation Fee: ₹${savedDoctor.consultationFee}`);
    }

    console.log(`\n🎉 All doctors created successfully!`);
    
  } catch (error) {
    console.error('❌ Error creating doctors:', error.message);
    console.error('💥 Doctor creation failed:', error.message);
  }
};

// Main execution
const main = async () => {
  await connectDB();
  await createMultipleDoctors();
  await mongoose.disconnect();
  console.log('\n📱 Database connection closed.');
};

// Run the script
main().catch(console.error);