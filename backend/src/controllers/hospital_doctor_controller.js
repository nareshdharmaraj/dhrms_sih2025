const HospitalDoctor = require('../models/HospitalDoctor');
const HospitalAssistant = require('../models/HospitalAssistant');
const Hospital = require('../models/Hospital');
const jwt = require('jsonwebtoken');

// ==================== HOSPITAL DOCTOR CONTROLLERS ====================

/**
 * @desc    Doctor login
 * @route   POST /api/hospital-doctor/login
 * @access  Public
 */
const doctorLogin = async (req, res) => {
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

    // Find doctor for this hospital (check both doctorId and username)
    const doctor = await HospitalDoctor.findOne({
      hospitalId,
      $or: [
        { username },
        { doctorId: username }
      ],
      isActive: true
    });

    if (!doctor) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check account lock
    if (doctor.accountLocked && doctor.lockUntil && doctor.lockUntil > new Date()) {
      return res.status(423).json({
        success: false,
        message: 'Account is temporarily locked due to multiple failed login attempts'
      });
    }

    // Validate password (plain text comparison as requested)
    if (doctor.password !== password) {
      // Increment failed login attempts
      doctor.failedLoginAttempts = (doctor.failedLoginAttempts || 0) + 1;
      
      if (doctor.failedLoginAttempts >= 5) {
        doctor.accountLocked = true;
        doctor.lockUntil = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes
      }
      
      await doctor.save();
      
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Reset failed attempts on successful login
    doctor.failedLoginAttempts = 0;
    doctor.accountLocked = false;
    doctor.lockUntil = null;
    doctor.lastLoginAt = new Date();
    doctor.lastLogin = new Date(); // Also update this field for compatibility
    await doctor.save();

    // Create JWT token
    const token = jwt.sign(
      { 
        doctorId: doctor.doctorId,
        hospitalId: doctor.hospitalId,
        role: 'hospital_doctor'
      },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '24h' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        doctor: {
          _id: doctor._id, // MongoDB ObjectId for compatibility
          doctorId: doctor.doctorId,
          doctorName: doctor.doctorName || doctor.name,
          name: doctor.name || doctor.doctorName,
          username: doctor.username,
          email: doctor.email,
          contactNumber: doctor.contactNumber,
          specialization: doctor.specialization,
          specializations: doctor.specializations || [doctor.specialization],
          department: doctor.department,
          hospitalId: doctor.hospitalId,
          hospitalName: hospital.name,
          designation: doctor.designation || 'Doctor',
          permissions: doctor.permissions,
          isActive: doctor.isActive,
          isOnDuty: doctor.isOnDuty
        }
      }
    });

  } catch (error) {
    console.error('Doctor login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login'
    });
  }
};

/**
 * @desc    Get doctor dashboard data
 * @route   GET /api/hospital-doctor/dashboard
 * @access  Private (Hospital Doctor)
 */
const getDoctorDashboard = async (req, res) => {
  try {
    const { doctorId, hospitalId } = req.doctor;

    // Get doctor details
    const doctor = await HospitalDoctor.findOne({
      doctorId,
      hospitalId,
      isActive: true
    }).select('-password');

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    // Get assigned assistants count
    const assignedAssistants = await HospitalAssistant.countDocuments({
      assignedDoctorId: doctorId,
      hospitalId,
      isActive: true
    });

    // Get assistants list
    const assistantsList = await HospitalAssistant.find({
      assignedDoctorId: doctorId,
      hospitalId,
      isActive: true
    })
    .select('assistantId assistantName designation contactNumber dutyStatus')
    .limit(5);

    // Get today's schedule
    const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
    const todaySchedule = doctor.dutySchedule?.[today] || null;

    res.json({
      success: true,
      data: {
        profile: {
          doctorId: doctor.doctorId,
          doctorName: doctor.doctorName,
          specialization: doctor.specialization,
          department: doctor.department,
          qualifications: doctor.qualifications,
          dutyStatus: doctor.dutyStatus,
          contactNumber: doctor.contactNumber,
          email: doctor.email
        },
        summary: {
          assignedAssistants,
          todaySchedule,
          permissions: doctor.permissions
        },
        assistants: assistantsList
      }
    });

  } catch (error) {
    console.error('Get doctor dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching dashboard data'
    });
  }
};

/**
 * @desc    Get doctor profile
 * @route   GET /api/hospital-doctor/profile
 * @access  Private (Hospital Doctor)
 */
const getDoctorProfile = async (req, res) => {
  try {
    const { doctorId, hospitalId } = req.doctor;

    const doctor = await HospitalDoctor.findOne({
      doctorId,
      hospitalId,
      isActive: true
    }).select('-password');

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    res.json({
      success: true,
      data: doctor
    });

  } catch (error) {
    console.error('Get doctor profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching profile'
    });
  }
};

/**
 * @desc    Update doctor profile
 * @route   PUT /api/hospital-doctor/profile
 * @access  Private (Hospital Doctor)
 */
const updateDoctorProfile = async (req, res) => {
  try {
    const { doctorId, hospitalId } = req.doctor;
    const updates = req.body;

    // Remove fields that shouldn't be updated by doctor
    delete updates.doctorId;
    delete updates.hospitalId;
    delete updates.username;
    delete updates.isActive;
    delete updates.createdAt;
    delete updates.permissions;

    const doctor = await HospitalDoctor.findOneAndUpdate(
      { doctorId, hospitalId, isActive: true },
      { ...updates, updatedAt: new Date() },
      { new: true, runValidators: true }
    ).select('-password');

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: doctor
    });

  } catch (error) {
    console.error('Update doctor profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating profile'
    });
  }
};

/**
 * @desc    Update doctor duty status
 * @route   PUT /api/hospital-doctor/duty-status
 * @access  Private (Hospital Doctor)
 */
const updateDutyStatus = async (req, res) => {
  try {
    const { doctorId, hospitalId } = req.doctor;
    const { dutyStatus } = req.body;

    if (!['On Duty', 'Off Duty', 'Emergency Leave', 'Break'].includes(dutyStatus)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid duty status'
      });
    }

    const doctor = await HospitalDoctor.findOneAndUpdate(
      { doctorId, hospitalId, isActive: true },
      { dutyStatus, updatedAt: new Date() },
      { new: true }
    ).select('doctorId doctorName dutyStatus');

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    res.json({
      success: true,
      message: 'Duty status updated successfully',
      data: doctor
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
 * @desc    Get assigned assistants
 * @route   GET /api/hospital-doctor/assistants
 * @access  Private (Hospital Doctor)
 */
const getAssignedAssistants = async (req, res) => {
  try {
    const { doctorId, hospitalId } = req.doctor;

    const assistants = await HospitalAssistant.find({
      assignedDoctorId: doctorId,
      hospitalId,
      isActive: true
    })
    .select('-password')
    .sort({ assistantName: 1 });

    res.json({
      success: true,
      count: assistants.length,
      data: assistants
    });

  } catch (error) {
    console.error('Get assigned assistants error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching assistants'
    });
  }
};

/**
 * @desc    Update duty schedule
 * @route   PUT /api/hospital-doctor/schedule
 * @access  Private (Hospital Doctor)
 */
const updateSchedule = async (req, res) => {
  try {
    const { doctorId, hospitalId } = req.doctor;
    const { dutySchedule } = req.body;

    if (!dutySchedule || typeof dutySchedule !== 'object') {
      return res.status(400).json({
        success: false,
        message: 'Invalid schedule format'
      });
    }

    const doctor = await HospitalDoctor.findOneAndUpdate(
      { doctorId, hospitalId, isActive: true },
      { dutySchedule, updatedAt: new Date() },
      { new: true, runValidators: true }
    ).select('doctorId doctorName dutySchedule');

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    res.json({
      success: true,
      message: 'Schedule updated successfully',
      data: doctor
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
 * @route   PUT /api/hospital-doctor/change-password
 * @access  Private (Hospital Doctor)
 */
const changePassword = async (req, res) => {
  try {
    const { doctorId, hospitalId } = req.doctor;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Current password and new password are required'
      });
    }

    const doctor = await HospitalDoctor.findOne({
      doctorId,
      hospitalId,
      isActive: true
    });

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    // Verify current password (plain text comparison as requested)
    if (doctor.password !== currentPassword) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect'
      });
    }

    // Update password (plain text as requested)
    doctor.password = newPassword;
    doctor.updatedAt = new Date();
    await doctor.save();

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

module.exports = {
  doctorLogin,
  getDoctorDashboard,
  getDoctorProfile,
  updateDoctorProfile,
  updateDutyStatus,
  getAssignedAssistants,
  updateSchedule,
  changePassword
};