const databaseService = require('../services/databaseService');
const uhiService = require('../services/uhiService');
const Patient = require('../models/Patient');
const HospitalStaff = require('../models/HospitalStaff');
const RegionalOfficer = require('../models/RegionalOfficer');

// Register a new user
const registerUser = async (req, res) => {
  try {
    const { username, email, password, fullName, phone, dateOfBirth, gender, address } = req.body;

    // Create user using database service
    const result = await databaseService.createUser({
      username,
      email,
      password,
      fullName,
      phone,
      dateOfBirth,
      gender,
      address
    });

    res.status(result.success ? 201 : 400).json(result);
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Login user
const loginUser = async (req, res) => {
  try {
    const { usernameOrEmail, password } = req.body;

    console.log('=== LOGIN DEBUG ===');
    console.log('Login request for:', usernameOrEmail);

    // Validate credentials using database service
    const result = await databaseService.validateUserCredentials(usernameOrEmail, password);
    
    console.log('Database service result:', JSON.stringify(result, null, 2));
    console.log('=== END LOGIN DEBUG ===');
    
    res.status(result.success ? 200 : 401).json(result);
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Logout user (simple implementation)
const logout = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Refresh token (placeholder)
const refreshToken = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Token refreshed (placeholder)'
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Forgot password (placeholder)
const forgotPassword = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Password reset instructions sent (placeholder)'
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Reset password (placeholder)
const resetPassword = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Password reset successfully (placeholder)'
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Verify email (placeholder)
const verifyEmail = async (req, res) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Email verified successfully (placeholder)'
    });
  } catch (error) {
    console.error('Verify email error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Register Patient with UHI generation
const registerPatient = async (req, res) => {
  try {
    console.log('=== REGISTRATION DEBUG START ===');
    console.log('Received request body:', JSON.stringify(req.body, null, 2));
    
    const {
      firstName,
      lastName,
      email,
      password,
      phone,
      aadhaarNumber,
      dateOfBirth,
      gender,
      bloodGroup,
      address,
      emergencyContact,
      workLocation,
      employerName,
      workPermitNumber,
      homeState,
      photo
    } = req.body;

    console.log('Extracted fields:');
    console.log('- firstName:', firstName);
    console.log('- lastName:', lastName);
    console.log('- email:', email);
    console.log('- phone:', phone);
    console.log('- aadhaarNumber:', aadhaarNumber);
    console.log('- dateOfBirth:', dateOfBirth);
    console.log('- gender:', gender);
    console.log('- bloodGroup:', bloodGroup);
    console.log('- address:', JSON.stringify(address));
    console.log('- emergencyContact:', JSON.stringify(emergencyContact));
    console.log('- homeState:', homeState);
    console.log('- photo length:', photo ? photo.length : 'null/undefined');

    // Check if email or aadhaar already exists
    const existingPatient = await Patient.findOne({
      $or: [
        { email: email && email.trim() !== '' ? email : null }, 
        { aadhaarNumber }
      ].filter(Boolean) // Remove null entries
    });

    if (existingPatient) {
      return res.status(400).json({
        success: false,
        message: 'Patient with this email or Aadhaar number already exists'
      });
    }

    // Generate unique UHID (but model expects 'uhid')
    const uhid = await uhiService.generateUHIWithContext({
      firstName,
      aadhaarNumber,
      dateOfBirth,
      role: 'patient'
    });

    console.log('Generated UHID:', uhid);

    // Create patient record with proper field names
    const patientData = {
      uhid, // Use 'uhid' not 'uhi' 
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      fullName: `${firstName?.trim() || ''} ${lastName?.trim() || ''}`.trim(),
      email: email?.toLowerCase().trim() || undefined, // Handle empty email properly
      password, // Note: In production, this should be hashed
      phone: phone?.trim(),
      aadhaarNumber: aadhaarNumber?.trim(),
      dateOfBirth: new Date(dateOfBirth),
      gender: gender?.toLowerCase(),
      bloodGroup,
      address,
      emergencyContact,
      workLocation,
      employerName,
      workPermitNumber,
      homeState,
      photo, // Include photo from request
      // Let the model pre-save hook generate username from uhid
      registrationDate: new Date()
    };

    console.log('Patient data to save:', JSON.stringify(patientData, null, 2));

    const patient = new Patient(patientData);
    await patient.save();

    console.log('Patient saved successfully:', {
      id: patient._id,
      uhid: patient.uhid,
      username: patient.username,
      fullName: patient.fullName
    });
    console.log('=== REGISTRATION DEBUG END ===');

    // Return success response with proper data
    res.status(201).json({
      success: true,
      message: 'Patient registered successfully with digital health card',
      patient: {
        uhid: patient.uhid,
        username: patient.username, // This will be generated by model (same as UHID)
        fullName: patient.fullName,
        email: patient.email,
        phone: patient.phone,
        digitalCard: patient.digitalCard,
        registrationDate: patient.registrationDate
      },
      uhid: patient.uhid // For backward compatibility with frontend
    });

  } catch (error) {
    console.error('Patient registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register patient'
    });
  }
};

// Register Hospital Staff with UHI generation
const registerHospitalStaff = async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      email,
      password,
      phone,
      aadhaarNumber,
      dateOfBirth,
      gender,
      staffRole,
      department,
      specialization,
      licenseNumber,
      yearsOfExperience,
      hospitalName,
      hospitalId,
      hospitalAddress
    } = req.body;

    // Check if email or aadhaar already exists
    const existingStaff = await HospitalStaff.findOne({
      $or: [{ email }, { aadhaarNumber }]
    });

    if (existingStaff) {
      return res.status(400).json({
        success: false,
        message: 'Hospital staff with this email or Aadhaar number already exists'
      });
    }

    // Generate unique UHI
    const uhi = await uhiService.generateUHIWithContext({
      firstName,
      aadhaarNumber,
      dateOfBirth,
      role: 'hospital_staff'
    });

    // Create hospital staff record
    const staff = new HospitalStaff({
      uhi,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      fullName: `${firstName.trim()} ${lastName.trim()}`,
      email: email.toLowerCase().trim(),
      password, // Note: In production, this should be hashed
      phone: phone.trim(),
      aadhaarNumber: aadhaarNumber.trim(),
      dateOfBirth: new Date(dateOfBirth),
      gender: gender.toLowerCase(),
      staffRole: staffRole.toLowerCase(),
      department,
      specialization,
      licenseNumber,
      yearsOfExperience,
      hospitalName,
      hospitalId,
      hospitalAddress,
      username: email.toLowerCase().trim(),
      registrationDate: new Date()
    });

    await staff.save();

    // Return success response with UHI
    res.status(201).json({
      success: true,
      message: 'Hospital staff registered successfully',
      data: {
        uhi,
        fullName: staff.fullName,
        email: staff.email,
        staffRole: staff.staffRole,
        department: staff.department,
        hospitalName: staff.hospitalName,
        registrationDate: staff.registrationDate
      }
    });

  } catch (error) {
    console.error('Hospital staff registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register hospital staff'
    });
  }
};

// Register Regional Officer with UHI generation
const registerRegionalOfficer = async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      email,
      password,
      phone,
      aadhaarNumber,
      dateOfBirth,
      gender,
      officerRank,
      employeeId,
      department,
      jurisdiction
    } = req.body;

    // Check if email, aadhaar, or employeeId already exists
    const existingOfficer = await RegionalOfficer.findOne({
      $or: [{ email }, { aadhaarNumber }, { employeeId }]
    });

    if (existingOfficer) {
      return res.status(400).json({
        success: false,
        message: 'Regional officer with this email, Aadhaar number, or employee ID already exists'
      });
    }

    // Generate unique UHI
    const uhi = await uhiService.generateUHIWithContext({
      firstName,
      aadhaarNumber,
      dateOfBirth,
      role: 'regional_officer'
    });

    // Create regional officer record
    const officer = new RegionalOfficer({
      uhi,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      fullName: `${firstName.trim()} ${lastName.trim()}`,
      email: email.toLowerCase().trim(),
      password, // Note: In production, this should be hashed
      phone: phone.trim(),
      aadhaarNumber: aadhaarNumber.trim(),
      dateOfBirth: new Date(dateOfBirth),
      gender: gender.toLowerCase(),
      officerRank: officerRank.toLowerCase(),
      employeeId: employeeId.trim(),
      department,
      jurisdiction,
      username: email.toLowerCase().trim(),
      registrationDate: new Date()
    });

    await officer.save();

    // Return success response with UHI
    res.status(201).json({
      success: true,
      message: 'Regional officer registered successfully',
      data: {
        uhi,
        fullName: officer.fullName,
        email: officer.email,
        officerRank: officer.officerRank,
        employeeId: officer.employeeId,
        department: officer.department,
        registrationDate: officer.registrationDate
      }
    });

  } catch (error) {
    console.error('Regional officer registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register regional officer'
    });
  }
};

module.exports = {
  registerUser,
  loginUser,
  logout,
  refreshToken,
  forgotPassword,
  resetPassword,
  verifyEmail,
  registerPatient,
  registerHospitalStaff,
  registerRegionalOfficer
};
