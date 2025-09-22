const express = require('express');
const router = express.Router();
const HospitalAppointment = require('../models/HospitalAppointment');
const HospitalDoctor = require('../models/HospitalDoctor');
const Hospital = require('../models/Hospital');

/**
 * @desc    Create a new appointment
 * @route   POST /api/appointments
 * @access  Public (Patient can book)
 */
router.post('/', async (req, res) => {
  try {
    console.log('📅 Creating new appointment:', req.body);

    const appointmentData = req.body;

    // Validate required fields
    const requiredFields = [
      'appointmentId', 'patientId', 'patientName', 'patientUhid',
      'doctorId', 'doctorName', 'hospitalId', 'hospitalName',
      'appointmentDate', 'appointmentTime', 'reason', 'consultationFee'
    ];

    for (const field of requiredFields) {
      if (!appointmentData[field]) {
        return res.status(400).json({
          success: false,
          message: `Missing required field: ${field}`
        });
      }
    }

    // Check if appointment ID already exists
    const existingAppointment = await HospitalAppointment.findOne({
      appointmentId: appointmentData.appointmentId
    });

    if (existingAppointment) {
      return res.status(400).json({
        success: false,
        message: 'Appointment ID already exists'
      });
    }

    // Create new appointment
    const appointment = new HospitalAppointment(appointmentData);
    await appointment.save();

    console.log('✅ Appointment created successfully:', appointment.appointmentId);

    res.status(201).json({
      success: true,
      message: 'Appointment booked successfully',
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
      patientId: patientId
    }).sort({ appointmentDate: -1, appointmentTime: -1 });

    console.log('✅ Found appointments:', appointments.length);

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

module.exports = router;