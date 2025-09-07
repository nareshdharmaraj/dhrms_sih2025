const jwt = require('jsonwebtoken');

// Generate JWT token
const generateToken = (payload, expiresIn = process.env.JWT_EXPIRE) => {
  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
};

// Generate refresh token
const generateRefreshToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, { 
    expiresIn: process.env.JWT_REFRESH_EXPIRE 
  });
};

// Verify JWT token
const verifyToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};

// Generate response with tokens
const generateAuthResponse = (user, role) => {
  const payload = {
    id: user._id,
    role: role
  };

  const token = generateToken(payload);
  const refreshToken = generateRefreshToken(payload);

  return {
    token,
    refreshToken,
    user: {
      id: user._id,
      role: role,
      ...getPublicUserData(user, role)
    }
  };
};

// Get public user data based on role
const getPublicUserData = (user, role) => {
  switch (role) {
    case 'hospital':
      return {
        hospitalId: user.hospitalId,
        name: user.name,
        email: user.contactInfo.email
      };
    case 'doctor':
      return {
        doctorId: user.doctorId,
        name: `${user.personalInfo.firstName} ${user.personalInfo.lastName}`,
        email: user.personalInfo.email,
        specialization: user.professionalInfo.specialization
      };
    case 'patient':
      return {
        patientId: user.patientId,
        uhi: user.uhi,
        name: `${user.personalInfo.firstName} ${user.personalInfo.lastName}`,
        email: user.personalInfo.email
      };
    default:
      return {};
  }
};

module.exports = {
  generateToken,
  generateRefreshToken,
  verifyToken,
  generateAuthResponse,
  getPublicUserData
};
