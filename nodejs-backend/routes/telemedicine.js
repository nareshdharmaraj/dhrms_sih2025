const express = require('express');
const { body, query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const { authenticate, authenticatePatient, authenticateDoctor } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// Telemedicine Session Schema (would be a separate model in real app)
const telemedicineSessionSchema = {
  sessionId: String,
  appointment: mongoose.Types.ObjectId,
  patient: mongoose.Types.ObjectId,
  doctor: mongoose.Types.ObjectId,
  sessionType: { type: String, enum: ['video', 'audio', 'chat'] },
  scheduledTime: Date,
  actualStartTime: Date,
  actualEndTime: Date,
  duration: Number, // in minutes
  status: { type: String, enum: ['scheduled', 'waiting', 'active', 'completed', 'cancelled', 'no-show'] },
  connection: {
    roomId: String,
    connectionToken: String,
    quality: { type: String, enum: ['excellent', 'good', 'fair', 'poor'] },
    technicalIssues: [String]
  },
  consultation: {
    chiefComplaint: String,
    symptoms: [String],
    assessment: String,
    diagnosis: String,
    treatment: String,
    prescriptions: [{
      medication: String,
      dosage: String,
      frequency: String,
      duration: String
    }],
    followUp: {
      required: Boolean,
      timeline: String,
      instructions: String
    }
  },
  recordings: {
    videoRecorded: Boolean,
    audioRecorded: Boolean,
    recordingPath: String,
    transcriptPath: String
  },
  feedback: {
    patientRating: Number,
    doctorRating: Number,
    technicalRating: Number,
    comments: String
  }
};

// @route   POST /api/v1/telemedicine/session/create
// @desc    Create new telemedicine session
// @access  Private (Patient, Doctor)
router.post('/session/create', authenticate, [
  body('appointmentId').isMongoId().withMessage('Valid appointment ID is required'),
  body('sessionType').isIn(['video', 'audio', 'chat']).withMessage('Valid session type required'),
  body('scheduledTime').isISO8601().withMessage('Valid scheduled time required')
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

    const { appointmentId, sessionType, scheduledTime, preferences } = req.body;

    // Verify appointment exists and user has access
    const appointment = await require('../models/Appointment').findById(appointmentId)
      .populate('patient', 'personalInfo')
      .populate('doctor', 'personalInfo');

    if (!appointment) {
      return res.status(404).json({
        status: 'error',
        message: 'Appointment not found'
      });
    }

    // Check if user can create session for this appointment
    const canCreate = 
      (req.user.userType === 'patient' && req.user.id === appointment.patient._id.toString()) ||
      (req.user.userType === 'doctor' && req.user.id === appointment.doctor._id.toString());

    if (!canCreate) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Generate session details
    const sessionId = `TM${Date.now()}${Math.random().toString(36).substr(2, 6).toUpperCase()}`;
    const roomId = `room_${sessionId}`;
    const connectionToken = `token_${sessionId}_${Date.now()}`;

    // Create telemedicine session
    const session = {
      sessionId,
      appointment: appointmentId,
      patient: appointment.patient._id,
      doctor: appointment.doctor._id,
      sessionType,
      scheduledTime: new Date(scheduledTime),
      status: 'scheduled',
      connection: {
        roomId,
        connectionToken,
        quality: null,
        technicalIssues: []
      },
      consultation: {
        chiefComplaint: null,
        symptoms: [],
        assessment: null,
        diagnosis: null,
        treatment: null,
        prescriptions: []
      },
      recordings: {
        videoRecorded: preferences?.recordVideo || false,
        audioRecorded: preferences?.recordAudio || false,
        recordingPath: null,
        transcriptPath: null
      },
      feedback: {
        patientRating: null,
        doctorRating: null,
        technicalRating: null,
        comments: null
      },
      createdAt: new Date(),
      createdBy: req.user.id
    };

    // In real app, would save to TelemedicineSessions collection
    logger.info(`Telemedicine session created: ${sessionId}`, {
      appointmentId,
      sessionType,
      patient: appointment.patient.personalInfo.firstName,
      doctor: appointment.doctor.personalInfo.firstName
    });

    res.status(201).json({
      status: 'success',
      message: 'Telemedicine session created successfully',
      data: {
        session: {
          sessionId,
          appointmentId,
          sessionType,
          scheduledTime: session.scheduledTime,
          status: session.status,
          roomId,
          connectionToken,
          participants: {
            patient: {
              id: appointment.patient._id,
              name: `${appointment.patient.personalInfo.firstName} ${appointment.patient.personalInfo.lastName}`
            },
            doctor: {
              id: appointment.doctor._id,
              name: `Dr. ${appointment.doctor.personalInfo.firstName} ${appointment.doctor.personalInfo.lastName}`
            }
          }
        }
      }
    });

  } catch (error) {
    logger.error('Create telemedicine session error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating telemedicine session'
    });
  }
});

// @route   GET /api/v1/telemedicine/session/:sessionId
// @desc    Get telemedicine session details
// @access  Private (Patient, Doctor)
router.get('/session/:sessionId', authenticate, async (req, res) => {
  try {
    const { sessionId } = req.params;

    // In real app, would query TelemedicineSessions collection
    // Simulating session data
    const mockSession = {
      sessionId,
      appointment: new mongoose.Types.ObjectId(),
      patient: {
        id: new mongoose.Types.ObjectId(),
        name: 'John Doe',
        age: 45
      },
      doctor: {
        id: new mongoose.Types.ObjectId(),
        name: 'Dr. Sarah Johnson',
        specialization: 'Cardiology'
      },
      sessionType: 'video',
      scheduledTime: new Date(),
      actualStartTime: null,
      actualEndTime: null,
      duration: null,
      status: 'scheduled',
      connection: {
        roomId: `room_${sessionId}`,
        connectionToken: `token_${sessionId}_${Date.now()}`,
        quality: null,
        technicalIssues: []
      },
      consultation: {
        chiefComplaint: null,
        symptoms: [],
        assessment: null,
        diagnosis: null,
        treatment: null,
        prescriptions: []
      },
      recordings: {
        videoRecorded: false,
        audioRecorded: false
      }
    };

    // Check access permissions
    const hasAccess = 
      (req.user.userType === 'patient' && req.user.id === mockSession.patient.id.toString()) ||
      (req.user.userType === 'doctor' && req.user.id === mockSession.doctor.id.toString());

    if (!hasAccess) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    res.json({
      status: 'success',
      data: {
        session: mockSession
      }
    });

  } catch (error) {
    logger.error('Get telemedicine session error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching telemedicine session'
    });
  }
});

// @route   POST /api/v1/telemedicine/session/:sessionId/join
// @desc    Join telemedicine session
// @access  Private (Patient, Doctor)
router.post('/session/:sessionId/join', authenticate, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { deviceInfo } = req.body;

    // In real app, would update session status and generate connection details
    const joinTime = new Date();
    const participantType = req.user.userType;

    // Generate WebRTC connection details (in real app would integrate with video service)
    const connectionDetails = {
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' }
      ],
      roomId: `room_${sessionId}`,
      participantId: `${participantType}_${req.user.id}`,
      token: `join_token_${Date.now()}`,
      mediaConstraints: {
        video: true,
        audio: true
      }
    };

    logger.info(`User joined telemedicine session: ${sessionId}`, {
      participantType,
      userId: req.user.id,
      joinTime
    });

    res.json({
      status: 'success',
      message: 'Successfully joined telemedicine session',
      data: {
        sessionId,
        participantType,
        joinTime,
        connectionDetails
      }
    });

  } catch (error) {
    logger.error('Join telemedicine session error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error joining telemedicine session'
    });
  }
});

// @route   POST /api/v1/telemedicine/session/:sessionId/start
// @desc    Start telemedicine session
// @access  Private (Doctor)
router.post('/session/:sessionId/start', authenticateDoctor, async (req, res) => {
  try {
    const { sessionId } = req.params;

    // In real app, would update session status to 'active'
    const startTime = new Date();

    logger.info(`Telemedicine session started: ${sessionId}`, {
      doctorId: req.user.id,
      startTime
    });

    res.json({
      status: 'success',
      message: 'Telemedicine session started',
      data: {
        sessionId,
        status: 'active',
        startTime
      }
    });

  } catch (error) {
    logger.error('Start telemedicine session error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error starting telemedicine session'
    });
  }
});

// @route   POST /api/v1/telemedicine/session/:sessionId/consultation
// @desc    Record consultation details during session
// @access  Private (Doctor)
router.post('/session/:sessionId/consultation', authenticateDoctor, [
  body('consultation.chiefComplaint').notEmpty().withMessage('Chief complaint is required'),
  body('consultation.symptoms').optional().isArray(),
  body('consultation.assessment').optional().isString(),
  body('consultation.diagnosis').optional().isString(),
  body('consultation.treatment').optional().isString(),
  body('consultation.prescriptions').optional().isArray()
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

    const { sessionId } = req.params;
    const { consultation } = req.body;

    // In real app, would update session consultation data
    const consultationRecord = {
      sessionId,
      ...consultation,
      recordedAt: new Date(),
      recordedBy: req.user.id
    };

    logger.info(`Consultation recorded for session: ${sessionId}`, {
      doctorId: req.user.id,
      chiefComplaint: consultation.chiefComplaint
    });

    res.json({
      status: 'success',
      message: 'Consultation details recorded',
      data: {
        consultation: consultationRecord
      }
    });

  } catch (error) {
    logger.error('Record consultation error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error recording consultation details'
    });
  }
});

// @route   POST /api/v1/telemedicine/session/:sessionId/end
// @desc    End telemedicine session
// @access  Private (Doctor, Patient)
router.post('/session/:sessionId/end', authenticate, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { reason } = req.body;

    const endTime = new Date();
    // In real app, would calculate actual duration from start time
    const duration = 30; // Simulated 30 minutes

    // In real app, would update session status to 'completed'
    logger.info(`Telemedicine session ended: ${sessionId}`, {
      endedBy: req.user.userType,
      userId: req.user.id,
      endTime,
      duration,
      reason
    });

    res.json({
      status: 'success',
      message: 'Telemedicine session ended',
      data: {
        sessionId,
        status: 'completed',
        endTime,
        duration,
        endedBy: req.user.userType
      }
    });

  } catch (error) {
    logger.error('End telemedicine session error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error ending telemedicine session'
    });
  }
});

// @route   GET /api/v1/telemedicine/sessions
// @desc    Get user's telemedicine sessions
// @access  Private (Patient, Doctor)
router.get('/sessions', authenticate, [
  query('status').optional().isIn(['scheduled', 'active', 'completed', 'cancelled']),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('offset').optional().isInt({ min: 0 })
], async (req, res) => {
  try {
    const { status, limit = 20, offset = 0 } = req.query;

    // In real app, would query TelemedicineSessions collection
    // Simulating user's sessions
    const mockSessions = [
      {
        sessionId: 'TM202312201A1B2C',
        appointmentId: new mongoose.Types.ObjectId(),
        sessionType: 'video',
        scheduledTime: new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
        status: 'scheduled',
        participant: req.user.userType === 'patient' ? 
          { type: 'doctor', name: 'Dr. Sarah Johnson', specialization: 'Cardiology' } :
          { type: 'patient', name: 'John Doe', age: 45 },
        duration: null
      },
      {
        sessionId: 'TM202312191D4E5F',
        appointmentId: new mongoose.Types.ObjectId(),
        sessionType: 'video',
        scheduledTime: new Date(Date.now() - 24 * 60 * 60 * 1000), // Yesterday
        status: 'completed',
        participant: req.user.userType === 'patient' ? 
          { type: 'doctor', name: 'Dr. Michael Brown', specialization: 'General Medicine' } :
          { type: 'patient', name: 'Jane Smith', age: 32 },
        duration: 25
      }
    ];

    // Filter by status if provided
    let filteredSessions = mockSessions;
    if (status) {
      filteredSessions = mockSessions.filter(s => s.status === status);
    }

    // Apply pagination
    const paginatedSessions = filteredSessions.slice(offset, offset + parseInt(limit));

    res.json({
      status: 'success',
      data: {
        sessions: paginatedSessions,
        pagination: {
          total: filteredSessions.length,
          limit: parseInt(limit),
          offset: parseInt(offset),
          hasMore: offset + parseInt(limit) < filteredSessions.length
        }
      }
    });

  } catch (error) {
    logger.error('Get telemedicine sessions error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching telemedicine sessions'
    });
  }
});

// @route   POST /api/v1/telemedicine/session/:sessionId/feedback
// @desc    Submit session feedback
// @access  Private (Patient, Doctor)
router.post('/session/:sessionId/feedback', authenticate, [
  body('feedback.rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('feedback.technicalRating').optional().isInt({ min: 1, max: 5 }),
  body('feedback.comments').optional().isLength({ max: 1000 })
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

    const { sessionId } = req.params;
    const { feedback } = req.body;

    // In real app, would update session feedback
    const feedbackRecord = {
      sessionId,
      submittedBy: req.user.userType,
      submittedAt: new Date(),
      ...feedback
    };

    logger.info(`Session feedback submitted: ${sessionId}`, {
      submittedBy: req.user.userType,
      rating: feedback.rating
    });

    res.json({
      status: 'success',
      message: 'Feedback submitted successfully',
      data: {
        feedback: feedbackRecord
      }
    });

  } catch (error) {
    logger.error('Submit session feedback error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error submitting session feedback'
    });
  }
});

// @route   GET /api/v1/telemedicine/session/:sessionId/recording
// @desc    Get session recording details
// @access  Private (Patient, Doctor)
router.get('/session/:sessionId/recording', authenticate, async (req, res) => {
  try {
    const { sessionId } = req.params;

    // In real app, would check if recording exists and user has access
    const mockRecording = {
      sessionId,
      available: true,
      recordingType: 'video',
      duration: 1800, // 30 minutes in seconds
      fileSize: '450MB',
      quality: 'HD',
      recordingDate: new Date(Date.now() - 24 * 60 * 60 * 1000),
      downloadUrl: `/api/v1/telemedicine/session/${sessionId}/recording/download`,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      transcript: {
        available: true,
        downloadUrl: `/api/v1/telemedicine/session/${sessionId}/transcript/download`
      }
    };

    res.json({
      status: 'success',
      data: {
        recording: mockRecording
      }
    });

  } catch (error) {
    logger.error('Get session recording error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching session recording'
    });
  }
});

// @route   GET /api/v1/telemedicine/statistics
// @desc    Get telemedicine usage statistics
// @access  Private (Doctor, Hospital)
router.get('/statistics', authenticate, [
  query('period').optional().isIn(['week', 'month', 'quarter', 'year'])
], async (req, res) => {
  try {
    // Only doctors and hospitals can access statistics
    if (!['doctor', 'hospital'].includes(req.user.userType)) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const period = req.query.period || 'month';

    // In real app, would aggregate statistics from TelemedicineSessions collection
    const statistics = {
      period: {
        type: period,
        startDate: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
        endDate: new Date()
      },
      sessions: {
        total: 156,
        completed: 142,
        cancelled: 8,
        noShow: 6,
        completionRate: 91.0
      },
      sessionTypes: {
        video: 120,
        audio: 28,
        chat: 8
      },
      averageDuration: 28.5, // minutes
      patientSatisfaction: {
        averageRating: 4.3,
        totalReviews: 135
      },
      technicalMetrics: {
        connectionSuccess: 98.5, // percentage
        averageQuality: 'good',
        commonIssues: ['audio delay', 'video pixelation']
      },
      topSpecialties: [
        { specialty: 'General Medicine', sessions: 45 },
        { specialty: 'Cardiology', sessions: 32 },
        { specialty: 'Dermatology', sessions: 28 }
      ]
    };

    res.json({
      status: 'success',
      data: {
        statistics
      }
    });

  } catch (error) {
    logger.error('Get telemedicine statistics error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching telemedicine statistics'
    });
  }
});

module.exports = router;
