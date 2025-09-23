const express = require('express');
const { body, param, query } = require('express-validator');
const ZoneManagementController = require('../controllers/zoneManagementController');

const router = express.Router();

// Validation middleware
const validateZoneCreation = [
  body('zoneName')
    .trim()
    .notEmpty()
    .withMessage('Zone name is required')
    .isLength({ min: 3, max: 100 })
    .withMessage('Zone name must be between 3 and 100 characters'),
  
  body('state')
    .trim()
    .notEmpty()
    .withMessage('State is required'),
  
  body('district')
    .trim()
    .notEmpty()
    .withMessage('District is required'),
  
  body('areas')
    .optional()
    .isArray()
    .withMessage('Areas must be an array'),
  
  body('areas.*.areaName')
    .if(body('areas').exists())
    .trim()
    .notEmpty()
    .withMessage('Area name is required'),
  
  body('areas.*.population')
    .if(body('areas').exists())
    .optional()
    .isNumeric()
    .withMessage('Population must be a number'),
  
  body('zoneType')
    .optional()
    .isIn(['urban', 'rural', 'semi-urban', 'metropolitan'])
    .withMessage('Invalid zone type'),
  
  body('priority')
    .optional()
    .isIn(['high', 'medium', 'low'])
    .withMessage('Invalid priority level'),
  
  body('createdBy.shoId')
    .trim()
    .notEmpty()
    .withMessage('SHO ID is required'),
  
  body('createdBy.shoName')
    .trim()
    .notEmpty()
    .withMessage('SHO name is required')
];

const validateRHOAssignment = [
  body('rhoId')
    .trim()
    .notEmpty()
    .withMessage('RHO ID is required'),
  
  body('rhoName')
    .trim()
    .notEmpty()
    .withMessage('RHO name is required'),
  
  body('assignedBy')
    .trim()
    .notEmpty()
    .withMessage('Assigned by (SHO ID) is required')
];

const validateZoneUpdate = [
  body('zoneName')
    .optional()
    .trim()
    .isLength({ min: 3, max: 100 })
    .withMessage('Zone name must be between 3 and 100 characters'),
  
  body('zoneType')
    .optional()
    .isIn(['urban', 'rural', 'semi-urban', 'metropolitan'])
    .withMessage('Invalid zone type'),
  
  body('priority')
    .optional()
    .isIn(['high', 'medium', 'low'])
    .withMessage('Invalid priority level'),
  
  body('areas')
    .optional()
    .isArray()
    .withMessage('Areas must be an array')
];

const validateAreaAddition = [
  body('area.areaName')
    .trim()
    .notEmpty()
    .withMessage('Area name is required'),
  
  body('area.population')
    .optional()
    .isNumeric()
    .withMessage('Population must be a number'),
  
  body('area.isDenselyPopulated')
    .optional()
    .isBoolean()
    .withMessage('isDenselyPopulated must be a boolean')
];

const validateParams = [
  param('state')
    .trim()
    .notEmpty()
    .withMessage('State parameter is required'),
  
  param('district')
    .trim()
    .notEmpty()
    .withMessage('District parameter is required')
];

const validateZoneId = [
  param('zoneId')
    .trim()
    .notEmpty()
    .withMessage('Zone ID is required')
];

const validateRHOId = [
  param('rhoId')
    .trim()
    .notEmpty()
    .withMessage('RHO ID is required')
];

// Zone Management Routes

/**
 * @route   POST /api/zone-management/zones
 * @desc    Create a new zone
 * @access  Private (SHO only)
 */
router.post('/zones', validateZoneCreation, ZoneManagementController.createZone);

/**
 * @route   GET /api/zone-management/zones/:state/:district
 * @desc    Get all zones for a district
 * @access  Private
 */
router.get('/zones/:state/:district', validateParams, ZoneManagementController.getZonesByDistrict);

/**
 * @route   GET /api/zone-management/zones/rho/:rhoId
 * @desc    Get zones assigned to a specific RHO
 * @access  Private
 */
router.get('/zones/rho/:rhoId', validateRHOId, ZoneManagementController.getZonesByRHO);

/**
 * @route   GET /api/zone-management/zones/:state/:district/unassigned
 * @desc    Get unassigned zones for a district
 * @access  Private
 */
router.get('/zones/:state/:district/unassigned', validateParams, ZoneManagementController.getUnassignedZones);

/**
 * @route   GET /api/zone-management/areas/:state/:district/available
 * @desc    Get available areas for a district (not assigned to any zone)
 * @access  Private
 */
router.get('/areas/:state/:district/available', validateParams, ZoneManagementController.getAvailableAreas);

/**
 * @route   POST /api/zone-management/zones/:zoneId/assign-rho
 * @desc    Assign RHO to a zone
 * @access  Private (SHO only)
 */
router.post('/zones/:zoneId/assign-rho', 
  [...validateZoneId, ...validateRHOAssignment], 
  ZoneManagementController.assignRHOToZone
);

/**
 * @route   DELETE /api/zone-management/zones/:zoneId/unassign-rho
 * @desc    Unassign RHO from a zone
 * @access  Private (SHO only)
 */
router.delete('/zones/:zoneId/unassign-rho', validateZoneId, ZoneManagementController.unassignRHOFromZone);

/**
 * @route   PUT /api/zone-management/zones/:zoneId
 * @desc    Update zone details
 * @access  Private (SHO only)
 */
router.put('/zones/:zoneId', 
  [...validateZoneId, ...validateZoneUpdate], 
  ZoneManagementController.updateZone
);

/**
 * @route   POST /api/zone-management/zones/:zoneId/areas
 * @desc    Add area to zone
 * @access  Private (SHO only)
 */
router.post('/zones/:zoneId/areas', 
  [...validateZoneId, ...validateAreaAddition], 
  ZoneManagementController.addAreaToZone
);

/**
 * @route   DELETE /api/zone-management/zones/:zoneId/areas/:areaName
 * @desc    Remove area from zone
 * @access  Private (SHO only)
 */
router.delete('/zones/:zoneId/areas/:areaName', 
  [
    ...validateZoneId,
    param('areaName').trim().notEmpty().withMessage('Area name is required')
  ], 
  ZoneManagementController.removeAreaFromZone
);

/**
 * @route   DELETE /api/zone-management/zones/:zoneId
 * @desc    Delete (deactivate) a zone
 * @access  Private (SHO only)
 */
router.delete('/zones/:zoneId', validateZoneId, ZoneManagementController.deleteZone);

/**
 * @route   GET /api/zone-management/rho-assignment/:state/:district/:areaName
 * @desc    Get RHO assignment for a specific area
 * @access  Private
 */
router.get('/rho-assignment/:state/:district/:areaName', 
  [
    ...validateParams,
    param('areaName').trim().notEmpty().withMessage('Area name is required')
  ], 
  ZoneManagementController.getRHOForArea
);

/**
 * @route   GET /api/zone-management/dashboard/:state/:district
 * @desc    Get comprehensive zone management dashboard data
 * @access  Private (SHO only)
 */
router.get('/dashboard/:state/:district', validateParams, ZoneManagementController.getZoneManagementDashboard);

// Additional utility routes

/**
 * @route   GET /api/zone-management/zones/:zoneId/details
 * @desc    Get detailed information about a specific zone
 * @access  Private
 */
router.get('/zones/:zoneId/details', validateZoneId, async (req, res) => {
  try {
    const { zoneId } = req.params;
    
    const Zone = require('../models/Zone');
    const zone = await Zone.findOne({ zoneId, isActive: true });
    
    if (!zone) {
      return res.status(404).json({
        success: false,
        message: 'Zone not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Zone details retrieved successfully',
      data: zone
    });

  } catch (error) {
    console.error('Error getting zone details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get zone details',
      error: error.message
    });
  }
});

/**
 * @route   GET /api/zone-management/search/zones
 * @desc    Search zones by name or area
 * @access  Private
 */
router.get('/search/zones', [
  query('state').trim().notEmpty().withMessage('State is required'),
  query('district').trim().notEmpty().withMessage('District is required'),
  query('searchTerm').optional().trim().isLength({ min: 2 }).withMessage('Search term must be at least 2 characters')
], async (req, res) => {
  try {
    const { state, district, searchTerm } = req.query;
    
    const Zone = require('../models/Zone');
    
    let searchQuery = {
      state: state,
      district: district,
      isActive: true
    };

    if (searchTerm) {
      searchQuery.$or = [
        { zoneName: { $regex: searchTerm, $options: 'i' } },
        { 'areas.areaName': { $regex: searchTerm, $options: 'i' } },
        { zoneType: { $regex: searchTerm, $options: 'i' } }
      ];
    }

    const zones = await Zone.find(searchQuery).sort({ zoneName: 1 });

    res.status(200).json({
      success: true,
      message: 'Zone search completed successfully',
      data: zones
    });

  } catch (error) {
    console.error('Error searching zones:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search zones',
      error: error.message
    });
  }
});

/**
 * @route   GET /api/zone-management/statistics/:state/:district
 * @desc    Get zone statistics for a district
 * @access  Private
 */
router.get('/statistics/:state/:district', validateParams, async (req, res) => {
  try {
    const { state, district } = req.params;
    
    const Zone = require('../models/Zone');
    const stats = await Zone.getDistrictStats(state, district);

    res.status(200).json({
      success: true,
      message: 'Zone statistics retrieved successfully',
      data: stats[0] || {
        totalZones: 0,
        assignedZones: 0,
        unassignedZones: 0,
        assignmentPercentage: 0,
        totalAreas: 0,
        coveredAreas: 0,
        coveragePercentage: 0
      }
    });

  } catch (error) {
    console.error('Error getting zone statistics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get zone statistics',
      error: error.message
    });
  }
});

module.exports = router;