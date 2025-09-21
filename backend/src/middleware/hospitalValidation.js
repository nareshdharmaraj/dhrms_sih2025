const { body, validationResult } = require('express-validator');

// ==================== VALIDATION MIDDLEWARE ====================

/**
 * Handle validation errors
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  next();
};

/**
 * Validate hospital registration
 */
const validateHospitalRegistration = [
  body('hospitalName')
    .notEmpty()
    .withMessage('Hospital name is required')
    .isLength({ min: 2, max: 100 })
    .withMessage('Hospital name must be between 2 and 100 characters'),
  
  body('address.street')
    .notEmpty()
    .withMessage('Street address is required'),
  
  body('address.city')
    .notEmpty()
    .withMessage('City is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('City must be between 2 and 50 characters'),
  
  body('address.state')
    .notEmpty()
    .withMessage('State is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('State must be between 2 and 50 characters'),
  
  body('address.pincode')
    .notEmpty()
    .withMessage('Pincode is required')
    .isLength({ min: 6, max: 6 })
    .withMessage('Pincode must be 6 digits')
    .isNumeric()
    .withMessage('Pincode must contain only numbers'),
  
  body('contactNumber')
    .notEmpty()
    .withMessage('Contact number is required')
    .isMobilePhone('en-IN')
    .withMessage('Please provide a valid Indian mobile number'),
  
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  
  body('registrationNumber')
    .notEmpty()
    .withMessage('Hospital registration number is required')
    .isLength({ min: 5, max: 50 })
    .withMessage('Registration number must be between 5 and 50 characters'),
  
  body('licenseId')
    .notEmpty()
    .withMessage('Hospital license ID is required')
    .isLength({ min: 5, max: 50 })
    .withMessage('License ID must be between 5 and 50 characters'),
  
  body('hospitalType')
    .isIn(['Government', 'Private', 'Semi-Government', 'Trust', 'Corporate'])
    .withMessage('Invalid hospital type'),
  
  body('totalBeds')
    .optional()
    .isInt({ min: 1, max: 10000 })
    .withMessage('Total beds must be a number between 1 and 10000'),
  
  body('establishedYear')
    .optional()
    .isInt({ min: 1800, max: new Date().getFullYear() })
    .withMessage('Invalid establishment year'),
  
  // Admin details validation
  body('adminDetails.username')
    .notEmpty()
    .withMessage('Admin username is required')
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('adminDetails.password')
    .notEmpty()
    .withMessage('Admin password is required')
    .isLength({ min: 6, max: 50 })
    .withMessage('Password must be between 6 and 50 characters'),
  
  body('adminDetails.adminName')
    .notEmpty()
    .withMessage('Admin name is required')
    .isLength({ min: 2, max: 100 })
    .withMessage('Admin name must be between 2 and 100 characters')
    .matches(/^[a-zA-Z\s]+$/)
    .withMessage('Admin name can only contain letters and spaces'),
  
  body('adminDetails.adminEmail')
    .isEmail()
    .withMessage('Please provide a valid admin email address')
    .normalizeEmail(),
  
  body('adminDetails.adminPhone')
    .notEmpty()
    .withMessage('Admin phone number is required')
    .isMobilePhone('en-IN')
    .withMessage('Please provide a valid Indian mobile number'),
  
  handleValidationErrors
];

/**
 * Validate admin login
 */
const validateAdminLogin = [
  body('hospitalId')
    .notEmpty()
    .withMessage('Hospital ID is required'),
  
  body('username')
    .notEmpty()
    .withMessage('Username is required')
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  
  handleValidationErrors
];

/**
 * Validate doctor creation
 */
const validateDoctorCreation = [
  body('doctorName')
    .notEmpty()
    .withMessage('Doctor name is required')
    .isLength({ min: 2, max: 100 })
    .withMessage('Doctor name must be between 2 and 100 characters')
    .matches(/^[a-zA-Z\s\.]+$/)
    .withMessage('Doctor name can only contain letters, spaces, and dots'),
  
  body('username')
    .notEmpty()
    .withMessage('Username is required')
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required')
    .isLength({ min: 6, max: 50 })
    .withMessage('Password must be between 6 and 50 characters'),
  
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  
  body('contactNumber')
    .notEmpty()
    .withMessage('Contact number is required')
    .isMobilePhone('en-IN')
    .withMessage('Please provide a valid Indian mobile number'),
  
  body('specialization')
    .notEmpty()
    .withMessage('Specialization is required')
    .isIn([
      'General Medicine', 'Cardiology', 'Neurology', 'Orthopedics', 'Pediatrics',
      'Gynecology', 'Dermatology', 'Psychiatry', 'Surgery', 'Anesthesiology',
      'Emergency Medicine', 'Radiology', 'Pathology', 'Ophthalmology', 'ENT',
      'Urology', 'Nephrology', 'Pulmonology', 'Gastroenterology', 'Endocrinology',
      'Oncology', 'Rheumatology', 'Plastic Surgery', 'Neurosurgery', 'Cardiac Surgery'
    ])
    .withMessage('Invalid specialization'),
  
  body('department')
    .notEmpty()
    .withMessage('Department is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('Department must be between 2 and 50 characters'),
  
  body('qualifications')
    .optional()
    .isArray()
    .withMessage('Qualifications must be an array'),
  
  body('emergencyContact.name')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Emergency contact name must be between 2 and 100 characters'),
  
  body('emergencyContact.phone')
    .optional()
    .isMobilePhone('en-IN')
    .withMessage('Please provide a valid emergency contact phone number'),
  
  handleValidationErrors
];

/**
 * Validate assistant creation
 */
const validateAssistantCreation = [
  body('assistantName')
    .notEmpty()
    .withMessage('Assistant name is required')
    .isLength({ min: 2, max: 100 })
    .withMessage('Assistant name must be between 2 and 100 characters')
    .matches(/^[a-zA-Z\s\.]+$/)
    .withMessage('Assistant name can only contain letters, spaces, and dots'),
  
  body('username')
    .notEmpty()
    .withMessage('Username is required')
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required')
    .isLength({ min: 6, max: 50 })
    .withMessage('Password must be between 6 and 50 characters'),
  
  body('email')
    .isEmail()
    .withMessage('Please provide a valid email address')
    .normalizeEmail(),
  
  body('contactNumber')
    .notEmpty()
    .withMessage('Contact number is required')
    .isMobilePhone('en-IN')
    .withMessage('Please provide a valid Indian mobile number'),
  
  body('designation')
    .notEmpty()
    .withMessage('Designation is required')
    .isIn([
      'Medical Assistant', 'Nursing Assistant', 'Lab Assistant', 'Pharmacy Assistant',
      'Administrative Assistant', 'Ward Assistant', 'Emergency Assistant', 'OT Assistant',
      'Physiotherapy Assistant', 'Radiology Assistant', 'Reception Assistant', 'General Assistant'
    ])
    .withMessage('Invalid designation'),
  
  body('department')
    .notEmpty()
    .withMessage('Department is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('Department must be between 2 and 50 characters'),
  
  body('assignedDoctorId')
    .optional()
    .isLength({ min: 5, max: 50 })
    .withMessage('Invalid doctor ID format'),
  
  body('emergencyContact.name')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Emergency contact name must be between 2 and 100 characters'),
  
  body('emergencyContact.phone')
    .optional()
    .isMobilePhone('en-IN')
    .withMessage('Please provide a valid emergency contact phone number'),
  
  handleValidationErrors
];

/**
 * Validate doctor/assistant login
 */
const validateStaffLogin = [
  body('hospitalId')
    .notEmpty()
    .withMessage('Hospital ID is required'),
  
  body('username')
    .notEmpty()
    .withMessage('Username is required')
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  
  handleValidationErrors
];

/**
 * Validate password change
 */
const validatePasswordChange = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  
  body('newPassword')
    .notEmpty()
    .withMessage('New password is required')
    .isLength({ min: 6, max: 50 })
    .withMessage('New password must be between 6 and 50 characters'),
  
  handleValidationErrors
];

/**
 * Validate duty status update
 */
const validateDutyStatusUpdate = [
  body('dutyStatus')
    .notEmpty()
    .withMessage('Duty status is required')
    .isIn(['On Duty', 'Off Duty', 'Emergency Leave', 'Break', 'Sick Leave'])
    .withMessage('Invalid duty status'),
  
  handleValidationErrors
];

/**
 * Validate hospital search
 */
const validateHospitalSearch = [
  body('query')
    .optional()
    .isLength({ min: 1, max: 100 })
    .withMessage('Search query must be between 1 and 100 characters'),
  
  handleValidationErrors
];

/**
 * Validate schedule update
 */
const validateScheduleUpdate = [
  body('dutySchedule')
    .notEmpty()
    .withMessage('Duty schedule is required')
    .isObject()
    .withMessage('Duty schedule must be an object'),
  
  handleValidationErrors
];

/**
 * Custom validation for MongoDB ObjectId
 */
const isValidObjectId = (value) => {
  return /^[0-9a-fA-F]{24}$/.test(value);
};

/**
 * Validate hospital ID format
 */
const validateHospitalId = [
  body('hospitalId')
    .notEmpty()
    .withMessage('Hospital ID is required')
    .matches(/^HOSP_[A-Z0-9]{8}$/)
    .withMessage('Invalid hospital ID format'),
  
  handleValidationErrors
];

module.exports = {
  validateHospitalRegistration,
  validateAdminLogin,
  validateDoctorCreation,
  validateAssistantCreation,
  validateStaffLogin,
  validatePasswordChange,
  validateDutyStatusUpdate,
  validateHospitalSearch,
  validateScheduleUpdate,
  validateHospitalId,
  handleValidationErrors
};