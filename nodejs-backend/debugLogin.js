const express = require('express');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const Hospital = require('./models/Hospital');
const Doctor = require('./models/Doctor');
const Patient = require('./models/Patient');
const { generateAuthResponse } = require('./utils/auth');

const router = express.Router();

// Debug login endpoint
router.post('/debug-login', [
  body('username').trim().notEmpty().withMessage('Username is required'),
  body('password').notEmpty().withMessage('Password is required'),
  body('role').isIn(['hospital', 'doctor', 'user', 'regional']).withMessage('Valid role is required')
], async (req, res) => {
  try {
    console.log('\n🔍 DEBUG LOGIN REQUEST:');
    console.log('Body:', req.body);
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('❌ Validation errors:', errors.array());
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { username, password, role } = req.body;
    console.log(`🔑 Login attempt: ${username} as ${role}`);
    
    let user = null;
    let userType = '';

    // Find user based on role
    switch (role) {
      case 'hospital':
        console.log('🏥 Looking for hospital admin...');
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
      default:
        console.log('❌ Invalid role specified');
        return res.status(400).json({
          success: false,
          message: 'Invalid role specified'
        });
    }

    console.log('👥 User found:', user ? 'YES' : 'NO');
    if (user) {
      console.log('👤 User details:', {
        id: user._id,
        username: user.credentials?.username,
        isActive: user.credentials?.isActive,
        hasPassword: !!user.credentials?.password
      });
    }

    if (!user) {
      console.log('❌ User not found in database');
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check if user is active
    if (!user.credentials.isActive) {
      console.log('❌ User account is inactive');
      return res.status(401).json({
        success: false,
        message: 'Account is inactive'
      });
    }

    // Check password
    console.log('🔐 Checking password...');
    const isMatch = await bcrypt.compare(password, user.credentials.password);
    console.log('🔐 Password match:', isMatch ? 'YES' : 'NO');
    
    if (!isMatch) {
      console.log('❌ Password does not match');
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    console.log('✅ Authentication successful!');

    // Update last login
    user.credentials.lastLogin = new Date();
    await user.save();

    // Generate authentication response
    const authResponse = generateAuthResponse(user, userType);
    console.log('🎫 Token generated:', authResponse.token ? 'YES' : 'NO');

    const response = {
      success: true,
      message: 'Login successful',
      token: authResponse.token,
      user: {
        id: user._id,
        name: user.name || user.fullName || `${user.personalInfo?.firstName} ${user.personalInfo?.lastName}`,
        role: role,
        email: user.credentials.email,
        phone: user.contactInfo?.phone || user.personalInfo?.phone,
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
          aadhaarLast4: user.personalInfo?.aadhaarNumber?.slice(-4),
          uniqueHealthId: user.personalInfo?.uniqueHealthId,
          bloodGroup: user.medicalInfo?.bloodGroup,
          address: user.personalInfo?.address
        })
      }
    };

    console.log('📤 Sending response:', { 
      success: response.success, 
      userName: response.user.name, 
      tokenLength: response.token ? response.token.length : 0 
    });

    res.json(response);

  } catch (error) {
    console.error('❌ Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login'
    });
  }
});

module.exports = router;
