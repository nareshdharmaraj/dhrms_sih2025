const express = require('express');
const { body, query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const Hospital = require('../models/Hospital');
const { authenticate, authenticateHospital } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// Emergency Case Schema (embedded within medical records)
const emergencyCaseSchema = {
  emergencyId: String,
  severity: { type: String, enum: ['critical', 'high', 'medium', 'low'] },
  category: { type: String, enum: ['trauma', 'cardiac', 'respiratory', 'neurological', 'poisoning', 'burn', 'other'] },
  triageInfo: {
    triageLevel: { type: Number, min: 1, max: 5 }, // 1 = immediate, 5 = non-urgent
    vitalSigns: {
      consciousness: String,
      breathing: String,
      circulation: String,
      painLevel: { type: Number, min: 0, max: 10 }
    },
    triageNurse: String,
    triageTime: Date
  },
  location: {
    type: String,
    coordinates: [Number], // [longitude, latitude]
    address: String
  },
  response: {
    ambulanceDispatched: Boolean,
    dispatchTime: Date,
    estimatedArrival: Date,
    actualArrival: Date,
    responseTeam: [String]
  },
  treatment: {
    initialAssessment: String,
    emergencyProcedures: [String],
    medicationsAdministered: [{
      medication: String,
      dosage: String,
      time: Date
    }],
    stabilizationTime: Date
  },
  outcome: {
    disposition: { type: String, enum: ['admitted', 'discharged', 'transferred', 'deceased'] },
    dischargeTime: Date,
    followUpRequired: Boolean,
    followUpInstructions: String
  },
  timeline: [{
    timestamp: Date,
    event: String,
    staff: String
  }]
};

// @route   POST /api/v1/emergency/alert
// @desc    Create emergency alert/case
// @access  Public (for emergency situations)
router.post('/alert', [
  body('patientInfo.name').notEmpty().withMessage('Patient name is required'),
  body('patientInfo.age').optional().isInt({ min: 0, max: 150 }),
  body('patientInfo.gender').optional().isIn(['male', 'female', 'other']),
  body('patientInfo.phone').optional().isMobilePhone(),
  body('emergency.severity').isIn(['critical', 'high', 'medium', 'low']),
  body('emergency.category').isIn(['trauma', 'cardiac', 'respiratory', 'neurological', 'poisoning', 'burn', 'other']),
  body('emergency.description').notEmpty().withMessage('Emergency description is required'),
  body('location.address').notEmpty().withMessage('Location address is required'),
  body('location.coordinates').optional().isArray().withMessage('Coordinates must be an array [lng, lat]'),
  body('reportedBy.name').notEmpty().withMessage('Reporter name is required'),
  body('reportedBy.phone').notEmpty().isMobilePhone().withMessage('Reporter phone is required'),
  body('reportedBy.relationship').optional().isString()
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

    const { patientInfo, emergency, location, reportedBy } = req.body;

    // Generate unique emergency ID
    const emergencyId = `EMG${Date.now()}${Math.random().toString(36).substr(2, 4).toUpperCase()}`;

    // Find nearest hospitals based on location
    let nearbyHospitals = [];
    if (location.coordinates && location.coordinates.length === 2) {
      // In a real app, you'd use geospatial queries
      nearbyHospitals = await Hospital.find({
        'contactInfo.address.coordinates': {
          $near: {
            $geometry: {
              type: 'Point',
              coordinates: location.coordinates
            },
            $maxDistance: 50000 // 50km radius
          }
        }
      }).limit(5);
    } else {
      // Fallback to all hospitals if no coordinates
      nearbyHospitals = await Hospital.find({}).limit(5);
    }

    // Determine triage level based on severity and category
    const getTriageLevel = (severity, category) => {
      if (severity === 'critical' || ['trauma', 'cardiac'].includes(category)) return 1;
      if (severity === 'high' || ['respiratory', 'neurological'].includes(category)) return 2;
      if (severity === 'medium') return 3;
      return 4;
    };

    // Create emergency case data
    const emergencyCase = {
      emergencyId,
      severity: emergency.severity,
      category: emergency.category,
      description: emergency.description,
      triageInfo: {
        triageLevel: getTriageLevel(emergency.severity, emergency.category),
        vitalSigns: emergency.vitalSigns || {},
        triageTime: new Date()
      },
      location: {
        type: 'Point',
        coordinates: location.coordinates || [0, 0],
        address: location.address
      },
      response: {
        ambulanceDispatched: false,
        dispatchTime: null,
        estimatedArrival: null,
        responseTeam: []
      },
      timeline: [{
        timestamp: new Date(),
        event: 'Emergency alert created',
        staff: 'System'
      }],
      patientInfo: {
        name: patientInfo.name,
        age: patientInfo.age,
        gender: patientInfo.gender,
        phone: patientInfo.phone,
        knownConditions: patientInfo.knownConditions || []
      },
      reportedBy,
      nearbyHospitals: nearbyHospitals.map(h => ({
        hospitalId: h._id,
        name: h.hospitalName,
        distance: Math.random() * 20 + 1, // Simulated distance in km
        emergencyCapacity: h.hospitalInfo?.emergencyCapacity || 'available',
        specialties: h.hospitalInfo?.specialties || []
      })),
      status: 'active',
      createdAt: new Date()
    };

    // In a real application, this would be stored in a dedicated Emergency collection
    // For now, we'll return the emergency case details and simulate alert dispatch
    
    // Simulate ambulance dispatch for critical cases
    if (emergency.severity === 'critical' || emergencyCase.triageInfo.triageLevel <= 2) {
      emergencyCase.response.ambulanceDispatched = true;
      emergencyCase.response.dispatchTime = new Date();
      emergencyCase.response.estimatedArrival = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
      emergencyCase.timeline.push({
        timestamp: new Date(),
        event: 'Ambulance dispatched',
        staff: 'Emergency Dispatch'
      });
    }

    // Log emergency alert
    logger.info(`Emergency alert created: ${emergencyId}`, {
      severity: emergency.severity,
      location: location.address,
      triageLevel: emergencyCase.triageInfo.triageLevel
    });

    res.status(201).json({
      status: 'success',
      message: 'Emergency alert created successfully',
      data: {
        emergencyCase: {
          emergencyId,
          severity: emergencyCase.severity,
          triageLevel: emergencyCase.triageInfo.triageLevel,
          ambulanceDispatched: emergencyCase.response.ambulanceDispatched,
          estimatedArrival: emergencyCase.response.estimatedArrival,
          nearbyHospitals: emergencyCase.nearbyHospitals.slice(0, 3) // Top 3 nearest
        }
      }
    });

  } catch (error) {
    logger.error('Create emergency alert error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating emergency alert'
    });
  }
});

// @route   GET /api/v1/emergency/cases
// @desc    Get emergency cases (for hospital staff)
// @access  Private (Hospital)
router.get('/cases', authenticateHospital, [
  query('status').optional().isIn(['active', 'resolved', 'transferred']),
  query('severity').optional().isIn(['critical', 'high', 'medium', 'low']),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('offset').optional().isInt({ min: 0 })
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

    const { status, severity, limit = 20, offset = 0 } = req.query;

    // Build query filters
    let filters = {
      // In real app, would filter by hospital proximity or assignment
      createdAt: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) } // Last 24 hours
    };

    if (status) filters.status = status;
    if (severity) filters.severity = severity;

    // Simulate emergency cases data (in real app would query Emergency collection)
    const mockEmergencyCases = [
      {
        emergencyId: 'EMG' + Date.now() + 'A1B2',
        patientInfo: { name: 'John Doe', age: 45, gender: 'male' },
        severity: 'critical',
        category: 'cardiac',
        triageInfo: { triageLevel: 1, triageTime: new Date(Date.now() - 2 * 60 * 60 * 1000) },
        location: { address: '123 Main St, Emergency Location' },
        response: { 
          ambulanceDispatched: true, 
          estimatedArrival: new Date(Date.now() + 10 * 60 * 1000)
        },
        status: 'active',
        createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000)
      },
      {
        emergencyId: 'EMG' + (Date.now() - 1000) + 'C3D4',
        patientInfo: { name: 'Jane Smith', age: 32, gender: 'female' },
        severity: 'high',
        category: 'trauma',
        triageInfo: { triageLevel: 2, triageTime: new Date(Date.now() - 1 * 60 * 60 * 1000) },
        location: { address: '456 Oak Ave, Accident Site' },
        response: { 
          ambulanceDispatched: true, 
          estimatedArrival: new Date(Date.now() + 5 * 60 * 1000)
        },
        status: 'active',
        createdAt: new Date(Date.now() - 1 * 60 * 60 * 1000)
      }
    ];

    // Filter cases based on query parameters
    let filteredCases = mockEmergencyCases;
    if (status) {
      filteredCases = filteredCases.filter(c => c.status === status);
    }
    if (severity) {
      filteredCases = filteredCases.filter(c => c.severity === severity);
    }

    // Apply pagination
    const paginatedCases = filteredCases.slice(offset, offset + parseInt(limit));

    res.json({
      status: 'success',
      data: {
        cases: paginatedCases.map(case_ => ({
          emergencyId: case_.emergencyId,
          patientInfo: case_.patientInfo,
          severity: case_.severity,
          category: case_.category,
          triageLevel: case_.triageInfo.triageLevel,
          location: case_.location.address,
          ambulanceDispatched: case_.response.ambulanceDispatched,
          estimatedArrival: case_.response.estimatedArrival,
          status: case_.status,
          timeElapsed: Math.floor((Date.now() - case_.createdAt.getTime()) / (1000 * 60)), // minutes
          createdAt: case_.createdAt
        })),
        pagination: {
          total: filteredCases.length,
          limit: parseInt(limit),
          offset: parseInt(offset),
          hasMore: offset + parseInt(limit) < filteredCases.length
        }
      }
    });

  } catch (error) {
    logger.error('Get emergency cases error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching emergency cases'
    });
  }
});

// @route   GET /api/v1/emergency/case/:emergencyId
// @desc    Get detailed emergency case information
// @access  Private (Hospital, Doctor)
router.get('/case/:emergencyId', authenticate, async (req, res) => {
  try {
    const { emergencyId } = req.params;

    // In real app, would query Emergency collection
    // For now, simulate detailed emergency case data
    const mockDetailedCase = {
      emergencyId,
      patientInfo: {
        name: 'John Doe',
        age: 45,
        gender: 'male',
        phone: '+1234567890',
        knownConditions: ['Hypertension', 'Diabetes Type 2'],
        bloodType: 'O+',
        allergies: ['Penicillin']
      },
      emergency: {
        severity: 'critical',
        category: 'cardiac',
        description: 'Chest pain, shortness of breath, suspected heart attack'
      },
      triageInfo: {
        triageLevel: 1,
        vitalSigns: {
          consciousness: 'Alert',
          breathing: 'Labored',
          circulation: 'Weak pulse',
          painLevel: 8,
          bloodPressure: '180/110',
          heartRate: 110,
          temperature: 98.6
        },
        triageNurse: 'Nurse Williams',
        triageTime: new Date(Date.now() - 2 * 60 * 60 * 1000)
      },
      location: {
        address: '123 Main St, Downtown',
        coordinates: [-74.005974, 40.714353]
      },
      response: {
        ambulanceDispatched: true,
        dispatchTime: new Date(Date.now() - 105 * 60 * 1000),
        estimatedArrival: new Date(Date.now() + 10 * 60 * 1000),
        actualArrival: null,
        responseTeam: ['Paramedic Johnson', 'EMT Davis']
      },
      treatment: {
        initialAssessment: 'STEMI suspected, chest pain 8/10, diaphoretic',
        emergencyProcedures: ['IV access', 'Oxygen therapy', 'ECG monitoring'],
        medicationsAdministered: [
          {
            medication: 'Aspirin',
            dosage: '325mg',
            time: new Date(Date.now() - 90 * 60 * 1000)
          },
          {
            medication: 'Nitroglycerin',
            dosage: '0.4mg SL',
            time: new Date(Date.now() - 85 * 60 * 1000)
          }
        ]
      },
      timeline: [
        {
          timestamp: new Date(Date.now() - 120 * 60 * 1000),
          event: 'Emergency call received',
          staff: 'Dispatch Operator'
        },
        {
          timestamp: new Date(Date.now() - 105 * 60 * 1000),
          event: 'Ambulance dispatched',
          staff: 'Emergency Dispatch'
        },
        {
          timestamp: new Date(Date.now() - 90 * 60 * 1000),
          event: 'First responders on scene',
          staff: 'Paramedic Johnson'
        },
        {
          timestamp: new Date(Date.now() - 85 * 60 * 1000),
          event: 'Patient stabilized, en route to hospital',
          staff: 'Paramedic Johnson'
        }
      ],
      reportedBy: {
        name: 'Sarah Doe',
        phone: '+1234567891',
        relationship: 'Spouse'
      },
      status: 'active',
      createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000)
    };

    res.json({
      status: 'success',
      data: {
        emergencyCase: mockDetailedCase
      }
    });

  } catch (error) {
    logger.error('Get emergency case details error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching emergency case details'
    });
  }
});

// @route   PUT /api/v1/emergency/case/:emergencyId/update
// @desc    Update emergency case status/information
// @access  Private (Hospital, Doctor)
router.put('/case/:emergencyId/update', authenticate, [
  body('update.type').isIn(['status', 'treatment', 'timeline', 'outcome']),
  body('update.data').notEmpty().withMessage('Update data is required')
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

    const { emergencyId } = req.params;
    const { update } = req.body;

    // In real app, would update Emergency collection
    // For now, simulate the update response

    const updateTypes = {
      'status': 'Emergency status updated',
      'treatment': 'Treatment information updated',
      'timeline': 'Timeline event added',
      'outcome': 'Patient outcome recorded'
    };

    const updatedTimestamp = new Date();
    const staffName = req.user.userType === 'doctor' ? 'Dr. ' + (req.user.name || 'Unknown') : 'Hospital Staff';

    logger.info(`Emergency case updated: ${emergencyId}`, {
      updateType: update.type,
      staff: staffName,
      timestamp: updatedTimestamp
    });

    res.json({
      status: 'success',
      message: updateTypes[update.type] || 'Emergency case updated',
      data: {
        emergencyId,
        updateType: update.type,
        timestamp: updatedTimestamp,
        updatedBy: staffName
      }
    });

  } catch (error) {
    logger.error('Update emergency case error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating emergency case'
    });
  }
});

// @route   POST /api/v1/emergency/dispatch-ambulance
// @desc    Dispatch ambulance for emergency
// @access  Private (Hospital)
router.post('/dispatch-ambulance', authenticateHospital, [
  body('emergencyId').notEmpty().withMessage('Emergency ID is required'),
  body('ambulanceInfo.vehicleId').notEmpty().withMessage('Vehicle ID is required'),
  body('ambulanceInfo.crew').isArray().withMessage('Crew must be an array'),
  body('dispatchDetails.priority').isIn(['immediate', 'urgent', 'standard']),
  body('dispatchDetails.estimatedArrival').optional().isISO8601()
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

    const { emergencyId, ambulanceInfo, dispatchDetails } = req.body;

    // In real app, would update Emergency collection and dispatch system
    const dispatchData = {
      emergencyId,
      ambulance: {
        vehicleId: ambulanceInfo.vehicleId,
        crew: ambulanceInfo.crew,
        equipment: ambulanceInfo.equipment || [],
        currentLocation: ambulanceInfo.currentLocation
      },
      dispatch: {
        priority: dispatchDetails.priority,
        dispatchTime: new Date(),
        estimatedArrival: dispatchDetails.estimatedArrival ? 
          new Date(dispatchDetails.estimatedArrival) : 
          new Date(Date.now() + 15 * 60 * 1000), // Default 15 minutes
        dispatchedBy: req.user.id,
        instructions: dispatchDetails.instructions
      }
    };

    logger.info(`Ambulance dispatched for emergency: ${emergencyId}`, {
      vehicleId: ambulanceInfo.vehicleId,
      priority: dispatchDetails.priority,
      estimatedArrival: dispatchData.dispatch.estimatedArrival
    });

    res.json({
      status: 'success',
      message: 'Ambulance dispatched successfully',
      data: {
        dispatch: dispatchData
      }
    });

  } catch (error) {
    logger.error('Dispatch ambulance error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error dispatching ambulance'
    });
  }
});

// @route   GET /api/v1/emergency/statistics
// @desc    Get emergency services statistics
// @access  Private (Hospital)
router.get('/statistics', authenticateHospital, [
  query('period').optional().isIn(['today', 'week', 'month', 'year'])
], async (req, res) => {
  try {
    const period = req.query.period || 'today';

    // Calculate date range
    const now = new Date();
    let startDate;
    
    switch (period) {
      case 'today':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        break;
      case 'week':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        startDate = new Date(now.getFullYear(), now.getMonth() - 1, now.getDate());
        break;
      case 'year':
        startDate = new Date(now.getFullYear() - 1, now.getMonth(), now.getDate());
        break;
    }

    // In real app, would query Emergency collection for actual statistics
    // Simulating emergency statistics
    const statistics = {
      period: {
        type: period,
        startDate,
        endDate: now
      },
      emergencies: {
        total: 45,
        active: 8,
        resolved: 35,
        transferred: 2,
        bySeverity: {
          critical: 12,
          high: 18,
          medium: 10,
          low: 5
        },
        byCategory: {
          cardiac: 15,
          trauma: 12,
          respiratory: 8,
          neurological: 5,
          poisoning: 2,
          burn: 1,
          other: 2
        }
      },
      responseMetrics: {
        averageResponseTime: 8.5, // minutes
        ambulanceDispatchRate: 85, // percentage
        patientSatisfactionScore: 4.2,
        mortalityRate: 2.3 // percentage
      },
      resources: {
        ambulancesAvailable: 12,
        ambulancesInUse: 4,
        emergencyBedsAvailable: 8,
        emergencyBedsOccupied: 15,
        staffOnDuty: {
          doctors: 6,
          nurses: 18,
          paramedics: 12
        }
      }
    };

    res.json({
      status: 'success',
      data: {
        statistics
      }
    });

  } catch (error) {
    logger.error('Get emergency statistics error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching emergency statistics'
    });
  }
});

module.exports = router;
