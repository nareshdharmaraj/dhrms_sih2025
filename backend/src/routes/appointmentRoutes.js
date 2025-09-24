const express = require('express');
const router = express.Router();
const HospitalAppointment = require('../models/HospitalAppointment');
const HospitalDoctor = require('../models/HospitalDoctor');
const Hospital = require('../models/Hospital');

/**
 * @desc    Get all appointments (for testing)
 * @route   GET /api/appointments
 * @access  Public (for testing)
 */
router.get('/', async (req, res) => {
  try {
    console.log('📋 Fetching all appointments...');
    const appointments = await HospitalAppointment.find({}).sort({ appointmentDate: -1 }).limit(20);
    console.log(`✅ Found ${appointments.length} appointments`);
    res.json({
      success: true,
      count: appointments.length,
      data: appointments
    });
  } catch (error) {
    console.error('❌ Error fetching appointments:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointments',
      error: error.message
    });
  }
});

/**
 * @desc    Create a new appointment
 * @route   POST /api/appointments
 * @access  Public (Patient can book)
 */
router.post('/', async (req, res) => {
  try {
    console.log('📅 Creating new appointment:', req.body);

    const appointmentData = req.body;

    // Validate required fields (excluding appointmentId - will be auto-generated)
    const requiredFields = [
      'patientId', 'patientName', 'doctorId', 'doctorName', 
      'hospitalId', 'hospitalName', 'appointmentDate', 'appointmentTime', 
      'reason', 'consultationFee'
    ];

    for (const field of requiredFields) {
      if (!appointmentData[field]) {
        return res.status(400).json({
          success: false,
          message: `Missing required field: ${field}`
        });
      }
    }

    // Auto-generate appointment ID
    const appointmentId = `APT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Keep date format as DD/MM/YYYY to match existing appointments
    let formattedDate = appointmentData.appointmentDate;
    // Convert YYYY-MM-DD to DD/MM/YYYY if needed
    if (formattedDate.includes('-') && formattedDate.length === 10) {
      const [year, month, day] = formattedDate.split('-');
      formattedDate = `${day}/${month}/${year}`;
    }

    // Prepare appointment data - map doctorId to hospitalStaffId to match existing schema
    const finalAppointmentData = {
      appointmentId: appointmentId,
      patientId: appointmentData.patientId,
      patientName: appointmentData.patientName,
      patientUhid: appointmentData.patientUhid || appointmentData.patientId,
      patientGender: appointmentData.patientGender,
      patientAge: appointmentData.patientAge,
      patientState: appointmentData.patientState,
      hospitalStaffId: appointmentData.doctorId, // Map doctorId to hospitalStaffId
      doctorName: appointmentData.doctorName,
      hospitalId: appointmentData.hospitalId,
      hospitalName: appointmentData.hospitalName,
      appointmentDate: formattedDate,
      appointmentTime: appointmentData.appointmentTime,
      reason: appointmentData.reason,
      consultationFee: appointmentData.consultationFee,
      status: 'pending'
    };

    // Create new appointment
    const appointment = new HospitalAppointment(finalAppointmentData);
    await appointment.save();

    console.log('✅ Appointment created successfully:', appointment.appointmentId);

    res.status(201).json({
      success: true,
      message: 'Appointment booked successfully',
      appointmentId: appointment.appointmentId,
      data: appointment
    });

  } catch (error) {
    console.error('❌ Error creating appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while creating appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Get appointments for a specific doctor
 * @route   GET /api/appointments/doctor/:doctorId
 * @access  Private (Doctor/Admin)
 */
router.get('/doctor/:doctorId', async (req, res) => {
  try {
    const { doctorId } = req.params;
    console.log('📅 Fetching appointments for doctor:', doctorId);

    const appointments = await HospitalAppointment.find({
      doctorId: doctorId
    }).sort({ appointmentDate: 1, appointmentTime: 1 });

    console.log('✅ Found appointments:', appointments.length);

    res.json(appointments);

  } catch (error) {
    console.error('❌ Error fetching doctor appointments:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointments',
      error: error.message
    });
  }
});

/**
 * @desc    Get appointments for a specific patient
 * @route   GET /api/appointments/patient/:patientId
 * @access  Private (Patient)
 */
router.get('/patient/:patientId', async (req, res) => {
  try {
    const { patientId } = req.params;
    console.log('📅 Fetching appointments for patient:', patientId);

    const appointments = await HospitalAppointment.find({
      $or: [
        { patientId: patientId },
        { patientUhid: patientId }
      ]
    }).sort({ appointmentDate: -1, appointmentTime: -1 });

    console.log('✅ Found appointments for patient:', appointments.length);

    res.json(appointments);

  } catch (error) {
    console.error('❌ Error fetching patient appointments:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointments',
      error: error.message
    });
  }
});

/**
 * @desc    Update appointment status
 * @route   PUT /api/appointments/:appointmentId/status
 * @access  Private (Doctor/Admin)
 */
router.put('/:appointmentId/status', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const { status } = req.body;

    console.log('📅 Updating appointment status:', appointmentId, 'to', status);

    // Validate status
    const validStatuses = ['pending', 'approved', 'rejected', 'completed'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status. Must be one of: ' + validStatuses.join(', ')
      });
    }

    const appointment = await HospitalAppointment.findOneAndUpdate(
      { appointmentId: appointmentId },
      { 
        status: status,
        updatedAt: new Date()
      },
      { new: true }
    );

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    console.log('✅ Appointment status updated successfully');

    res.json({
      success: true,
      message: 'Appointment status updated successfully',
      data: appointment
    });

  } catch (error) {
    console.error('❌ Error updating appointment status:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Get doctors for a specific hospital
 * @route   GET /api/appointments/hospitals/:hospitalId/doctors
 * @access  Public
 */
router.get('/hospitals/:hospitalId/doctors', async (req, res) => {
  try {
    const { hospitalId } = req.params;
    console.log('👨‍⚕️ Fetching doctors for hospital:', hospitalId);

    const doctors = await HospitalDoctor.find({ 
      hospitalId: hospitalId,
      isActive: true 
    }).select('doctorId doctorName specialization department designation experienceYears consultationFee availableTimings');

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

/**
 * @desc    Get appointment by ID
 * @route   GET /api/appointments/:appointmentId
 * @access  Private
 */
router.get('/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    console.log('📅 Fetching appointment:', appointmentId);

    const appointment = await HospitalAppointment.findOne({
      appointmentId: appointmentId
    });

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    console.log('✅ Appointment found');

    res.json({
      success: true,
      data: appointment
    });

  } catch (error) {
    console.error('❌ Error fetching appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Get appointments for a specific doctor/staff member
 * @route   GET /api/appointments/staff/:staffId
 * @access  Public (for now)
 */
router.get('/staff/:staffId', async (req, res) => {
  try {
    console.log('👨‍⚕️ Fetching appointments for staff ID:', req.params.staffId);
    
    const appointments = await HospitalAppointment.find({ 
      hospitalStaffId: req.params.staffId 
    })
    .populate('patientId', 'fullName bloodGroup phone email age gender')
    .sort({ appointmentDate: 1, appointmentTime: 1 });
    
    console.log(`✅ Found ${appointments.length} appointments for staff`);
    
    res.json(appointments);
  } catch (error) {
    console.error('❌ Error fetching staff appointments:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching staff appointments',
      error: error.message
    });
  }
});

/**
 * @desc    Mark appointment as completed
 * @route   PATCH /api/appointments/:appointmentId/complete
 * @access  Private (Doctor)
 */
router.patch('/:appointmentId/complete', async (req, res) => {
  try {
    const { appointmentId } = req.params;

    console.log('✅ Marking appointment as completed:', appointmentId);

    const appointment = await HospitalAppointment.findByIdAndUpdate(
      appointmentId,
      { 
        status: 'completed',
        completedAt: new Date(),
        updatedAt: new Date()
      },
      { new: true }
    );

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    console.log('✅ Appointment marked as completed successfully');

    res.json({
      success: true,
      message: 'Appointment completed successfully',
      data: appointment
    });

  } catch (error) {
    console.error('❌ Error completing appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while completing appointment',
      error: error.message
    });
  }
});

module.exports = router;