const express = require('express');
const { body, validationResult, query } = require('express-validator');
const mongoose = require('mongoose');
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

// @route   PUT /api/v1/hospitals/profile
// @desc    Update hospital profile
// @access  Private (Hospital)
router.put('/profile', authenticateHospital, [
  body('contactInfo.email').optional().isEmail(),
  body('contactInfo.phone').optional().isMobilePhone(),
  body('contactInfo.website').optional().isURL(),
  body('operationalInfo.totalBeds').optional().isInt({ min: 1 }),
  body('operationalInfo.icuBeds').optional().isInt({ min: 0 })
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
      'contactInfo',
      'address',
      'operationalInfo',
      'facilities',
      'accreditation',
      'emergencyServices',
      'insuranceAccepted'
    ];

    const updates = {};
    Object.keys(req.body).forEach(key => {
      if (allowedUpdates.includes(key)) {
        updates[key] = req.body[key];
      }
    });

    const hospital = await Hospital.findByIdAndUpdate(
      req.user.id,
      { $set: updates },
      { new: true, runValidators: true }
    ).select('-credentials.password');

    logger.info(`Hospital profile updated: ${hospital.name}`, { hospitalId: hospital.hospitalId });

    res.json({
      status: 'success',
      message: 'Hospital profile updated successfully',
      data: {
        hospital
      }
    });

  } catch (error) {
    logger.error('Update hospital profile error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating hospital profile'
    });
  }
});

// @route   GET /api/v1/hospitals/departments
// @desc    Get hospital departments
// @access  Private (Hospital)
router.get('/departments', authenticateHospital, async (req, res) => {
  try {
    const hospital = await Hospital.findById(req.user.id)
      .select('departments')
      .populate('departments.headDoctor', 'doctorId personalInfo.firstName personalInfo.lastName');

    if (!hospital) {
      return res.status(404).json({
        status: 'error',
        message: 'Hospital not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        departments: hospital.departments
      }
    });

  } catch (error) {
    logger.error('Get departments error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching departments'
    });
  }
});

// @route   POST /api/v1/hospitals/departments
// @desc    Add new department
// @access  Private (Hospital)
router.post('/departments', authenticateHospital, [
  body('name').notEmpty().withMessage('Department name is required'),
  body('type').isIn(['general', 'specialized', 'emergency', 'surgical', 'diagnostic']).withMessage('Valid department type required'),
  body('floor').isInt({ min: 0 }).withMessage('Valid floor number required'),
  body('headDoctor').optional().isMongoId().withMessage('Valid doctor ID required')
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

    const { name, type, description, floor, capacity, headDoctor, contactInfo } = req.body;

    // Check if department already exists
    const hospital = await Hospital.findById(req.user.id);
    const existingDept = hospital.departments.find(dept => dept.name.toLowerCase() === name.toLowerCase());
    
    if (existingDept) {
      return res.status(400).json({
        status: 'error',
        message: 'Department with this name already exists'
      });
    }

    // Verify head doctor if provided
    if (headDoctor) {
      const doctor = await Doctor.findOne({ _id: headDoctor, hospital: req.user.id });
      if (!doctor) {
        return res.status(404).json({
          status: 'error',
          message: 'Head doctor not found or not associated with this hospital'
        });
      }
    }

    const newDepartment = {
      name,
      type,
      description: description || '',
      floor,
      capacity: capacity || 0,
      headDoctor: headDoctor || null,
      contactInfo: contactInfo || {},
      isActive: true,
      createdAt: new Date()
    };

    await Hospital.findByIdAndUpdate(
      req.user.id,
      { $push: { departments: newDepartment } },
      { new: true }
    );

    logger.info(`Department added: ${name} at ${hospital.name}`, { hospitalId: hospital.hospitalId });

    res.status(201).json({
      status: 'success',
      message: 'Department created successfully',
      data: {
        department: newDepartment
      }
    });

  } catch (error) {
    logger.error('Add department error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating department'
    });
  }
});

// @route   PUT /api/v1/hospitals/departments/:departmentId
// @desc    Update department
// @access  Private (Hospital)
router.put('/departments/:departmentId', authenticateHospital, [
  body('name').optional().notEmpty(),
  body('type').optional().isIn(['general', 'specialized', 'emergency', 'surgical', 'diagnostic']),
  body('floor').optional().isInt({ min: 0 }),
  body('headDoctor').optional().isMongoId()
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

    const { departmentId } = req.params;
    const updates = req.body;

    // Verify head doctor if being updated
    if (updates.headDoctor) {
      const doctor = await Doctor.findOne({ _id: updates.headDoctor, hospital: req.user.id });
      if (!doctor) {
        return res.status(404).json({
          status: 'error',
          message: 'Head doctor not found or not associated with this hospital'
        });
      }
    }

    const hospital = await Hospital.findOneAndUpdate(
      { 
        _id: req.user.id,
        'departments._id': departmentId
      },
      {
        $set: Object.keys(updates).reduce((acc, key) => {
          acc[`departments.$.${key}`] = updates[key];
          return acc;
        }, {})
      },
      { new: true }
    ).populate('departments.headDoctor', 'doctorId personalInfo.firstName personalInfo.lastName');

    if (!hospital) {
      return res.status(404).json({
        status: 'error',
        message: 'Department not found'
      });
    }

    const updatedDepartment = hospital.departments.id(departmentId);

    logger.info(`Department updated: ${updatedDepartment.name}`, { hospitalId: hospital.hospitalId });

    res.json({
      status: 'success',
      message: 'Department updated successfully',
      data: {
        department: updatedDepartment
      }
    });

  } catch (error) {
    logger.error('Update department error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating department'
    });
  }
});

// @route   DELETE /api/v1/hospitals/departments/:departmentId
// @desc    Delete department
// @access  Private (Hospital)
router.delete('/departments/:departmentId', authenticateHospital, async (req, res) => {
  try {
    const { departmentId } = req.params;

    const hospital = await Hospital.findByIdAndUpdate(
      req.user.id,
      { $pull: { departments: { _id: departmentId } } },
      { new: true }
    );

    if (!hospital) {
      return res.status(404).json({
        status: 'error',
        message: 'Department not found'
      });
    }

    logger.info(`Department deleted from ${hospital.name}`, { 
      hospitalId: hospital.hospitalId,
      departmentId 
    });

    res.json({
      status: 'success',
      message: 'Department deleted successfully'
    });

  } catch (error) {
    logger.error('Delete department error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error deleting department'
    });
  }
});

// @route   PUT /api/v1/hospitals/doctors/:doctorId
// @desc    Update doctor information
// @access  Private (Hospital)
router.put('/doctors/:doctorId', authenticateHospital, [
  body('professionalInfo.department').optional().notEmpty(),
  body('professionalInfo.designation').optional().notEmpty(),
  body('availability.isAvailable').optional().isBoolean()
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

    const { doctorId } = req.params;
    const updates = req.body;

    const doctor = await Doctor.findOne({ _id: doctorId, hospital: req.user.id });
    
    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found or not associated with this hospital'
      });
    }

    const allowedUpdates = [
      'professionalInfo.department',
      'professionalInfo.designation',
      'professionalInfo.experience',
      'availability',
      'services'
    ];

    const updateData = {};
    Object.keys(updates).forEach(key => {
      if (allowedUpdates.some(field => field.startsWith(key))) {
        updateData[key] = updates[key];
      }
    });

    const updatedDoctor = await Doctor.findByIdAndUpdate(
      doctorId,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('-credentials.password');

    logger.info(`Doctor updated by hospital: ${updatedDoctor.fullName}`, { 
      doctorId: updatedDoctor.doctorId,
      hospitalId: req.user.hospitalId 
    });

    res.json({
      status: 'success',
      message: 'Doctor information updated successfully',
      data: {
        doctor: updatedDoctor
      }
    });

  } catch (error) {
    logger.error('Update doctor error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating doctor information'
    });
  }
});

// @route   GET /api/v1/hospitals/bed-availability
// @desc    Get bed availability information
// @access  Private (Hospital)
router.get('/bed-availability', authenticateHospital, async (req, res) => {
  try {
    const hospital = await Hospital.findById(req.user.id).select('operationalInfo departments');

    if (!hospital) {
      return res.status(404).json({
        status: 'error',
        message: 'Hospital not found'
      });
    }

    // Calculate bed availability
    const totalBeds = hospital.operationalInfo?.totalBeds || 0;
    const icuBeds = hospital.operationalInfo?.icuBeds || 0;
    const generalBeds = totalBeds - icuBeds;

    // For now, simulating occupancy (in real implementation, this would come from actual bed management system)
    const occupiedGeneral = Math.floor(generalBeds * 0.7); // 70% occupancy simulation
    const occupiedICU = Math.floor(icuBeds * 0.8); // 80% ICU occupancy simulation

    const bedAvailability = {
      general: {
        total: generalBeds,
        occupied: occupiedGeneral,
        available: generalBeds - occupiedGeneral,
        occupancyRate: generalBeds > 0 ? (occupiedGeneral / generalBeds) * 100 : 0
      },
      icu: {
        total: icuBeds,
        occupied: occupiedICU,
        available: icuBeds - occupiedICU,
        occupancyRate: icuBeds > 0 ? (occupiedICU / icuBeds) * 100 : 0
      },
      overall: {
        total: totalBeds,
        occupied: occupiedGeneral + occupiedICU,
        available: (generalBeds - occupiedGeneral) + (icuBeds - occupiedICU),
        occupancyRate: totalBeds > 0 ? ((occupiedGeneral + occupiedICU) / totalBeds) * 100 : 0
      }
    };

    res.json({
      status: 'success',
      data: {
        bedAvailability,
        lastUpdated: new Date()
      }
    });

  } catch (error) {
    logger.error('Get bed availability error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching bed availability'
    });
  }
});

// @route   PUT /api/v1/hospitals/bed-availability
// @desc    Update bed availability
// @access  Private (Hospital)
router.put('/bed-availability', authenticateHospital, [
  body('totalBeds').isInt({ min: 1 }).withMessage('Total beds must be a positive integer'),
  body('icuBeds').isInt({ min: 0 }).withMessage('ICU beds must be a non-negative integer'),
  body('occupiedGeneral').optional().isInt({ min: 0 }),
  body('occupiedICU').optional().isInt({ min: 0 })
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

    const { totalBeds, icuBeds, occupiedGeneral, occupiedICU } = req.body;

    if (icuBeds > totalBeds) {
      return res.status(400).json({
        status: 'error',
        message: 'ICU beds cannot exceed total beds'
      });
    }

    const updateData = {
      'operationalInfo.totalBeds': totalBeds,
      'operationalInfo.icuBeds': icuBeds,
      'operationalInfo.lastUpdated': new Date()
    };

    const hospital = await Hospital.findByIdAndUpdate(
      req.user.id,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('hospitalId name operationalInfo');

    logger.info(`Bed availability updated for ${hospital.name}`, { 
      hospitalId: hospital.hospitalId,
      totalBeds,
      icuBeds 
    });

    res.json({
      status: 'success',
      message: 'Bed availability updated successfully',
      data: {
        hospital: {
          hospitalId: hospital.hospitalId,
          name: hospital.name,
          bedInfo: hospital.operationalInfo
        }
      }
    });

  } catch (error) {
    logger.error('Update bed availability error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating bed availability'
    });
  }
});

// @route   GET /api/v1/hospitals/statistics
// @desc    Get hospital statistics and analytics
// @access  Private (Hospital)
router.get('/statistics', authenticateHospital, async (req, res) => {
  try {
    const hospitalId = req.user.id;
    const now = new Date();
    const startOfDay = new Date(now.setHours(0, 0, 0, 0));
    const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay()));
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    // Get comprehensive hospital statistics
    const [
      totalDoctors,
      totalAppointments,
      totalPatients,
      todayAppointments,
      weeklyAppointments,
      monthlyAppointments,
      departmentStats,
      appointmentStatusStats
    ] = await Promise.all([
      // Total doctors
      Doctor.countDocuments({ hospital: hospitalId }),

      // Total appointments
      require('../models/Appointment').countDocuments({ hospital: hospitalId }),

      // Total unique patients
      require('../models/Appointment').aggregate([
        { $match: { hospital: mongoose.Types.ObjectId(hospitalId) } },
        { $group: { _id: '$patient' } },
        { $count: 'total' }
      ]),

      // Today's appointments
      require('../models/Appointment').countDocuments({
        hospital: hospitalId,
        'scheduling.timeSlot.startTime': {
          $gte: startOfDay,
          $lt: new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000)
        }
      }),

      // Weekly appointments
      require('../models/Appointment').countDocuments({
        hospital: hospitalId,
        'scheduling.timeSlot.startTime': { $gte: startOfWeek }
      }),

      // Monthly appointments
      require('../models/Appointment').countDocuments({
        hospital: hospitalId,
        'scheduling.timeSlot.startTime': { $gte: startOfMonth }
      }),

      // Department-wise doctor count
      Doctor.aggregate([
        { $match: { hospital: mongoose.Types.ObjectId(hospitalId) } },
        {
          $group: {
            _id: '$professionalInfo.department',
            doctorCount: { $sum: 1 }
          }
        }
      ]),

      // Appointment status breakdown
      require('../models/Appointment').aggregate([
        { $match: { hospital: mongoose.Types.ObjectId(hospitalId) } },
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 }
          }
        }
      ])
    ]);

    const statistics = {
      overview: {
        totalDoctors,
        totalAppointments,
        totalPatients: totalPatients[0]?.total || 0,
        todayAppointments,
        weeklyAppointments,
        monthlyAppointments
      },
      departments: departmentStats.reduce((acc, stat) => {
        acc[stat._id || 'Unknown'] = stat.doctorCount;
        return acc;
      }, {}),
      appointmentStatus: appointmentStatusStats.reduce((acc, stat) => {
        acc[stat._id] = stat.count;
        return acc;
      }, {})
    };

    res.json({
      status: 'success',
      data: {
        statistics
      }
    });

  } catch (error) {
    logger.error('Get hospital statistics error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching hospital statistics'
    });
  }
});

// @route   GET /api/v1/hospitals/appointments
// @desc    Get hospital appointments
// @access  Private (Hospital)
router.get('/appointments', authenticateHospital, [
  query('status').optional().isIn(['pending', 'confirmed', 'in-progress', 'completed', 'cancelled', 'no-show', 'rescheduled']),
  query('date').optional().isISO8601(),
  query('department').optional().isString(),
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
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Build query
    let query = { hospital: req.user.id };

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

    if (req.query.department) {
      query['appointmentDetails.specialty'] = new RegExp(req.query.department, 'i');
    }

    const [appointments, total] = await Promise.all([
      require('../models/Appointment').find(query)
        .sort({ 'scheduling.timeSlot.startTime': -1 })
        .skip(skip)
        .limit(limit)
        .populate('patient', 'patientId personalInfo.firstName personalInfo.lastName personalInfo.phone')
        .populate('doctor', 'doctorId personalInfo.firstName personalInfo.lastName professionalInfo.department'),
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
    logger.error('Get hospital appointments error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching hospital appointments'
    });
  }
});

module.exports = router;
