const express = require('express');
const { authenticateDoctor } = require('../middleware/auth');
const Doctor = require('../models/Doctor');
const Patient = require('../models/Patient');
const Prescription = require('../models/Prescription');
const logger = require('../utils/logger');

const router = express.Router();

// @route   GET /api/v1/doctors/profile
// @desc    Get doctor profile
// @access  Private (Doctor)
router.get('/profile', authenticateDoctor, async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.user.id)
      .select('-credentials.password -__v')
      .populate('hospital', 'hospitalId name contactInfo');

    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        doctor
      }
    });

  } catch (error) {
    logger.error('Get doctor profile error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching doctor profile'
    });
  }
});

// @route   GET /api/v1/doctors/patients
// @desc    Get doctor's patients
// @access  Private (Doctor)
router.get('/patients', authenticateDoctor, async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.user.id).populate({
      path: 'patients.patient',
      select: 'patientId uhi personalInfo currentHealth createdAt'
    });

    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        patients: doctor.patients,
        total: doctor.patients.length
      }
    });

  } catch (error) {
    logger.error('Get doctor patients error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching patients'
    });
  }
});

// @route   GET /api/v1/doctors/dashboard
// @desc    Get doctor dashboard data
// @access  Private (Doctor)
router.get('/dashboard', authenticateDoctor, async (req, res) => {
  try {
    const doctor = await Doctor.findById(req.user.id).populate('hospital', 'name');

    // Get today's date range
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const endOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);

    // Get recent prescriptions
    const recentPrescriptions = await Prescription.find({ doctor: req.user.id })
      .populate('patient', 'patientId personalInfo.firstName personalInfo.lastName')
      .sort({ createdAt: -1 })
      .limit(5);

    // Get today's prescriptions
    const todayPrescriptions = await Prescription.countDocuments({
      doctor: req.user.id,
      createdAt: { $gte: startOfDay, $lt: endOfDay }
    });

    const dashboardData = {
      doctor: {
        name: doctor.fullName,
        doctorId: doctor.doctorId,
        specialization: doctor.professionalInfo.specialization,
        department: doctor.professionalInfo.department,
        hospital: doctor.hospital.name
      },
      statistics: {
        totalPatients: doctor.statistics.totalPatients || 0,
        totalPrescriptions: doctor.statistics.totalPrescriptions || 0,
        totalConsultations: doctor.statistics.totalConsultations || 0,
        todayPrescriptions: todayPrescriptions
      },
      recentPrescriptions: recentPrescriptions
    };

    res.json({
      status: 'success',
      data: dashboardData
    });

  } catch (error) {
    logger.error('Get doctor dashboard error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching dashboard data'
    });
  }
});

module.exports = router;
