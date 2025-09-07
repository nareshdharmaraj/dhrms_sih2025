const jwt = require('jsonwebtoken');
const Hospital = require('../models/Hospital');
const Doctor = require('../models/Doctor');
const Patient = require('../models/Patient');

// General authentication middleware
const authenticate = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. No token provided.'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid token.'
    });
  }
};

// Hospital authentication middleware
const authenticateHospital = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. No token provided.'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    if (decoded.role !== 'hospital') {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. Hospital authentication required.'
      });
    }

    const hospital = await Hospital.findById(decoded.id);
    if (!hospital || !hospital.credentials.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Hospital account not found or inactive.'
      });
    }

    req.user = decoded;
    req.hospital = hospital;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid token.'
    });
  }
};

// Doctor authentication middleware
const authenticateDoctor = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. No token provided.'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    if (decoded.role !== 'doctor') {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. Doctor authentication required.'
      });
    }

    const doctor = await Doctor.findById(decoded.id).populate('hospital');
    if (!doctor || !doctor.credentials.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Doctor account not found or inactive.'
      });
    }

    req.user = decoded;
    req.doctor = doctor;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid token.'
    });
  }
};

// Patient authentication middleware
const authenticatePatient = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. No token provided.'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    if (decoded.role !== 'patient') {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. Patient authentication required.'
      });
    }

    const patient = await Patient.findById(decoded.id);
    if (!patient || !patient.credentials.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Patient account not found or inactive.'
      });
    }

    req.user = decoded;
    req.patient = patient;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid token.'
    });
  }
};

// Role-based authorization middleware
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        status: 'error',
        message: 'Authentication required.'
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        status: 'error',
        message: `Access denied. Required roles: ${roles.join(', ')}`
      });
    }

    next();
  };
};

// Hospital-Doctor relationship verification
const verifyHospitalDoctorRelationship = async (req, res, next) => {
  try {
    if (req.user.role === 'hospital') {
      // Hospital can manage their own doctors
      next();
    } else if (req.user.role === 'doctor') {
      // Doctor can only access their own data
      const doctor = await Doctor.findById(req.user.id);
      if (!doctor) {
        return res.status(404).json({
          status: 'error',
          message: 'Doctor not found.'
        });
      }
      req.doctor = doctor;
      next();
    } else {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. Hospital or Doctor authentication required.'
      });
    }
  } catch (error) {
    return res.status(500).json({
      status: 'error',
      message: 'Server error during authorization.'
    });
  }
};

module.exports = {
  authenticate,
  authenticateHospital,
  authenticateDoctor,
  authenticatePatient,
  authorize,
  verifyHospitalDoctorRelationship
};
