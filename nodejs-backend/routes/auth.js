const express = require('express');
const { body, validationResult } = require('express-validator');
const Hospital = require('../models/Hospital');
const Doctor = require('../models/Doctor');
const Patient = require('../models/Patient');
const { generateAuthResponse } = require('../utils/auth');
const { authenticate } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// Validation middleware
const validateRegistration = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long')
];

const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty().withMessage('Password is required')
];

// @route   POST /api/v1/auth/hospital/register
// @desc    Register a new hospital
// @access  Public
router.post('/hospital/register', [
  ...validateRegistration,
  body('name').trim().notEmpty().withMessage('Hospital name is required'),
  body('registrationNumber').trim().notEmpty().withMessage('Registration number is required'),
  body('phone').trim().notEmpty().withMessage('Phone number is required'),
  body('username').trim().notEmpty().withMessage('Username is required')
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
      name,
      type,
      registrationNumber,
      address,
      phone,
      email,
      website,
      username,
      password
    } = req.body;

    // Check if hospital already exists
    const existingHospital = await Hospital.findOne({
      $or: [
        { 'contactInfo.email': email },
        { 'credentials.username': username },
        { registrationNumber }
      ]
    });

    if (existingHospital) {
      return res.status(400).json({
        status: 'error',
        message: 'Hospital with this email, username, or registration number already exists'
      });
    }

    // Create new hospital
    const hospital = new Hospital({
      name,
      type: type || 'private',
      registrationNumber,
      address,
      contactInfo: {
        phone,
        email,
        website
      },
      credentials: {
        username,
        password
      }
    });

    await hospital.save();

    const authResponse = generateAuthResponse(hospital, 'hospital');

    logger.info(`New hospital registered: ${hospital.name}`, { hospitalId: hospital.hospitalId });

    res.status(201).json({
      status: 'success',
      message: 'Hospital registered successfully',
      data: authResponse
    });

  } catch (error) {
    logger.error('Hospital registration error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during registration'
    });
  }
});

// @route   POST /api/v1/auth/hospital/login
// @desc    Login hospital
// @access  Public
router.post('/hospital/login', [
  body('username').trim().notEmpty().withMessage('Username is required'),
  body('password').notEmpty().withMessage('Password is required')
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

    const { username, password } = req.body;

    // Find hospital by username
    const hospital = await Hospital.findOne({ 'credentials.username': username });

    if (!hospital) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Check if hospital is active
    if (!hospital.credentials.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Hospital account is deactivated'
      });
    }

    // Verify password
    const isPasswordValid = await hospital.comparePassword(password);

    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Update last login
    hospital.credentials.lastLogin = new Date();
    await hospital.save();

    const authResponse = generateAuthResponse(hospital, 'hospital');

    logger.info(`Hospital login: ${hospital.name}`, { hospitalId: hospital.hospitalId });

    res.json({
      status: 'success',
      message: 'Login successful',
      data: authResponse
    });

  } catch (error) {
    logger.error('Hospital login error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during login'
    });
  }
});

// @route   POST /api/v1/auth/doctor/login
// @desc    Login doctor
// @access  Public
router.post('/doctor/login', [
  body('username').trim().notEmpty().withMessage('Username is required'),
  body('password').notEmpty().withMessage('Password is required')
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

    const { username, password } = req.body;

    // Find doctor by username
    const doctor = await Doctor.findOne({ 'credentials.username': username }).populate('hospital');

    if (!doctor) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Check if doctor is active and verified
    if (!doctor.credentials.isActive || !doctor.credentials.isVerified) {
      return res.status(401).json({
        status: 'error',
        message: 'Doctor account is inactive or not verified'
      });
    }

    // Verify password
    const isPasswordValid = await doctor.comparePassword(password);

    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Update last login
    doctor.credentials.lastLogin = new Date();
    await doctor.save();

    const authResponse = generateAuthResponse(doctor, 'doctor');

    logger.info(`Doctor login: ${doctor.fullName}`, { doctorId: doctor.doctorId });

    res.json({
      status: 'success',
      message: 'Login successful',
      data: authResponse
    });

  } catch (error) {
    logger.error('Doctor login error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during login'
    });
  }
});

// @route   POST /api/v1/auth/patient/register
// @desc    Register a new patient
// @access  Public
router.post('/patient/register', [
  ...validateRegistration,
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
      password,
      address,
      emergencyContacts
    } = req.body;

    // Check if patient already exists
    const existingPatient = await Patient.findOne({
      $or: [
        { 'personalInfo.email': email },
        { 'personalInfo.aadhaarNumber': aadhaarNumber },
        { 'personalInfo.phone': phone }
      ]
    });

    if (existingPatient) {
      return res.status(400).json({
        status: 'error',
        message: 'Patient with this email, phone, or Aadhaar number already exists'
      });
    }

    // Create new patient
    const patient = new Patient({
      personalInfo: {
        firstName,
        lastName,
        email,
        phone,
        aadhaarNumber,
        dateOfBirth,
        gender
      },
      address: address || {},
      credentials: {
        password
      },
      emergencyContacts: emergencyContacts || []
    });

    await patient.save();

    const authResponse = generateAuthResponse(patient, 'patient');

    logger.info(`New patient registered: ${patient.fullName}`, { patientId: patient.patientId });

    res.status(201).json({
      status: 'success',
      message: 'Patient registered successfully',
      data: {
        ...authResponse,
        patientId: patient.patientId,
        uhi: patient.uhi
      }
    });

  } catch (error) {
    logger.error('Patient registration error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during registration'
    });
  }
});

// @route   POST /api/v1/auth/patient/login
// @desc    Login patient
// @access  Public
router.post('/patient/login', [
  body('identifier').trim().notEmpty().withMessage('Patient ID, UHI, or email is required'),
  body('password').notEmpty().withMessage('Password is required')
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

    const { identifier, password } = req.body;

    // Find patient by patientId, UHI, or email
    const patient = await Patient.findOne({
      $or: [
        { patientId: identifier },
        { uhi: identifier.toUpperCase() },
        { 'personalInfo.email': identifier.toLowerCase() }
      ]
    });

    if (!patient) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Check if patient is active
    if (!patient.credentials.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Patient account is deactivated'
      });
    }

    // Verify password
    const isPasswordValid = await patient.comparePassword(password);

    if (!isPasswordValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid credentials'
      });
    }

    // Update last login
    patient.credentials.lastLogin = new Date();
    await patient.save();

    const authResponse = generateAuthResponse(patient, 'patient');

    logger.info(`Patient login: ${patient.fullName}`, { patientId: patient.patientId });

    res.json({
      status: 'success',
      message: 'Login successful',
      data: authResponse
    });

  } catch (error) {
    logger.error('Patient login error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during login'
    });
  }
});

// @route   POST /api/v1/auth/logout
// @desc    Logout user (invalidate token on client side)
// @access  Private
router.post('/logout', authenticate, async (req, res) => {
  try {
    // In a production environment, you might want to blacklist the token
    // For now, we'll just send a success response
    
    logger.info(`User logout`, { userId: req.user.id, role: req.user.role });

    res.json({
      status: 'success',
      message: 'Logged out successfully'
    });

  } catch (error) {
    logger.error('Logout error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error during logout'
    });
  }
});

// @route   GET /api/v1/auth/me
// @desc    Get current user profile
// @access  Private
router.get('/me', authenticate, async (req, res) => {
  try {
    let user;
    let role = req.user.role;

    switch (role) {
      case 'hospital':
        user = await Hospital.findById(req.user.id);
        break;
      case 'doctor':
        user = await Doctor.findById(req.user.id).populate('hospital');
        break;
      case 'patient':
        user = await Patient.findById(req.user.id);
        break;
      default:
        return res.status(400).json({
          status: 'error',
          message: 'Invalid user role'
        });
    }

    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'User not found'
      });
    }

    res.json({
      status: 'success',
      data: {
        user: {
          id: user._id,
          role: role,
          ...getPublicUserData(user, role)
        }
      }
    });

  } catch (error) {
    logger.error('Get profile error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Server error'
    });
  }
});

// @route   POST /api/v1/auth/login
// @desc    Universal login endpoint for all roles
// @access  Public
router.post('/login', [
  body('username').trim().notEmpty().withMessage('Username is required'),
  body('password').notEmpty().withMessage('Password is required'),
  body('role').isIn(['hospital', 'doctor', 'user', 'regional']).withMessage('Valid role is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { username, password, role } = req.body;
    let user = null;
    let userType = '';

    console.log(`🔍 Login attempt - Username: ${username}, Role: ${role}`);

    // Find user based on role
    switch (role) {
      case 'hospital':
        console.log('🏥 Looking for hospital...');
        user = await Hospital.findOne({ 'credentials.username': username });
        userType = 'hospital';
        break;
      case 'doctor':
        console.log('👨‍⚕️ Looking for doctor...');
        user = await Doctor.findOne({ 'credentials.username': username });
        userType = 'doctor';
        break;
      case 'user':
        console.log('👤 Looking for patient...');
        user = await Patient.findOne({ 'credentials.username': username });
        userType = 'patient';
        break;
      case 'regional':
        // For now, we'll use a simple check for regional officers
        // In a real app, you'd have a RegionalOfficer model
        if (username === 'regional.admin' && password === 'regional@123') {
          return res.json({
            success: true,
            message: 'Login successful',
            userId: 'regional_001',
            role: 'regional',
            user: {
              id: 'regional_001',
              name: 'Regional Health Officer',
              role: 'regional',
              region: 'Kerala',
              designation: 'Regional Health Officer'
            }
          });
        }
        break;
      default:
        return res.status(400).json({
          success: false,
          message: 'Invalid role specified'
        });
    }

    if (!user) {
      console.log(`❌ User not found for username: ${username}, role: ${role}`);
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    console.log(`✅ User found: ${user._id}`);
    console.log(`📋 User active status: ${user.credentials.isActive}`);

    // Check if user is active
    if (!user.credentials.isActive) {
      console.log(`❌ Account inactive for user: ${username}`);
      return res.status(401).json({
        success: false,
        message: 'Account is inactive'
      });
    }

    // Check password (plaintext comparison)
    console.log(`🔐 Comparing passwords - Input: "${password}", Stored: "${user.credentials.password}"`);
    const isMatch = await user.comparePassword(password);
    console.log(`🔐 Password match result: ${isMatch}`);
    
    if (!isMatch) {
      console.log(`❌ Password mismatch for user: ${username}`);
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Update last login
    user.credentials.lastLogin = new Date();
    await user.save();

    // Generate authentication response
    const authResponse = generateAuthResponse(user, userType);

    logger.info(`${userType} login: ${user.name || user.fullName}`, { 
      userId: user._id,
      userType: userType
    });

    res.json({
      success: true,
      message: 'Login successful',
      userId: authResponse.userId,
      role: authResponse.role,
      user: {
        id: user._id,
        name: user.name || user.fullName,
        role: role,
        email: user.credentials.email,
        phone: user.contactInfo.phone,
        // Add role-specific fields
        ...(userType === 'hospital' && {
          hospitalName: user.name,
          department: user.type
        }),
        ...(userType === 'doctor' && {
          specialization: user.specialization,
          licenseNumber: user.licenseNumber,
          hospitalName: user.hospitalAffiliation
        }),
        ...(userType === 'patient' && {
          aadhaarLast4: user.personalInfo.aadhaarNumber?.slice(-4),
          uniqueHealthId: user.personalInfo.uniqueHealthId,
          bloodGroup: user.medicalInfo.bloodGroup,
          address: user.personalInfo.address
        })
      }
    });

  } catch (error) {
    logger.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login'
    });
  }
});

// @route   POST /api/v1/auth/register
// @desc    Universal registration endpoint for all roles
// @access  Public
router.post('/register', [
  body('username').trim().notEmpty().withMessage('Username is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters long'),
  body('email').isEmail().normalizeEmail(),
  body('role').isIn(['hospital', 'doctor', 'user']).withMessage('Valid role is required'),
  body('firstName').trim().notEmpty().withMessage('First name is required'),
  body('lastName').trim().notEmpty().withMessage('Last name is required'),
  body('phone').trim().notEmpty().withMessage('Phone number is required')
], async (req, res) => {
  try {
    console.log('Registration request received:');
    console.log('Body:', JSON.stringify(req.body, null, 2));
    console.log('Headers:', req.headers);
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('Validation errors:', errors.array());
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { username, password, email, role, firstName, lastName, phone, ...additionalData } = req.body;

    // Check if user already exists
    let existingUser = null;
    switch (role) {
      case 'hospital':
        existingUser = await Hospital.findOne({
          $or: [
            { 'credentials.username': username },
            { 'credentials.email': email }
          ]
        });
        break;
      case 'doctor':
        existingUser = await Doctor.findOne({
          $or: [
            { 'credentials.username': username },
            { 'credentials.email': email }
          ]
        });
        break;
      case 'user':
        existingUser = await Patient.findOne({
          $or: [
            { 'credentials.username': username },
            { 'credentials.email': email }
          ]
        });
        break;
    }

    if (existingUser) {
      return res.status(409).json({
        success: false,
        message: 'User with this username or email already exists'
      });
    }

    // Create new user based on role
    let newUser = null;
    const currentDate = new Date();

    switch (role) {
      case 'hospital':
        newUser = new Hospital({
          hospitalId: `HOSP${Date.now()}`,
          name: `${firstName} ${lastName} Hospital`,
          type: additionalData.hospitalType || 'private',
          registrationNumber: `REG${Date.now()}`,
          address: {
            street: additionalData.address?.street || '',
            city: additionalData.address?.city || '',
            state: additionalData.address?.state || '',
            pincode: additionalData.address?.pincode || '',
            coordinates: {
              latitude: 0,
              longitude: 0
            }
          },
          contactInfo: {
            phone: phone,
            email: email,
            website: additionalData.website || '',
            emergencyContact: phone
          },
          credentials: {
            username: username,
            password: password,
            email: email,
            isActive: true,
            createdAt: currentDate,
            lastLogin: null
          },
          facilities: [],
          departments: [],
          statistics: {
            totalDoctors: 0,
            totalPatients: 0,
            totalBeds: 0,
            availableBeds: 0
          },
          certification: {
            accreditation: 'Pending',
            validUntil: new Date(currentDate.getFullYear() + 5, currentDate.getMonth(), currentDate.getDate()),
            isVerified: false
          }
        });
        break;

      case 'doctor':
        newUser = new Doctor({
          doctorId: `DOC${Date.now()}`,
          personalInfo: {
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            dateOfBirth: new Date(additionalData.dateOfBirth || '1980-01-01'),
            gender: additionalData.gender || 'male',
            address: {
              street: additionalData.address?.street || '',
              city: additionalData.address?.city || '',
              state: additionalData.address?.state || '',
              pincode: additionalData.address?.pincode || ''
            }
          },
          professionalInfo: {
            specialization: additionalData.specialization || 'General Medicine',
            qualification: additionalData.qualification || 'MBBS',
            experience: additionalData.experience || 0,
            licenseNumber: `LIC${Date.now()}`,
            registrationDate: currentDate
          },
          credentials: {
            username: username,
            password: password,
            email: email,
            isActive: true,
            createdAt: currentDate,
            lastLogin: null
          },
          hospitalAffiliation: additionalData.hospitalAffiliation || 'Independent',
          consultationFee: additionalData.consultationFee || 500,
          availability: {
            schedule: [
              { day: 'Monday', startTime: '09:00', endTime: '17:00', isAvailable: true },
              { day: 'Tuesday', startTime: '09:00', endTime: '17:00', isAvailable: true },
              { day: 'Wednesday', startTime: '09:00', endTime: '17:00', isAvailable: true },
              { day: 'Thursday', startTime: '09:00', endTime: '17:00', isAvailable: true },
              { day: 'Friday', startTime: '09:00', endTime: '17:00', isAvailable: true },
              { day: 'Saturday', startTime: '09:00', endTime: '12:00', isAvailable: true },
              { day: 'Sunday', startTime: '10:00', endTime: '12:00', isAvailable: false }
            ],
            emergencyAvailable: false
          }
        });
        break;

      case 'user':
        newUser = new Patient({
          patientId: `PAT${Date.now()}`,
          uhi: `UHI${Date.now()}`,
          personalInfo: {
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            aadhaarNumber: additionalData.aadhaarNumber || `${Math.floor(Math.random() * 9000000000) + 1000000000}`,
            dateOfBirth: new Date(additionalData.dateOfBirth || '1990-01-01'),
            gender: additionalData.gender || 'male',
            bloodGroup: additionalData.bloodGroup || 'O+',
            address: {
              street: additionalData.address?.street || '',
              city: additionalData.address?.city || '',
              state: additionalData.address?.state || '',
              pincode: additionalData.address?.pincode || '',
              country: 'India'
            },
            emergencyContact: {
              name: additionalData.emergencyContact?.name || 'Emergency Contact',
              relationship: additionalData.emergencyContact?.relationship || 'Family',
              phone: additionalData.emergencyContact?.phone || phone
            },
            uniqueHealthId: `UHI${Date.now()}`
          },
          credentials: {
            username: username,
            password: password,
            email: email,
            isActive: true,
            createdAt: currentDate,
            lastLogin: null
          },
          medicalInfo: {
            bloodGroup: additionalData.bloodGroup || 'O+',
            allergies: [],
            chronicConditions: [],
            medications: [],
            surgicalHistory: [],
            familyHistory: [],
            vaccinations: []
          },
          insuranceInfo: {
            provider: additionalData.insurance?.provider || 'None',
            policyNumber: additionalData.insurance?.policyNumber || '',
            validUntil: additionalData.insurance?.validUntil || null,
            coverageAmount: additionalData.insurance?.coverageAmount || 0
          },
          vitalSigns: {
            height: additionalData.height || 170,
            weight: additionalData.weight || 70,
            bmi: null,
            bloodPressure: { systolic: 120, diastolic: 80 },
            heartRate: 72,
            temperature: 98.6,
            respiratoryRate: 16,
            oxygenSaturation: 98
          }
        });
        
        // Calculate BMI
        if (newUser.vitalSigns.height && newUser.vitalSigns.weight) {
          const heightInM = newUser.vitalSigns.height / 100;
          newUser.vitalSigns.bmi = (newUser.vitalSigns.weight / (heightInM * heightInM)).toFixed(1);
        }
        break;
    }

    // Save the new user
    await newUser.save();

    // Generate authentication response
    const authResponse = generateAuthResponse(newUser, role === 'user' ? 'patient' : role);

    logger.info(`New ${role} registered: ${firstName} ${lastName}`, { 
      userId: newUser._id,
      username: username
    });

    res.status(201).json({
      success: true,
      message: 'Registration successful',
      token: authResponse.token,
      user: {
        id: newUser._id,
        name: `${firstName} ${lastName}`,
        role: role,
        email: email,
        phone: phone,
        username: username,
        // Add role-specific fields
        ...(role === 'hospital' && {
          hospitalName: newUser.name,
          department: newUser.type
        }),
        ...(role === 'doctor' && {
          specialization: newUser.professionalInfo.specialization,
          licenseNumber: newUser.professionalInfo.licenseNumber
        }),
        ...(role === 'user' && {
          patientId: newUser.patientId,
          uniqueHealthId: newUser.personalInfo.uniqueHealthId,
          bloodGroup: newUser.medicalInfo.bloodGroup
        })
      }
    });

  } catch (error) {
    logger.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during registration'
    });
  }
});

module.exports = router;
