const express = require('express');
const { body, validationResult, query } = require('express-validator');
const Patient = require('../models/Patient');
const Doctor = require('../models/Doctor');
const Prescription = require('../models/Prescription');
const { authenticateDoctor, authenticatePatient, authenticate } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// @route   POST /api/v1/patients/sample
// @desc    Insert sample patient data
// @access  Public (for testing)
router.post('/sample', async (req, res) => {
  try {
    // Sample patient data
    const samplePatients = [
      {
        personalInfo: {
          firstName: 'Rajesh',
          lastName: 'Kumar',
          email: 'rajesh.kumar@example.com',
          phone: '+91 9876543210',
          aadhaarNumber: '123456789012',
          dateOfBirth: new Date('1985-03-15'),
          gender: 'male',
          bloodGroup: 'B+',
          maritalStatus: 'married'
        },
        address: {
          current: {
            street: '123 MG Road',
            city: 'Kochi',
            state: 'Kerala',
            pincode: '682001',
            coordinates: {
              latitude: 9.9312,
              longitude: 76.2673
            }
          },
          permanent: {
            street: '456 Village Road',
            city: 'Thrissur',
            state: 'Kerala',
            pincode: '680001'
          }
        },
        credentials: {
          password: 'password123'
        },
        medicalHistory: {
          allergies: [
            {
              allergen: 'Penicillin',
              severity: 'severe',
              description: 'Causes severe rash and breathing difficulty'
            }
          ],
          chronicConditions: [
            {
              condition: 'Hypertension',
              diagnosedDate: new Date('2020-01-15'),
              status: 'controlled'
            }
          ],
          vaccinations: [
            {
              vaccine: 'COVID-19 (Covishield)',
              date: new Date('2021-06-15'),
              batch: 'COV001'
            }
          ]
        },
        currentHealth: {
          vitals: {
            height: 175,
            weight: 78,
            bloodPressure: {
              systolic: 130,
              diastolic: 85
            },
            heartRate: 72,
            temperature: 98.6
          }
        },
        emergencyContacts: [
          {
            name: 'Priya Kumar',
            relationship: 'Wife',
            phone: '+91 9876543211',
            email: 'priya.kumar@example.com',
            isPrimary: true
          }
        ],
        employment: {
          employer: 'Tech Solutions Pvt Ltd',
          occupation: 'Software Engineer',
          workLocation: {
            city: 'Kochi',
            state: 'Kerala'
          },
          employmentType: 'permanent'
        },
        insurance: {
          provider: 'National Insurance',
          policyNumber: 'NI123456789',
          validUntil: new Date('2024-12-31'),
          coverageAmount: 500000,
          ayushmanBharat: {
            isEnrolled: true,
            cardNumber: 'AB1234567890'
          }
        }
      },
      {
        personalInfo: {
          firstName: 'Meera',
          lastName: 'Nair',
          email: 'meera.nair@example.com',
          phone: '+91 9876543220',
          aadhaarNumber: '123456789013',
          dateOfBirth: new Date('1992-08-22'),
          gender: 'female',
          bloodGroup: 'A+',
          maritalStatus: 'single'
        },
        address: {
          current: {
            street: '789 Beach Road',
            city: 'Thiruvananthapuram',
            state: 'Kerala',
            pincode: '695001',
            coordinates: {
              latitude: 8.5241,
              longitude: 76.9366
            }
          }
        },
        credentials: {
          password: 'password123'
        },
        medicalHistory: {
          allergies: [
            {
              allergen: 'Shellfish',
              severity: 'moderate',
              description: 'Causes hives and nausea'
            }
          ],
          vaccinations: [
            {
              vaccine: 'COVID-19 (Covaxin)',
              date: new Date('2021-07-20'),
              batch: 'COV002'
            }
          ]
        },
        currentHealth: {
          vitals: {
            height: 162,
            weight: 58,
            bloodPressure: {
              systolic: 120,
              diastolic: 80
            },
            heartRate: 68,
            temperature: 98.4
          }
        },
        emergencyContacts: [
          {
            name: 'Sunitha Nair',
            relationship: 'Mother',
            phone: '+91 9876543221',
            isPrimary: true
          }
        ],
        employment: {
          employer: 'Design Studio',
          occupation: 'Graphic Designer',
          workLocation: {
            city: 'Thiruvananthapuram',
            state: 'Kerala'
          },
          employmentType: 'contract'
        }
      },
      {
        personalInfo: {
          firstName: 'Arun',
          lastName: 'Pillai',
          email: 'arun.pillai@example.com',
          phone: '+91 9876543230',
          aadhaarNumber: '123456789014',
          dateOfBirth: new Date('1978-12-10'),
          gender: 'male',
          bloodGroup: 'O-',
          maritalStatus: 'married'
        },
        address: {
          current: {
            street: '321 Hill View',
            city: 'Munnar',
            state: 'Kerala',
            pincode: '685612'
          }
        },
        credentials: {
          password: 'password123'
        },
        medicalHistory: {
          chronicConditions: [
            {
              condition: 'Diabetes Type 2',
              diagnosedDate: new Date('2018-05-20'),
              status: 'controlled'
            }
          ],
          surgicalHistory: [
            {
              surgery: 'Appendectomy',
              date: new Date('2015-03-10'),
              hospital: 'Medical Trust Hospital',
              surgeon: 'Dr. Pradeep Kumar'
            }
          ]
        },
        currentHealth: {
          vitals: {
            height: 170,
            weight: 82,
            bloodPressure: {
              systolic: 140,
              diastolic: 90
            },
            heartRate: 76,
            temperature: 98.8
          },
          currentMedications: [
            {
              medication: 'Metformin',
              dosage: '500mg',
              frequency: 'Twice daily',
              startDate: new Date('2018-05-20')
            }
          ]
        },
        emergencyContacts: [
          {
            name: 'Latha Pillai',
            relationship: 'Wife',
            phone: '+91 9876543231',
            isPrimary: true
          }
        ],
        employment: {
          employer: 'Tea Estate',
          occupation: 'Estate Manager',
          workLocation: {
            city: 'Munnar',
            state: 'Kerala'
          },
          employmentType: 'permanent'
        }
      }
    ];

    // Insert sample patients
    const insertedPatients = [];
    
    for (const patientData of samplePatients) {
      try {
        // Check if patient already exists
        const existingPatient = await Patient.findOne({
          'personalInfo.aadhaarNumber': patientData.personalInfo.aadhaarNumber
        });
        
        if (!existingPatient) {
          const patient = new Patient(patientData);
          await patient.save();
          insertedPatients.push({
            patientId: patient.patientId,
            uhi: patient.uhi,
            name: patient.fullName,
            email: patient.personalInfo.email
          });
          
          logger.info(`Sample patient created: ${patient.fullName}`, { patientId: patient.patientId });
        } else {
          logger.info(`Sample patient already exists: ${existingPatient.fullName}`);
        }
      } catch (error) {
        logger.error(`Error creating sample patient: ${patientData.personalInfo.firstName}`, error);
      }
    }

    res.status(201).json({
      status: 'success',
      message: 'Sample patients inserted successfully',
      data: {
        insertedCount: insertedPatients.length,
        patients: insertedPatients
      }
    });

  } catch (error) {
    logger.error('Sample patient insertion error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error inserting sample patients'
    });
  }
});

// @route   GET /api/v1/patients
// @desc    Get all patients (for doctors/hospitals)
// @access  Private (Doctor)
router.get('/', authenticateDoctor, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('search').optional().trim()
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
    const search = req.query.search;

    let query = {};

    // Add search functionality
    if (search) {
      query = {
        $or: [
          { 'personalInfo.firstName': { $regex: search, $options: 'i' } },
          { 'personalInfo.lastName': { $regex: search, $options: 'i' } },
          { patientId: { $regex: search, $options: 'i' } },
          { uhi: { $regex: search, $options: 'i' } },
          { 'personalInfo.phone': { $regex: search, $options: 'i' } }
        ]
      };
    }

    const patients = await Patient.find(query)
      .select('-credentials.password -__v')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Patient.countDocuments(query);

    res.json({
      status: 'success',
      data: {
        patients,
        pagination: {
          page,
          limit,
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });

  } catch (error) {
    logger.error('Get patients error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching patients'
    });
  }
});

// @route   GET /api/v1/patients/:id
// @desc    Get patient by ID
// @access  Private (Doctor/Patient)
router.get('/:id', authenticate, async (req, res) => {
  try {
    const patientId = req.params.id;
    
    let query;
    if (patientId.length === 24) {
      // MongoDB ObjectId
      query = { _id: patientId };
    } else {
      // Patient ID or UHI
      query = {
        $or: [
          { patientId: patientId },
          { uhi: patientId.toUpperCase() }
        ]
      };
    }

    const patient = await Patient.findOne(query)
      .select('-credentials.password -__v')
      .populate('healthRecords.doctor', 'doctorId personalInfo.firstName personalInfo.lastName')
      .populate('healthRecords.hospital', 'hospitalId name');

    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // Check authorization
    if (req.user.role === 'patient' && req.user.id !== patient._id.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. You can only view your own profile.'
      });
    }

    res.json({
      status: 'success',
      data: {
        patient
      }
    });

  } catch (error) {
    logger.error('Get patient error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching patient'
    });
  }
});

// @route   POST /api/v1/patients
// @desc    Create new patient (by doctor)
// @access  Private (Doctor)
router.post('/', authenticateDoctor, [
  body('firstName').trim().notEmpty().withMessage('First name is required'),
  body('lastName').trim().notEmpty().withMessage('Last name is required'),
  body('phone').trim().notEmpty().withMessage('Phone number is required'),
  body('aadhaarNumber').isLength({ min: 12, max: 12 }).withMessage('Aadhaar number must be 12 digits'),
  body('dateOfBirth').isISO8601().withMessage('Valid date of birth is required'),
  body('gender').isIn(['male', 'female', 'other']).withMessage('Valid gender is required')
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
      aadhaarNumber,
      dateOfBirth,
      gender,
      bloodGroup,
      address,
      emergencyContacts,
      medicalHistory
    } = req.body;

    // Check if patient already exists
    const existingPatient = await Patient.findOne({
      $or: [
        { 'personalInfo.aadhaarNumber': aadhaarNumber },
        { 'personalInfo.phone': phone }
      ]
    });

    if (existingPatient) {
      return res.status(400).json({
        status: 'error',
        message: 'Patient with this Aadhaar number or phone already exists'
      });
    }

    // Generate temporary password
    const tempPassword = Math.random().toString(36).slice(-8);

    // Create new patient
    const patient = new Patient({
      personalInfo: {
        firstName,
        lastName,
        email,
        phone,
        aadhaarNumber,
        dateOfBirth,
        gender,
        bloodGroup
      },
      address: address || {},
      credentials: {
        password: tempPassword,
        isVerified: false
      },
      emergencyContacts: emergencyContacts || [],
      medicalHistory: medicalHistory || {}
    });

    await patient.save();

    // Add patient to doctor's patient list
    await Doctor.findByIdAndUpdate(req.user.id, {
      $push: {
        patients: {
          patient: patient._id,
          firstConsultation: new Date(),
          status: 'active'
        }
      },
      $inc: { 'statistics.totalPatients': 1 }
    });

    logger.info(`New patient created by doctor: ${patient.fullName}`, { 
      patientId: patient.patientId,
      doctorId: req.doctor.doctorId 
    });

    res.status(201).json({
      status: 'success',
      message: 'Patient created successfully',
      data: {
        patient: {
          id: patient._id,
          patientId: patient.patientId,
          uhi: patient.uhi,
          name: patient.fullName,
          email: patient.personalInfo.email,
          phone: patient.personalInfo.phone,
          tempPassword: tempPassword
        }
      }
    });

  } catch (error) {
    logger.error('Create patient error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating patient'
    });
  }
});

// @route   PUT /api/v1/patients/:id
// @desc    Update patient profile
// @access  Private (Patient/Doctor)
router.put('/:id', authenticate, async (req, res) => {
  try {
    const patientId = req.params.id;
    
    let query;
    if (patientId.length === 24) {
      query = { _id: patientId };
    } else {
      query = {
        $or: [
          { patientId: patientId },
          { uhi: patientId.toUpperCase() }
        ]
      };
    }

    const patient = await Patient.findOne(query);

    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // Check authorization
    if (req.user.role === 'patient' && req.user.id !== patient._id.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. You can only update your own profile.'
      });
    }

    // Update allowed fields
    const allowedUpdates = [
      'personalInfo.email',
      'personalInfo.phone',
      'address',
      'emergencyContacts',
      'currentHealth.vitals',
      'insurance'
    ];

    const updates = {};
    Object.keys(req.body).forEach(key => {
      if (allowedUpdates.some(field => field.startsWith(key))) {
        updates[key] = req.body[key];
      }
    });

    const updatedPatient = await Patient.findOneAndUpdate(
      query,
      { $set: updates },
      { new: true, runValidators: true }
    ).select('-credentials.password -__v');

    logger.info(`Patient profile updated: ${updatedPatient.fullName}`, { 
      patientId: updatedPatient.patientId 
    });

    res.json({
      status: 'success',
      message: 'Patient profile updated successfully',
      data: {
        patient: updatedPatient
      }
    });

  } catch (error) {
    logger.error('Update patient error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating patient'
    });
  }
});

// @route   GET /api/v1/patients/:id/prescriptions
// @desc    Get patient's prescriptions
// @access  Private (Patient/Doctor)
router.get('/:id/prescriptions', authenticate, async (req, res) => {
  try {
    const patientId = req.params.id;
    
    let patient;
    if (patientId.length === 24) {
      patient = await Patient.findById(patientId);
    } else {
      patient = await Patient.findOne({
        $or: [
          { patientId: patientId },
          { uhi: patientId.toUpperCase() }
        ]
      });
    }

    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // Check authorization
    if (req.user.role === 'patient' && req.user.id !== patient._id.toString()) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const prescriptions = await Prescription.find({ patient: patient._id })
      .populate('doctor', 'doctorId personalInfo.firstName personalInfo.lastName professionalInfo.specialization')
      .populate('hospital', 'hospitalId name')
      .sort({ createdAt: -1 });

    res.json({
      status: 'success',
      data: {
        prescriptions,
        total: prescriptions.length
      }
    });

  } catch (error) {
    logger.error('Get patient prescriptions error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching prescriptions'
    });
  }
});

// @route   POST /api/v1/patients/create-sample
// @desc    Create sample patients for testing
// @access  Public (for testing purposes)
router.post('/create-sample', async (req, res) => {
  try {
    // Sample patients data for frontend testing
    const samplePatientsData = [
      {
        patientId: `PAT${Date.now()}1`,
        uhi: `UHI${Date.now()}1`,
        personalInfo: {
          firstName: "Test",
          lastName: "Patient",
          email: `test.patient.${Date.now()}@example.com`,
          phone: "+91-98765-00001",
          aadhaarNumber: `${Date.now()}001`.substring(0, 12),
          dateOfBirth: new Date("1995-01-01"),
          gender: "male",
          bloodGroup: "B+",
          address: {
            street: "Test Street",
            city: "Test City",
            state: "Test State",
            pincode: "123456"
          }
        },
        credentials: {
          username: `test_patient_${Date.now()}`,
          password: "test123"
        },
        emergencyContact: {
          name: "Test Emergency",
          relationship: "friend",
          phone: "+91-98765-00002"
        },
        medicalHistory: {
          allergies: [],
          chronicConditions: [],
          surgicalHistory: [],
          familyHistory: [],
          vaccinations: []
        },
        insurance: {
          provider: "Test Insurance",
          policyNumber: `TEST${Date.now()}`,
          coverage: 100000,
          validUntil: new Date("2025-12-31"),
          isActive: true
        },
        vitalSigns: {
          height: 175,
          weight: 70,
          bmi: 22.9,
          bloodPressure: { systolic: 120, diastolic: 80 },
          heartRate: 72,
          temperature: 98.6,
          lastUpdated: new Date()
        }
      }
    ];

    const patients = await Patient.insertMany(samplePatientsData);
    
    logger.info(`Sample patients created for testing`, { count: patients.length });

    res.status(201).json({
      status: 'success',
      message: 'Sample patients created successfully',
      data: {
        patients: patients.map(patient => ({
          id: patient._id,
          patientId: patient.patientId,
          uhi: patient.uhi,
          name: patient.fullName,
          email: patient.personalInfo.email,
          phone: patient.personalInfo.phone,
          username: patient.credentials.username,
          password: "test123", // Only for testing
          createdAt: patient.createdAt
        }))
      }
    });

  } catch (error) {
    logger.error('Create sample patients error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error creating sample patients'
    });
  }
});

module.exports = router;
