const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Appointment = require('../models/Appointment');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const Hospital = require('../models/Hospital');
const { authenticatePatient, authenticateDoctor, authenticateHospital, authenticate } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// @route   POST /api/v1/appointments
// @desc    Book a new appointment
// @access  Private (Patient, Doctor, Hospital)
router.post('/', authenticate, [
  body('doctor').isMongoId().withMessage('Valid doctor ID required'),
  body('hospital').isMongoId().withMessage('Valid hospital ID required'),
  body('appointmentDetails.specialty').notEmpty().withMessage('Specialty is required'),
  body('appointmentDetails.reasonForVisit').isLength({ min: 10, max: 500 }).withMessage('Reason for visit must be 10-500 characters'),
  body('scheduling.preferredDate').isISO8601().withMessage('Valid date required'),
  body('scheduling.preferredTime').matches(/^([01]?[0-9]|2[0-3]):[0-5][0-9]$/).withMessage('Valid time in HH:MM format required'),
  body('bookingInfo.consultationFee').isNumeric().withMessage('Valid consultation fee required')
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
      patient: requestedPatient,
      doctor: doctorId,
      hospital: hospitalId,
      appointmentDetails,
      scheduling,
      bookingInfo
    } = req.body;

    // Determine patient ID - use from request body if booking for someone else (doctor/hospital), otherwise use authenticated user
    let patientId;
    if (req.user.userType === 'patient') {
      patientId = req.user.id;
    } else if (requestedPatient) {
      patientId = requestedPatient;
    } else {
      return res.status(400).json({
        status: 'error',
        message: 'Patient ID required when booking appointment'
      });
    }

    // Verify all entities exist
    const [patient, doctor, hospital] = await Promise.all([
      Patient.findById(patientId),
      Doctor.findById(doctorId),
      Hospital.findById(hospitalId)
    ]);

    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    if (!hospital) {
      return res.status(404).json({
        status: 'error',
        message: 'Hospital not found'
      });
    }

    // Check if doctor is associated with the hospital
    if (doctor.hospital.toString() !== hospitalId) {
      return res.status(400).json({
        status: 'error',
        message: 'Doctor is not associated with the selected hospital'
      });
    }

    // Create time slot
    const preferredDate = new Date(scheduling.preferredDate);
    const [hours, minutes] = scheduling.preferredTime.split(':');
    const startTime = new Date(preferredDate);
    startTime.setHours(parseInt(hours), parseInt(minutes), 0, 0);
    
    const endTime = new Date(startTime);
    endTime.setMinutes(endTime.getMinutes() + (scheduling.duration || 30));

    // Check for conflicts
    const conflicts = await Appointment.findConflicts(doctorId, startTime, endTime);
    if (conflicts.length > 0) {
      return res.status(409).json({
        status: 'error',
        message: 'Time slot not available. Doctor has conflicting appointment.',
        conflicts: conflicts.map(appt => ({
          appointmentId: appt.appointmentId,
          startTime: appt.scheduling.timeSlot.startTime,
          endTime: appt.scheduling.timeSlot.endTime
        }))
      });
    }

    // Create appointment
    const appointment = new Appointment({
      patient: patientId,
      doctor: doctorId,
      hospital: hospitalId,
      appointmentDetails: {
        ...appointmentDetails,
        priority: appointmentDetails.priority || 'medium'
      },
      scheduling: {
        ...scheduling,
        timeSlot: {
          startTime,
          endTime
        }
      },
      bookingInfo: {
        ...bookingInfo,
        bookedBy: req.user.userType,
        consultationFee: bookingInfo.consultationFee
      },
      history: [{
        action: 'created',
        updatedBy: {
          userId: req.user.id,
          userType: req.user.userType
        }
      }]
    });

    await appointment.save();

    // Populate appointment details for response
    await appointment.populate([
      { path: 'patient', select: 'patientId personalInfo.firstName personalInfo.lastName personalInfo.phone' },
      { path: 'doctor', select: 'doctorId personalInfo.firstName personalInfo.lastName specialization' },
      { path: 'hospital', select: 'hospitalId name contactInfo' }
    ]);

    logger.info(`Appointment created: ${appointment.appointmentId} by ${req.user.userType} ${req.user.id}`);

    res.status(201).json({
      status: 'success',
      message: 'Appointment booked successfully',
      data: {
        appointment
      }
    });

  } catch (error) {
    logger.error('Book appointment error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error booking appointment'
    });
  }
});

// @route   GET /api/v1/appointments
// @desc    Get appointments (with filters)
// @access  Private
router.get('/', authenticate, [
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  query('status').optional().isIn(['pending', 'confirmed', 'in-progress', 'completed', 'cancelled', 'no-show', 'rescheduled']),
  query('date').optional().isISO8601().withMessage('Valid date required'),
  query('specialty').optional().isString()
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
      query.doctor = req.user.id;
    } else if (req.user.userType === 'hospital') {
      query.hospital = req.user.id;
    }

    // Add filters
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

    if (req.query.specialty) {
      query['appointmentDetails.specialty'] = new RegExp(req.query.specialty, 'i');
    }

    // Execute query
    const [appointments, total] = await Promise.all([
      Appointment.find(query)
        .sort({ 'scheduling.timeSlot.startTime': 1 })
        .skip(skip)
        .limit(limit)
        .populate('patient', 'patientId personalInfo.firstName personalInfo.lastName personalInfo.phone')
        .populate('doctor', 'doctorId personalInfo.firstName personalInfo.lastName specialization')
        .populate('hospital', 'hospitalId name contactInfo'),
      Appointment.countDocuments(query)
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
    logger.error('Get appointments error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching appointments'
    });
  }
});

// @route   GET /api/v1/appointments/:id
// @desc    Get appointment by ID
// @access  Private
router.get('/:id', authenticate, async (req, res) => {
  try {
    const appointment = await Appointment.findOne({
      $or: [
        { _id: req.params.id },
        { appointmentId: req.params.id }
      ]
    }).populate([
      { path: 'patient', select: 'patientId personalInfo currentHealth' },
      { path: 'doctor', select: 'doctorId personalInfo specialization experience' },
      { path: 'hospital', select: 'hospitalId name contactInfo address' },
      { path: 'consultation.prescription' }
    ]);

    if (!appointment) {
      return res.status(404).json({
        status: 'error',
        message: 'Appointment not found'
      });
    }

    // Check if user has access to this appointment
    const hasAccess = 
      (req.user.userType === 'patient' && appointment.patient._id.toString() === req.user.id) ||
      (req.user.userType === 'doctor' && appointment.doctor._id.toString() === req.user.id) ||
      (req.user.userType === 'hospital' && appointment.hospital._id.toString() === req.user.id);

    if (!hasAccess) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    res.json({
      status: 'success',
      data: {
        appointment
      }
    });

  } catch (error) {
    logger.error('Get appointment error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching appointment'
    });
  }
});

// @route   PUT /api/v1/appointments/:id
// @desc    Update appointment (reschedule, confirm, etc.)
// @access  Private
router.put('/:id', authenticate, [
  body('action').isIn(['confirm', 'reschedule', 'cancel', 'complete', 'no-show']).withMessage('Valid action required'),
  body('reason').optional().isLength({ max: 500 }).withMessage('Reason must be less than 500 characters')
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

    const appointment = await Appointment.findOne({
      $or: [
        { _id: req.params.id },
        { appointmentId: req.params.id }
      ]
    });

    if (!appointment) {
      return res.status(404).json({
        status: 'error',
        message: 'Appointment not found'
      });
    }

    // Check access permissions
    const hasAccess = 
      (req.user.userType === 'patient' && appointment.patient.toString() === req.user.id) ||
      (req.user.userType === 'doctor' && appointment.doctor.toString() === req.user.id) ||
      (req.user.userType === 'hospital' && appointment.hospital.toString() === req.user.id);

    if (!hasAccess) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const { action, reason, newDate, newTime, consultationNotes, diagnosis } = req.body;

    // Handle different actions
    switch (action) {
      case 'confirm':
        if (appointment.status !== 'pending') {
          return res.status(400).json({
            status: 'error',
            message: 'Only pending appointments can be confirmed'
          });
        }
        appointment.status = 'confirmed';
        break;

      case 'reschedule':
        if (!appointment.canBeRescheduled()) {
          return res.status(400).json({
            status: 'error',
            message: 'Appointment cannot be rescheduled (less than 12 hours remaining or invalid status)'
          });
        }

        if (newDate && newTime) {
          const rescheduleDate = new Date(newDate);
          const [hours, minutes] = newTime.split(':');
          const newStartTime = new Date(rescheduleDate);
          newStartTime.setHours(parseInt(hours), parseInt(minutes), 0, 0);
          
          const newEndTime = new Date(newStartTime);
          newEndTime.setMinutes(newEndTime.getMinutes() + appointment.scheduling.duration);

          // Check for conflicts
          const conflicts = await Appointment.findConflicts(appointment.doctor, newStartTime, newEndTime, appointment._id);
          if (conflicts.length > 0) {
            return res.status(409).json({
              status: 'error',
              message: 'New time slot not available'
            });
          }

          appointment.scheduling.preferredDate = rescheduleDate;
          appointment.scheduling.preferredTime = newTime;
          appointment.scheduling.timeSlot = {
            startTime: newStartTime,
            endTime: newEndTime
          };
        }
        
        appointment.status = 'rescheduled';
        break;

      case 'cancel':
        if (!appointment.canBeCancelled()) {
          return res.status(400).json({
            status: 'error',
            message: 'Appointment cannot be cancelled (less than 24 hours remaining or invalid status)'
          });
        }
        
        appointment.status = 'cancelled';
        appointment.cancellation = {
          cancelledBy: req.user.userType,
          cancellationDate: new Date(),
          reason: reason || 'No reason provided'
        };
        break;

      case 'complete':
        if (req.user.userType !== 'doctor') {
          return res.status(403).json({
            status: 'error',
            message: 'Only doctors can complete appointments'
          });
        }
        
        appointment.status = 'completed';
        appointment.consultation.actualEndTime = new Date();
        
        if (consultationNotes) {
          appointment.consultation.consultationNotes = consultationNotes;
        }
        
        if (diagnosis) {
          appointment.consultation.diagnosis = diagnosis;
        }
        break;

      case 'no-show':
        if (req.user.userType !== 'doctor' && req.user.userType !== 'hospital') {
          return res.status(403).json({
            status: 'error',
            message: 'Only doctors or hospitals can mark appointments as no-show'
          });
        }
        
        appointment.status = 'no-show';
        break;

      default:
        return res.status(400).json({
          status: 'error',
          message: 'Invalid action'
        });
    }

    // Add to history
    appointment.history.push({
      action,
      reason,
      updatedBy: {
        userId: req.user.id,
        userType: req.user.userType
      }
    });

    await appointment.save();

    await appointment.populate([
      { path: 'patient', select: 'patientId personalInfo.firstName personalInfo.lastName' },
      { path: 'doctor', select: 'doctorId personalInfo.firstName personalInfo.lastName specialization' },
      { path: 'hospital', select: 'hospitalId name' }
    ]);

    logger.info(`Appointment ${appointment.appointmentId} ${action} by ${req.user.userType} ${req.user.id}`);

    res.json({
      status: 'success',
      message: `Appointment ${action} successfully`,
      data: {
        appointment
      }
    });

  } catch (error) {
    logger.error('Update appointment error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating appointment'
    });
  }
});

// @route   GET /api/v1/appointments/availability/:doctorId
// @desc    Get doctor's availability
// @access  Private
router.get('/availability/:doctorId', authenticate, [
  query('date').isISO8601().withMessage('Valid date required'),
  query('duration').optional().isInt({ min: 15, max: 240 }).withMessage('Duration must be between 15 and 240 minutes')
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
    const { date } = req.query;
    const duration = parseInt(req.query.duration) || 30;

    // Check if doctor exists
    const doctor = await Doctor.findById(doctorId).select('availability schedule');
    if (!doctor) {
      return res.status(404).json({
        status: 'error',
        message: 'Doctor not found'
      });
    }

    const checkDate = new Date(date);
    const dayOfWeek = checkDate.getDay(); // 0 = Sunday, 6 = Saturday

    // Get doctor's schedule for the day (if available in doctor model)
    // For now, assume standard working hours: 9 AM to 5 PM
    const workingHours = {
      start: 9,
      end: 17,
      slotDuration: duration
    };

    // Get existing appointments for the date
    const nextDay = new Date(checkDate);
    nextDay.setDate(nextDay.getDate() + 1);

    const existingAppointments = await Appointment.find({
      doctor: doctorId,
      status: { $in: ['confirmed', 'in-progress'] },
      'scheduling.timeSlot.startTime': {
        $gte: checkDate,
        $lt: nextDay
      }
    }).select('scheduling.timeSlot');

    // Generate available time slots
    const availableSlots = [];
    const startHour = workingHours.start;
    const endHour = workingHours.end;

    for (let hour = startHour; hour < endHour; hour++) {
      for (let minute = 0; minute < 60; minute += duration) {
        const slotStart = new Date(checkDate);
        slotStart.setHours(hour, minute, 0, 0);
        
        const slotEnd = new Date(slotStart);
        slotEnd.setMinutes(slotEnd.getMinutes() + duration);

        // Check if slot conflicts with existing appointments
        const hasConflict = existingAppointments.some(appointment => {
          const appointmentStart = new Date(appointment.scheduling.timeSlot.startTime);
          const appointmentEnd = new Date(appointment.scheduling.timeSlot.endTime);
          
          return (slotStart < appointmentEnd && slotEnd > appointmentStart);
        });

        if (!hasConflict && slotEnd.getHours() <= endHour) {
          availableSlots.push({
            startTime: slotStart,
            endTime: slotEnd,
            duration: duration,
            available: true
          });
        }
      }
    }

    res.json({
      status: 'success',
      data: {
        doctorId,
        date: checkDate,
        availableSlots,
        totalSlots: availableSlots.length,
        duration: duration
      }
    });

  } catch (error) {
    logger.error('Get availability error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching availability'
    });
  }
});

// @route   GET /api/v1/appointments/dashboard/stats
// @desc    Get appointment statistics for dashboard
// @access  Private
router.get('/dashboard/stats', authenticate, async (req, res) => {
  try {
    let matchQuery = {};
    
    if (req.user.userType === 'patient') {
      matchQuery.patient = req.user.id;
    } else if (req.user.userType === 'doctor') {
      matchQuery.doctor = req.user.id;
    } else if (req.user.userType === 'hospital') {
      matchQuery.hospital = req.user.id;
    }

    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));
    const startOfWeek = new Date(today.setDate(today.getDate() - today.getDay()));
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const stats = await Appointment.aggregate([
      { $match: matchQuery },
      {
        $facet: {
          totalAppointments: [
            { $count: "count" }
          ],
          todayAppointments: [
            {
              $match: {
                'scheduling.timeSlot.startTime': {
                  $gte: startOfDay,
                  $lte: endOfDay
                }
              }
            },
            { $count: "count" }
          ],
          weeklyAppointments: [
            {
              $match: {
                'scheduling.timeSlot.startTime': {
                  $gte: startOfWeek
                }
              }
            },
            { $count: "count" }
          ],
          monthlyAppointments: [
            {
              $match: {
                'scheduling.timeSlot.startTime': {
                  $gte: startOfMonth
                }
              }
            },
            { $count: "count" }
          ],
          statusBreakdown: [
            {
              $group: {
                _id: "$status",
                count: { $sum: 1 }
              }
            }
          ],
          upcomingAppointments: [
            {
              $match: {
                status: { $in: ['confirmed', 'pending'] },
                'scheduling.timeSlot.startTime': { $gte: new Date() }
              }
            },
            { $sort: { 'scheduling.timeSlot.startTime': 1 } },
            { $limit: 5 },
            {
              $lookup: {
                from: 'patients',
                localField: 'patient',
                foreignField: '_id',
                as: 'patient'
              }
            },
            {
              $lookup: {
                from: 'doctors',
                localField: 'doctor',
                foreignField: '_id',
                as: 'doctor'
              }
            }
          ]
        }
      }
    ]);

    const result = stats[0];

    res.json({
      status: 'success',
      data: {
        totalAppointments: result.totalAppointments[0]?.count || 0,
        todayAppointments: result.todayAppointments[0]?.count || 0,
        weeklyAppointments: result.weeklyAppointments[0]?.count || 0,
        monthlyAppointments: result.monthlyAppointments[0]?.count || 0,
        statusBreakdown: result.statusBreakdown,
        upcomingAppointments: result.upcomingAppointments
      }
    });

  } catch (error) {
    logger.error('Get appointment stats error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching appointment statistics'
    });
  }
});

module.exports = router;
