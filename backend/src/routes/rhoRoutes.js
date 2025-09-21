const express = require('express');
const { body } = require('express-validator');
const router = express.Router();

// Import middleware
const { rhoManagementAuth, rhoViewAuth, auditRHOOperation } = require('../middleware/rhoAuth');

// Import RHO controller
const {
  createRHO,
  getRHOsBySHO,
  getRHOById,
  updateRHO,
  deleteRHO,
  toggleRHOStatus,
  updateRHOPermissions,
  resetRHOPassword,
  getRHOStatistics,
  getAvailableDistricts,
  getMockRHOData,
  createRHOFromMockData,
  getDistrictAssignmentInfo,
  getAreaCoverageDetails
} = require('../controllers/rhoController');

// Validation rules for RHO creation
const createRHOValidation = [
  body('fullName')
    .trim()
    .isLength({ min: 2 })
    .withMessage('Full name must be at least 2 characters')
    .matches(/^[a-zA-Z\s.]+$/)
    .withMessage('Full name can only contain letters, spaces, and dots (e.g., "Dr. John Smith")'),
  
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  
  body('phone')
    .matches(/^[+]?[0-9]{10,15}$/)
    .withMessage('Please provide a valid phone number (10-15 digits)'),
  
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character from: @$!%*?& (e.g., "MyPass123!")'),
  
  body('assignedDistrict')
    .trim()
    .isLength({ min: 2 })
    .withMessage('Assigned district must be at least 2 characters'),
  
  body('assignedAreas')
    .optional()
    .isArray()
    .withMessage('Assigned areas must be an array')
    .custom((value) => {
      if (value && value.length > 0) {
        const isValidArray = value.every(area => 
          typeof area === 'string' && area.trim().length >= 2
        );
        if (!isValidArray) {
          throw new Error('Each assigned area must be a valid string with at least 2 characters');
        }
      }
      return true;
    }),
  
  body('assignedRegion')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Assigned region must be at least 2 characters'),
  
  body('regionCode')
    .optional()
    .trim()
    .isLength({ min: 2, max: 10 })
    .withMessage('Region code must be between 2 and 10 characters')
    .matches(/^[A-Z0-9\-]+$/)
    .withMessage('Region code can only contain uppercase letters, numbers, and hyphens'),
  
  body('districtCode')
    .optional()
    .trim()
    .isLength({ min: 2, max: 10 })
    .withMessage('District code must be between 2 and 10 characters')
    .matches(/^[A-Z0-9]+$/)
    .withMessage('District code can only contain uppercase letters and numbers'),
  
  body('qualification')
    .trim()
    .isLength({ min: 2 })
    .withMessage('Qualification must be at least 2 characters'),
  
  body('experience')
    .isInt({ min: 0, max: 50 })
    .withMessage('Experience must be a number between 0 and 50 years'),
  
  body('licenseNumber')
    .trim()
    .isLength({ min: 5 })
    .withMessage('License number must be at least 5 characters')
    .matches(/^[A-Z0-9\-\/]+$/)
    .withMessage('License number can only contain uppercase letters, numbers, hyphens, and forward slashes'),
  
  // Optional fields validation
  body('officeAddress.city')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Office city must be at least 2 characters'),
  
  body('officeAddress.zipCode')
    .optional()
    .matches(/^[0-9]{6}$/)
    .withMessage('ZIP code must be exactly 6 digits'),
  
  body('officePhone')
    .optional()
    .matches(/^[+]?[0-9]{10,15}$/)
    .withMessage('Office phone must be a valid phone number'),
  
  body('emergencyContact.name')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Emergency contact name must be at least 2 characters'),
  
  body('emergencyContact.phone')
    .optional()
    .matches(/^[+]?[0-9]{10,15}$/)
    .withMessage('Emergency contact phone must be a valid phone number'),
  
  body('emergencyContact.email')
    .optional()
    .isEmail()
    .withMessage('Emergency contact email must be valid'),
  
  body('staffLimits.maxDirectStaff')
    .optional()
    .isInt({ min: 1, max: 200 })
    .withMessage('Max direct staff must be between 1 and 200'),
  
  body('staffLimits.maxHospitalsOversight')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Max hospitals oversight must be between 1 and 100'),
  
  body('coverage.population')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Population must be a non-negative number'),
  
  body('coverage.areaKm2')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Area must be a non-negative number')
];

// Validation rules for RHO updates
const updateRHOValidation = [
  body('fullName')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Full name must be at least 2 characters'),
  
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  
  body('phone')
    .optional()
    .matches(/^[+]?[0-9]{10,15}$/)
    .withMessage('Please provide a valid phone number'),
  
  body('assignedRegion')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Assigned region must be at least 2 characters'),
  
  body('qualification')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Qualification must be at least 2 characters'),
  
  body('experience')
    .optional()
    .isInt({ min: 0, max: 50 })
    .withMessage('Experience must be between 0 and 50 years')
];

// Password reset validation
const passwordResetValidation = [
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters long')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character')
];

// Routes

// Get district assignment strategy and available areas
router.get('/districts/:district/assignment-info', 
  rhoViewAuth,
  auditRHOOperation('VIEW_DISTRICT_ASSIGNMENT_INFO'),
  getDistrictAssignmentInfo
);

// Get area coverage details for a specific area
router.get('/districts/:district/areas/:areaName', 
  rhoViewAuth,
  auditRHOOperation('VIEW_AREA_COVERAGE_DETAILS'),
  getAreaCoverageDetails
);

// Get available districts for RHO assignment
router.get('/districts', 
  rhoViewAuth,
  auditRHOOperation('VIEW_AVAILABLE_DISTRICTS'),
  getAvailableDistricts
);

// Get mock RHO data for testing/demo
router.get('/mock-data', 
  rhoViewAuth,
  auditRHOOperation('VIEW_MOCK_RHO_DATA'),
  getMockRHOData
);

// Create RHO from mock data
router.post('/create-from-mock', 
  rhoManagementAuth,
  auditRHOOperation('CREATE_RHO_FROM_MOCK'),
  createRHOFromMockData
);

// Get RHO statistics (dashboard data)
router.get('/statistics', 
  rhoViewAuth,
  auditRHOOperation('VIEW_RHO_STATISTICS'),
  getRHOStatistics
);

// Get all RHOs managed by current SHO
router.get('/', 
  rhoViewAuth,
  auditRHOOperation('VIEW_RHOS'),
  getRHOsBySHO
);

// Get specific RHO by ID
router.get('/:rhoId', 
  rhoViewAuth,
  auditRHOOperation('VIEW_RHO_DETAILS'),
  getRHOById
);

// Create new RHO (main endpoint)
router.post('/', 
  createRHOValidation,
  rhoManagementAuth,
  auditRHOOperation('CREATE_RHO'),
  createRHO
);

// Create new RHO (alternative endpoint for frontend compatibility)
router.post('/create', 
  createRHOValidation,
  rhoManagementAuth,
  auditRHOOperation('CREATE_RHO'),
  createRHO
);

// Update RHO details
router.put('/:rhoId', 
  updateRHOValidation,
  rhoManagementAuth,
  auditRHOOperation('UPDATE_RHO'),
  updateRHO
);

// Delete RHO
router.delete('/:rhoId', 
  rhoManagementAuth,
  auditRHOOperation('DELETE_RHO'),
  deleteRHO
);

// Toggle RHO active status
router.patch('/:rhoId/toggle-status', 
  rhoManagementAuth,
  auditRHOOperation('TOGGLE_RHO_STATUS'),
  toggleRHOStatus
);

// Update RHO permissions
router.patch('/:rhoId/permissions', 
  rhoManagementAuth,
  auditRHOOperation('UPDATE_RHO_PERMISSIONS'),
  updateRHOPermissions
);

// Reset RHO password
router.patch('/:rhoId/reset-password', 
  passwordResetValidation,
  rhoManagementAuth,
  auditRHOOperation('RESET_RHO_PASSWORD'),
  resetRHOPassword
);

module.exports = router;