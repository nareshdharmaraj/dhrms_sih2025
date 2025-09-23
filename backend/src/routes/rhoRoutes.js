const express = require('express');
const { body } = require('express-validator');
const router = express.Router();

// Import middleware
const { rhoManagementAuth, rhoViewAuth, auditRHOOperation } = require('../middleware/rhoAuth');
const { rhoAuth, rhoViewAccess, auditRHOSelfOperation } = require('../middleware/rhoSelfAuth');

// Import RHO controller
const {
  loginRHO,
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
  getAreaCoverageDetails,
  getPublicRHOs
} = require('../controllers/rhoController');

// Import RHO Hospital Approval controller
const {
  getPendingHospitals,
  getAllHospitalsInRegion,
  getHospitalDetails,
  approveHospital,
  rejectHospital,
  getHospitalStatistics
} = require('../controllers/rho_hospital_controller');

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

// Public Routes (No authentication required)

// Get active RHOs for hospital registration - NO AUTH REQUIRED
router.get('/public', getPublicRHOs);

// RHO Login - No authentication required for login
router.post('/login', [
  body('rhoId')
    .trim()
    .notEmpty()
    .withMessage('RHO ID is required'),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
  body('state')
    .optional()
    .trim()
], loginRHO);

// RHO Self-Service Routes (RHO accessing their own data)

// Get RHO's own statistics/dashboard data
router.get('/my/statistics', 
  rhoAuth,
  auditRHOSelfOperation('VIEW_SELF_STATISTICS'),
  async (req, res) => {
    try {
      const rho = await require('../models/RegionalHealthOfficer').findById(req.rho.rhoId)
        .populate('parentSHO', 'fullName officerId');
      
      if (!rho) {
        return res.status(404).json({
          success: false,
          message: 'RHO profile not found'
        });
      }

      // Process assigned areas with detailed information
      const assignedAreas = rho.assignedAreas.map(area => ({
        name: area.name,
        code: area.code,
        type: area.type,
        population: area.population || 0,
        areaKm2: area.areaKm2 || 0,
        healthFacilities: {
          primaryHealthCenters: Math.floor(area.population / 20000) || 1, // Estimated based on population
          communityHealthCenters: Math.floor(area.population / 80000) || 1,
          hospitals: Math.floor(area.population / 100000) || 1
        },
        coveragePercentage: Math.min(100, (area.population / 50000) * 100) || 85 // Default 85%
      }));

      // Calculate coverage summary
      const coverageSummary = {
        totalAreas: rho.assignedAreas.length,
        totalPopulation: rho.assignedAreas.reduce((sum, area) => sum + (area.population || 0), 0),
        totalAreaKm2: rho.assignedAreas.reduce((sum, area) => sum + (area.areaKm2 || 0), 0),
        primaryDistrict: rho.coverage?.primaryDistrict || rho.assignedDistrict,
        subDistricts: rho.coverage?.subDistricts || [],
        blocks: rho.coverage?.blocks || [],
        villages: rho.coverage?.villages || [],
        primaryHealthCenters: rho.coverage?.primaryHealthCenters || [],
        communityHealthCenters: rho.coverage?.communityHealthCenters || []
      };

      // Create dashboard data structure expected by Flutter
      const dashboardData = {
        populationCovered: coverageSummary.totalPopulation || rho.coverage?.population || 0,
        healthcareCenters: rho.statistics?.hospitalsOverseen || assignedAreas.reduce((sum, area) => sum + area.healthFacilities.hospitals, 0),
        emergencyServices: rho.statistics?.emergencyServices || 5, // Default fallback
        mobileUnits: rho.statistics?.mobileUnits || 2, // Default fallback
        totalStaffManaged: rho.statistics?.totalStaffManaged || 0,
        patientsServed: rho.statistics?.patientsServed || 0,
        
        // Enhanced coverage area information
        assignedAreas: assignedAreas,
        coverageSummary: coverageSummary,
        
        // Area-specific statistics
        areaStatistics: {
          averageCoveragePercentage: assignedAreas.length > 0 ? 
            assignedAreas.reduce((sum, area) => sum + area.coveragePercentage, 0) / assignedAreas.length : 0,
          totalHealthFacilities: assignedAreas.reduce((sum, area) => 
            sum + area.healthFacilities.primaryHealthCenters + 
            area.healthFacilities.communityHealthCenters + 
            area.healthFacilities.hospitals, 0),
          largestArea: assignedAreas.length > 0 ? 
            assignedAreas.reduce((max, area) => area.population > max.population ? area : max, assignedAreas[0]) : null,
          mostDenseArea: assignedAreas.length > 0 ? 
            assignedAreas.reduce((max, area) => 
              (area.population / (area.areaKm2 || 1)) > (max.population / (max.areaKm2 || 1)) ? area : max, assignedAreas[0]) : null
        },

        recentActivities: rho.activities || [
          {
            type: 'Area Inspection',
            location: assignedAreas.length > 0 ? assignedAreas[0].name : rho.assignedDistrict,
            timestamp: new Date().toISOString(),
            status: 'Completed'
          },
          {
            type: 'Health Facility Review',
            location: rho.assignedDistrict,
            timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(), // Yesterday
            status: 'In Progress'
          }
        ],
        profile: {
          officerId: rho.officerId,
          fullName: rho.fullName,
          assignedState: rho.assignedState,
          assignedDistrict: rho.assignedDistrict,
          assignedRegion: rho.assignedRegion,
          isActive: rho.isActive,
          lastLogin: rho.lastLogin
        }
      };

      res.json({
        success: true,
        message: 'Statistics retrieved successfully',
        data: dashboardData
      });
    } catch (error) {
      console.error('Get RHO self statistics error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error fetching statistics'
      });
    }
  }
);

// Get RHO's own profile
router.get('/my/profile', 
  rhoAuth,
  auditRHOSelfOperation('VIEW_SELF_PROFILE'),
  async (req, res) => {
    try {
      const rho = await require('../models/RegionalHealthOfficer').findById(req.rho.rhoId)
        .select('-password')
        .populate('parentSHO', 'fullName officerId assignedState');
      
      if (!rho) {
        return res.status(404).json({
          success: false,
          message: 'RHO profile not found'
        });
      }

      res.json({
        success: true,
        rho
      });
    } catch (error) {
      console.error('Get RHO self profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Server error fetching profile'
      });
    }
  }
);

// SHO Management Routes (SHO managing RHOs)

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

// ==================== RHO HOSPITAL APPROVAL ROUTES ====================

// Get pending hospitals for approval
router.get('/hospitals/pending', 
  rhoAuth,
  auditRHOSelfOperation('VIEW_PENDING_HOSPITALS'),
  getPendingHospitals
);

// Get all hospitals in RHO's region
router.get('/hospitals/all', 
  rhoAuth,
  auditRHOSelfOperation('VIEW_REGION_HOSPITALS'),
  getAllHospitalsInRegion
);

// Get hospital approval statistics
router.get('/hospitals/statistics', 
  rhoAuth,
  auditRHOSelfOperation('VIEW_HOSPITAL_STATISTICS'),
  getHospitalStatistics
);

// Get specific hospital details for review
router.get('/hospitals/:hospitalId/details', 
  rhoAuth,
  auditRHOSelfOperation('VIEW_HOSPITAL_DETAILS'),
  getHospitalDetails
);

// Approve hospital registration
router.post('/hospitals/:hospitalId/approve', 
  [
    body('comments').optional().isLength({ max: 1000 }).withMessage('Comments must not exceed 1000 characters'),
    body('assignedRO').optional().isMongoId().withMessage('Assigned RO must be a valid ID')
  ],
  rhoAuth,
  auditRHOSelfOperation('APPROVE_HOSPITAL'),
  approveHospital
);

// Reject hospital registration
router.post('/hospitals/:hospitalId/reject', 
  [
    body('comments').notEmpty().isLength({ min: 10, max: 1000 }).withMessage('Rejection comments are required (10-1000 characters)')
  ],
  rhoAuth,
  auditRHOSelfOperation('REJECT_HOSPITAL'),
  rejectHospital
);

module.exports = router;