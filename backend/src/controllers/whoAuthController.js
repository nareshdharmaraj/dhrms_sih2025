const jwt = require('jsonwebtoken');
const WhoAdmin = require('../models/WhoAdmin');
const { validationResult } = require('express-validator');

// Generate JWT token
const generateToken = (adminId) => {
  return jwt.sign(
    { adminId, type: 'who_admin' },
    process.env.JWT_SECRET || 'dhrms-who-secret-key',
    { expiresIn: process.env.JWT_EXPIRE || '24h' }
  );
};

// Login WHO Admin
const loginWhoAdmin = async (req, res) => {
  try {
    // Debug: Log the request body
    console.log('🔍 WHO Login Request Body:', req.body);
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

    const { adminId, username, password } = req.body;
    const loginIdentifier = adminId || username;

    if (!loginIdentifier) {
      console.log('❌ No login identifier provided');
      return res.status(400).json({
        success: false,
        message: 'Admin ID or username is required'
      });
    }

    console.log('🔍 Looking for admin with identifier:', loginIdentifier);

    // Find admin by adminId or username
    const admin = await WhoAdmin.findOne({ 
      $or: [
        { adminId: loginIdentifier },
        { username: loginIdentifier }
      ]
    }).select('+password');
    
    console.log('🔍 Admin found:', admin ? 'YES' : 'NO');
    if (admin) {
      console.log('🔍 Admin details:', {
        id: admin._id,
        adminId: admin.adminId,
        username: admin.username,
        email: admin.email,
        isActive: admin.isActive
      });
    }
    
    if (!admin) {
      console.log('❌ Admin not found in database');
      return res.status(401).json({
        success: false,
        message: 'Invalid admin ID or password'
      });
    }

    // Check if account is active
    if (!admin.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Account is deactivated. Please contact system administrator.'
      });
    }

    // Check if account is locked - DISABLED FOR TESTING
    /* 
    if (admin.isLocked()) {
      return res.status(423).json({
        success: false,
        message: 'Account is temporarily locked due to multiple failed login attempts. Please try again later.'
      });
    }
    */

    // Check password
    const isPasswordValid = await admin.comparePassword(password);
    console.log('🔍 Password validation result:', isPasswordValid);
    
    if (!isPasswordValid) {
      // Increment login attempts - DISABLED FOR TESTING
      // await admin.incLoginAttempts();
      
      return res.status(401).json({
        success: false,
        message: 'Invalid admin ID or password'
      });
    }

    console.log('✅ Password validation successful');

    // Reset login attempts on successful login - DISABLED FOR TESTING
    // await admin.resetLoginAttempts();
    console.log('✅ Login attempts reset (skipped for testing)');

    // Generate token
    console.log('🔑 Generating JWT token...');
    const token = generateToken(admin._id);
    console.log('🔑 Token generated:', token ? 'SUCCESS' : 'FAILED');

    // Update last login
    admin.lastLogin = new Date();
    // await admin.save();  // DISABLED FOR TESTING
    console.log('✅ Last login updated (skipped for testing)');

    // Remove password from response
    const adminData = admin.toJSON();
    console.log('📋 Admin data prepared for response');

    const response = {
      success: true,
      message: 'Login successful',
      admin: adminData,
      token,
      expiresIn: process.env.JWT_EXPIRE || '24h'
    };

    console.log('� Sending successful response...');
    res.status(200).json(response);

  } catch (error) {
    console.error('WHO Admin login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Logout WHO Admin
const logoutWhoAdmin = async (req, res) => {
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
    console.error('WHO Admin logout error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during logout'
    });
  }
};

// Logout from all sessions
const logoutAllWhoAdmin = async (req, res) => {
  try {
    const adminId = req.admin.adminId;
    
    const admin = await WhoAdmin.findById(adminId);
    
    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }

    // Deactivate all sessions
    admin.sessions = admin.sessions.map(session => ({
      ...session,
      isActive: false
    }));

    await admin.save();

    res.status(200).json({
      success: true,
      message: 'Logged out from all sessions successfully'
    });

  } catch (error) {
    console.error('Logout all error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during logout'
    });
  }
};

// Get current WHO admin profile
const getCurrentAdmin = async (req, res) => {
  try {
    const admin = await WhoAdmin.findById(req.admin.adminId);
    
    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }

    res.status(200).json({
      success: true,
      admin: admin.toJSON()
    });

  } catch (error) {
    console.error('Get current admin error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching admin profile'
    });
  }
};

// Update WHO admin profile
const updateAdminProfile = async (req, res) => {
  try {
    const { fullName, email, phone, managedStates } = req.body;
    const adminId = req.admin.adminId;

    const updateData = {};
    if (fullName) updateData.fullName = fullName;
    if (email) updateData.email = email;
    if (phone) updateData.phone = phone;
    if (managedStates) updateData.managedStates = managedStates;
    
    updateData.updatedAt = new Date();

    const admin = await WhoAdmin.findByIdAndUpdate(
      adminId,
      updateData,
      { new: true, runValidators: true }
    );

    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      admin: admin.toJSON()
    });

  } catch (error) {
    console.error('Update admin profile error:', error);
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
    const adminId = req.admin.adminId;

    // Find admin with password
    const admin = await WhoAdmin.findById(adminId).select('+password');
    
    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }

    // Verify current password
    const isCurrentPasswordValid = await admin.comparePassword(currentPassword);
    
    if (!isCurrentPasswordValid) {
      return res.status(400).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Update password
    admin.password = newPassword;
    admin.updatedAt = new Date();
    await admin.save();

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
    const admin = await WhoAdmin.findById(req.admin.adminId);
    
    if (!admin || !admin.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired token'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Token is valid',
      admin: admin.toJSON()
    });

  } catch (error) {
    console.error('Verify token error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error verifying token'
    });
  }
};

module.exports = {
  login: loginWhoAdmin,
  logout: logoutWhoAdmin,
  logoutAll: logoutAllWhoAdmin,
  getProfile: getCurrentAdmin,
  updateProfile: updateAdminProfile,
  changePassword,
  verifyToken
};