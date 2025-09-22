const HospitalAssistant = require('../models/HospitalAssistant');
const HospitalDoctor = require('../models/HospitalDoctor');
const Hospital = require('../models/Hospital');
const jwt = require('jsonwebtoken');

// ==================== HOSPITAL ASSISTANT CONTROLLERS ====================

/**
 * @desc    Assistant login
 * @route   POST /api/hospital-assistant/login
 * @access  Public
 */
const assistantLogin = async (req, res) => {
  try {
    const { hospitalId, username, password } = req.body;

    if (!hospitalId || !username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Hospital ID, username, and password are required'
      });
    }

    // Check if hospital exists and is active
    const hospital = await Hospital.findOne({ 
      hospitalId, 
      isActive: true,
      status: 'Active' 
    });

    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found or inactive'
      });
    }

    // Find assistant for this hospital
    const assistant = await HospitalAssistant.findOne({
      hospitalId,
      username,
      isActive: true
    });

    if (!assistant) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check account lock
    if (assistant.accountLocked && assistant.lockUntil > new Date()) {
      return res.status(423).json({
        success: false,
        message: 'Account is temporarily locked due to multiple failed login attempts'
      });
    }

    // Validate password (plain text comparison as requested)
    if (assistant.password !== password) {
      // Increment failed login attempts
      assistant.failedLoginAttempts += 1;
      
      if (assistant.failedLoginAttempts >= 5) {
        assistant.accountLocked = true;
        assistant.lockUntil = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes
      }
      
      // Skip validation for login attempt tracking to prevent schema conflicts
      await assistant.save({ validateBeforeSave: false });
      
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Reset failed attempts on successful login
    assistant.failedLoginAttempts = 0;
    assistant.accountLocked = false;
    assistant.lockUntil = null;
    assistant.lastLoginAt = new Date();
    
    // Skip validation during login updates to prevent schema validation errors
    // on existing records after model schema changes
    await assistant.save({ validateBeforeSave: false });

    // Get assigned doctor details if available
    let assignedDoctor = null;
    if (assistant.assignedDoctorId) {
      assignedDoctor = await HospitalDoctor.findOne({
        doctorId: assistant.assignedDoctorId,
        hospitalId,
        isActive: true
      }).select('doctorId doctorName specialization department');
    }

    // Create JWT token
    const token = jwt.sign(
      { 
        assistantId: assistant.assistantId,
        hospitalId: assistant.hospitalId,
        role: 'hospital_assistant'
      },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '24h' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        assistant: {
          assistantId: assistant.assistantId,
          assistantName: assistant.assistantName,
          username: assistant.username,
          email: assistant.email,
          designation: assistant.designation,
          department: assistant.department,
          hospitalId: assistant.hospitalId,
          hospitalName: hospital.name,
          assignedDoctor,
          permissions: assistant.permissions
        }
      }
    });

  } catch (error) {
    console.error('Assistant login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login'
    });
  }
};

/**
 * @desc    Get assistant dashboard data
 * @route   GET /api/hospital-assistant/dashboard
 * @access  Private (Hospital Assistant)
 */
const getAssistantDashboard = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;

    // Get assistant details
    const assistant = await HospitalAssistant.findOne({
      assistantId,
      hospitalId,
      isActive: true
    }).select('-password');

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    // Get assigned doctor details if available
    let assignedDoctor = null;
    if (assistant.assignedDoctorId) {
      assignedDoctor = await HospitalDoctor.findOne({
        doctorId: assistant.assignedDoctorId,
        hospitalId,
        isActive: true
      }).select('doctorId doctorName specialization department dutyStatus contactNumber');
    }

    // Get today's schedule
    const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
    const todaySchedule = assistant.dutySchedule?.[today] || null;

    // Get duties/tasks for today (if assigned to doctor)
    let todayDuties = [];
    if (assistant.duties && assistant.duties.length > 0) {
      todayDuties = assistant.duties.filter(duty => {
        const dutyDate = new Date(duty.assignedDate);
        const today = new Date();
        return dutyDate.toDateString() === today.toDateString();
      });
    }

    res.json({
      success: true,
      data: {
        profile: {
          assistantId: assistant.assistantId,
          assistantName: assistant.assistantName,
          designation: assistant.designation,
          department: assistant.department,
          dutyStatus: assistant.dutyStatus,
          contactNumber: assistant.contactNumber,
          email: assistant.email
        },
        summary: {
          assignedDoctor,
          todaySchedule,
          todayDuties: todayDuties.length,
          permissions: assistant.permissions
        },
        duties: todayDuties
      }
    });

  } catch (error) {
    console.error('Get assistant dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching dashboard data'
    });
  }
};

/**
 * @desc    Get assistant profile
 * @route   GET /api/hospital-assistant/profile
 * @access  Private (Hospital Assistant)
 */
const getAssistantProfile = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;

    const assistant = await HospitalAssistant.findOne({
      assistantId,
      hospitalId,
      isActive: true
    })
    .select('-password')
    .populate('assignedDoctorId', 'doctorName specialization department');

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    res.json({
      success: true,
      data: assistant
    });

  } catch (error) {
    console.error('Get assistant profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching profile'
    });
  }
};

/**
 * @desc    Update assistant profile
 * @route   PUT /api/hospital-assistant/profile
 * @access  Private (Hospital Assistant)
 */
const updateAssistantProfile = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;
    const updates = req.body;

    // Remove fields that shouldn't be updated by assistant
    delete updates.assistantId;
    delete updates.hospitalId;
    delete updates.username;
    delete updates.isActive;
    delete updates.createdAt;
    delete updates.permissions;
    delete updates.assignedDoctorId; // Only admin can change doctor assignment

    const assistant = await HospitalAssistant.findOneAndUpdate(
      { assistantId, hospitalId, isActive: true },
      { ...updates, updatedAt: new Date() },
      { new: true, runValidators: true }
    ).select('-password');

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: assistant
    });

  } catch (error) {
    console.error('Update assistant profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating profile'
    });
  }
};

/**
 * @desc    Update assistant duty status
 * @route   PUT /api/hospital-assistant/duty-status
 * @access  Private (Hospital Assistant)
 */
const updateDutyStatus = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;
    const { dutyStatus } = req.body;

    if (!['On Duty', 'Off Duty', 'Break', 'Sick Leave'].includes(dutyStatus)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid duty status'
      });
    }

    const assistant = await HospitalAssistant.findOneAndUpdate(
      { assistantId, hospitalId, isActive: true },
      { dutyStatus, updatedAt: new Date() },
      { new: true }
    ).select('assistantId assistantName dutyStatus');

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    res.json({
      success: true,
      message: 'Duty status updated successfully',
      data: assistant
    });

  } catch (error) {
    console.error('Update duty status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating duty status'
    });
  }
};

/**
 * @desc    Get assigned doctor details
 * @route   GET /api/hospital-assistant/assigned-doctor
 * @access  Private (Hospital Assistant)
 */
const getAssignedDoctor = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;

    const assistant = await HospitalAssistant.findOne({
      assistantId,
      hospitalId,
      isActive: true
    }).select('assignedDoctorId');

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    if (!assistant.assignedDoctorId) {
      return res.json({
        success: true,
        message: 'No doctor assigned',
        data: null
      });
    }

    const doctor = await HospitalDoctor.findOne({
      doctorId: assistant.assignedDoctorId,
      hospitalId,
      isActive: true
    }).select('-password');

    res.json({
      success: true,
      data: doctor
    });

  } catch (error) {
    console.error('Get assigned doctor error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching assigned doctor'
    });
  }
};

/**
 * @desc    Update duty schedule
 * @route   PUT /api/hospital-assistant/schedule
 * @access  Private (Hospital Assistant)
 */
const updateSchedule = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;
    const { dutySchedule } = req.body;

    if (!dutySchedule || typeof dutySchedule !== 'object') {
      return res.status(400).json({
        success: false,
        message: 'Invalid schedule format'
      });
    }

    const assistant = await HospitalAssistant.findOneAndUpdate(
      { assistantId, hospitalId, isActive: true },
      { dutySchedule, updatedAt: new Date() },
      { new: true, runValidators: true }
    ).select('assistantId assistantName dutySchedule');

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    res.json({
      success: true,
      message: 'Schedule updated successfully',
      data: assistant
    });

  } catch (error) {
    console.error('Update schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating schedule'
    });
  }
};

/**
 * @desc    Change password
 * @route   PUT /api/hospital-assistant/change-password
 * @access  Private (Hospital Assistant)
 */
const changePassword = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Current password and new password are required'
      });
    }

    const assistant = await HospitalAssistant.findOne({
      assistantId,
      hospitalId,
      isActive: true
    });

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    // Verify current password (plain text comparison as requested)
    if (assistant.password !== currentPassword) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Update password (plain text as requested)
    assistant.password = newPassword;
    assistant.updatedAt = new Date();
    await assistant.save();

    res.json({
      success: true,
      message: 'Password changed successfully'
    });

  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while changing password'
    });
  }
};

/**
 * @desc    Get duties/tasks
 * @route   GET /api/hospital-assistant/duties
 * @access  Private (Hospital Assistant)
 */
const getDuties = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;
    const { date, status } = req.query;

    const assistant = await HospitalAssistant.findOne({
      assistantId,
      hospitalId,
      isActive: true
    }).select('duties');

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    let duties = assistant.duties || [];

    // Filter by date if provided
    if (date) {
      const filterDate = new Date(date);
      duties = duties.filter(duty => {
        const dutyDate = new Date(duty.assignedDate);
        return dutyDate.toDateString() === filterDate.toDateString();
      });
    }

    // Filter by status if provided
    if (status) {
      duties = duties.filter(duty => duty.status === status);
    }

    res.json({
      success: true,
      count: duties.length,
      data: duties
    });

  } catch (error) {
    console.error('Get duties error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching duties'
    });
  }
};

/**
 * @desc    Update duty status
 * @route   PUT /api/hospital-assistant/duties/:dutyId
 * @access  Private (Hospital Assistant)
 */
const updateDutyTaskStatus = async (req, res) => {
  try {
    const { assistantId, hospitalId } = req.assistant;
    const { dutyId } = req.params;
    const { status, notes } = req.body;

    if (!['Pending', 'In Progress', 'Completed', 'Cancelled'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid duty status'
      });
    }

    const assistant = await HospitalAssistant.findOne({
      assistantId,
      hospitalId,
      isActive: true
    });

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    const dutyIndex = assistant.duties.findIndex(duty => duty._id.toString() === dutyId);
    
    if (dutyIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Duty not found'
      });
    }

    assistant.duties[dutyIndex].status = status;
    if (notes) {
      assistant.duties[dutyIndex].notes = notes;
    }
    assistant.duties[dutyIndex].updatedAt = new Date();

    await assistant.save();

    res.json({
      success: true,
      message: 'Duty status updated successfully',
      data: assistant.duties[dutyIndex]
    });

  } catch (error) {
    console.error('Update duty status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating duty status'
    });
  }
};

module.exports = {
  assistantLogin,
  getAssistantDashboard,
  getAssistantProfile,
  updateAssistantProfile,
  updateDutyStatus,
  getAssignedDoctor,
  updateSchedule,
  changePassword,
  getDuties,
  updateDutyTaskStatus
};