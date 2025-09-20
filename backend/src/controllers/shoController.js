const StateHealthOfficer = require('../models/StateHealthOfficer');
const { validationResult } = require('express-validator');

// Get all SHOs
const getAllSHOs = async (req, res) => {
  try {
    const { state, status, page = 1, limit = 10 } = req.query;
    
    // Build filter
    let filter = {};
    if (state) filter.assignedState = state;
    if (status) filter.isActive = status === 'active';
    
    // Pagination
    const skip = (page - 1) * limit;
    
    const [shos, total] = await Promise.all([
      StateHealthOfficer.find(filter)
        .select('-password')
        .populate('createdBy', 'fullName adminId')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      StateHealthOfficer.countDocuments(filter)
    ]);
    
    res.status(200).json({
      success: true,
      shos,
      pagination: {
        total,
        page: parseInt(page),
        pages: Math.ceil(total / limit),
        limit: parseInt(limit)
      }
    });
    
  } catch (error) {
    console.error('Get all SHOs error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching SHOs'
    });
  }
};

// Get SHO by ID
const getSHOById = async (req, res) => {
  try {
    const { shoId } = req.params;
    
    const sho = await StateHealthOfficer.findById(shoId)
      .select('-password')
      .populate('createdBy', 'fullName adminId');
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }
    
    res.status(200).json({
      success: true,
      sho
    });
    
  } catch (error) {
    console.error('Get SHO by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching SHO'
    });
  }
};

// Create new SHO
const createSHO = async (req, res) => {
  try {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('SHO Creation Validation Errors:', errors.array());
      console.log('Request Body:', req.body);
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }
    
    const {
      officerId,
      fullName,
      email,
      phone,
      assignedState,
      password,
      permissions
    } = req.body;
    
    // Check if SHO already exists
    const existingSHO = await StateHealthOfficer.findOne({
      $or: [
        { officerId },
        { email },
        { assignedState } // Only one SHO per state
      ]
    });
    
    if (existingSHO) {
      let message = 'SHO already exists';
      if (existingSHO.officerId === officerId) message = 'Officer ID already exists';
      else if (existingSHO.email === email) message = 'Email already exists';
      else if (existingSHO.assignedState === assignedState) message = 'State already has an assigned SHO';
      
      return res.status(400).json({
        success: false,
        message
      });
    }
    
    // Create new SHO
    const newSHO = new StateHealthOfficer({
      officerId,
      fullName,
      email,
      phone,
      assignedState,
      password,
      permissions: permissions || {
        canManageRegionalOfficers: true,
        canViewRegionalOfficers: true,
        canManageHospitals: true,
        canViewHospitals: true,
        canManageUsers: true,
        canViewUsers: true,
        canGenerateReports: true,
        canExportData: true,
        canViewAnalytics: true
      },
      createdBy: req.admin.adminId  // Use adminId instead of _id
    });
    
    console.log('Attempting to save SHO:', {
      officerId,
      fullName,
      email,
      phone,
      assignedState,
      createdBy: req.admin.adminId  // Use adminId instead of _id
    });

    await newSHO.save();    // Return SHO without password
    const shoResponse = await StateHealthOfficer.findById(newSHO._id)
      .select('-password')
      .populate('createdBy', 'fullName adminId');
    
    res.status(201).json({
      success: true,
      message: 'SHO created successfully',
      sho: shoResponse
    });
    
  } catch (error) {
    console.error('Create SHO error:', error);
    console.error('Error details:', {
      message: error.message,
      stack: error.stack,
      name: error.name
    });
    if (error.name === 'ValidationError') {
      console.error('Mongoose validation errors:', error.errors);
    }
    res.status(500).json({
      success: false,
      message: 'Server error creating SHO',
      error: error.message
    });
  }
};

// Update SHO
const updateSHO = async (req, res) => {
  try {
    const { shoId } = req.params;
    const updates = req.body;
    
    // Remove fields that shouldn't be updated directly
    delete updates.password; // Use separate endpoint for password change
    delete updates.officerId; // Officer ID should not be changed
    delete updates.createdBy;
    delete updates.createdAt;
    
    const sho = await StateHealthOfficer.findByIdAndUpdate(
      shoId,
      { ...updates, updatedAt: Date.now() },
      { new: true, runValidators: true }
    ).select('-password').populate('createdBy', 'fullName adminId');
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'SHO updated successfully',
      sho
    });
    
  } catch (error) {
    console.error('Update SHO error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating SHO'
    });
  }
};

// Deactivate SHO
const deactivateSHO = async (req, res) => {
  try {
    const { shoId } = req.params;
    
    const sho = await StateHealthOfficer.findByIdAndUpdate(
      shoId,
      { 
        isActive: false,
        updatedAt: Date.now()
      },
      { new: true }
    ).select('-password');
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'SHO deactivated successfully',
      sho
    });
    
  } catch (error) {
    console.error('Deactivate SHO error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error deactivating SHO'
    });
  }
};

// Activate SHO
const activateSHO = async (req, res) => {
  try {
    const { shoId } = req.params;
    
    const sho = await StateHealthOfficer.findByIdAndUpdate(
      shoId,
      { 
        isActive: true,
        updatedAt: Date.now()
      },
      { new: true }
    ).select('-password');
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'SHO activated successfully',
      sho
    });
    
  } catch (error) {
    console.error('Activate SHO error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error activating SHO'
    });
  }
};

// Change SHO password
const changeSHOPassword = async (req, res) => {
  try {
    const { shoId } = req.params;
    const { newPassword } = req.body;
    
    if (!newPassword || newPassword.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long'
      });
    }
    
    const sho = await StateHealthOfficer.findById(shoId);
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }
    
    sho.password = newPassword; // Will be hashed by pre-save middleware
    await sho.save();
    
    res.status(200).json({
      success: true,
      message: 'Password changed successfully'
    });
    
  } catch (error) {
    console.error('Change SHO password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error changing password'
    });
  }
};

// Get SHO statistics
const getSHOStatistics = async (req, res) => {
  try {
    const stats = await StateHealthOfficer.aggregate([
      {
        $group: {
          _id: null,
          total: { $sum: 1 },
          active: { $sum: { $cond: ['$isActive', 1, 0] } },
          inactive: { $sum: { $cond: ['$isActive', 0, 1] } }
        }
      }
    ]);
    
    const stateStats = await StateHealthOfficer.aggregate([
      {
        $group: {
          _id: '$assignedState',
          count: { $sum: 1 },
          active: { $sum: { $cond: ['$isActive', 1, 0] } }
        }
      },
      { $sort: { _id: 1 } }
    ]);
    
    const result = stats[0] || { total: 0, active: 0, inactive: 0 };
    
    res.status(200).json({
      success: true,
      statistics: {
        ...result,
        stateDistribution: stateStats
      }
    });
    
  } catch (error) {
    console.error('Get SHO statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching statistics'
    });
  }
};

// Reset SHO Password (accepts custom password or generates random one)
const resetPassword = async (req, res) => {
  try {
    const { shoId } = req.params;
    const { newPassword } = req.body;
    
    console.log('Reset password request for SHO ID:', shoId);
    console.log('Custom password provided:', !!newPassword);
    
    // Validate new password if provided
    if (newPassword) {
      if (typeof newPassword !== 'string' || newPassword.length < 8) {
        return res.status(400).json({
          success: false,
          message: 'Password must be at least 8 characters long'
        });
      }
    }
    
    // Find the SHO
    const sho = await StateHealthOfficer.findById(shoId);
    
    if (!sho) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }
    
    // Use provided password or generate a new random password
    const finalPassword = newPassword || generateRandomPassword();
    console.log('Using password for SHO:', sho.fullName, 'Password length:', finalPassword.length, 'Custom:', !!newPassword);
    
    // Update the password
    sho.password = finalPassword;
    sho.updatedAt = new Date();
    
    // Reset login attempts if any
    sho.loginAttempts = 0;
    sho.lockUntil = undefined;
    
    await sho.save();
    
    console.log('Password reset successful for SHO:', sho.fullName);
    
    res.status(200).json({
      success: true,
      message: 'Password reset successfully',
      data: {
        shoId: sho._id,
        fullName: sho.fullName,
        username: sho.officerId,
        email: sho.email,
        newPassword: finalPassword, // Send the plain password for display
        isCustomPassword: !!newPassword // Indicate if it was a custom password
      }
    });
    
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error resetting password'
    });
  }
};

// Helper function to generate random password
const generateRandomPassword = () => {
  const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%';
  let password = '';
  
  // Ensure at least one uppercase, one lowercase, one number, and one special char
  password += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Math.floor(Math.random() * 26)];
  password += 'abcdefghijklmnopqrstuvwxyz'[Math.floor(Math.random() * 26)];
  password += '0123456789'[Math.floor(Math.random() * 10)];
  password += '!@#$%'[Math.floor(Math.random() * 5)];
  
  // Fill the rest randomly (minimum 8 chars total)
  for (let i = password.length; i < 12; i++) {
    password += charset[Math.floor(Math.random() * charset.length)];
  }
  
  // Shuffle the password
  return password.split('').sort(() => Math.random() - 0.5).join('');
};

module.exports = {
  getAllSHOs,
  getSHOById,
  createSHO,
  updateSHO,
  deactivateSHO,
  activateSHO,
  changeSHOPassword,
  getSHOStatistics,
  resetPassword
};
