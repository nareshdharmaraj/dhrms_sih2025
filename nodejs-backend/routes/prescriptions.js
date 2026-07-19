const express = require('express');
const { body, validationResult, query } = require('express-validator');
const mongoose = require('mongoose');
const Prescription = require('../models/Prescription');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const Hospital = require('../models/Hospital');
const { authenticateDoctor, authenticatePatient, authenticate } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// @route   POST /api/v1/prescriptions
// @desc    Create new prescription
// @access  Private (Doctor)
router.post('/', authenticateDoctor, [
  body('patient').isMongoId().withMessage('Valid patient ID required'),
  body('medications').isArray({ min: 1 }).withMessage('At least one medication required'),
  body('medications.*.drugName').notEmpty().withMessage('Drug name is required'),
  body('medications.*.dosage').notEmpty().withMessage('Dosage is required'),
  body('medications.*.frequency').notEmpty().withMessage('Frequency is required'),
  body('medications.*.duration').notEmpty().withMessage('Duration is required'),
  body('diagnosis').notEmpty().withMessage('Diagnosis is required')
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
      patient: patientId,
      medications,
      diagnosis,
      instructions,
      followUpDate,
      urgency,
      medicalRecordRef
    } = req.body;

    // Verify patient exists
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // Get doctor and hospital info
    const doctor = await Doctor.findById(req.user.id);
    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    // Calculate prescription end date based on maximum medication duration
    const maxDuration = Math.max(...medications.map(med => {
      const match = med.duration.match(/(\d+)/);
      return match ? parseInt(match[1]) : 7; // Default 7 days
    }));

    const endDate = new Date();
    endDate.setDate(endDate.getDate() + maxDuration);

    // Create prescription
    const prescription = new Prescription({
      patient: patientId,
      doctor: req.user.id,
      hospital: doctor.hospital,
      medicalRecord: medicalRecordRef,
      prescriptionInfo: {
        diagnosis,
        symptoms: req.body.symptoms || [],
        instructions: instructions || ''
      },
      medications: medications.map(med => ({
        drugName: med.drugName,
        genericName: med.genericName || '',
        dosage: med.dosage,
        frequency: med.frequency,
        duration: med.duration,
        route: med.route || 'oral',
        instructions: med.instructions || '',
        quantity: med.quantity || '',
        refills: med.refills || 0
      })),
      validity: {
        startDate: new Date(),
        endDate: endDate
      },
      urgency: urgency || 'normal',
      followUpRequired: !!followUpDate,
      followUpDate: followUpDate ? new Date(followUpDate) : null,
      status: 'active'
    });

    await prescription.save();

    // Update doctor's prescription count
    await Doctor.findByIdAndUpdate(req.user.id, {
      $inc: { 'statistics.totalPrescriptions': 1 }
    });

    // Populate prescription for response
    await prescription.populate([
      { path: 'patient', select: 'patientId personalInfo.firstName personalInfo.lastName' },
      { path: 'doctor', select: 'doctorId personalInfo.firstName personalInfo.lastName' },
      { path: 'hospital', select: 'hospitalId name' }
    ]);

    logger.info(`Prescription created: ${prescription.prescriptionId} by doctor ${req.user.id}`);

    res.status(201).json({
      status: 'success',
      message: 'Prescription created successfully',
      data: {
        prescription
      }
    });

  } catch (error) {
    logger.error('Create prescription error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating prescription'
    });
  }
});

// @route   GET /api/v1/prescriptions
// @desc    Get prescriptions (with filters)
// @access  Private
router.get('/', authenticate, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('status').optional().isIn(['active', 'completed', 'cancelled', 'expired']),
  query('patient').optional().isMongoId(),
  query('startDate').optional().isISO8601(),
  query('endDate').optional().isISO8601()
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

    // Build query based on user type
    let query = {};
    
    if (req.user.userType === 'patient') {
      query.patient = req.user.id;
    } else if (req.user.userType === 'doctor') {
      if (req.query.patient) {
        // Doctor viewing specific patient's prescriptions
        query.patient = req.query.patient;
      } else {
        query.doctor = req.user.id;
      }
    } else if (req.user.userType === 'hospital') {
      query.hospital = req.user.id;
      if (req.query.patient) {
        query.patient = req.query.patient;
      }
    }

    // Add filters
    if (req.query.status) {
      query.status = req.query.status;
    }

    if (req.query.startDate || req.query.endDate) {
      query.createdAt = {};
      if (req.query.startDate) {
        query.createdAt.$gte = new Date(req.query.startDate);
      }
      if (req.query.endDate) {
        query.createdAt.$lte = new Date(req.query.endDate);
      }
    }

    const [prescriptions, total] = await Promise.all([
      Prescription.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('patient', 'patientId personalInfo.firstName personalInfo.lastName')
        .populate('doctor', 'doctorId personalInfo.firstName personalInfo.lastName')
        .populate('hospital', 'hospitalId name'),
      Prescription.countDocuments(query)
    ]);

    res.json({
      status: 'success',
      data: {
        prescriptions,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalPrescriptions: total,
          hasNext: page < Math.ceil(total / limit),
          hasPrev: page > 1
        }
      }
    });

  } catch (error) {
    logger.error('Get prescriptions error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching prescriptions'
    });
  }
});

// @route   GET /api/v1/prescriptions/:id
// @desc    Get prescription by ID
// @access  Private
router.get('/:id', authenticate, async (req, res) => {
  try {
    const prescription = await Prescription.findOne({
      $or: [
        { _id: req.params.id },
        { prescriptionId: req.params.id }
      ]
    }).populate([
      { path: 'patient', select: 'patientId personalInfo currentHealth.allergies' },
      { path: 'doctor', select: 'doctorId personalInfo professionalInfo' },
      { path: 'hospital', select: 'hospitalId name contactInfo' },
      { path: 'medicalRecord', select: 'recordId visitInfo diagnosis' }
    ]);

    if (!prescription) {
      return res.status(404).json({
        status: 'error',
        message: 'Prescription not found'
      });
    }

    // Check access permissions
    const hasAccess = 
      (req.user.userType === 'patient' && prescription.patient._id.toString() === req.user.id) ||
      (req.user.userType === 'doctor' && prescription.doctor._id.toString() === req.user.id) ||
      (req.user.userType === 'hospital' && prescription.hospital._id.toString() === req.user.id);

    if (!hasAccess) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    res.json({
      status: 'success',
      data: {
        prescription
      }
    });

  } catch (error) {
    logger.error('Get prescription error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching prescription'
    });
  }
});

// @route   PUT /api/v1/prescriptions/:id
// @desc    Update prescription
// @access  Private (Doctor who created it)
router.put('/:id', authenticateDoctor, [
  body('status').optional().isIn(['active', 'completed', 'cancelled', 'expired']),
  body('medications').optional().isArray(),
  body('instructions').optional().isString()
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

    const prescription = await Prescription.findOne({
      $or: [
        { _id: req.params.id },
        { prescriptionId: req.params.id }
      ]
    });

    if (!prescription) {
      return res.status(404).json({
        status: 'error',
        message: 'Prescription not found'
      });
    }

    // Check if doctor can edit this prescription
    if (prescription.doctor.toString() !== req.user.id) {
      return res.status(403).json({
        status: 'error',
        message: 'You can only edit prescriptions you created'
      });
    }

    const {
      status,
      medications,
      instructions,
      followUpDate,
      notes
    } = req.body;

    // Update fields if provided
    if (status) prescription.status = status;
    if (medications) prescription.medications = medications;
    if (instructions) prescription.prescriptionInfo.instructions = instructions;
    if (followUpDate) {
      prescription.followUpRequired = true;
      prescription.followUpDate = new Date(followUpDate);
    }
    if (notes) prescription.notes = notes;

    // Add to history
    prescription.history.push({
      action: 'updated',
      timestamp: new Date(),
      updatedBy: req.user.id,
      changes: Object.keys(req.body).join(', ')
    });

    await prescription.save();

    await prescription.populate([
      { path: 'patient', select: 'patientId personalInfo.firstName personalInfo.lastName' },
      { path: 'doctor', select: 'doctorId personalInfo.firstName personalInfo.lastName' },
      { path: 'hospital', select: 'hospitalId name' }
    ]);

    logger.info(`Prescription updated: ${prescription.prescriptionId} by doctor ${req.user.id}`);

    res.json({
      status: 'success',
      message: 'Prescription updated successfully',
      data: {
        prescription
      }
    });

  } catch (error) {
    logger.error('Update prescription error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating prescription'
    });
  }
});

// @route   POST /api/v1/prescriptions/:id/dispense
// @desc    Mark prescription as dispensed (for pharmacy)
// @access  Private (Doctor/Hospital)
router.post('/:id/dispense', authenticate, [
  body('pharmacyInfo.name').notEmpty().withMessage('Pharmacy name required'),
  body('pharmacyInfo.license').notEmpty().withMessage('Pharmacy license required'),
  body('dispensedMedications').isArray({ min: 1 }).withMessage('At least one dispensed medication required')
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

    // Only doctors and hospitals can mark as dispensed
    if (req.user.userType === 'patient') {
      return res.status(403).json({
        status: 'error',
        message: 'Patients cannot mark prescriptions as dispensed'
      });
    }

    const prescription = await Prescription.findOne({
      $or: [
        { _id: req.params.id },
        { prescriptionId: req.params.id }
      ]
    });

    if (!prescription) {
      return res.status(404).json({
        status: 'error',
        message: 'Prescription not found'
      });
    }

    const { pharmacyInfo, dispensedMedications, pharmacistNotes } = req.body;

    prescription.dispensingInfo = {
      isDispensed: true,
      dispensedDate: new Date(),
      pharmacy: pharmacyInfo,
      dispensedMedications,
      pharmacistNotes: pharmacistNotes || '',
      dispensedBy: req.user.id
    };

    // Add to history
    prescription.history.push({
      action: 'dispensed',
      timestamp: new Date(),
      updatedBy: req.user.id,
      changes: `Dispensed at ${pharmacyInfo.name}`
    });

    await prescription.save();

    logger.info(`Prescription dispensed: ${prescription.prescriptionId} at ${pharmacyInfo.name}`);

    res.json({
      status: 'success',
      message: 'Prescription marked as dispensed successfully',
      data: {
        prescription: {
          prescriptionId: prescription.prescriptionId,
          dispensingInfo: prescription.dispensingInfo
        }
      }
    });

  } catch (error) {
    logger.error('Dispense prescription error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error marking prescription as dispensed'
    });
  }
});

// @route   GET /api/v1/prescriptions/patient/:patientId/active
// @desc    Get active prescriptions for a patient
// @access  Private
router.get('/patient/:patientId/active', authenticate, async (req, res) => {
  try {
    const { patientId } = req.params;

    // Check access permissions
    const hasAccess = 
      (req.user.userType === 'patient' && req.user.id === patientId) ||
      (req.user.userType === 'doctor') ||
      (req.user.userType === 'hospital');

    if (!hasAccess) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const activePrescriptions = await Prescription.find({
      patient: patientId,
      status: 'active',
      'validity.endDate': { $gte: new Date() }
    })
    .sort({ createdAt: -1 })
    .populate('doctor', 'doctorId personalInfo.firstName personalInfo.lastName')
    .populate('hospital', 'hospitalId name');

    res.json({
      status: 'success',
      data: {
        activePrescriptions,
        count: activePrescriptions.length
      }
    });

  } catch (error) {
    logger.error('Get active prescriptions error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching active prescriptions'
    });
  }
});

// @route   GET /api/v1/prescriptions/doctor/:doctorId/statistics
// @desc    Get prescription statistics for a doctor
// @access  Private (Doctor)
router.get('/doctor/:doctorId/statistics', authenticateDoctor, async (req, res) => {
  try {
    const { doctorId } = req.params;

    // Check if doctor can access these statistics
    if (req.user.id !== doctorId) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay()));

    const [
      totalPrescriptions,
      activePrescriptions,
      monthlyPrescriptions,
      weeklyPrescriptions,
      commonMedications,
      statusBreakdown
    ] = await Promise.all([
      // Total prescriptions
      Prescription.countDocuments({ doctor: doctorId }),

      // Active prescriptions
      Prescription.countDocuments({
        doctor: doctorId,
        status: 'active',
        'validity.endDate': { $gte: new Date() }
      }),

      // Monthly prescriptions
      Prescription.countDocuments({
        doctor: doctorId,
        createdAt: { $gte: startOfMonth }
      }),

      // Weekly prescriptions
      Prescription.countDocuments({
        doctor: doctorId,
        createdAt: { $gte: startOfWeek }
      }),

      // Common medications
      Prescription.aggregate([
        { $match: { doctor: mongoose.Types.ObjectId(doctorId) } },
        { $unwind: '$medications' },
        {
          $group: {
            _id: '$medications.drugName',
            count: { $sum: 1 }
          }
        },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]),

      // Status breakdown
      Prescription.aggregate([
        { $match: { doctor: mongoose.Types.ObjectId(doctorId) } },
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
        totalPrescriptions,
        activePrescriptions,
        monthlyPrescriptions,
        weeklyPrescriptions
      },
      commonMedications: commonMedications.map(med => ({
        medication: med._id,
        prescriptionCount: med.count
      })),
      statusBreakdown: statusBreakdown.reduce((acc, stat) => {
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
    logger.error('Get prescription statistics error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching prescription statistics'
    });
  }
});

module.exports = router;
