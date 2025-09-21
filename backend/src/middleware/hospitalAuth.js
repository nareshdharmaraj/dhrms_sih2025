const jwt = require('jsonwebtoken');
const HospitalAdmin = require('../models/HospitalAdmin');
const HospitalDoctor = require('../models/HospitalDoctor');
const HospitalAssistant = require('../models/HospitalAssistant');

// ==================== AUTHENTICATION MIDDLEWARE ====================

/**
 * @desc    Authenticate Hospital Admin
 */
const authenticateHospitalAdmin = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token is required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

    if (decoded.role !== 'hospital_admin') {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Hospital admin role required.'
      });
    }

    const admin = await HospitalAdmin.findOne({
      adminId: decoded.adminId,
      hospitalId: decoded.hospitalId,
      isActive: true
    });

    if (!admin) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token or admin not found'
      });
    }

    req.admin = {
      adminId: admin.adminId,
      hospitalId: admin.hospitalId,
      adminName: admin.adminName,
      permissions: admin.permissions
    };

    next();
  } catch (error) {
    console.error('Admin authentication error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

/**
 * @desc    Authenticate Hospital Doctor
 */
const authenticateHospitalDoctor = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token is required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

    if (decoded.role !== 'hospital_doctor') {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Hospital doctor role required.'
      });
    }

    const doctor = await HospitalDoctor.findOne({
      doctorId: decoded.doctorId,
      hospitalId: decoded.hospitalId,
      isActive: true
    });

    if (!doctor) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token or doctor not found'
      });
    }

    req.doctor = {
      doctorId: doctor.doctorId,
      hospitalId: doctor.hospitalId,
      doctorName: doctor.doctorName,
      specialization: doctor.specialization,
      department: doctor.department,
      permissions: doctor.permissions
    };

    next();
  } catch (error) {
    console.error('Doctor authentication error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

/**
 * @desc    Authenticate Hospital Assistant
 */
const authenticateHospitalAssistant = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token is required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

    if (decoded.role !== 'hospital_assistant') {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Hospital assistant role required.'
      });
    }

    const assistant = await HospitalAssistant.findOne({
      assistantId: decoded.assistantId,
      hospitalId: decoded.hospitalId,
      isActive: true
    });

    if (!assistant) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token or assistant not found'
      });
    }

    req.assistant = {
      assistantId: assistant.assistantId,
      hospitalId: assistant.hospitalId,
      assistantName: assistant.assistantName,
      designation: assistant.designation,
      department: assistant.department,
      assignedDoctorId: assistant.assignedDoctorId,
      permissions: assistant.permissions
    };

    next();
  } catch (error) {
    console.error('Assistant authentication error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

/**
 * @desc    Authenticate any hospital staff (Admin, Doctor, or Assistant)
 */
const authenticateHospitalStaff = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token is required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

    if (!['hospital_admin', 'hospital_doctor', 'hospital_assistant'].includes(decoded.role)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Hospital staff role required.'
      });
    }

    let user = null;
    let userType = null;

    // Check based on role
    if (decoded.role === 'hospital_admin') {
      user = await HospitalAdmin.findOne({
        adminId: decoded.adminId,
        hospitalId: decoded.hospitalId,
        isActive: true
      });
      userType = 'admin';
    } else if (decoded.role === 'hospital_doctor') {
      user = await HospitalDoctor.findOne({
        doctorId: decoded.doctorId,
        hospitalId: decoded.hospitalId,
        isActive: true
      });
      userType = 'doctor';
    } else if (decoded.role === 'hospital_assistant') {
      user = await HospitalAssistant.findOne({
        assistantId: decoded.assistantId,
        hospitalId: decoded.hospitalId,
        isActive: true
      });
      userType = 'assistant';
    }

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token or user not found'
      });
    }

    req.user = user;
    req.userType = userType;
    req.hospitalId = decoded.hospitalId;
    req.role = decoded.role;

    next();
  } catch (error) {
    console.error('Staff authentication error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

/**
 * @desc    Check specific permission for hospital admin
 */
const requireAdminPermission = (permission) => {
  return (req, res, next) => {
    if (!req.admin) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    if (!req.admin.permissions || !req.admin.permissions.includes(permission)) {
      return res.status(403).json({
        success: false,
        message: `Permission denied. Required permission: ${permission}`
      });
    }

    next();
  };
};

/**
 * @desc    Check if user has admin or doctor role
 */
const requireAdminOrDoctor = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token is required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

    if (!['hospital_admin', 'hospital_doctor'].includes(decoded.role)) {
      return res.status(403).json({
        success: false,
        message: 'Access denied. Admin or Doctor role required.'
      });
    }

    let user = null;
    if (decoded.role === 'hospital_admin') {
      user = await HospitalAdmin.findOne({
        adminId: decoded.adminId,
        hospitalId: decoded.hospitalId,
        isActive: true
      });
      req.admin = {
        adminId: user.adminId,
        hospitalId: user.hospitalId,
        adminName: user.adminName,
        permissions: user.permissions
      };
    } else {
      user = await HospitalDoctor.findOne({
        doctorId: decoded.doctorId,
        hospitalId: decoded.hospitalId,
        isActive: true
      });
      req.doctor = {
        doctorId: user.doctorId,
        hospitalId: user.hospitalId,
        doctorName: user.doctorName,
        specialization: user.specialization,
        department: user.department,
        permissions: user.permissions
      };
    }

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token or user not found'
      });
    }

    req.role = decoded.role;
    next();
  } catch (error) {
    console.error('Admin or Doctor authentication error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error during authentication'
    });
  }
};

module.exports = {
  authenticateHospitalAdmin,
  authenticateHospitalDoctor,
  authenticateHospitalAssistant,
  authenticateHospitalStaff,
  requireAdminPermission,
  requireAdminOrDoctor
};