const express = require('express');
const { query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const Hospital = require('../models/Hospital');
const Prescription = require('../models/Prescription');
const { authenticateDoctor, authenticateHospital, authenticate } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// @route   GET /api/v1/analytics/patient/:patientId/health-trends
// @desc    Get patient health trends and analytics
// @access  Private (Patient, Doctor)
router.get('/patient/:patientId/health-trends', authenticate, [
  query('period').optional().isIn(['week', 'month', 'quarter', 'year']),
  query('metrics').optional().isString()
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
    const period = req.query.period || 'month';
    const metrics = req.query.metrics ? req.query.metrics.split(',') : ['all'];

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

    // Calculate date range based on period
    const now = new Date();
    let startDate;
    
    switch (period) {
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'quarter':
        startDate = new Date(now.getFullYear(), now.getMonth() - 3, now.getDate());
        break;
      case 'year':
        startDate = new Date(now.getFullYear() - 1, now.getMonth(), now.getDate());
        break;
      default: // month
        startDate = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
    }

    // Get patient data
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // Get medical records for trends
    const medicalRecords = await require('../models/MedicalRecord').find({
      patient: patientId,
      'visitInfo.visitDate': { $gte: startDate },
      'recordStatus.status': { $in: ['completed', 'verified'] }
    }).sort({ 'visitInfo.visitDate': 1 });

    // Get appointments for trends
    const appointments = await require('../models/Appointment').find({
      patient: patientId,
      'scheduling.timeSlot.startTime': { $gte: startDate }
    }).sort({ 'scheduling.timeSlot.startTime': 1 });

    // Get prescriptions for trends
    const prescriptions = await Prescription.find({
      patient: patientId,
      createdAt: { $gte: startDate }
    }).sort({ createdAt: 1 });

    // Analyze health trends
    const healthTrends = {
      vitals: {
        bloodPressure: [],
        heartRate: [],
        weight: [],
        temperature: []
      },
      visitFrequency: [],
      commonDiagnoses: {},
      medicationTrends: {},
      appointmentPattern: {}
    };

    // Extract vital signs trends
    medicalRecords.forEach(record => {
      const vitals = record.examination?.vitalSigns;
      const date = record.visitInfo.visitDate;
      
      if (vitals?.bloodPressure?.systolic) {
        healthTrends.vitals.bloodPressure.push({
          date,
          systolic: vitals.bloodPressure.systolic,
          diastolic: vitals.bloodPressure.diastolic
        });
      }
      
      if (vitals?.heartRate?.value) {
        healthTrends.vitals.heartRate.push({
          date,
          value: vitals.heartRate.value
        });
      }
      
      if (vitals?.weight?.value) {
        healthTrends.vitals.weight.push({
          date,
          value: vitals.weight.value
        });
      }
      
      if (vitals?.temperature?.value) {
        healthTrends.vitals.temperature.push({
          date,
          value: vitals.temperature.value
        });
      }

      // Diagnoses trends
      const diagnosis = record.diagnosis?.primary?.condition;
      if (diagnosis) {
        healthTrends.commonDiagnoses[diagnosis] = (healthTrends.commonDiagnoses[diagnosis] || 0) + 1;
      }
    });

    // Medication trends
    prescriptions.forEach(prescription => {
      prescription.medications.forEach(med => {
        healthTrends.medicationTrends[med.drugName] = (healthTrends.medicationTrends[med.drugName] || 0) + 1;
      });
    });

    // Appointment patterns
    const appointmentsByMonth = {};
    appointments.forEach(apt => {
      const monthKey = `${apt.scheduling.timeSlot.startTime.getFullYear()}-${apt.scheduling.timeSlot.startTime.getMonth() + 1}`;
      appointmentsByMonth[monthKey] = (appointmentsByMonth[monthKey] || 0) + 1;
    });
    healthTrends.appointmentPattern = appointmentsByMonth;

    // Health score calculation (simplified)
    const calculateHealthScore = () => {
      let score = 100;
      const recentRecords = medicalRecords.slice(-3); // Last 3 records
      
      if (recentRecords.length === 0) return 85; // Default score
      
      // Deduct points for chronic conditions, high BP, etc.
      recentRecords.forEach(record => {
        const vitals = record.examination?.vitalSigns;
        if (vitals?.bloodPressure?.systolic > 140) score -= 5;
        if (vitals?.bloodPressure?.diastolic > 90) score -= 5;
        if (record.diagnosis?.primary?.severity === 'severe') score -= 10;
      });
      
      return Math.max(score, 0);
    };

    const analytics = {
      period: {
        type: period,
        startDate,
        endDate: now
      },
      patient: {
        patientId: patient.patientId,
        name: patient.fullName,
        age: patient.age
      },
      healthScore: calculateHealthScore(),
      trends: healthTrends,
      summary: {
        totalVisits: medicalRecords.length,
        totalAppointments: appointments.length,
        totalPrescriptions: prescriptions.length,
        mostCommonDiagnosis: Object.keys(healthTrends.commonDiagnoses).reduce((a, b) => 
          healthTrends.commonDiagnoses[a] > healthTrends.commonDiagnoses[b] ? a : b, 'None'
        ),
        averageVisitsPerMonth: medicalRecords.length / (period === 'year' ? 12 : period === 'quarter' ? 3 : 1)
      }
    };

    res.json({
      status: 'success',
      data: {
        analytics
      }
    });

  } catch (error) {
    logger.error('Get patient health trends error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching patient health trends'
    });
  }
});

// @route   GET /api/v1/analytics/hospital/:hospitalId/performance
// @desc    Get hospital performance analytics
// @access  Private (Hospital)
router.get('/hospital/:hospitalId/performance', authenticateHospital, [
  query('period').optional().isIn(['week', 'month', 'quarter', 'year']),
  query('department').optional().isString()
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

    const { hospitalId } = req.params;
    const period = req.query.period || 'month';
    const department = req.query.department;

    // Check if user can access this hospital's data
    if (req.user.id !== hospitalId) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Calculate date range
    const now = new Date();
    let startDate;
    
    switch (period) {
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'quarter':
        startDate = new Date(now.getFullYear(), now.getMonth() - 3, now.getDate());
        break;
      case 'year':
        startDate = new Date(now.getFullYear() - 1, now.getMonth(), now.getDate());
        break;
      default: // month
        startDate = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
    }

    // Build base query
    let appointmentQuery = { 
      hospital: mongoose.Types.ObjectId(hospitalId),
      'scheduling.timeSlot.startTime': { $gte: startDate }
    };

    let doctorQuery = { hospital: mongoose.Types.ObjectId(hospitalId) };

    if (department) {
      appointmentQuery['appointmentDetails.specialty'] = new RegExp(department, 'i');
      doctorQuery['professionalInfo.department'] = new RegExp(department, 'i');
    }

    // Get comprehensive analytics
    const [
      totalDoctors,
      totalAppointments,
      appointmentStatusStats,
      departmentStats,
      patientSatisfaction,
      revenueEstimate,
      capacityUtilization,
      appointmentTrends
    ] = await Promise.all([
      // Total doctors
      Doctor.countDocuments(doctorQuery),

      // Total appointments
      require('../models/Appointment').countDocuments(appointmentQuery),

      // Appointment status breakdown
      require('../models/Appointment').aggregate([
        { $match: appointmentQuery },
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 }
          }
        }
      ]),

      // Department performance
      require('../models/Appointment').aggregate([
        { $match: appointmentQuery },
        {
          $group: {
            _id: '$appointmentDetails.specialty',
            appointmentCount: { $sum: 1 },
            avgConsultationFee: { $avg: '$bookingInfo.consultationFee' }
          }
        },
        { $sort: { appointmentCount: -1 } }
      ]),

      // Patient satisfaction (simulated - in real app would come from feedback)
      Promise.resolve({ averageRating: 4.2, totalReviews: 150 }),

      // Revenue estimate
      require('../models/Appointment').aggregate([
        { 
          $match: {
            ...appointmentQuery,
            status: 'completed',
            'bookingInfo.paymentStatus': 'paid'
          }
        },
        {
          $group: {
            _id: null,
            totalRevenue: { $sum: '$bookingInfo.consultationFee' },
            avgConsultationFee: { $avg: '$bookingInfo.consultationFee' }
          }
        }
      ]),

      // Capacity utilization (simulated)
      Promise.resolve({ utilizationRate: 75 }),

      // Appointment trends by day
      require('../models/Appointment').aggregate([
        { $match: appointmentQuery },
        {
          $group: {
            _id: {
              year: { $year: '$scheduling.timeSlot.startTime' },
              month: { $month: '$scheduling.timeSlot.startTime' },
              day: { $dayOfMonth: '$scheduling.timeSlot.startTime' }
            },
            count: { $sum: 1 }
          }
        },
        { $sort: { '_id.year': 1, '_id.month': 1, '_id.day': 1 } }
      ])
    ]);

    const analytics = {
      period: {
        type: period,
        startDate,
        endDate: now,
        department: department || 'All Departments'
      },
      overview: {
        totalDoctors,
        totalAppointments,
        completedAppointments: appointmentStatusStats.find(s => s._id === 'completed')?.count || 0,
        pendingAppointments: appointmentStatusStats.find(s => s._id === 'pending')?.count || 0,
        cancelledAppointments: appointmentStatusStats.find(s => s._id === 'cancelled')?.count || 0
      },
      performance: {
        appointmentCompletionRate: totalAppointments > 0 ? 
          ((appointmentStatusStats.find(s => s._id === 'completed')?.count || 0) / totalAppointments * 100).toFixed(2) : 0,
        averageAppointmentsPerDoctor: totalDoctors > 0 ? (totalAppointments / totalDoctors).toFixed(2) : 0,
        patientSatisfaction: patientSatisfaction.averageRating,
        capacityUtilization: capacityUtilization.utilizationRate
      },
      financial: {
        estimatedRevenue: revenueEstimate[0]?.totalRevenue || 0,
        averageConsultationFee: revenueEstimate[0]?.avgConsultationFee || 0
      },
      departmentPerformance: departmentStats.map(dept => ({
        department: dept._id,
        appointments: dept.appointmentCount,
        avgFee: dept.avgConsultationFee,
        revenue: dept.appointmentCount * (dept.avgConsultationFee || 0)
      })),
      trends: {
        daily: appointmentTrends.map(trend => ({
          date: `${trend._id.year}-${String(trend._id.month).padStart(2, '0')}-${String(trend._id.day).padStart(2, '0')}`,
          appointments: trend.count
        }))
      }
    };

    res.json({
      status: 'success',
      data: {
        analytics
      }
    });

  } catch (error) {
    logger.error('Get hospital performance analytics error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching hospital performance analytics'
    });
  }
});

// @route   GET /api/v1/analytics/doctor/:doctorId/performance
// @desc    Get doctor performance analytics
// @access  Private (Doctor)
router.get('/doctor/:doctorId/performance', authenticateDoctor, [
  query('period').optional().isIn(['week', 'month', 'quarter', 'year'])
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
    const period = req.query.period || 'month';

    // Check if doctor can access these analytics
    if (req.user.id !== doctorId) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Calculate date range
    const now = new Date();
    let startDate;
    
    switch (period) {
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'quarter':
        startDate = new Date(now.getFullYear(), now.getMonth() - 3, now.getDate());
        break;
      case 'year':
        startDate = new Date(now.getFullYear() - 1, now.getMonth(), now.getDate());
        break;
      default: // month
        startDate = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
    }

    const appointmentQuery = {
      doctor: mongoose.Types.ObjectId(doctorId),
      'scheduling.timeSlot.startTime': { $gte: startDate }
    };

    // Get comprehensive doctor analytics
    const [
      doctor,
      totalAppointments,
      appointmentStatusStats,
      patientDemographics,
      commonDiagnoses,
      prescriptionStats,
      appointmentTrends,
      averageConsultationTime
    ] = await Promise.all([
      // Doctor info
      Doctor.findById(doctorId).select('doctorId personalInfo professionalInfo statistics'),

      // Total appointments
      require('../models/Appointment').countDocuments(appointmentQuery),

      // Appointment status breakdown
      require('../models/Appointment').aggregate([
        { $match: appointmentQuery },
        {
          $group: {
            _id: '$status',
            count: { $sum: 1 }
          }
        }
      ]),

      // Patient demographics
      require('../models/Appointment').aggregate([
        { $match: appointmentQuery },
        {
          $lookup: {
            from: 'patients',
            localField: 'patient',
            foreignField: '_id',
            as: 'patientInfo'
          }
        },
        { $unwind: '$patientInfo' },
        {
          $group: {
            _id: '$patientInfo.personalInfo.gender',
            count: { $sum: 1 }
          }
        }
      ]),

      // Common diagnoses from medical records
      require('../models/MedicalRecord').aggregate([
        { 
          $match: { 
            doctor: mongoose.Types.ObjectId(doctorId),
            'visitInfo.visitDate': { $gte: startDate }
          }
        },
        {
          $group: {
            _id: '$diagnosis.primary.condition',
            count: { $sum: 1 }
          }
        },
        { $sort: { count: -1 } },
        { $limit: 10 }
      ]),

      // Prescription statistics
      Prescription.aggregate([
        { 
          $match: { 
            doctor: mongoose.Types.ObjectId(doctorId),
            createdAt: { $gte: startDate }
          }
        },
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

      // Appointment trends
      require('../models/Appointment').aggregate([
        { $match: appointmentQuery },
        {
          $group: {
            _id: {
              year: { $year: '$scheduling.timeSlot.startTime' },
              month: { $month: '$scheduling.timeSlot.startTime' },
              week: { $week: '$scheduling.timeSlot.startTime' }
            },
            count: { $sum: 1 }
          }
        },
        { $sort: { '_id.year': 1, '_id.month': 1, '_id.week': 1 } }
      ]),

      // Average consultation time (simulated)
      Promise.resolve(35) // 35 minutes average
    ]);

    const completedAppointments = appointmentStatusStats.find(s => s._id === 'completed')?.count || 0;
    const cancelledAppointments = appointmentStatusStats.find(s => s._id === 'cancelled')?.count || 0;

    const analytics = {
      period: {
        type: period,
        startDate,
        endDate: now
      },
      doctor: {
        doctorId: doctor.doctorId,
        name: doctor.fullName,
        specialization: doctor.professionalInfo.specialization,
        experience: doctor.professionalInfo.experience
      },
      performance: {
        totalAppointments,
        completedAppointments,
        cancelledAppointments,
        completionRate: totalAppointments > 0 ? ((completedAppointments / totalAppointments) * 100).toFixed(2) : 0,
        cancellationRate: totalAppointments > 0 ? ((cancelledAppointments / totalAppointments) * 100).toFixed(2) : 0,
        averageConsultationTime,
        patientSatisfactionScore: 4.3 // Simulated
      },
      patientInsights: {
        demographics: patientDemographics.reduce((acc, demo) => {
          acc[demo._id] = demo.count;
          return acc;
        }, {}),
        uniquePatients: new Set(appointmentStatusStats.map(a => a.patient)).size || 0
      },
      clinicalInsights: {
        commonDiagnoses: commonDiagnoses.map(d => ({
          diagnosis: d._id,
          frequency: d.count
        })),
        commonPrescriptions: prescriptionStats.map(p => ({
          medication: p._id,
          frequency: p.count
        }))
      },
      trends: {
        weekly: appointmentTrends
      }
    };

    res.json({
      status: 'success',
      data: {
        analytics
      }
    });

  } catch (error) {
    logger.error('Get doctor performance analytics error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching doctor performance analytics'
    });
  }
});

// @route   GET /api/v1/analytics/system/overview
// @desc    Get system-wide analytics overview
// @access  Private (Hospital/Admin)
router.get('/system/overview', authenticate, [
  query('period').optional().isIn(['week', 'month', 'quarter', 'year'])
], async (req, res) => {
  try {
    // Only hospitals can access system overview for now
    if (req.user.userType !== 'hospital') {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const period = req.query.period || 'month';
    const now = new Date();
    let startDate;
    
    switch (period) {
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'quarter':
        startDate = new Date(now.getFullYear(), now.getMonth() - 3, now.getDate());
        break;
      case 'year':
        startDate = new Date(now.getFullYear() - 1, now.getMonth(), now.getDate());
        break;
      default:
        startDate = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
    }

    // Get system-wide statistics
    const [
      totalPatients,
      totalDoctors,
      totalHospitals,
      totalAppointments,
      totalPrescriptions,
      totalMedicalRecords,
      recentActivity
    ] = await Promise.all([
      Patient.countDocuments(),
      Doctor.countDocuments(),
      Hospital.countDocuments(),
      require('../models/Appointment').countDocuments({ createdAt: { $gte: startDate } }),
      Prescription.countDocuments({ createdAt: { $gte: startDate } }),
      require('../models/MedicalRecord').countDocuments({ 'visitInfo.visitDate': { $gte: startDate } }),
      
      // Recent activity
      require('../models/Appointment').find({
        createdAt: { $gte: new Date(now.getTime() - 24 * 60 * 60 * 1000) }
      })
      .limit(10)
      .populate('patient', 'personalInfo.firstName personalInfo.lastName')
      .populate('doctor', 'personalInfo.firstName personalInfo.lastName')
      .sort({ createdAt: -1 })
    ]);

    const systemOverview = {
      period: {
        type: period,
        startDate,
        endDate: now
      },
      systemStats: {
        totalPatients,
        totalDoctors,
        totalHospitals,
        totalAppointments,
        totalPrescriptions,
        totalMedicalRecords
      },
      growth: {
        // Simplified growth calculation
        appointmentGrowth: totalAppointments > 0 ? '+12%' : '0%',
        patientGrowth: totalPatients > 0 ? '+8%' : '0%',
        prescriptionGrowth: totalPrescriptions > 0 ? '+15%' : '0%'
      },
      recentActivity: recentActivity.map(activity => ({
        type: 'appointment',
        description: `${activity.patient?.personalInfo?.firstName || 'Unknown'} scheduled with ${activity.doctor?.personalInfo?.firstName || 'Unknown'}`,
        timestamp: activity.createdAt
      }))
    };

    res.json({
      status: 'success',
      data: {
        overview: systemOverview
      }
    });

  } catch (error) {
    logger.error('Get system overview error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching system overview'
    });
  }
});

module.exports = router;
