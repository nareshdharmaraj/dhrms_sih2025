const express = require('express');
const { body, validationResult } = require('express-validator');
const Hospital = require('../models/Hospital');
const Doctor = require('../models/Doctor');
const { authenticateHospital } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// @route   GET /api/v1/hospitals/profile
// @desc    Get hospital profile
// @access  Private (Hospital)
router.get('/profile', authenticateHospital, async (req, res) => {
  try {
    const hospital = await Hospital.findById(req.user.id)
      .select('-credentials.password -__v')
      .populate({
        path: 'departments.headDoctor',
        select: 'doctorId personalInfo.firstName personalInfo.lastName'
      });

    if (!hospital) {
      return res.status(404).json({
        status: 'error',
        message: 'Hospital not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        hospital
      }
    });

  } catch (error) {
    logger.error('Get hospital profile error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching hospital profile'
    });
  }
});

// @route   GET /api/v1/hospitals/doctors
// @desc    Get all doctors in hospital
// @access  Private (Hospital)
router.get('/doctors', authenticateHospital, async (req, res) => {
  try {
    const doctors = await Doctor.find({ hospital: req.user.id })
      .select('-credentials.password -__v')
      .sort({ createdAt: -1 });

    res.json({
      status: 'success',
      data: {
        doctors,
        total: doctors.length
      }
    });

  } catch (error) {
    logger.error('Get hospital doctors error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching doctors'
    });
  }
});

// @route   POST /api/v1/hospitals/doctors
// @desc    Create new doctor
// @access  Private (Hospital)
router.post('/doctors', authenticateHospital, [
  body('firstName').trim().notEmpty().withMessage('First name is required'),
  body('lastName').trim().notEmpty().withMessage('Last name is required'),
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),
  body('phone').trim().notEmpty().withMessage('Phone number is required'),
  body('medicalLicenseNumber').trim().notEmpty().withMessage('Medical license number is required'),
  body('specialization').isArray({ min: 1 }).withMessage('At least one specialization is required'),
  body('department').trim().notEmpty().withMessage('Department is required'),
  body('experience').isInt({ min: 0 }).withMessage('Experience must be a positive number'),
  body('username').trim().notEmpty().withMessage('Username is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const {
      firstName,
      lastName,
      email,
      phone,
      dateOfBirth,
      gender,
      address,
      medicalLicenseNumber,
      specialization,
      qualification,
      experience,
      department,
      position,
      schedule,
      username,
      password
    } = req.body;

    // Check if doctor already exists
    const existingDoctor = await Doctor.findOne({
      $or: [
        { 'personalInfo.email': email },
        { 'credentials.username': username },
        { 'professionalInfo.medicalLicenseNumber': medicalLicenseNumber }
      ]
    });

    if (existingDoctor) {
      return res.status(400).json({
        status: 'error',
        message: 'Doctor with this email, username, or license number already exists'
      });
    }

    // Create new doctor
    const doctor = new Doctor({
      hospital: req.user.id,
      personalInfo: {
        firstName,
        lastName,
        email,
        phone,
        dateOfBirth,
        gender,
        address
      },
      professionalInfo: {
        medicalLicenseNumber,
        specialization,
        qualification: qualification || [],
        experience,
        department,
        position: position || 'junior'
      },
      credentials: {
        username,
        password,
        isVerified: true // Hospital-created doctors are auto-verified
      },
      schedule: schedule || {}
    });

    await doctor.save();

    // Update hospital statistics
    await Hospital.findByIdAndUpdate(req.user.id, {
      $inc: { 'statistics.totalDoctors': 1 }
    });

    logger.info(`New doctor created: ${doctor.fullName}`, { 
      doctorId: doctor.doctorId,
      hospitalId: req.hospital.hospitalId 
    });

    res.status(201).json({
      status: 'success',
      message: 'Doctor created successfully',
      data: {
        doctor: {
          id: doctor._id,
          doctorId: doctor.doctorId,
          name: doctor.fullName,
          email: doctor.personalInfo.email,
          specialization: doctor.professionalInfo.specialization,
          department: doctor.professionalInfo.department,
          username: doctor.credentials.username
        }
      }
    });

  } catch (error) {
    logger.error('Create doctor error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating doctor'
    });
  }
});

// @route   GET /api/v1/hospitals/dashboard
// @desc    Get hospital dashboard data
// @access  Private (Hospital)
router.get('/dashboard', authenticateHospital, async (req, res) => {
  try {
    const hospital = await Hospital.findById(req.user.id);
    
    // Get doctors count
    const doctorsCount = await Doctor.countDocuments({ hospital: req.user.id });
    
    // Get active doctors
    const activeDoctors = await Doctor.countDocuments({ 
      hospital: req.user.id, 
      'credentials.isActive': true 
    });

    // Get recent doctors
    const recentDoctors = await Doctor.find({ hospital: req.user.id })
      .select('doctorId personalInfo.firstName personalInfo.lastName professionalInfo.specialization createdAt')
      .sort({ createdAt: -1 })
      .limit(5);

    // Calculate department-wise statistics
    const departmentStats = await Doctor.aggregate([
      { $match: { hospital: hospital._id } },
      { 
        $group: {
          _id: '$professionalInfo.department',
          count: { $sum: 1 }
        }
      }
    ]);

    const dashboardData = {
      hospital: {
        name: hospital.name,
        hospitalId: hospital.hospitalId,
        type: hospital.type
      },
      statistics: {
        totalDoctors: doctorsCount,
        activeDoctors: activeDoctors,
        totalPatients: hospital.statistics.totalPatients || 0,
        totalBeds: hospital.statistics.totalBeds || 0,
        availableBeds: hospital.statistics.availableBeds || 0
      },
      departmentStats: departmentStats,
      recentDoctors: recentDoctors
    };

    res.json({
      status: 'success',
      data: dashboardData
    });

  } catch (error) {
    logger.error('Get hospital dashboard error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching dashboard data'
    });
  }
});

module.exports = router;
