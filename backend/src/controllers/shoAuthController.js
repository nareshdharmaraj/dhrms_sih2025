const jwt = require('jsonwebtoken');
const SHO = require('../models/StateHealthOfficer');
const { validationResult } = require('express-validator');

// Generate JWT token for SHO
const generateToken = (shoId) => {
  return jwt.sign(
    { shoId, type: 'sho' },
    process.env.JWT_SECRET || 'dhrms-sho-secret-key',
    { expiresIn: process.env.JWT_EXPIRE || '24h' }
  );
};

// Login SHO
const loginSHO = async (req, res) => {
  try {
    // Debug: Log the request body
    console.log('🔍 SHO Login Request Body:', req.body);
    console.log('🔍 Request Headers:', req.headers);
    
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('❌ Validation Errors:', errors.array());
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { username, email, password } = req.body;
    const loginIdentifier = username || email;

    if (!loginIdentifier) {
      console.log('❌ No login identifier provided');
      return res.status(400).json({
        success: false,
        message: 'Username or email is required'
      });
    }

    if (!password) {
      console.log('❌ No password provided');
      return res.status(400).json({
        success: false,
        message: 'Password is required'
      });
    }

    console.log('🔍 Looking for SHO with identifier:', loginIdentifier);

    // Find SHO by officerId, username, or email
    const sho = await SHO.findOne({ 
      $or: [
        { officerId: loginIdentifier },
        { username: loginIdentifier },
        { email: loginIdentifier }
      ]
    }).select('+password');
    
    console.log('🔍 SHO found:', sho ? 'YES' : 'NO');
    if (sho) {
      console.log('🔍 SHO details:', {
        id: sho._id,
        officerId: sho.officerId,
        username: sho.username,
        email: sho.email,
        assignedState: sho.assignedState,
        isActive: sho.isActive
      });
    }
    
    if (!sho) {
      console.log('❌ SHO not found in database');
      return res.status(401).json({
        success: false,
        message: 'Invalid username/email or password'
      });
    }

    // Check if account is active
    if (!sho.isActive) {
      console.log('❌ Account is deactivated');
      return res.status(401).json({
        success: false,
        message: 'Account is deactivated. Please contact WHO administrator.'
      });
    }

    // Check if account is locked
    if (sho.isLocked) {
      console.log('❌ Account is locked due to too many failed attempts');
      return res.status(401).json({
        success: false,
        message: 'Account is temporarily locked due to too many failed login attempts. Please try again later.'
      });
    }

    // Check password using bcrypt comparison
    console.log('🔍 Password validation...');
    const isPasswordValid = await sho.comparePassword(password);
    console.log('🔍 Password validation result:', isPasswordValid);
    
    if (!isPasswordValid) {
      console.log('❌ Password validation failed, incrementing login attempts');
      await sho.incLoginAttempts();
      return res.status(401).json({
        success: false,
        message: 'Invalid username/email or password'
      });
    }

    console.log('✅ Password validation successful');

    // Reset login attempts on successful login
    if (sho.loginAttempts > 0) {
      console.log('🔄 Resetting login attempts');
      await sho.resetLoginAttempts();
    }

    // Generate token
    console.log('🔑 Generating JWT token...');
    const token = generateToken(sho._id);
    console.log('🔑 Token generated:', token ? 'SUCCESS' : 'FAILED');

    // Update last login
    sho.lastLogin = new Date();
    await sho.save();
    console.log('✅ Last login updated');

    // Remove password from response
    const shoData = sho.toJSON();
    delete shoData.password;
    console.log('📋 SHO data prepared for response');

    const response = {
      success: true,
      message: 'Login successful',
      sho: shoData,
      token,
      expiresIn: process.env.JWT_EXPIRE || '24h'
    };

    console.log('📤 Sending successful response...');
    res.status(200).json(response);

  } catch (error) {
    console.error('SHO login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Logout SHO
const logoutSHO = async (req, res) => {
  try {
    // In a production environment, you might want to:
    // 1. Add the token to a blacklist
    // 2. Store session information in Redis
    // 3. Clear any cached data
    
    res.status(200).json({
      success: true,
      message: 'Logout successful'
    });

  } catch (error) {
    console.error('SHO logout error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during logout'
    });
  }
};

// Get current SHO profile
const getCurrentSHO = async (req, res) => {
  try {
    const sho = await SHO.findById(req.sho.shoId);
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    res.status(200).json({
      success: true,
      sho: sho.toJSON()
    });

  } catch (error) {
    console.error('Get current SHO error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching SHO profile'
    });
  }
};

// Update SHO profile
const updateSHOProfile = async (req, res) => {
  try {
    const { fullName, email, phone } = req.body;
    const shoId = req.sho.shoId;

    const updateData = {};
    if (fullName) updateData.fullName = fullName;
    if (email) updateData.email = email;
    if (phone) updateData.phone = phone;
    
    updateData.updatedAt = new Date();

    const sho = await SHO.findByIdAndUpdate(
      shoId,
      updateData,
      { new: true, runValidators: true }
    );

    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      sho: sho.toJSON()
    });

  } catch (error) {
    console.error('Update SHO profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating profile'
    });
  }
};

// Change password
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const shoId = req.sho.shoId;

    // Find SHO with password
    const sho = await SHO.findById(shoId).select('+password');
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    // Verify current password
    const isCurrentPasswordValid = sho.password === currentPassword;
    
    if (!isCurrentPasswordValid) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Update password
    sho.password = newPassword;
    sho.updatedAt = new Date();
    await sho.save();

    res.status(200).json({
      success: true,
      message: 'Password changed successfully'
    });

  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error changing password'
    });
  }
};

// Verify token
const verifyToken = async (req, res) => {
  try {
    const sho = await SHO.findById(req.sho.shoId);
    
    if (!sho || !sho.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired token'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Token is valid',
      sho: sho.toJSON()
    });

  } catch (error) {
    console.error('Verify token error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error verifying token'
    });
  }
};

// Get SHO dashboard data
const getDashboardData = async (req, res) => {
  try {
    const shoId = req.sho.shoId;
    const sho = await SHO.findById(shoId);
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    // Get state-specific health statistics
    // This would typically involve querying patient data, hospital data, etc.
    // For now, we'll return mock data structure
    const dashboardData = {
      sho: sho.toJSON(),
      stateInfo: {
        name: sho.assignedState,
        totalHospitals: 0, // This would come from actual hospital data
        totalPatients: 0,  // This would come from actual patient data
        totalStaff: 0      // This would come from actual staff data
      },
      recentActivities: [],
      healthMetrics: {
        totalRegistrations: 0,
        activePatients: 0,
        healthcareFacilities: 0
      },
      notifications: []
    };

    res.status(200).json({
      success: true,
      data: dashboardData
    });

  } catch (error) {
    console.error('Get dashboard data error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching dashboard data'
    });
  }
};

module.exports = {
  login: loginSHO,
  logout: logoutSHO,
  getProfile: getCurrentSHO,
  updateProfile: updateSHOProfile,
  changePassword,
  verifyToken,
  getDashboardData
};