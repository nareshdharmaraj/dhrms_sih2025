const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Import routes
const authRoutes = require('./routes/auth_routes');
const patientRoutes = require('./routes/patientRoutes');
const patientSettingsRoutes = require('./routes/patient_settings_routes');
const userRoutes = require('./routes/user_routes');
const allRolesRoutes = require('./routes/all_roles_routes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const wearableRoutes = require('./routes/wearableRoutes');
const whoRoutes = require('./routes/whoRoutes');
const shoRoutes = require('./routes/shoRoutes');
const shoAuthRoutes = require('./routes/shoAuthRoutes');
const rhoRoutes = require('./routes/rhoRoutes');
const contactTracingRoutes = require('./routes/contactTracing');

// Zone Management Routes
const zoneManagementRoutes = require('./routes/zoneManagement');

// Hospital Management Routes
const hospitalManagementRoutes = require('./routes/hospital_management_routes');
const hospitalAdminRoutes = require('./routes/hospital_admin_routes');
const hospitalDoctorRoutes = require('./routes/hospital_doctor_routes');
const hospitalAssistantRoutes = require('./routes/hospital_assistant_routes');
const appointmentRoutes = require('./routes/appointmentRoutes');
const patientAppointmentRoutes = require('./routes/patientAppointmentRoutes');
const doctorAppointmentRoutes = require('./routes/doctorAppointmentRoutes');
const prescriptionRoutes = require('./routes/prescriptionRoutes');
const diseasesRoutes = require('./routes/diseasesRoutes');

// Import middleware
const errorHandler = require('./middleware/error_handler');
const logger = require('./middleware/logger');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // Enable CORS
app.use(express.json({ limit: '10mb' })); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies
app.use(logger); // Request logging

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'DHRMS Backend is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/patients', patientSettingsRoutes);
app.use('/api/users', userRoutes);
app.use('/api/roles', allRolesRoutes);
app.use('/api', dashboardRoutes);
app.use('/api/wearables', wearableRoutes);
app.use('/api/who', whoRoutes);
app.use('/api/sho', shoRoutes);
app.use('/api/sho-auth', shoAuthRoutes);
app.use('/api/rho', rhoRoutes);
app.use('/api/rho', rhoRoutes);
app.use('/api/contact-tracing', contactTracingRoutes);

// Zone Management API Routes
app.use('/api/zone-management', zoneManagementRoutes);

// Hospital Management API Routes
app.use('/api/hospital', hospitalManagementRoutes);
app.use('/api/hospital-admin', hospitalAdminRoutes);
app.use('/api/hospital-doctor', hospitalDoctorRoutes);
app.use('/api/hospital-assistant', hospitalAssistantRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/patient-appointments', patientAppointmentRoutes);
app.use('/api/doctor-appointments', doctorAppointmentRoutes);
app.use('/api/prescriptions', prescriptionRoutes);
app.use('/api/diseases', diseasesRoutes);

// Test prescription routes (temporary for debugging)
const testPrescriptionRoutes = require('./routes/testPrescriptionRoutes');
app.use('/api/test-prescriptions', testPrescriptionRoutes);

// Enhanced hospitals endpoint for patient appointment booking with RHO information
app.get('/api/hospitals', async (req, res) => {
  try {
    const Hospital = require('./models/Hospital');
    const ZoneManagementController = require('./controllers/zoneManagementController');
    console.log('🏥 Fetching all hospitals for appointment booking with RHO info...');

    console.log('🔍 Querying hospitals...');
    const hospitalsData = await Hospital.find({})
      .populate('managedBy', 'officerId fullName email phoneNumber'); // Populate RHO details
    
    console.log('Raw hospital data:', hospitalsData.length, 'records found');
    
    if (hospitalsData.length > 0) {
      console.log('First hospital sample:', {
        hospitalId: hospitalsData[0].hospitalId,
        name: hospitalsData[0].name,
        isActive: hospitalsData[0].isActive
      });
    }

    // Enrich hospital data with RHO information
    const enrichedHospitals = await Promise.all(
      hospitalsData.map(async (hospital) => {
        let rhoInfo = null;
        
        // Try to get RHO info from direct assignment first
        if (hospital.managedBy) {
          rhoInfo = {
            rhoId: hospital.managedBy.officerId,
            rhoName: hospital.managedBy.fullName,
            rhoEmail: hospital.managedBy.email,
            rhoPhone: hospital.managedBy.phoneNumber,
            assignmentType: 'direct'
          };
          console.log(`✅ Direct RHO assignment found for ${hospital.name}: ${rhoInfo.rhoName}`);
        } else if (hospital.zoneAssignment && hospital.zoneAssignment.area && 
                   hospital.location && hospital.location.state && hospital.location.district) {
          // Try zone-based assignment
          try {
            console.log(`🔍 Looking up zone RHO for ${hospital.name}: ${hospital.location.state}/${hospital.location.district}/${hospital.zoneAssignment.area}`);
            
            const mockReq = {
              params: {
                state: hospital.location.state,
                district: hospital.location.district,
                areaName: hospital.zoneAssignment.area
              }
            };
            const mockRes = {
              statusCode: null,
              data: null,
              status: function(code) { this.statusCode = code; return this; },
              json: function(data) { this.data = data; return this; }
            };
            
            await ZoneManagementController.getRHOForArea(mockReq, mockRes);
            
            if (mockRes.statusCode === 200 && mockRes.data && mockRes.data.success && mockRes.data.data.assignedRHO) {
              rhoInfo = {
                rhoId: mockRes.data.data.assignedRHO.rhoId,
                rhoName: mockRes.data.data.assignedRHO.rhoName,
                zoneName: mockRes.data.data.zone?.zoneName,
                areaName: hospital.zoneAssignment.area,
                assignmentType: 'zone-based'
              };
              console.log(`✅ Zone-based RHO found for ${hospital.name}: ${rhoInfo.rhoName}`);
            } else {
              console.log(`⚠️ No zone RHO found for ${hospital.name}`);
            }
          } catch (error) {
            console.log(`❌ Failed to get zone RHO for hospital ${hospital.hospitalId}:`, error.message);
          }
        } else {
          console.log(`⚠️ No RHO assignment method available for ${hospital.name}`);
        }
        
        // Debug: Log approval status for each hospital
        console.log(`🔍 Hospital "${hospital.name}" approval status: "${hospital.approval?.status || 'UNDEFINED'}"`);
        
        return {
          hospitalId: hospital.hospitalId,
          hospitalName: hospital.name || 'Unknown Hospital',
          name: hospital.name,
          location: hospital.location,
          region: hospital.region,
          contactInfo: hospital.contact || hospital.contactInfo,
          capacity: hospital.capacity,
          isActive: hospital.isActive,
          status: hospital.status,
          approval: hospital.approval, // Include approval object with status
          type: hospital.type,
          services: hospital.services,
          rhoAssignment: rhoInfo
        };
      })
    );

    console.log('✅ Found hospitals with RHO info:', enrichedHospitals.length);
    
    // Log RHO assignment statistics
    const withRHO = enrichedHospitals.filter(h => h.rhoAssignment).length;
    const withoutRHO = enrichedHospitals.length - withRHO;
    console.log(`📊 RHO Assignment Stats: ${withRHO} hospitals with RHO, ${withoutRHO} without RHO`);
    
    // Return structured response that frontend expects
    res.json({
      success: true,
      message: 'Hospitals retrieved successfully',
      data: enrichedHospitals,
      count: enrichedHospitals.length,
      statistics: {
        withRHO,
        withoutRHO,
        total: enrichedHospitals.length
      }
    });

  } catch (error) {
    console.error('❌ Error fetching hospitals:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching hospitals',
      error: error.message
    });
  }
});

// Simple doctors endpoint for patient appointment booking
app.get('/api/doctors/hospital/:hospitalId', async (req, res) => {
  try {
    const HospitalDoctor = require('./models/HospitalDoctor');
    const { hospitalId } = req.params;
    console.log('👨‍⚕️ Fetching doctors for hospital:', hospitalId);

    const doctorsData = await HospitalDoctor.find({
      hospitalId: hospitalId,
      isActive: { $ne: false }
    }).select('doctorId doctorName specialization qualification experience consultationFee availability contactInfo department availableTimings isActive')
    .sort({ doctorName: 1 });

    // Map doctors to ensure required fields
    const doctors = doctorsData.map(doctor => ({
      ...doctor.toObject(),
      consultationFee: doctor.consultationFee || 500, // Default fee if not set
      doctorName: doctor.doctorName || doctor.name || 'Unknown Doctor'
    }));

    console.log('✅ Found doctors:', doctors.length);
    res.json(doctors);

  } catch (error) {
    console.error('❌ Error fetching doctors:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching doctors',
      error: error.message
    });
  }
});

// Test endpoint for doctors debugging
app.get('/api/test/doctors/:hospitalId', async (req, res) => {
  try {
    const HospitalDoctor = require('./models/HospitalDoctor');
    const { hospitalId } = req.params;
    
    // Check all doctors
    const allDoctors = await HospitalDoctor.find({}).limit(3);
    
    // Check doctors for specific hospital
    const hospitalDoctors = await HospitalDoctor.find({ hospitalId: hospitalId });
    
    // Check doctors with isActive
    const activeDoctors = await HospitalDoctor.find({ 
      hospitalId: hospitalId, 
      isActive: { $ne: false } 
    });
    
    res.json({
      requestedHospitalId: hospitalId,
      totalDoctorsInDB: allDoctors.length,
      allDoctorsPreview: allDoctors.map(d => ({
        doctorId: d.doctorId,
        doctorName: d.doctorName || d.name,
        hospitalId: d.hospitalId,
        isActive: d.isActive
      })),
      doctorsForThisHospital: hospitalDoctors.length,
      activeDoctorsForThisHospital: activeDoctors.length,
      doctorsData: activeDoctors.map(d => ({
        doctorId: d.doctorId,
        doctorName: d.doctorName || d.name,
        specialization: d.specialization,
        isActive: d.isActive
      }))
    });
  } catch (error) {
    res.status(500).json({ error: error.message, stack: error.stack });
  }
});

// Patient endpoint 
app.get('/api/patients', async (req, res) => {
  try {
    const Patient = require('./models/Patient');
    console.log('👤 Fetching all patients...');

    const patients = await Patient.find({}).sort({ name: 1 });

    console.log('✅ Found patients:', patients.length);
    res.json(patients);

  } catch (error) {
    console.error('❌ Error fetching patients:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching patients',
      error: error.message
    });
  }
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `Cannot ${req.method} ${req.originalUrl}`
  });
});

// Error handling middleware
app.use(errorHandler);

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✅ Connected to MongoDB - Database: myhealth');
  
  // Start server
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 DHRMS Backend server running on port ${PORT}`);
    console.log(`📋 Health check: http://localhost:${PORT}/health`);
    console.log(`🌐 External access: http://10.123.62.47:${PORT}/health`);
  });
})
.catch((error) => {
  console.error('❌ MongoDB connection error:', error);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down gracefully...');
  mongoose.connection.close(() => {
    console.log('MongoDB connection closed.');
    process.exit(0);
  });
});

module.exports = app;
