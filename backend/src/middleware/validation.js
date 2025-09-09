// Simple validation middleware
const validateRegister = (req, res, next) => {
  const { username, email, password, fullName } = req.body;

  // Basic validation
  if (!username || !email || !password || !fullName) {
    return res.status(400).json({
      success: false,
      message: 'Username, email, password, and full name are required'
    });
  }

  // Email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      success: false,
      message: 'Please provide a valid email address'
    });
  }

  // Password validation
  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Password must be at least 6 characters long'
    });
  }

  next();
};

// Login validation
const validateLogin = (req, res, next) => {
  const { usernameOrEmail, password } = req.body;

  if (!usernameOrEmail || !password) {
    return res.status(400).json({
      success: false,
      message: 'Username/email and password are required'
    });
  }

  next();
};

// Patient registration validation
const validatePatientRegister = (req, res, next) => {
  const { 
    firstName, 
    lastName, 
    email, 
    password, 
    phone, 
    aadhaarNumber, 
    dateOfBirth, 
    gender, 
    address 
  } = req.body;

  // Required field validation
  if (!firstName || !lastName || !email || !password || !phone || !aadhaarNumber || !dateOfBirth || !gender) {
    return res.status(400).json({
      success: false,
      message: 'All required fields must be provided (firstName, lastName, email, password, phone, aadhaarNumber, dateOfBirth, gender)'
    });
  }

  // Email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      success: false,
      message: 'Please provide a valid email address'
    });
  }

  // Password validation
  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Password must be at least 6 characters long'
    });
  }

  // Aadhaar validation
  if (!/^\d{12}$/.test(aadhaarNumber)) {
    return res.status(400).json({
      success: false,
      message: 'Aadhaar number must be exactly 12 digits'
    });
  }

  // Phone validation
  if (!/^\d{10}$/.test(phone.replace(/[^\d]/g, ''))) {
    return res.status(400).json({
      success: false,
      message: 'Please provide a valid 10-digit phone number'
    });
  }

  // Gender validation
  if (!['male', 'female', 'other'].includes(gender.toLowerCase())) {
    return res.status(400).json({
      success: false,
      message: 'Gender must be male, female, or other'
    });
  }

  // Address validation
  if (!address || !address.street || !address.city || !address.state || !address.zipCode) {
    return res.status(400).json({
      success: false,
      message: 'Complete address (street, city, state, zipCode) is required'
    });
  }

  next();
};

// Hospital staff registration validation
const validateHospitalStaffRegister = (req, res, next) => {
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
    hospitalName,
    hospitalAddress
  } = req.body;

  // Required field validation
  if (!firstName || !lastName || !email || !password || !phone || !aadhaarNumber || 
      !dateOfBirth || !gender || !staffRole || !department || !hospitalName) {
    return res.status(400).json({
      success: false,
      message: 'All required fields must be provided'
    });
  }

  // Email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      success: false,
      message: 'Please provide a valid email address'
    });
  }

  // Password validation
  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Password must be at least 6 characters long'
    });
  }

  // Aadhaar validation
  if (!/^\d{12}$/.test(aadhaarNumber)) {
    return res.status(400).json({
      success: false,
      message: 'Aadhaar number must be exactly 12 digits'
    });
  }

  // Staff role validation
  const validRoles = ['doctor', 'nurse', 'admin', 'pharmacist', 'technician', 'assistant'];
  if (!validRoles.includes(staffRole.toLowerCase())) {
    return res.status(400).json({
      success: false,
      message: 'Invalid staff role'
    });
  }

  // Hospital address validation
  if (!hospitalAddress || !hospitalAddress.street || !hospitalAddress.city || !hospitalAddress.state) {
    return res.status(400).json({
      success: false,
      message: 'Complete hospital address is required'
    });
  }

  next();
};

// Regional officer registration validation
const validateRegionalOfficerRegister = (req, res, next) => {
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

  // Required field validation
  if (!firstName || !lastName || !email || !password || !phone || !aadhaarNumber || 
      !dateOfBirth || !gender || !officerRank || !employeeId || !department) {
    return res.status(400).json({
      success: false,
      message: 'All required fields must be provided'
    });
  }

  // Email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({
      success: false,
      message: 'Please provide a valid email address'
    });
  }

  // Password validation
  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'Password must be at least 6 characters long'
    });
  }

  // Aadhaar validation
  if (!/^\d{12}$/.test(aadhaarNumber)) {
    return res.status(400).json({
      success: false,
      message: 'Aadhaar number must be exactly 12 digits'
    });
  }

  // Officer rank validation
  const validRanks = ['assistant_health_officer', 'health_officer', 'district_health_officer', 'state_health_officer', 'regional_director'];
  if (!validRanks.includes(officerRank.toLowerCase())) {
    return res.status(400).json({
      success: false,
      message: 'Invalid officer rank'
    });
  }

  next();
};

module.exports = {
  validateRegister,
  validateLogin,
  validatePatientRegister,
  validateHospitalStaffRegister,
  validateRegionalOfficerRegister
};
