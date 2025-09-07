// Simple auth utilities (no JWT)

// Generate simple auth response (no JWT)
const generateAuthResponse = (user, role) => {
  return {
    userId: user._id,
    role: role,
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
  generateAuthResponse,
  getPublicUserData
};
