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
  // Support both new and legacy field names
  body('name')
    .optional()
    .isLength({ min: 3, max: 50 })
    .withMessage('Name must be between 3 and 50 characters')
    .matches(/^[a-zA-Z0-9\s\.\-\_]+$/)
    .withMessage('Name can only contain letters, numbers, spaces, dots, hyphens, and underscores'),
  
  body('doctorName')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Doctor name must be between 2 and 100 characters')
    .matches(/^[a-zA-Z0-9\s\.\-\_]+$/)
    .withMessage('Doctor name can only contain letters, numbers, spaces, dots, hyphens, and underscores'),
  
  // Either name or doctorName must be provided
  body().custom((body) => {
    if (!body.name && !body.doctorName) {
      throw new Error('Name is required (provide either name or doctorName)');
    }
    return true;
  }),
  
  body('gender')
    .optional()
    .isIn(['Male', 'Female', 'Other'])
    .withMessage('Gender must be Male, Female, or Other'),
  
  body('dateOfBirth')
    .optional()
    .isISO8601()
    .withMessage('Date of birth must be a valid date')
    .custom((value) => {
      const age = (new Date().getFullYear()) - (new Date(value).getFullYear());
      if (age < 18 || age > 100) {
        throw new Error('Doctor must be between 18 and 100 years old');
      }
      return true;
    }),
  
  body('specializations')
    .optional()
    .isArray({ min: 1, max: 5 })
    .withMessage('Specializations must be an array with 1-5 items')
    .custom((specializations) => {
      const validSpecializations = [
        'General Medicine', 'Cardiology', 'Neurology', 'Orthopedics', 'Pediatrics',
        'Gynecology', 'Dermatology', 'Psychiatry', 'Surgery', 'Anesthesiology',
        'Emergency Medicine', 'Radiology', 'Pathology', 'Ophthalmology', 'ENT',
        'Urology', 'Nephrology', 'Pulmonology', 'Gastroenterology', 'Endocrinology',
        'Oncology', 'Rheumatology', 'Plastic Surgery', 'Neurosurgery', 'Cardiac Surgery'
      ];
      for (const spec of specializations) {
        if (!validSpecializations.includes(spec)) {
          throw new Error(`Invalid specialization: ${spec}`);
        }
      }
      return true;
    }),
  
  body('specialization')
    .optional()
    .isIn([
      'General Medicine', 'Cardiology', 'Neurology', 'Orthopedics', 'Pediatrics',
      'Gynecology', 'Dermatology', 'Psychiatry', 'Surgery', 'Anesthesiology',
      'Emergency Medicine', 'Radiology', 'Pathology', 'Ophthalmology', 'ENT',
      'Urology', 'Nephrology', 'Pulmonology', 'Gastroenterology', 'Endocrinology',
      'Oncology', 'Rheumatology', 'Plastic Surgery', 'Neurosurgery', 'Cardiac Surgery'
    ])
    .withMessage('Invalid specialization'),
  
  // Either specializations or specialization must be provided
  body().custom((body) => {
    if (!body.specializations && !body.specialization) {
      throw new Error('Specialization is required (provide either specializations array or specialization)');
    }
    return true;
  }),
  
  body('username')
    .optional()
    .isLength({ min: 3, max: 30 })
    .withMessage('Username must be between 3 and 30 characters')
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username can only contain letters, numbers, and underscores'),
  
  body('doctorId')
    .optional()
    .isLength({ min: 3, max: 30 })
    .withMessage('Doctor ID must be between 3 and 30 characters'),
  
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
    .isLength({ min: 10, max: 10 })
    .withMessage('Contact number must be exactly 10 digits')
    .isNumeric()
    .withMessage('Contact number must contain only numbers'),
  
  body('qualification')
    .optional()
    .isLength({ min: 2, max: 30 })
    .withMessage('Qualification must be between 2 and 30 characters'),
  
  body('experienceYears')
    .optional()
    .isInt({ min: 0, max: 50 })
    .withMessage('Experience years must be between 0 and 50'),
  
  body('availableTimings')
    .optional()
    .custom((value) => {
      // Allow pre-defined slots
      const predefinedSlots = ['9:00 AM - 12:00 PM', '12:00 PM - 3:00 PM', '3:00 PM - 6:00 PM', '6:00 PM - 9:00 PM', '24/7 Emergency', 'Flexible'];
      if (predefinedSlots.includes(value)) {
        return true;
      }
      
      // Allow custom time format: "HH:MM AM/PM - HH:MM AM/PM"
      const timePattern = /^(\d{1,2}:\d{2}\s?(AM|PM))\s?-\s?(\d{1,2}:\d{2}\s?(AM|PM))$/i;
      if (timePattern.test(value)) {
        return true;
      }
      
      // Allow flexible text formats for special cases
      if (value && value.length >= 5 && value.length <= 100) {
        return true;
      }
      
      throw new Error('Available timings must be in format "HH:MM AM/PM - HH:MM AM/PM" or one of the predefined slots');
    }),
  
  body('consultationFee')
    .optional()
    .isInt({ min: 0, max: 99999 })
    .withMessage('Consultation fee must be between 0 and 99999'),
  
  body('department')
    .optional()
    .isLength({ min: 2, max: 50 })
    .withMessage('Department must be between 2 and 50 characters'),
  
  // Legacy support
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