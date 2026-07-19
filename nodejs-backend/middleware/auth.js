const Hospital = require('../models/Hospital');
const Doctor = require('../models/Doctor');
const Patient = require('../models/Patient');

// General authentication middleware (simplified - no JWT)
const authenticate = async (req, res, next) => {
  try {
    const userId = req.header('X-User-ID');
    const userRole = req.header('X-User-Role');
    
    if (!userId || !userRole) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. User ID and Role required.'
      });
    }

    req.user = { id: userId, role: userRole };
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid authentication.'
    });
  }
};

// Hospital authentication middleware (simplified)
const authenticateHospital = async (req, res, next) => {
  try {
    const userId = req.header('X-User-ID');
    const userRole = req.header('X-User-Role');
    
    if (!userId || !userRole) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. User ID and Role required.'
      });
    }

    if (userRole !== 'hospital') {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. Hospital authentication required.'
      });
    }

    const hospital = await Hospital.findById(userId);
    if (!hospital || !hospital.credentials.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Hospital account not found or inactive.'
      });
    }

    req.user = { id: userId, role: userRole };
    req.hospital = hospital;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid authentication.'
    });
  }
};

// Doctor authentication middleware (simplified)
const authenticateDoctor = async (req, res, next) => {
  try {
    const userId = req.header('X-User-ID');
    const userRole = req.header('X-User-Role');
    
    if (!userId || !userRole) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. User ID and Role required.'
      });
    }

    if (userRole !== 'doctor') {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. Doctor authentication required.'
      });
    }

    const doctor = await Doctor.findById(userId).populate('hospital');
    if (!doctor || !doctor.credentials.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Doctor account not found or inactive.'
      });
    }

    req.user = { id: userId, role: userRole };
    req.doctor = doctor;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid authentication.'
    });
  }
};

// Patient authentication middleware (simplified)
const authenticatePatient = async (req, res, next) => {
  try {
    const userId = req.header('X-User-ID');
    const userRole = req.header('X-User-Role');
    
    if (!userId || !userRole) {
      return res.status(401).json({
        status: 'error',
        message: 'Access denied. User ID and Role required.'
      });
    }

    if (userRole !== 'patient') {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied. Patient authentication required.'
      });
    }

    const patient = await Patient.findById(userId);
    if (!patient || !patient.credentials.isActive) {
      return res.status(401).json({
        status: 'error',
        message: 'Patient account not found or inactive.'
      });
    }

    req.user = { id: userId, role: userRole };
    req.patient = patient;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid authentication.'
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
