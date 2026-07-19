const express = require('express');
const { body, validationResult, query } = require('express-validator');
const MedicalRecord = require('../models/MedicalRecord');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const Hospital = require('../models/Hospital');
const Appointment = require('../models/Appointment');
const { authenticateDoctor, authenticatePatient, authenticate } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// @route   POST /api/v1/medical-records
// @desc    Create a new medical record
// @access  Private (Doctor)
router.post('/', authenticateDoctor, [
  body('patient').isMongoId().withMessage('Valid patient ID required'),
  body('visitInfo.visitType').isIn(['consultation', 'follow-up', 'emergency', 'procedure', 'surgery', 'therapy', 'diagnostic']).withMessage('Valid visit type required'),
  body('visitInfo.department').notEmpty().withMessage('Department is required'),
  body('visitInfo.specialty').notEmpty().withMessage('Specialty is required'),
  body('chiefComplaint.primaryComplaint').isLength({ min: 10, max: 1000 }).withMessage('Primary complaint must be 10-1000 characters'),
  body('diagnosis.primary.condition').notEmpty().withMessage('Primary diagnosis is required')
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
      appointment: appointmentId,
      visitInfo,
      chiefComplaint,
      examination,
      diagnosis,
      investigations,
      treatment,
      planAndAdvice,
      attachments
    } = req.body;

    // Verify patient exists
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // Get doctor info
    const doctor = await Doctor.findById(req.user.id);
    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    // Verify appointment if provided
    let appointment = null;
    if (appointmentId) {
      appointment = await Appointment.findById(appointmentId);
      if (!appointment) {
        return res.status(404).json({
          status: 'error',
          message: 'Appointment not found'
        });
      }

      // Verify appointment belongs to this doctor and patient
      if (appointment.doctor.toString() !== req.user.id || appointment.patient.toString() !== patientId) {
        return res.status(400).json({
          status: 'error',
          message: 'Appointment does not match doctor and patient'
        });
      }
    }

    // Create medical record
    const medicalRecord = new MedicalRecord({
      patient: patientId,
      doctor: req.user.id,
      hospital: doctor.hospital,
      appointment: appointmentId,
      visitInfo: {
        ...visitInfo,
        visitDate: visitInfo.visitDate || new Date()
      },
      chiefComplaint,
      examination,
      diagnosis,
      investigations,
      treatment,
      planAndAdvice,
      attachments: attachments || [],
      recordStatus: {
        status: 'draft'
      }
    });

    await medicalRecord.save();

    // Update appointment if provided
    if (appointment) {
      appointment.status = 'completed';
      appointment.consultation.actualEndTime = new Date();
      appointment.consultation.consultationNotes = chiefComplaint.primaryComplaint;
      appointment.consultation.diagnosis = diagnosis.primary.condition;
      await appointment.save();
    }

    // Populate the response
    await medicalRecord.populate([
      { path: 'patient', select: 'patientId personalInfo.firstName personalInfo.lastName personalInfo.dateOfBirth' },
      { path: 'doctor', select: 'doctorId personalInfo.firstName personalInfo.lastName specialization' },
      { path: 'hospital', select: 'hospitalId name' }
    ]);

    logger.info(`Medical record created: ${medicalRecord.recordId} by doctor ${req.user.id}`);

    res.status(201).json({
      status: 'success',
      message: 'Medical record created successfully',
      data: {
        medicalRecord
      }
    });

  } catch (error) {
    logger.error('Create medical record error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating medical record'
    });
  }
});

// @route   GET /api/v1/medical-records
// @desc    Get medical records (with filters)
// @access  Private
router.get('/', authenticate, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('patient').optional().isMongoId().withMessage('Valid patient ID required'),
  query('diagnosis').optional().isString(),
  query('dateFrom').optional().isISO8601().withMessage('Valid date required'),
  query('dateTo').optional().isISO8601().withMessage('Valid date required')
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
        // Doctor accessing specific patient's records
        query = {
          $or: [
            { doctor: req.user.id },
            { patient: req.query.patient, 'recordStatus.status': 'completed' }
          ]
        };
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
    if (req.query.diagnosis) {
      query.$or = [
        { 'diagnosis.primary.condition': new RegExp(req.query.diagnosis, 'i') },
        { 'diagnosis.secondary.condition': new RegExp(req.query.diagnosis, 'i') }
      ];
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

    // Execute query
    const [medicalRecords, total] = await Promise.all([
      MedicalRecord.find(query)
        .sort({ 'visitInfo.visitDate': -1 })
        .skip(skip)
        .limit(limit)
        .populate('patient', 'patientId personalInfo.firstName personalInfo.lastName personalInfo.dateOfBirth')
        .populate('doctor', 'doctorId personalInfo.firstName personalInfo.lastName specialization')
        .populate('hospital', 'hospitalId name'),
      MedicalRecord.countDocuments(query)
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
    logger.error('Get medical records error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching medical records'
    });
  }
});

// @route   GET /api/v1/medical-records/:id
// @desc    Get medical record by ID
// @access  Private
router.get('/:id', authenticate, async (req, res) => {
  try {
    const medicalRecord = await MedicalRecord.findOne({
      $or: [
        { _id: req.params.id },
        { recordId: req.params.id }
      ]
    }).populate([
      { path: 'patient', select: 'patientId personalInfo currentHealth' },
      { path: 'doctor', select: 'doctorId personalInfo specialization experience' },
      { path: 'hospital', select: 'hospitalId name contactInfo' },
      { path: 'appointment', select: 'appointmentId scheduling' }
    ]);

    if (!medicalRecord) {
      return res.status(404).json({
        status: 'error',
        message: 'Medical record not found'
      });
    }

    // Check access permissions
    const hasAccess = 
      (req.user.userType === 'patient' && medicalRecord.patient._id.toString() === req.user.id) ||
      (req.user.userType === 'doctor' && (
        medicalRecord.doctor._id.toString() === req.user.id ||
        medicalRecord.recordStatus.status === 'completed'
      )) ||
      (req.user.userType === 'hospital' && medicalRecord.hospital._id.toString() === req.user.id);

    if (!hasAccess) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Log access for audit trail
    medicalRecord.logAccess(
      req.user.id,
      req.user.userType,
      `${req.user.firstName || ''} ${req.user.lastName || ''}`.trim(),
      'view',
      req.ip
    );

    res.json({
      status: 'success',
      data: {
        medicalRecord
      }
    });

  } catch (error) {
    logger.error('Get medical record error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching medical record'
    });
  }
});

// @route   PUT /api/v1/medical-records/:id
// @desc    Update medical record
// @access  Private (Doctor who created it)
router.put('/:id', authenticateDoctor, [
  body('recordStatus.status').optional().isIn(['draft', 'completed', 'verified', 'amended']),
  body('amendments.reason').if(body('recordStatus.status').equals('amended')).notEmpty()
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

    const medicalRecord = await MedicalRecord.findOne({
      $or: [
        { _id: req.params.id },
        { recordId: req.params.id }
      ]
    });

    if (!medicalRecord) {
      return res.status(404).json({
        status: 'error',
        message: 'Medical record not found'
      });
    }

    // Check if doctor can edit this record
    if (medicalRecord.doctor.toString() !== req.user.id) {
      return res.status(403).json({
        status: 'error',
        message: 'You can only edit medical records you created'
      });
    }

    // Check if record can be edited
    if (medicalRecord.recordStatus.status === 'verified' && req.body.recordStatus?.status !== 'amended') {
      return res.status(400).json({
        status: 'error',
        message: 'Verified records can only be amended, not edited'
      });
    }

    const {
      visitInfo,
      chiefComplaint,
      examination,
      diagnosis,
      investigations,
      treatment,
      planAndAdvice,
      attachments,
      recordStatus,
      amendments
    } = req.body;

    // Update fields if provided
    if (visitInfo) medicalRecord.visitInfo = { ...medicalRecord.visitInfo, ...visitInfo };
    if (chiefComplaint) medicalRecord.chiefComplaint = { ...medicalRecord.chiefComplaint, ...chiefComplaint };
    if (examination) medicalRecord.examination = { ...medicalRecord.examination, ...examination };
    if (diagnosis) medicalRecord.diagnosis = { ...medicalRecord.diagnosis, ...diagnosis };
    if (investigations) medicalRecord.investigations = { ...medicalRecord.investigations, ...investigations };
    if (treatment) medicalRecord.treatment = { ...medicalRecord.treatment, ...treatment };
    if (planAndAdvice) medicalRecord.planAndAdvice = { ...medicalRecord.planAndAdvice, ...planAndAdvice };
    if (attachments) medicalRecord.attachments = attachments;

    // Handle status changes
    if (recordStatus) {
      if (recordStatus.status === 'verified') {
        medicalRecord.recordStatus.status = 'verified';
        medicalRecord.recordStatus.verifiedBy = req.user.id;
        medicalRecord.recordStatus.verificationDate = new Date();
      } else if (recordStatus.status === 'amended' && amendments) {
        medicalRecord.recordStatus.status = 'amended';
        medicalRecord.recordStatus.amendments.push({
          amendedBy: req.user.id,
          reason: amendments.reason,
          changes: amendments.changes || 'Record amended'
        });
      } else {
        medicalRecord.recordStatus.status = recordStatus.status;
      }
    }

    await medicalRecord.save();

    // Log access for audit trail
    medicalRecord.logAccess(
      req.user.id,
      req.user.userType,
      `${req.user.firstName || ''} ${req.user.lastName || ''}`.trim(),
      'edit',
      req.ip
    );

    await medicalRecord.populate([
      { path: 'patient', select: 'patientId personalInfo.firstName personalInfo.lastName' },
      { path: 'doctor', select: 'doctorId personalInfo.firstName personalInfo.lastName specialization' },
      { path: 'hospital', select: 'hospitalId name' }
    ]);

    logger.info(`Medical record updated: ${medicalRecord.recordId} by doctor ${req.user.id}`);

    res.json({
      status: 'success',
      message: 'Medical record updated successfully',
      data: {
        medicalRecord
      }
    });

  } catch (error) {
    logger.error('Update medical record error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating medical record'
    });
  }
});

// @route   GET /api/v1/medical-records/patient/:patientId/history
// @desc    Get patient's complete medical history
// @access  Private
router.get('/patient/:patientId/history', authenticate, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('specialty').optional().isString(),
  query('condition').optional().isString()
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

    const { patientId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;

    // Check if user has access to this patient's records
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

    // Build query
    let query = { patient: patientId, 'recordStatus.status': { $in: ['completed', 'verified'] } };

    if (req.query.specialty) {
      query['visitInfo.specialty'] = new RegExp(req.query.specialty, 'i');
    }

    if (req.query.condition) {
      query.$or = [
        { 'diagnosis.primary.condition': new RegExp(req.query.condition, 'i') },
        { 'diagnosis.secondary.condition': new RegExp(req.query.condition, 'i') }
      ];
    }

    const options = {
      limit,
      skip: (page - 1) * limit
    };

    const medicalRecords = await MedicalRecord.getPatientHistory(patientId, options);
    const total = await MedicalRecord.countDocuments(query);

    // Get summary statistics
    const summaryStats = await MedicalRecord.aggregate([
      { $match: { patient: mongoose.Types.ObjectId(patientId) } },
      {
        $group: {
          _id: null,
          totalVisits: { $sum: 1 },
          specialties: { $addToSet: '$visitInfo.specialty' },
          commonDiagnoses: { $push: '$diagnosis.primary.condition' },
          lastVisit: { $max: '$visitInfo.visitDate' },
          firstVisit: { $min: '$visitInfo.visitDate' }
        }
      }
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
        },
        summary: summaryStats[0] || {
          totalVisits: 0,
          specialties: [],
          commonDiagnoses: [],
          lastVisit: null,
          firstVisit: null
        }
      }
    });

  } catch (error) {
    logger.error('Get patient history error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching patient medical history'
    });
  }
});

// @route   GET /api/v1/medical-records/search
// @desc    Search medical records by various criteria
// @access  Private (Doctor, Hospital)
router.get('/search', authenticate, [
  query('q').optional().isString().withMessage('Search query required'),
  query('type').optional().isIn(['diagnosis', 'symptoms', 'medications', 'procedures']),
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 50 })
], async (req, res) => {
  try {
    // Only allow doctors and hospitals to search across records
    if (req.user.userType === 'patient') {
      return res.status(403).json({
        status: 'error',
        message: 'Patients can only access their own medical records'
      });
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { q, type } = req.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    if (!q) {
      return res.status(400).json({
        status: 'error',
        message: 'Search query is required'
      });
    }

    // Build search query based on type
    let searchQuery = {};

    // Base access control
    if (req.user.userType === 'doctor') {
      searchQuery.doctor = req.user.id;
    } else if (req.user.userType === 'hospital') {
      searchQuery.hospital = req.user.id;
    }

    // Add search criteria
    const searchRegex = new RegExp(q, 'i');

    switch (type) {
      case 'diagnosis':
        searchQuery.$or = [
          { 'diagnosis.primary.condition': searchRegex },
          { 'diagnosis.secondary.condition': searchRegex }
        ];
        break;
      case 'symptoms':
        searchQuery.$or = [
          { 'chiefComplaint.symptoms.symptom': searchRegex },
          { 'chiefComplaint.primaryComplaint': searchRegex }
        ];
        break;
      case 'medications':
        searchQuery['treatment.medications.medicationName'] = searchRegex;
        break;
      case 'procedures':
        searchQuery.$or = [
          { 'investigations.procedures.procedureName': searchRegex },
          { 'treatment.procedures.name': searchRegex }
        ];
        break;
      default:
        // General search across multiple fields
        searchQuery.$or = [
          { 'diagnosis.primary.condition': searchRegex },
          { 'chiefComplaint.primaryComplaint': searchRegex },
          { 'treatment.medications.medicationName': searchRegex },
          { 'investigations.procedures.procedureName': searchRegex }
        ];
    }

    const [medicalRecords, total] = await Promise.all([
      MedicalRecord.find(searchQuery)
        .sort({ 'visitInfo.visitDate': -1 })
        .skip(skip)
        .limit(limit)
        .populate('patient', 'patientId personalInfo.firstName personalInfo.lastName personalInfo.dateOfBirth')
        .populate('doctor', 'doctorId personalInfo.firstName personalInfo.lastName specialization')
        .populate('hospital', 'hospitalId name'),
      MedicalRecord.countDocuments(searchQuery)
    ]);

    res.json({
      status: 'success',
      data: {
        medicalRecords,
        searchQuery: q,
        searchType: type || 'general',
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
    logger.error('Search medical records error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error searching medical records'
    });
  }
});

module.exports = router;
