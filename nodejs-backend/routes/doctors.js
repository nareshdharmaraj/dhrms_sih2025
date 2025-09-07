const express = require('express');
const { body, validationResult, query } = require('express-validator');
const mongoose = require('mongoose');
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

// @route   PUT /api/v1/doctors/profile
// @desc    Update doctor profile
// @access  Private (Doctor)
router.put('/profile', authenticateDoctor, [
  body('personalInfo.phone').optional().isMobilePhone(),
  body('personalInfo.email').optional().isEmail(),
  body('professionalInfo.experience').optional().isInt({ min: 0 }),
  body('availability.consultationFee').optional().isNumeric()
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

    const allowedUpdates = [
      'personalInfo.phone',
      'personalInfo.email',
      'personalInfo.address',
      'professionalInfo.experience',
      'professionalInfo.qualifications',
      'professionalInfo.bio',
      'availability',
      'services'
    ];

    const updates = {};
    Object.keys(req.body).forEach(key => {
      if (allowedUpdates.some(field => field.startsWith(key))) {
        updates[key] = req.body[key];
      }
    });

    const doctor = await Doctor.findByIdAndUpdate(
      req.user.id,
      { $set: updates },
      { new: true, runValidators: true }
    ).select('-credentials.password').populate('hospital', 'hospitalId name contactInfo');

    logger.info(`Doctor profile updated: ${doctor.fullName}`, { doctorId: doctor.doctorId });

    res.json({
      status: 'success',
      message: 'Profile updated successfully',
      data: {
        doctor
      }
    });

  } catch (error) {
    logger.error('Update doctor profile error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating profile'
    });
  }
});

// @route   GET /api/v1/doctors/appointments
// @desc    Get doctor's appointments
// @access  Private (Doctor)
router.get('/appointments', authenticateDoctor, [
  query('status').optional().isIn(['pending', 'confirmed', 'in-progress', 'completed', 'cancelled', 'no-show', 'rescheduled']),
  query('date').optional().isISO8601(),
  query('upcoming').optional().isBoolean(),
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 })
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

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // Build query
    let query = { doctor: req.user.id };

    if (req.query.status) {
      query.status = req.query.status;
    }

    if (req.query.date) {
      const filterDate = new Date(req.query.date);
      const nextDay = new Date(filterDate);
      nextDay.setDate(nextDay.getDate() + 1);
      
      query['scheduling.timeSlot.startTime'] = {
        $gte: filterDate,
        $lt: nextDay
      };
    }

    if (req.query.upcoming === 'true') {
      query['scheduling.timeSlot.startTime'] = { $gte: new Date() };
      query.status = { $in: ['pending', 'confirmed'] };
    }

    const [appointments, total] = await Promise.all([
      require('../models/Appointment').find(query)
        .sort({ 'scheduling.timeSlot.startTime': 1 })
        .skip(skip)
        .limit(limit)
        .populate('patient', 'patientId personalInfo.firstName personalInfo.lastName personalInfo.phone')
        .populate('hospital', 'hospitalId name'),
      require('../models/Appointment').countDocuments(query)
    ]);

    res.json({
      status: 'success',
      data: {
        appointments,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalAppointments: total,
          hasNext: page < Math.ceil(total / limit),
          hasPrev: page > 1
        }
      }
    });

  } catch (error) {
    logger.error('Get doctor appointments error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching appointments'
    });
  }
});

// @route   GET /api/v1/doctors/schedule
// @desc    Get doctor's schedule/availability
// @access  Private (Doctor)
router.get('/schedule', authenticateDoctor, [
  query('date').optional().isISO8601(),
  query('week').optional().isBoolean()
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

    const doctor = await Doctor.findById(req.user.id).select('availability schedule');
    
    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    let startDate, endDate;

    if (req.query.date) {
      startDate = new Date(req.query.date);
      endDate = new Date(startDate);
      
      if (req.query.week === 'true') {
        // Get week view
        const dayOfWeek = startDate.getDay();
        startDate.setDate(startDate.getDate() - dayOfWeek);
        endDate.setDate(startDate.getDate() + 6);
      } else {
        // Get single day
        endDate.setDate(endDate.getDate() + 1);
      }
    } else {
      // Default to current week
      startDate = new Date();
      const dayOfWeek = startDate.getDay();
      startDate.setDate(startDate.getDate() - dayOfWeek);
      endDate = new Date(startDate);
      endDate.setDate(endDate.getDate() + 6);
    }

    // Get appointments for the period
    const appointments = await require('../models/Appointment').find({
      doctor: req.user.id,
      status: { $in: ['confirmed', 'in-progress'] },
      'scheduling.timeSlot.startTime': {
        $gte: startDate,
        $lt: endDate
      }
    }).populate('patient', 'personalInfo.firstName personalInfo.lastName');

    // Build schedule response
    const schedule = {
      period: {
        startDate,
        endDate,
        type: req.query.week === 'true' ? 'week' : 'day'
      },
      availability: doctor.availability || {},
      appointments: appointments.map(apt => ({
        appointmentId: apt.appointmentId,
        patient: apt.patient ? `${apt.patient.personalInfo.firstName} ${apt.patient.personalInfo.lastName}` : 'Unknown',
        startTime: apt.scheduling.timeSlot.startTime,
        endTime: apt.scheduling.timeSlot.endTime,
        status: apt.status,
        specialty: apt.appointmentDetails.specialty,
        type: apt.appointmentDetails.type
      }))
    };

    res.json({
      status: 'success',
      data: {
        schedule
      }
    });

  } catch (error) {
    logger.error('Get doctor schedule error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching schedule'
    });
  }
});

// @route   PUT /api/v1/doctors/availability
// @desc    Update doctor's availability
// @access  Private (Doctor)
router.put('/availability', authenticateDoctor, [
  body('workingHours').optional().isObject(),
  body('timeSlots').optional().isArray(),
  body('consultationFee').optional().isNumeric(),
  body('breakTime').optional().isObject()
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

    const { workingHours, timeSlots, consultationFee, breakTime, isAvailable } = req.body;

    const updateData = {};
    if (workingHours) updateData['availability.workingHours'] = workingHours;
    if (timeSlots) updateData['availability.timeSlots'] = timeSlots;
    if (consultationFee) updateData['availability.consultationFee'] = consultationFee;
    if (breakTime) updateData['availability.breakTime'] = breakTime;
    if (typeof isAvailable === 'boolean') updateData['availability.isAvailable'] = isAvailable;

    const doctor = await Doctor.findByIdAndUpdate(
      req.user.id,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('availability personalInfo.firstName personalInfo.lastName');

    logger.info(`Doctor availability updated: ${doctor.personalInfo.firstName} ${doctor.personalInfo.lastName}`);

    res.json({
      status: 'success',
      message: 'Availability updated successfully',
      data: {
        availability: doctor.availability
      }
    });

  } catch (error) {
    logger.error('Update doctor availability error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating availability'
    });
  }
});

// @route   GET /api/v1/doctors/medical-records
// @desc    Get medical records created by doctor
// @access  Private (Doctor)
router.get('/medical-records', authenticateDoctor, [
  query('patient').optional().isMongoId(),
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('dateFrom').optional().isISO8601(),
  query('dateTo').optional().isISO8601()
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

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // Build query
    let query = { doctor: req.user.id };

    if (req.query.patient) {
      query.patient = req.query.patient;
    }

    if (req.query.dateFrom || req.query.dateTo) {
      query['visitInfo.visitDate'] = {};
      if (req.query.dateFrom) {
        query['visitInfo.visitDate'].$gte = new Date(req.query.dateFrom);
      }
      if (req.query.dateTo) {
        query['visitInfo.visitDate'].$lte = new Date(req.query.dateTo);
      }
    }

    const [medicalRecords, total] = await Promise.all([
      require('../models/MedicalRecord').find(query)
        .sort({ 'visitInfo.visitDate': -1 })
        .skip(skip)
        .limit(limit)
        .populate('patient', 'patientId personalInfo.firstName personalInfo.lastName personalInfo.dateOfBirth')
        .populate('hospital', 'hospitalId name'),
      require('../models/MedicalRecord').countDocuments(query)
    ]);

    res.json({
      status: 'success',
      data: {
        medicalRecords,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalRecords: total,
          hasNext: page < Math.ceil(total / limit),
          hasPrev: page > 1
        }
      }
    });

  } catch (error) {
    logger.error('Get doctor medical records error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching medical records'
    });
  }
});

// @route   GET /api/v1/doctors/statistics
// @desc    Get doctor's statistics and analytics
// @access  Private (Doctor)
router.get('/statistics', authenticateDoctor, async (req, res) => {
  try {
    const doctorId = req.user.id;
    const now = new Date();
    const startOfDay = new Date(now.setHours(0, 0, 0, 0));
    const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay()));
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    // Get comprehensive statistics
    const [
      totalPatients,
      totalAppointments,
      totalMedicalRecords,
      totalPrescriptions,
      todayAppointments,
      weeklyAppointments,
      monthlyAppointments,
      appointmentStats,
      recentActivity
    ] = await Promise.all([
      // Total unique patients
      require('../models/Appointment').aggregate([
        { $match: { doctor: mongoose.Types.ObjectId(doctorId) } },
        { $group: { _id: '$patient' } },
        { $count: 'total' }
      ]),

      // Total appointments
      require('../models/Appointment').countDocuments({ doctor: doctorId }),

      // Total medical records
      require('../models/MedicalRecord').countDocuments({ doctor: doctorId }),

      // Total prescriptions
      Prescription.countDocuments({ doctor: doctorId }),

      // Today's appointments
      require('../models/Appointment').countDocuments({
        doctor: doctorId,
        'scheduling.timeSlot.startTime': {
          $gte: startOfDay,
          $lt: new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000)
        }
      }),

      // Weekly appointments
      require('../models/Appointment').countDocuments({
        doctor: doctorId,
        'scheduling.timeSlot.startTime': { $gte: startOfWeek }
      }),

      // Monthly appointments
      require('../models/Appointment').countDocuments({
        doctor: doctorId,
        'scheduling.timeSlot.startTime': { $gte: startOfMonth }
      }),

      // Appointment status breakdown
      require('../models/Appointment').aggregate([
        { $match: { doctor: mongoose.Types.ObjectId(doctorId) } },
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 }
          }
        }
      ]),

      // Recent activity
      require('../models/Appointment').find({
        doctor: doctorId,
        'scheduling.timeSlot.startTime': { $gte: startOfWeek }
      })
      .limit(10)
      .populate('patient', 'personalInfo.firstName personalInfo.lastName')
      .sort({ 'scheduling.timeSlot.startTime': -1 })
    ]);

    const statistics = {
      overview: {
        totalPatients: totalPatients[0]?.total || 0,
        totalAppointments,
        totalMedicalRecords,
        totalPrescriptions,
        todayAppointments,
        weeklyAppointments,
        monthlyAppointments
      },
      appointmentBreakdown: appointmentStats.reduce((acc, stat) => {
        acc[stat._id] = stat.count;
        return acc;
      }, {}),
      recentActivity: recentActivity.map(apt => ({
        type: 'appointment',
        patientName: apt.patient ? `${apt.patient.personalInfo.firstName} ${apt.patient.personalInfo.lastName}` : 'Unknown',
        date: apt.scheduling.timeSlot.startTime,
        status: apt.status
      }))
    };

    res.json({
      status: 'success',
      data: {
        statistics
      }
    });

  } catch (error) {
    logger.error('Get doctor statistics error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching statistics'
    });
  }
});

module.exports = router;
