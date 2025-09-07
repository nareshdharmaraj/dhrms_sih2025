const express = require('express');
const { body, query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const { authenticate, authenticatePatient, authenticateDoctor } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// Health Monitoring Data Schema (would be a separate model in real app)
const healthDataSchema = {
  patientId: mongoose.Types.ObjectId,
  deviceId: String,
  dataType: { type: String, enum: ['vitals', 'activity', 'sleep', 'glucose', 'medication'] },
  measurements: [{
    timestamp: Date,
    value: mongoose.Schema.Types.Mixed,
    unit: String,
    source: { type: String, enum: ['device', 'manual', 'clinical'] }
  }],
  alerts: [{
    type: { type: String, enum: ['critical', 'warning', 'info'] },
    message: String,
    timestamp: Date,
    acknowledged: Boolean
  }],
  trends: {
    daily: mongoose.Schema.Types.Mixed,
    weekly: mongoose.Schema.Types.Mixed,
    monthly: mongoose.Schema.Types.Mixed
  }
};

// @route   POST /api/v1/health/vitals
// @desc    Record patient vital signs
// @access  Private (Patient, Doctor, Hospital)
router.post('/vitals', authenticate, [
  body('patientId').isMongoId().withMessage('Valid patient ID is required'),
  body('vitals.bloodPressure.systolic').optional().isInt({ min: 50, max: 250 }),
  body('vitals.bloodPressure.diastolic').optional().isInt({ min: 30, max: 150 }),
  body('vitals.heartRate').optional().isInt({ min: 30, max: 200 }),
  body('vitals.temperature').optional().isFloat({ min: 90, max: 110 }),
  body('vitals.oxygenSaturation').optional().isInt({ min: 70, max: 100 }),
  body('vitals.respiratoryRate').optional().isInt({ min: 5, max: 40 }),
  body('vitals.weight').optional().isFloat({ min: 20, max: 500 }),
  body('vitals.height').optional().isInt({ min: 50, max: 250 }),
  body('source').optional().isIn(['device', 'manual', 'clinical'])
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

    const { patientId, vitals, source = 'manual', deviceId, notes } = req.body;

    // Check if user can record vitals for this patient
    const canRecord = 
      (req.user.userType === 'patient' && req.user.id === patientId) ||
      (req.user.userType === 'doctor') ||
      (req.user.userType === 'hospital');

    if (!canRecord) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Verify patient exists
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    const timestamp = new Date();
    
    // Calculate BMI if weight and height provided
    let bmi = null;
    if (vitals.weight && vitals.height) {
      const heightInMeters = vitals.height / 100;
      bmi = (vitals.weight / (heightInMeters * heightInMeters)).toFixed(1);
    }

    // Check for alerts based on vital signs
    const alerts = [];
    
    // Blood pressure alerts
    if (vitals.bloodPressure) {
      const { systolic, diastolic } = vitals.bloodPressure;
      if (systolic >= 180 || diastolic >= 120) {
        alerts.push({
          type: 'critical',
          message: 'Hypertensive crisis - Systolic ≥180 or Diastolic ≥120',
          timestamp,
          acknowledged: false
        });
      } else if (systolic >= 140 || diastolic >= 90) {
        alerts.push({
          type: 'warning',
          message: 'High blood pressure detected',
          timestamp,
          acknowledged: false
        });
      }
    }

    // Heart rate alerts
    if (vitals.heartRate) {
      if (vitals.heartRate > 100) {
        alerts.push({
          type: 'warning',
          message: 'Tachycardia - Heart rate > 100 bpm',
          timestamp,
          acknowledged: false
        });
      } else if (vitals.heartRate < 60) {
        alerts.push({
          type: 'warning',
          message: 'Bradycardia - Heart rate < 60 bpm',
          timestamp,
          acknowledged: false
        });
      }
    }

    // Oxygen saturation alerts
    if (vitals.oxygenSaturation && vitals.oxygenSaturation < 95) {
      alerts.push({
        type: 'critical',
        message: 'Low oxygen saturation - SpO2 < 95%',
        timestamp,
        acknowledged: false
      });
    }

    // Temperature alerts
    if (vitals.temperature) {
      if (vitals.temperature >= 104) {
        alerts.push({
          type: 'critical',
          message: 'High fever - Temperature ≥ 104°F',
          timestamp,
          acknowledged: false
        });
      } else if (vitals.temperature >= 100.4) {
        alerts.push({
          type: 'warning',
          message: 'Fever detected - Temperature ≥ 100.4°F',
          timestamp,
          acknowledged: false
        });
      }
    }

    // Create vital signs record
    const vitalRecord = {
      id: new mongoose.Types.ObjectId(),
      patientId,
      timestamp,
      vitals: {
        ...vitals,
        bmi: bmi ? parseFloat(bmi) : undefined
      },
      source,
      deviceId,
      notes,
      alerts,
      recordedBy: req.user.id,
      recordedByType: req.user.userType
    };

    // In real app, would save to HealthData collection
    logger.info(`Vital signs recorded for patient: ${patientId}`, {
      source,
      alertCount: alerts.length,
      recordedBy: req.user.userType
    });

    res.status(201).json({
      status: 'success',
      message: 'Vital signs recorded successfully',
      data: {
        vitalRecord: {
          id: vitalRecord.id,
          timestamp: vitalRecord.timestamp,
          vitals: vitalRecord.vitals,
          alerts: alerts.length > 0 ? alerts : undefined,
          bmi: bmi ? parseFloat(bmi) : undefined
        }
      }
    });

  } catch (error) {
    logger.error('Record vital signs error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error recording vital signs'
    });
  }
});

// @route   GET /api/v1/health/vitals/:patientId
// @desc    Get patient vital signs history
// @access  Private (Patient, Doctor, Hospital)
router.get('/vitals/:patientId', authenticate, [
  query('startDate').optional().isISO8601(),
  query('endDate').optional().isISO8601(),
  query('type').optional().isIn(['bloodPressure', 'heartRate', 'temperature', 'weight', 'all']),
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

    const { patientId } = req.params;
    const { startDate, endDate, type = 'all', limit = 50 } = req.query;

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

    // Verify patient exists
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // In real app, would query HealthData collection
    // Simulating vital signs history
    const now = new Date();
    const mockVitalsHistory = [];
    
    for (let i = 0; i < Math.min(parseInt(limit), 20); i++) {
      const recordDate = new Date(now.getTime() - i * 24 * 60 * 60 * 1000);
      
      if (startDate && recordDate < new Date(startDate)) break;
      if (endDate && recordDate > new Date(endDate)) continue;

      mockVitalsHistory.push({
        id: new mongoose.Types.ObjectId(),
        timestamp: recordDate,
        vitals: {
          bloodPressure: {
            systolic: 120 + Math.random() * 40,
            diastolic: 80 + Math.random() * 20
          },
          heartRate: 70 + Math.random() * 30,
          temperature: 98.6 + Math.random() * 2,
          oxygenSaturation: 95 + Math.random() * 5,
          weight: 70 + Math.random() * 10,
          bmi: 22 + Math.random() * 5
        },
        source: Math.random() > 0.5 ? 'device' : 'manual'
      });
    }

    // Filter by type if specified
    let filteredHistory = mockVitalsHistory;
    if (type !== 'all') {
      filteredHistory = mockVitalsHistory.filter(record => record.vitals[type] !== undefined);
    }

    // Calculate trends
    const calculateTrends = (data, field) => {
      if (data.length < 2) return null;
      
      const values = data.map(d => d.vitals[field]).filter(v => v !== undefined);
      if (values.length < 2) return null;
      
      const latest = values[0];
      const previous = values[1];
      const change = latest - previous;
      const percentChange = ((change / previous) * 100).toFixed(1);
      
      return {
        current: latest,
        previous,
        change,
        percentChange: parseFloat(percentChange),
        trend: change > 0 ? 'increasing' : change < 0 ? 'decreasing' : 'stable'
      };
    };

    const trends = {};
    if (type === 'all') {
      trends.heartRate = calculateTrends(filteredHistory, 'heartRate');
      trends.bloodPressure = {
        systolic: calculateTrends(filteredHistory.map(h => ({
          vitals: { systolic: h.vitals.bloodPressure?.systolic }
        })), 'systolic'),
        diastolic: calculateTrends(filteredHistory.map(h => ({
          vitals: { diastolic: h.vitals.bloodPressure?.diastolic }
        })), 'diastolic')
      };
    } else {
      trends[type] = calculateTrends(filteredHistory, type);
    }

    res.json({
      status: 'success',
      data: {
        patientId,
        vitalsHistory: filteredHistory.map(record => ({
          id: record.id,
          timestamp: record.timestamp,
          vitals: type === 'all' ? record.vitals : { [type]: record.vitals[type] },
          source: record.source
        })),
        trends,
        summary: {
          totalRecords: filteredHistory.length,
          dateRange: {
            from: filteredHistory[filteredHistory.length - 1]?.timestamp,
            to: filteredHistory[0]?.timestamp
          }
        }
      }
    });

  } catch (error) {
    logger.error('Get vital signs history error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching vital signs history'
    });
  }
});

// @route   POST /api/v1/health/device/connect
// @desc    Connect wearable device to patient account
// @access  Private (Patient)
router.post('/device/connect', authenticatePatient, [
  body('deviceInfo.deviceId').notEmpty().withMessage('Device ID is required'),
  body('deviceInfo.deviceType').isIn(['smartwatch', 'fitness_tracker', 'heart_monitor', 'glucose_meter', 'blood_pressure_monitor']),
  body('deviceInfo.brand').notEmpty().withMessage('Device brand is required'),
  body('deviceInfo.model').notEmpty().withMessage('Device model is required')
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

    const { deviceInfo, syncSettings } = req.body;
    const patientId = req.user.id;

    // Create device connection record
    const deviceConnection = {
      id: new mongoose.Types.ObjectId(),
      patientId,
      device: {
        deviceId: deviceInfo.deviceId,
        type: deviceInfo.deviceType,
        brand: deviceInfo.brand,
        model: deviceInfo.model,
        firmwareVersion: deviceInfo.firmwareVersion
      },
      syncSettings: {
        autoSync: syncSettings?.autoSync !== false,
        syncInterval: syncSettings?.syncInterval || 15, // minutes
        dataTypes: syncSettings?.dataTypes || ['vitals', 'activity', 'sleep']
      },
      status: 'connected',
      connectedAt: new Date(),
      lastSyncAt: null
    };

    // In real app, would save to DeviceConnections collection
    logger.info(`Device connected for patient: ${patientId}`, {
      deviceType: deviceInfo.deviceType,
      deviceId: deviceInfo.deviceId
    });

    res.status(201).json({
      status: 'success',
      message: 'Device connected successfully',
      data: {
        connection: {
          id: deviceConnection.id,
          deviceId: deviceConnection.device.deviceId,
          deviceType: deviceConnection.device.type,
          status: deviceConnection.status,
          connectedAt: deviceConnection.connectedAt
        }
      }
    });

  } catch (error) {
    logger.error('Connect device error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error connecting device'
    });
  }
});

// @route   GET /api/v1/health/devices/:patientId
// @desc    Get connected devices for patient
// @access  Private (Patient, Doctor)
router.get('/devices/:patientId', authenticate, async (req, res) => {
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

    // In real app, would query DeviceConnections collection
    // Simulating connected devices
    const mockConnectedDevices = [
      {
        id: new mongoose.Types.ObjectId(),
        device: {
          deviceId: 'AW-2023-001',
          type: 'smartwatch',
          brand: 'Apple',
          model: 'Watch Series 9'
        },
        status: 'connected',
        connectedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        lastSyncAt: new Date(Date.now() - 15 * 60 * 1000),
        dataTypes: ['vitals', 'activity', 'sleep'],
        batteryLevel: 85
      },
      {
        id: new mongoose.Types.ObjectId(),
        device: {
          deviceId: 'BP-2023-002',
          type: 'blood_pressure_monitor',
          brand: 'Omron',
          model: 'Platinum'
        },
        status: 'connected',
        connectedAt: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
        lastSyncAt: new Date(Date.now() - 2 * 60 * 60 * 1000),
        dataTypes: ['vitals'],
        batteryLevel: 65
      }
    ];

    res.json({
      status: 'success',
      data: {
        devices: mockConnectedDevices,
        summary: {
          totalDevices: mockConnectedDevices.length,
          activeDevices: mockConnectedDevices.filter(d => d.status === 'connected').length
        }
      }
    });

  } catch (error) {
    logger.error('Get connected devices error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching connected devices'
    });
  }
});

// @route   POST /api/v1/health/alerts/acknowledge
// @desc    Acknowledge health alerts
// @access  Private (Patient, Doctor)
router.post('/alerts/acknowledge', authenticate, [
  body('alertIds').isArray().withMessage('Alert IDs must be an array'),
  body('alertIds.*').isMongoId().withMessage('Invalid alert ID format')
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

    const { alertIds } = req.body;

    // In real app, would update alert acknowledgment in database
    const acknowledgedAt = new Date();
    const acknowledgedBy = req.user.id;

    logger.info(`Health alerts acknowledged: ${alertIds.length} alerts`, {
      alertIds,
      acknowledgedBy: req.user.userType,
      acknowledgedAt
    });

    res.json({
      status: 'success',
      message: `${alertIds.length} alert(s) acknowledged successfully`,
      data: {
        acknowledgedCount: alertIds.length,
        acknowledgedAt,
        acknowledgedBy: req.user.userType
      }
    });

  } catch (error) {
    logger.error('Acknowledge alerts error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error acknowledging alerts'
    });
  }
});

// @route   GET /api/v1/health/monitoring-dashboard/:patientId
// @desc    Get comprehensive health monitoring dashboard
// @access  Private (Patient, Doctor)
router.get('/monitoring-dashboard/:patientId', authenticate, [
  query('period').optional().isIn(['24h', '7d', '30d', '90d'])
], async (req, res) => {
  try {
    const { patientId } = req.params;
    const period = req.query.period || '7d';

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

    // Calculate date range
    const now = new Date();
    let startDate;
    switch (period) {
      case '24h':
        startDate = new Date(now.getTime() - 24 * 60 * 60 * 1000);
        break;
      case '30d':
        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case '90d':
        startDate = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      default: // 7d
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    }

    // In real app, would aggregate data from multiple collections
    // Simulating comprehensive health dashboard
    const dashboard = {
      patient: {
        patientId,
        name: 'John Doe', // Would get from patient record
        age: 45
      },
      period: {
        type: period,
        startDate,
        endDate: now
      },
      currentVitals: {
        bloodPressure: { systolic: 125, diastolic: 85, timestamp: new Date() },
        heartRate: { value: 72, timestamp: new Date() },
        temperature: { value: 98.7, timestamp: new Date() },
        oxygenSaturation: { value: 98, timestamp: new Date() },
        weight: { value: 75.5, timestamp: new Date() }
      },
      alerts: [
        {
          id: new mongoose.Types.ObjectId(),
          type: 'warning',
          message: 'Blood pressure trending higher than normal',
          timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000),
          acknowledged: false
        }
      ],
      trends: {
        bloodPressure: {
          trend: 'increasing',
          change: '+5.2%',
          concern: 'moderate'
        },
        heartRate: {
          trend: 'stable',
          change: '-1.1%',
          concern: 'none'
        },
        weight: {
          trend: 'decreasing',
          change: '-2.3%',
          concern: 'none'
        }
      },
      deviceStatus: {
        connected: 2,
        lastSync: new Date(Date.now() - 15 * 60 * 1000),
        batteryLevels: { average: 75, lowest: 65 }
      },
      healthScore: 78, // Out of 100
      recommendations: [
        'Consider reducing sodium intake due to elevated blood pressure trend',
        'Maintain current exercise routine - heart rate patterns are excellent',
        'Schedule follow-up with cardiologist within 2 weeks'
      ]
    };

    res.json({
      status: 'success',
      data: {
        dashboard
      }
    });

  } catch (error) {
    logger.error('Get monitoring dashboard error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching monitoring dashboard'
    });
  }
});

module.exports = router;
