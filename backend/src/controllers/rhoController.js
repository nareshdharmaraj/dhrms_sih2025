const RegionalHealthOfficer = require('../models/RegionalHealthOfficer');
const StateHealthOfficer = require('../models/StateHealthOfficer');
const { validationResult } = require('express-validator');
const { 
  DISTRICT_MAPPING, 
  MOCK_RHO_DATA, 
  generateMockStaffData,
  getDistrictsByState,
  getRegionByDistrict,
  generateDistrictCode,
  generateRegionCode 
} = require('../services/districtMockDataService');
const { AreaAssignmentService } = require('../services/areaAssignmentService');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// RHO Login - Authenticate using RHO ID and state
const loginRHO = async (req, res) => {
  try {
    const { rhoId, password, state } = req.body;

    console.log('🔐 RHO Login attempt:', { rhoId, state });

    if (!rhoId || !password) {
      return res.status(400).json({
        success: false,
        message: 'RHO ID and password are required'
      });
    }

    // Find RHO by officerId and optionally by state
    const query = { officerId: rhoId };
    if (state) {
      query.assignedState = state;
    }

    const rho = await RegionalHealthOfficer.findOne(query);

    if (!rho) {
      console.log('❌ RHO not found:', { rhoId, state });
      return res.status(401).json({
        success: false,
        message: 'Invalid RHO ID or password'
      });
    }

    // Check if RHO is active
    if (!rho.isActive) {
      console.log('❌ RHO account is deactivated:', rhoId);
      return res.status(401).json({
        success: false,
        message: 'Account is deactivated. Please contact your State Health Officer.'
      });
    }

    // Validate password
    const isValidPassword = await bcrypt.compare(password, rho.password);
    if (!isValidPassword) {
      console.log('❌ Invalid password for RHO:', rhoId);
      return res.status(401).json({
        success: false,
        message: 'Invalid RHO ID or password'
      });
    }

    // Update last login
    rho.lastLogin = new Date();
    await rho.save();

    // Generate JWT token
    const token = jwt.sign(
      { 
        rhoId: rho.officerId,
        id: rho._id,
        userType: 'RHO',
        state: rho.assignedState,
        district: rho.assignedDistrict
      },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    console.log('✅ RHO login successful:', rhoId);

    res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      rho: {
        id: rho._id,
        rhoId: rho.officerId,
        fullName: rho.fullName,
        email: rho.email,
        state: rho.assignedState,
        district: rho.assignedDistrict,
        zone: rho.zone,
        areas: rho.areas,
        isActive: rho.isActive,
        lastLogin: rho.lastLogin
      }
    });

  } catch (error) {
    console.error('RHO login error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Generate unique RHO Officer ID with area support
const generateRHOId = async (state, district, areaName = null) => {
  try {
    // Use the new area-based ID generation
    return await AreaAssignmentService.generateAreaBasedRHOId(state, district, areaName);
  } catch (error) {
    console.error('Error generating RHO ID:', error);
    throw new Error('Failed to generate RHO ID');
  }
};

// Create Regional Health Officer
const createRHO = async (req, res) => {
  try {
    console.log('🚀 Creating new RHO by SHO:', req.sho?.fullName);
    
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('❌ Validation errors:', errors.array());
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const {
      fullName,
      email,
      phone,
      password,
      assignedDistrict,
      assignedAreas, // New field for area-specific assignment
      assignedRegion,
      regionCode,
      districtCode,
      qualification,
      experience,
      licenseNumber,
      officeAddress,
      officePhone,
      emergencyContact,
      staffLimits,
      coverage
    } = req.body;

    // Initialize variables for zone area extraction
    let zoneAreas = []; // To store areas from assigned zone

    // Verify the SHO can create RHOs in their assigned state only
    const shoData = await StateHealthOfficer.findById(req.sho.shoId);
    if (!shoData) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    // Validate district assignment
    const availableDistricts = getDistrictsByState(shoData.assignedState);
    if (!availableDistricts.includes(assignedDistrict)) {
      return res.status(400).json({
        success: false,
        message: `Invalid district. Available districts for ${shoData.assignedState}: ${availableDistricts.join(', ')}`
      });
    }

    // Check for existing zones in the district
    const Zone = require('../models/Zone');
    const existingZones = await Zone.find({
      state: shoData.assignedState,
      district: assignedDistrict,
      isActive: true
    });

    // CRITICAL FIX: Extract zone areas BEFORE validation if zone assignment is specified
    if (req.body.assignToZone && req.body.zoneId) {
      try {
        const targetZone = await Zone.findOne({ 
          zoneId: req.body.zoneId, 
          state: shoData.assignedState,
          district: assignedDistrict,
          isActive: true 
        });
        
        if (targetZone && targetZone.areas && targetZone.areas.length > 0) {
          zoneAreas = targetZone.areas.map(area => ({
            name: area.areaName,
            code: area.areaCode || area.areaName.substring(0, 3).toUpperCase(),
            type: 'area',
            population: area.population || 0,
            areaKm2: area.areaKm2 || 0,
            isDenselyPopulated: area.isDenselyPopulated || false,
            zoneAreaId: area._id ? area._id.toString() : (area.id ? area.id.toString() : '')
          }));
          console.log(`✅ Pre-extracted ${zoneAreas.length} areas from zone ${targetZone.zoneName} for validation:`, 
                     zoneAreas.map(a => `${a.name} (${a.code}) - Dense: ${a.isDenselyPopulated}`).join(', '));
        } else {
          console.warn(`⚠️ Zone ${req.body.zoneId} not found or has no areas`);
        }
      } catch (error) {
        console.warn('⚠️ Failed to pre-extract zone areas:', error.message);
      }
    }

    // Validate area assignment using the new service
    const areaValidation = await AreaAssignmentService.validateAreaAssignment(
      shoData.assignedState, 
      assignedDistrict, 
      assignedAreas
    );
    
    if (!areaValidation.isValid) {
      return res.status(400).json({
        success: false,
        message: 'Area assignment validation failed',
        errors: areaValidation.errors
      });
    }

    // If this is a dense district and zones exist, suggest zone-based assignment
    let zoneAssignmentSuggestion = null;
    if (areaValidation.strategy.isDense && existingZones.length > 0) {
      const unassignedZones = existingZones.filter(zone => 
        !zone.assignedRHO || !zone.assignedRHO.rhoId
      );
      
      if (unassignedZones.length > 0) {
        zoneAssignmentSuggestion = {
          hasUnassignedZones: true,
          unassignedZones: unassignedZones.map(zone => ({
            zoneId: zone.zoneId,
            zoneName: zone.zoneName,
            areas: zone.areas.map(area => area.areaName),
            priority: zone.priority
          })),
          message: 'Unassigned zones available for RHO assignment'
        };
      }
    }

    // Auto-generate region and codes if not provided
    const autoRegion = assignedRegion || getRegionByDistrict(shoData.assignedState, assignedDistrict);
    const autoDistrictCode = districtCode || generateDistrictCode(assignedDistrict);
    const autoRegionCode = regionCode || generateRegionCode(shoData.assignedState, autoRegion);

    // Generate unique RHO ID with area support
    const primaryArea = assignedAreas && assignedAreas.length > 0 ? assignedAreas[0] : null;
    const officerId = await generateRHOId(shoData.assignedState, assignedDistrict, primaryArea);
    console.log('📋 Generated RHO ID:', officerId);

    // Check if email or license number already exists
    const existingRHO = await RegionalHealthOfficer.findOne({
      $or: [
        { email: email.toLowerCase() },
        { licenseNumber }
      ]
    });

    if (existingRHO) {
      let errorMessage = 'Regional Health Officer already exists for this ';
      if (existingRHO.email === email.toLowerCase()) {
        errorMessage += 'email address';
      } else if (existingRHO.licenseNumber === licenseNumber) {
        errorMessage += 'license number';
      }
      
      return res.status(400).json({
        success: false,
        message: errorMessage
      });
    }

    // Build assigned areas data
    let processedAreas = [];
    
    // First priority: Use areas extracted from assigned zone
    if (zoneAreas.length > 0) {
      processedAreas = zoneAreas;
      console.log(`📍 Using ${zoneAreas.length} areas from assigned zone for RHO.assignedAreas`);
    } 
    // Second priority: Use areas provided in request (for dense districts)
    else if (areaValidation.strategy.isDense && assignedAreas && assignedAreas.length > 0) {
      // For dense districts with specific areas
      assignedAreas.forEach(areaName => {
        const areaData = AreaAssignmentService.getAreaByName(assignedDistrict, areaName);
        if (areaData) {
          processedAreas.push({
            name: areaData.name,
            code: areaData.code,
            type: 'area',
            population: areaData.population,
            areaKm2: areaData.areaKm2,
            isDenselyPopulated: true, // Dense districts have dense areas
            zoneAreaId: '' // Manual assignment, no zone reference
          });
        }
      });
    } 
    // ERROR: Dense districts without zone assignment or specific areas
    else if (areaValidation.strategy.isDense) {
      console.error('❌ Dense district RHO creation failed: No zone areas extracted and no specific areas provided');
      return res.status(400).json({
        success: false,
        message: 'Dense districts require zone-based area assignment or specific area selection. Please assign RHO to a zone or specify areas.',
        details: {
          district: assignedDistrict,
          strategy: 'dense',
          zoneAreasExtracted: zoneAreas.length,
          specificAreasProvided: assignedAreas ? assignedAreas.length : 0
        }
      });
    }
    // Default: For sparse districts only - full district assignment
    else {
      processedAreas.push({
        name: 'Full District',
        code: autoDistrictCode,
        type: 'full-district',
        population: coverage?.population || 0,
        areaKm2: coverage?.areaKm2 || 0,
        isDenselyPopulated: false,
        zoneAreaId: ''
      });
    }

    // Get coverage data based on assigned areas
    const areaCoverage = AreaAssignmentService.getCoverageForAreas(assignedDistrict, assignedAreas || []);
    
    // If we have zone areas, include them in subDistricts
    const zoneSubDistricts = zoneAreas.length > 0 ? zoneAreas.map(area => area.name) : [];
    
    // Merge with any provided coverage data
    const finalCoverage = {
      primaryDistrict: assignedDistrict.trim(),
      subDistricts: coverage?.subDistricts || areaCoverage.subDistricts || zoneSubDistricts,
      blocks: coverage?.blocks || areaCoverage.blocks,
      villages: coverage?.villages || areaCoverage.villages,
      primaryHealthCenters: coverage?.primaryHealthCenters || [],
      communityHealthCenters: coverage?.communityHealthCenters || [],
      population: coverage?.population || areaCoverage.population,
      areaKm2: coverage?.areaKm2 || areaCoverage.areaKm2,
      ruralPopulation: coverage?.ruralPopulation || areaCoverage.ruralPopulation,
      urbanPopulation: coverage?.urbanPopulation || areaCoverage.urbanPopulation
    };

    // Create new RHO with area-based assignment
    const newRHO = new RegionalHealthOfficer({
      officerId,
      username: officerId, // Use officerId as username
      fullName: fullName.trim(),
      email: email.toLowerCase(),
      phone,
      password, // Will be hashed by pre-save middleware
      assignedState: shoData.assignedState,
      assignedDistrict: assignedDistrict.trim(),
      assignedAreas: processedAreas,
      assignedRegion: autoRegion.trim(),
      regionCode: autoRegionCode.trim(),
      districtCode: autoDistrictCode.trim(),
      parentSHO: req.sho.shoId,
      qualification,
      experience: parseInt(experience),
      licenseNumber,
      
      // Optional fields with defaults
      staffLimits: {
        maxDirectStaff: staffLimits?.maxDirectStaff || 50,
        maxHospitalsOversight: staffLimits?.maxHospitalsOversight || 20,
        maxRegionsManaged: staffLimits?.maxRegionsManaged || 5
      },
      
      coverage: finalCoverage,
      
      officeAddress: {
        buildingName: officeAddress?.buildingName || '',
        street: officeAddress?.street || '',
        city: officeAddress?.city || assignedDistrict,
        state: shoData.assignedState,
        zipCode: officeAddress?.zipCode || '',
        country: 'India'
      },
      
      officePhone: officePhone || phone,
      
      emergencyContact: emergencyContact || {},
      
      // Set created by current SHO
      createdBy: req.sho.shoId,
      
      // Initialize statistics with frontend-expected structure
      statistics: {
        totalStaffManaged: 0,
        hospitalsOverseen: 0,
        patientsServed: 0,
        emergencyResponsesHandled: 0,
        reportsGenerated: 0,
        performanceRating: 3,
        // Frontend expected fields
        totalStaff: 0,
        activeStaff: 0,
        totalPatients: 0,
        monthlyPatients: 0
      },
      
      // Default permissions - can be customized later
      permissions: {
        canViewHospitals: true,
        canManageHospitalStaff: true,
        canViewHospitalReports: true,
        canViewPatientData: true,
        canAccessMedicalRecords: false, // Restricted by default
        canGenerateReports: true,
        canViewRegionalStats: true,
        canInitiateEmergencyResponse: true,
        canAccessEmergencyContacts: true,
        canManageProfile: true,
        canChangePassword: true
      }
    });

    await newRHO.save();
    console.log('✅ RHO created successfully:', officerId);
    console.log('📍 Assigned areas:', processedAreas.map(a => a.name).join(', '));

    // Auto-assign to zone if specified in request
    let zoneAssignment = null;
    if (req.body.assignToZone && req.body.zoneId) {
      try {
        const targetZone = await Zone.findOne({ 
          zoneId: req.body.zoneId, 
          state: shoData.assignedState,
          district: assignedDistrict,
          isActive: true 
        });
        
        if (targetZone && (!targetZone.assignedRHO || !targetZone.assignedRHO.rhoId)) {
          await targetZone.assignRHO(officerId, fullName.trim(), req.sho.shoId);
          
          zoneAssignment = {
            zoneId: targetZone.zoneId,
            zoneName: targetZone.zoneName,
            assignmentStatus: 'success',
            areasExtracted: zoneAreas.length
          };
          console.log('✅ RHO automatically assigned to zone:', targetZone.zoneName);
        } else if (!targetZone) {
          zoneAssignment = {
            assignmentStatus: 'failed',
            error: 'Zone not found or inactive'
          };
        } else {
          zoneAssignment = {
            assignmentStatus: 'failed',
            error: 'Zone already assigned to another RHO'
          };
        }
      } catch (zoneError) {
        console.warn('⚠️ Zone assignment failed:', zoneError.message);
        zoneAssignment = {
          assignmentStatus: 'failed',
          error: zoneError.message
        };
      }
    }

    // Return RHO data without password
    const rhoResponse = await RegionalHealthOfficer.findById(newRHO._id)
      .select('-password')
      .populate('parentSHO', 'fullName officerId assignedState');

    res.status(201).json({
      success: true,
      message: 'Regional Health Officer created successfully',
      rho: rhoResponse,
      assignmentInfo: {
        districtType: areaValidation.strategy.isDense ? 'dense' : 'sparse',
        assignmentType: areaValidation.strategy.assignmentType,
        areasAssigned: processedAreas.map(a => a.name)
      },
      zoneInfo: {
        suggestion: zoneAssignmentSuggestion,
        assignment: zoneAssignment
      },
      loginCredentials: {
        officerId,
        username: newRHO.username,
        temporaryPassword: 'Note: Password has been set as provided'
      }
    });

  } catch (error) {
    console.error('Create RHO error:', error);
    
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Regional Health Officer with this email or license number already exists'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error creating Regional Health Officer'
    });
  }
};

// Get all RHOs managed by current SHO
const getRHOsBySHO = async (req, res) => {
  try {
    console.log('📋 Getting RHOs for SHO:', req.sho?.fullName);
    console.log('📋 SHO assigned state:', req.sho?.assignedState);
    
    const { page = 1, limit = 10, status, search, region } = req.query;
    
    // Build filter - show ALL RHOs in the SHO's assigned state
    // Removed parentSHO filter so SHO can see all RHOs in their state
    let filter = { 
      assignedState: req.sho.assignedState 
    };
    
    console.log('📋 Base filter for RHOs:', filter);
    
    // Add status filter
    if (status) {
      filter.isActive = status === 'active';
    }
    
    // Add region filter
    if (region && region !== 'all') {
      filter.assignedRegion = { $regex: region, $options: 'i' };
    }
    
    // Add search filter
    if (search) {
      filter.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { officerId: { $regex: search, $options: 'i' } },
        { assignedRegion: { $regex: search, $options: 'i' } }
      ];
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Get RHOs with pagination
    const [rhos, total] = await Promise.all([
      RegionalHealthOfficer.find(filter)
        .select('-password')
        .populate('parentSHO', 'fullName officerId')
        .skip(skip)
        .limit(parseInt(limit))
        .sort({ createdAt: -1 }),
      RegionalHealthOfficer.countDocuments(filter)
    ]);

    // Map RHO data to match frontend expectations
    const mappedRHOs = rhos.map(rho => {
      const rhoObj = rho.toObject();
      
      // Format assignedAreas to match Flutter expectations
      rhoObj.assignedAreas = (rhoObj.assignedAreas || []).map(area => ({
        name: String(area.name || ''),
        code: String(area.code || ''),
        type: String(area.type || 'area'),
        population: Number(area.population || 0),
        areaKm2: Number(area.areaKm2 || 0),
        healthFacilities: {
          primaryHealthCenters: Math.floor((Number(area.population) || 0) / 20000) || 1,
          communityHealthCenters: Math.floor((Number(area.population) || 0) / 80000) || 1,
          hospitals: Math.floor((Number(area.population) || 0) / 100000) || 1
        },
        coveragePercentage: Math.min(100, ((Number(area.population) || 0) / 50000) * 100) || 85
      }));
      
      // If no specific areas assigned, create a default full-district assignment
      if (rhoObj.assignedAreas.length === 0) {
        rhoObj.assignedAreas = [{
          name: `Full District`,
          code: rhoObj.districtCode || 'FD',
          type: 'full-district',
          population: 0,
          areaKm2: 0,
          healthFacilities: {
            primaryHealthCenters: 1,
            communityHealthCenters: 1,
            hospitals: 1
          },
          coveragePercentage: 85
        }];
      }
      
      // Map statistics fields to match frontend expectations
      rhoObj.statistics = {
        totalStaff: rhoObj.statistics?.totalStaffManaged || 0,
        activeStaff: rhoObj.statistics?.totalStaffManaged || 0, // Assuming all managed staff are active
        totalPatients: rhoObj.statistics?.patientsServed || 0,
        monthlyPatients: Math.floor((rhoObj.statistics?.patientsServed || 0) / 12), // Rough estimate
        ...rhoObj.statistics // Keep other fields
      };
      
      // Map staffLimits fields to match frontend expectations
      rhoObj.staffLimits = {
        maxDoctors: Math.floor((rhoObj.staffLimits?.maxDirectStaff || 50) * 0.3), // 30% doctors
        maxNurses: Math.floor((rhoObj.staffLimits?.maxDirectStaff || 50) * 0.4), // 40% nurses
        maxLabAssistants: Math.floor((rhoObj.staffLimits?.maxDirectStaff || 50) * 0.15), // 15% lab assistants
        maxPharmacists: Math.floor((rhoObj.staffLimits?.maxDirectStaff || 50) * 0.15), // 15% pharmacists
        ...rhoObj.staffLimits // Keep other fields
      };
      
      // Ensure coverage fields match expectations - properly format all arrays and strings
      rhoObj.coverage = {
        districts: [rhoObj.assignedDistrict].filter(Boolean),
        subDistricts: Array.isArray(rhoObj.coverage?.subDistricts) ? rhoObj.coverage.subDistricts : [],
        blocks: Array.isArray(rhoObj.coverage?.blocks) ? rhoObj.coverage.blocks : [],
        villages: Array.isArray(rhoObj.coverage?.villages) ? rhoObj.coverage.villages : [],
        primaryHealthCenters: Array.isArray(rhoObj.coverage?.primaryHealthCenters) ? rhoObj.coverage.primaryHealthCenters : [],
        communityHealthCenters: Array.isArray(rhoObj.coverage?.communityHealthCenters) ? rhoObj.coverage.communityHealthCenters : [],
        hospitals: Array.isArray(rhoObj.coverage?.hospitals) ? rhoObj.coverage.hospitals : [],
        populationCovered: rhoObj.coverage?.population || 0,
        hospitalsCovered: Array.isArray(rhoObj.coverage?.hospitals) ? rhoObj.coverage.hospitals.length : 0,
        primaryDistrict: rhoObj.coverage?.primaryDistrict || rhoObj.assignedDistrict || '',
        population: rhoObj.coverage?.population || 0,
        areaKm2: rhoObj.coverage?.areaKm2 || 0,
        ruralPopulation: rhoObj.coverage?.ruralPopulation || 0,
        urbanPopulation: rhoObj.coverage?.urbanPopulation || 0
      };
      
      // Map office address to simplified format
      if (rhoObj.officeAddress) {
        const addressParts = [
          rhoObj.officeAddress.buildingName,
          rhoObj.officeAddress.street
        ].filter(Boolean);
        
        rhoObj.officeAddress = {
          address: addressParts.length > 0 ? addressParts.join(', ') : '',
          city: rhoObj.officeAddress.city || '',
          state: rhoObj.officeAddress.state || '',
          pincode: rhoObj.officeAddress.zipCode || ''
        };
      } else {
        // Ensure officeAddress exists even if empty
        rhoObj.officeAddress = {
          address: '',
          city: '',
          state: '',
          pincode: ''
        };
      }
      
      console.log(`📋 Mapped RHO ${rhoObj.officerId}: totalStaff=${rhoObj.statistics.totalStaff}, staffLimits=${JSON.stringify(rhoObj.staffLimits)}`);
      
      return rhoObj;
    });

    // Get statistics for all RHOs in the state
    const stats = await RegionalHealthOfficer.aggregate([
      { $match: { assignedState: req.sho.assignedState } },
      {
        $group: {
          _id: null,
          total: { $sum: 1 },
          active: { $sum: { $cond: ['$isActive', 1, 0] } },
          inactive: { $sum: { $cond: ['$isActive', 0, 1] } }
        }
      }
    ]);

    const statistics = stats[0] || { total: 0, active: 0, inactive: 0 };
    console.log('📋 RHO Statistics for state:', statistics);

    res.status(200).json({
      success: true,
      rhos: mappedRHOs,
      statistics,
      pagination: {
        current: parseInt(page),
        total: Math.ceil(total / parseInt(limit)),
        count: total,
        limit: parseInt(limit)
      }
    });

  } catch (error) {
    console.error('Get RHOs by SHO error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching Regional Health Officers'
    });
  }
};

// Get specific RHO by ID
const getRHOById = async (req, res) => {
  try {
    const { rhoId } = req.params;
    console.log('📋 Getting RHO details:', rhoId);
    
    const rho = await RegionalHealthOfficer.findOne({
      _id: rhoId,
      parentSHO: req.sho.shoId // Ensure SHO can only access their own RHOs
    })
    .select('-password')
    .populate('parentSHO', 'fullName officerId assignedState')
    .populate('coverage.hospitals', 'name type location');

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'Regional Health Officer not found or access denied'
      });
    }

    // Format the RHO data to match frontend expectations
    const rhoObj = rho.toObject();
    
    // Format assignedAreas consistently
    rhoObj.assignedAreas = (rhoObj.assignedAreas || []).map(area => ({
      name: String(area.name || ''),
      code: String(area.code || ''),
      type: String(area.type || 'area'),
      population: Number(area.population || 0),
      areaKm2: Number(area.areaKm2 || 0),
      isDenselyPopulated: Boolean(area.isDenselyPopulated || false),
      zoneAreaId: String(area.zoneAreaId || ''),
      healthFacilities: {
        primaryHealthCenters: Math.floor((Number(area.population) || 0) / 20000) || 1,
        communityHealthCenters: Math.floor((Number(area.population) || 0) / 80000) || 1,
        hospitals: Math.floor((Number(area.population) || 0) / 100000) || 1
      },
      coveragePercentage: Math.min(100, ((Number(area.population) || 0) / 50000) * 100) || 85,
      populationDensity: (Number(area.areaKm2) || 0) > 0 ? 
        Math.round((Number(area.population) || 0) / (Number(area.areaKm2) || 1)) : 0
    }));
    
    // Only create default full-district assignment for sparse districts
    // Dense districts should ALWAYS have specific zone-based area assignments
    if (rhoObj.assignedAreas.length === 0) {
      // Check if this is a dense district by examining the district
      const AreaAssignmentService = require('../services/areaAssignmentService');
      const areaValidation = await AreaAssignmentService.validateAreaAssignment(
        rhoObj.assignedState, 
        rhoObj.assignedDistrict, 
        []
      );
      
      if (areaValidation.strategy.isDense) {
        console.warn(`⚠️ Dense district RHO ${rhoObj.officerId} has no assigned areas - this may indicate a zone assignment issue`);
        // For dense districts, return empty areas array instead of creating fake "Full District"
        rhoObj.assignedAreas = [];
        rhoObj.assignmentNote = 'Dense district RHO requires zone-based area assignment';
      } else {
        // Only sparse districts get full-district assignment
        rhoObj.assignedAreas = [{
          name: `Full District`,
          code: rhoObj.districtCode || 'FD',
          type: 'full-district',
          population: 0,
          areaKm2: 0,
          isDenselyPopulated: false,
          zoneAreaId: '',
          healthFacilities: {
            primaryHealthCenters: 1,
            communityHealthCenters: 1,
            hospitals: 1
          },
          coveragePercentage: 85,
          populationDensity: 0
        }];
      }
    }

    // Format coverage object properly to avoid JSON parsing issues
    if (rhoObj.coverage) {
      rhoObj.coverage = {
        districts: [rhoObj.assignedDistrict].filter(Boolean),
        subDistricts: Array.isArray(rhoObj.coverage.subDistricts) ? rhoObj.coverage.subDistricts : [],
        blocks: Array.isArray(rhoObj.coverage.blocks) ? rhoObj.coverage.blocks : [],
        villages: Array.isArray(rhoObj.coverage.villages) ? rhoObj.coverage.villages : [],
        primaryHealthCenters: Array.isArray(rhoObj.coverage.primaryHealthCenters) ? rhoObj.coverage.primaryHealthCenters : [],
        communityHealthCenters: Array.isArray(rhoObj.coverage.communityHealthCenters) ? rhoObj.coverage.communityHealthCenters : [],
        hospitals: Array.isArray(rhoObj.coverage.hospitals) ? rhoObj.coverage.hospitals : [],
        populationCovered: rhoObj.coverage.population || 0,
        hospitalsCovered: Array.isArray(rhoObj.coverage.hospitals) ? rhoObj.coverage.hospitals.length : 0,
        primaryDistrict: rhoObj.coverage.primaryDistrict || rhoObj.assignedDistrict || '',
        population: rhoObj.coverage.population || 0,
        areaKm2: rhoObj.coverage.areaKm2 || 0,
        ruralPopulation: rhoObj.coverage.ruralPopulation || 0,
        urbanPopulation: rhoObj.coverage.urbanPopulation || 0
      };
    }

    res.status(200).json({
      success: true,
      rho: rhoObj
    });

  } catch (error) {
    console.error('Get RHO by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching Regional Health Officer details'
    });
  }
};

// Update RHO details
const updateRHO = async (req, res) => {
  try {
    const { rhoId } = req.params;
    console.log('✏️ Updating RHO:', rhoId);
    
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const updates = { ...req.body };
    
    // Remove fields that shouldn't be updated directly
    delete updates.password; // Use separate endpoint for password
    delete updates.officerId; // Officer ID should not be changed
    delete updates.parentSHO; // Parent SHO should not be changed
    delete updates.assignedState; // State assignment should not be changed
    delete updates.createdBy;
    delete updates.createdAt;
    
    // Add updated timestamp
    updates.updatedAt = new Date();

    const rho = await RegionalHealthOfficer.findOneAndUpdate(
      { 
        _id: rhoId, 
        parentSHO: req.sho.shoId // Ensure SHO can only update their own RHOs
      },
      updates,
      { new: true, runValidators: true }
    )
    .select('-password')
    .populate('parentSHO', 'fullName officerId');

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'Regional Health Officer not found or access denied'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Regional Health Officer updated successfully',
      rho
    });

  } catch (error) {
    console.error('Update RHO error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating Regional Health Officer'
    });
  }
};

// Toggle RHO active status
const toggleRHOStatus = async (req, res) => {
  try {
    const { rhoId } = req.params;
    console.log('🔄 Toggling RHO status:', rhoId);
    
    const rho = await RegionalHealthOfficer.findOne({
      _id: rhoId,
      parentSHO: req.sho.shoId
    });

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'Regional Health Officer not found or access denied'
      });
    }

    rho.isActive = !rho.isActive;
    rho.updatedAt = new Date();
    await rho.save();

    const updatedRHO = await RegionalHealthOfficer.findById(rho._id)
      .select('-password')
      .populate('parentSHO', 'fullName officerId');

    // Convert the RHO data to match frontend expectations
    const mappedRHO = {
      id: updatedRHO._id.toString(),
      officerId: updatedRHO.officerId,
      fullName: updatedRHO.fullName,
      email: updatedRHO.email,
      phone: updatedRHO.phone,
      assignedState: updatedRHO.assignedState,
      assignedDistrict: updatedRHO.assignedDistrict,
      assignedRegion: updatedRHO.assignedRegion,
      regionCode: updatedRHO.regionCode,
      districtCode: updatedRHO.districtCode,
      assignedAreas: updatedRHO.assignedAreas || [],
      parentSHO: updatedRHO.parentSHO?._id?.toString() || updatedRHO.parentSHO,
      permissions: updatedRHO.permissions || {},
      staffLimits: {
        maxDoctors: updatedRHO.staffLimits?.maxDirectStaff || 0,
        maxNurses: updatedRHO.staffLimits?.maxHospitalsOversight || 0,
        maxLabAssistants: updatedRHO.staffLimits?.maxRegionsManaged || 0,
        maxPharmacists: 0
      },
      coverage: updatedRHO.coverage || {},
      statistics: {
        totalStaff: updatedRHO.statistics?.totalStaffManaged || 0,
        activeStaff: updatedRHO.statistics?.activeStaffCount || 0,
        totalPatients: updatedRHO.statistics?.patientsServed || 0,
        monthlyPatients: updatedRHO.statistics?.monthlyConsultations || 0
      },
      officeAddress: updatedRHO.officeAddress || {},
      officePhone: updatedRHO.officePhone,
      emergencyContact: updatedRHO.emergencyContact,
      isActive: updatedRHO.isActive,
      lastLogin: updatedRHO.lastLogin,
      createdAt: updatedRHO.createdAt,
      updatedAt: updatedRHO.updatedAt
    };

    res.status(200).json({
      success: true,
      message: `Regional Health Officer ${rho.isActive ? 'activated' : 'deactivated'} successfully`,
      data: mappedRHO
    });

  } catch (error) {
    console.error('Toggle RHO status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating Regional Health Officer status'
    });
  }
};

// Delete RHO
const deleteRHO = async (req, res) => {
  try {
    const { rhoId } = req.params;
    console.log('🗑️ Deleting RHO:', rhoId);
    
    // First, check if RHO exists and belongs to this SHO
    const rho = await RegionalHealthOfficer.findOne({
      _id: rhoId,
      parentSHO: req.sho.shoId
    });

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'Regional Health Officer not found or access denied'
      });
    }

    // Check if RHO has active staff members
    // This is a safety check to prevent deleting RHOs with active assignments
    const hasActiveStaff = rho.statistics && rho.statistics.totalStaffManaged > 0;
    
    if (hasActiveStaff) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete RHO with active staff members. Please reassign staff first.'
      });
    }

    // Perform the deletion
    await RegionalHealthOfficer.findByIdAndDelete(rhoId);

    console.log('✅ RHO deleted successfully:', rho.officerId);

    res.status(200).json({
      success: true,
      message: `Regional Health Officer ${rho.fullName} (${rho.officerId}) deleted successfully`
    });

  } catch (error) {
    console.error('Delete RHO error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error deleting Regional Health Officer'
    });
  }
};

// Update RHO permissions
const updateRHOPermissions = async (req, res) => {
  try {
    const { rhoId } = req.params;
    const { permissions } = req.body;
    console.log('🔐 Updating RHO permissions:', rhoId);
    
    const rho = await RegionalHealthOfficer.findOneAndUpdate(
      { 
        _id: rhoId, 
        parentSHO: req.sho.shoId 
      },
      { 
        permissions: permissions,
        updatedAt: new Date()
      },
      { new: true, runValidators: true }
    )
    .select('-password')
    .populate('parentSHO', 'fullName officerId');

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'Regional Health Officer not found or access denied'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Regional Health Officer permissions updated successfully',
      rho
    });

  } catch (error) {
    console.error('Update RHO permissions error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating Regional Health Officer permissions'
    });
  }
};

// Reset RHO password
const resetRHOPassword = async (req, res) => {
  try {
    const { rhoId } = req.params;
    const { newPassword } = req.body;
    console.log('🔑 Resetting RHO password:', rhoId);
    
    if (!newPassword || newPassword.length < 8) {
      return res.status(400).json({
        success: false,
        message: 'Password must be at least 8 characters long'
      });
    }

    const rho = await RegionalHealthOfficer.findOne({
      _id: rhoId,
      parentSHO: req.sho.shoId
    });

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'Regional Health Officer not found or access denied'
      });
    }

    rho.password = newPassword; // Will be hashed by pre-save middleware
    rho.updatedAt = new Date();
    await rho.save();

    res.status(200).json({
      success: true,
      message: 'Regional Health Officer password reset successfully'
    });

  } catch (error) {
    console.error('Reset RHO password error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error resetting Regional Health Officer password'
    });
  }
};

// Get RHO statistics for dashboard
const getRHOStatistics = async (req, res) => {
  try {
    console.log('📊 Getting RHO statistics for SHO:', req.sho?.fullName);
    
    const stats = await RegionalHealthOfficer.aggregate([
      { $match: { parentSHO: req.sho.shoId } },
      {
        $group: {
          _id: null,
          total: { $sum: 1 },
          active: { $sum: { $cond: ['$isActive', 1, 0] } },
          inactive: { $sum: { $cond: ['$isActive', 0, 1] } },
          totalStaffManaged: { $sum: '$statistics.totalStaffManaged' },
          totalHospitalsOverseen: { $sum: '$statistics.hospitalsOverseen' },
          totalPatientsServed: { $sum: '$statistics.patientsServed' }
        }
      }
    ]);

    // Get region distribution
    const regionStats = await RegionalHealthOfficer.aggregate([
      { $match: { parentSHO: req.sho.shoId, isActive: true } },
      {
        $group: {
          _id: '$assignedRegion',
          count: { $sum: 1 },
          totalStaff: { $sum: '$statistics.totalStaffManaged' },
          totalHospitals: { $sum: '$statistics.hospitalsOverseen' }
        }
      },
      { $sort: { count: -1 } }
    ]);

    const statistics = stats[0] || { 
      total: 0, 
      active: 0, 
      inactive: 0,
      totalStaffManaged: 0,
      totalHospitalsOverseen: 0,
      totalPatientsServed: 0
    };

    res.status(200).json({
      success: true,
      statistics: {
        ...statistics,
        regionDistribution: regionStats
      }
    });

  } catch (error) {
    console.error('Get RHO statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching Regional Health Officer statistics'
    });
  }
};

// Get available districts for SHO's state
const getAvailableDistricts = async (req, res) => {
  try {
    console.log('📋 Getting available districts for SHO state:', req.sho?.assignedState);
    
    const shoData = await StateHealthOfficer.findById(req.sho.shoId);
    if (!shoData) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    // Use real state data instead of mock data
    let districts;
    try {
      districts = AreaAssignmentService.getDistrictsForState(shoData.assignedState);
    } catch (error) {
      console.error('Error getting districts for state:', error);
      // Fallback to mock data if real data fails
      districts = getDistrictsByState(shoData.assignedState).map(district => ({
        name: district,
        state: shoData.assignedState,
        isDense: AreaAssignmentService.isDenseDistrict(shoData.assignedState, district),
        subdistricts: [],
        hasAreas: false
      }));
    }

    // Filter districts based on zone availability for dense districts
    // and RHO availability for sparse districts
    const Zone = require('../models/Zone');
    const availableDistricts = [];
    
    for (const district of districts) {
      const districtName = district.name;
      
      if (district.isDense) {
        // For dense districts, check if there are unassigned zones
        const unassignedZones = await Zone.findUnassigned(shoData.assignedState, districtName);
        
        if (unassignedZones.length > 0) {
          // District has unassigned zones, so it's available for RHO creation
          availableDistricts.push({
            ...district,
            availabilityReason: `${unassignedZones.length} unassigned zone(s)`,
            unassignedZonesCount: unassignedZones.length
          });
        }
        // If no unassigned zones, district won't appear in dropdown
        
      } else {
        // For sparse districts, use the original logic - check if any RHO is assigned
        const existingRHO = await RegionalHealthOfficer.findOne({
          assignedState: shoData.assignedState,
          assignedDistrict: districtName,
          parentSHO: req.sho.shoId,
          isActive: true
        });
        
        if (!existingRHO) {
          // District has no RHO assigned, so it's available
          availableDistricts.push({
            ...district,
            availabilityReason: 'No RHO assigned',
            unassignedZonesCount: 0
          });
        }
        // If RHO exists, district won't appear in dropdown
      }
    }

    // Get all assigned districts for reference (both dense and sparse)
    const assignedDistricts = await RegionalHealthOfficer.find({
      assignedState: shoData.assignedState,
      parentSHO: req.sho.shoId,
      isActive: true
    }).distinct('assignedDistrict');

    console.log(`📊 Found ${districts.length} total districts:`);
    console.log(`   - ${availableDistricts.length} available for RHO creation`);
    console.log(`   - ${assignedDistricts.length} already assigned or fully covered`);
    
    // Log detailed availability info
    availableDistricts.forEach(district => {
      console.log(`   ✅ ${district.name}: ${district.availabilityReason}`);
    });

    res.status(200).json({
      success: true,
      data: {
        state: shoData.assignedState,
        allDistricts: districts,
        availableDistricts: availableDistricts,
        assignedDistricts,
        districtCount: districts.length,
        availableCount: availableDistricts.length,
        summary: {
          total: districts.length,
          available: availableDistricts.length,
          assigned: assignedDistricts.length,
          denseDistricts: districts.filter(d => d.isDense).length,
          sparseDistricts: districts.filter(d => !d.isDense).length
        }
      }
    });

  } catch (error) {
    console.error('Get available districts error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching available districts'
    });
  }
};

// Get mock RHO data for testing/demo purposes
const getMockRHOData = async (req, res) => {
  try {
    console.log('📋 Getting mock RHO data for state:', req.sho?.assignedState);
    
    const shoData = await StateHealthOfficer.findById(req.sho.shoId);
    if (!shoData) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    const mockRHOs = MOCK_RHO_DATA[shoData.assignedState] || [];
    
    // Generate mock staff data for each RHO
    const mockRHOsWithStaff = mockRHOs.map((rho, index) => ({
      ...rho,
      id: `mock_rho_${index + 1}`,
      officerId: `RHO_${generateDistrictCode(rho.assignedDistrict)}_${String(index + 1).padStart(3, '0')}`,
      parentSHO: req.sho.shoId,
      mockStaff: generateMockStaffData(`mock_rho_${index + 1}`, rho.assignedDistrict, 25),
      isActive: true,
      createdAt: new Date(2024, Math.floor(Math.random() * 6), Math.floor(Math.random() * 28) + 1),
      updatedAt: new Date()
    }));

    res.status(200).json({
      success: true,
      data: {
        state: shoData.assignedState,
        mockRHOs: mockRHOsWithStaff,
        totalMockRHOs: mockRHOsWithStaff.length,
        note: 'This is mock data for testing and demonstration purposes'
      }
    });

  } catch (error) {
    console.error('Get mock RHO data error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching mock RHO data'
    });
  }
};

// Create RHO from mock data
const createRHOFromMockData = async (req, res) => {
  try {
    const { mockRHOIndex } = req.body;
    console.log('🚀 Creating RHO from mock data, index:', mockRHOIndex);
    
    const shoData = await StateHealthOfficer.findById(req.sho.shoId);
    if (!shoData) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    const mockRHOs = MOCK_RHO_DATA[shoData.assignedState] || [];
    if (mockRHOIndex >= mockRHOs.length || mockRHOIndex < 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid mock RHO index'
      });
    }

    const mockRHO = mockRHOs[mockRHOIndex];
    
    // Check if district already has an active RHO
    const existingRHO = await RegionalHealthOfficer.findOne({
      assignedDistrict: mockRHO.assignedDistrict,
      assignedState: shoData.assignedState,
      parentSHO: req.sho.shoId,
      isActive: true
    });

    if (existingRHO) {
      return res.status(400).json({
        success: false,
        message: `District ${mockRHO.assignedDistrict} already has an active RHO assigned`
      });
    }

    // Generate unique RHO ID
    const officerId = await generateRHOId(shoData.assignedState, mockRHO.assignedDistrict);
    
    // Create RHO from mock data
    const newRHO = new RegionalHealthOfficer({
      officerId,
      fullName: mockRHO.fullName,
      email: mockRHO.email,
      phone: mockRHO.phone,
      password: 'TempPassword@2024', // Temporary password
      assignedState: shoData.assignedState,
      assignedDistrict: mockRHO.assignedDistrict,
      assignedRegion: mockRHO.assignedRegion,
      regionCode: mockRHO.regionCode,
      districtCode: mockRHO.districtCode,
      parentSHO: req.sho.shoId,
      qualification: mockRHO.qualification,
      experience: mockRHO.experience,
      licenseNumber: mockRHO.licenseNumber,
      
      staffLimits: {
        maxDirectStaff: 50,
        maxHospitalsOversight: 20,
        maxRegionsManaged: 5
      },
      
      coverage: {
        primaryDistrict: mockRHO.coverage.primaryDistrict,
        subDistricts: mockRHO.coverage.subDistricts || [],
        blocks: mockRHO.coverage.blocks || [],
        villages: [],
        primaryHealthCenters: [],
        communityHealthCenters: [],
        population: mockRHO.coverage.population,
        areaKm2: mockRHO.coverage.areaKm2,
        ruralPopulation: mockRHO.coverage.ruralPopulation,
        urbanPopulation: mockRHO.coverage.urbanPopulation
      },
      
      officeAddress: {
        buildingName: 'District Health Office',
        street: 'Government Complex',
        city: mockRHO.assignedDistrict,
        state: shoData.assignedState,
        zipCode: '000000',
        country: 'India'
      },
      
      officePhone: mockRHO.phone,
      createdBy: req.sho.shoId,
      
      permissions: {
        canViewHospitals: true,
        canManageHospitalStaff: true,
        canViewHospitalReports: true,
        canViewPatientData: true,
        canAccessMedicalRecords: false,
        canGenerateReports: true,
        canViewRegionalStats: true,
        canInitiateEmergencyResponse: true,
        canAccessEmergencyContacts: true,
        canManageProfile: true,
        canChangePassword: true
      }
    });

    await newRHO.save();
    console.log('✅ RHO created from mock data:', officerId);

    // Return RHO data without password
    const rhoResponse = await RegionalHealthOfficer.findById(newRHO._id)
      .select('-password')
      .populate('parentSHO', 'fullName officerId assignedState');

    res.status(201).json({
      success: true,
      message: 'Regional Health Officer created successfully from mock data',
      rho: rhoResponse,
      loginCredentials: {
        officerId,
        username: newRHO.username,
        temporaryPassword: 'TempPassword@2024'
      },
      mockDataUsed: true
    });

  } catch (error) {
    console.error('Create RHO from mock data error:', error);
    
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'RHO with this email or license number already exists'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error creating RHO from mock data'
    });
  }
};

// Get district assignment strategy and available areas
const getDistrictAssignmentInfo = async (req, res) => {
  try {
    const { district } = req.params;
    
    // Verify the SHO can access this district
    const shoData = await StateHealthOfficer.findById(req.sho.shoId);
    if (!shoData) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    // Get real district data for the state
    let availableDistricts;
    try {
      const districts = AreaAssignmentService.getDistrictsForState(shoData.assignedState);
      availableDistricts = districts.map(d => d.name);
    } catch (error) {
      // Fallback to mock data
      availableDistricts = getDistrictsByState(shoData.assignedState);
    }

    if (!availableDistricts.includes(district)) {
      return res.status(400).json({
        success: false,
        message: `Invalid district for your state (${shoData.assignedState})`
      });
    }

    // Get assignment strategy and area information using real data
    let assignmentInfo;
    try {
      assignmentInfo = AreaAssignmentService.getDistrictAssignmentInfoWithRealData(district);
    } catch (error) {
      console.error('Error getting real district assignment info, falling back to mock:', error);
      // Fallback to existing logic
      const strategy = AreaAssignmentService.getAssignmentStrategy(shoData.assignedState, district);
      const areaOptions = AreaAssignmentService.getAreaOptions(district);
      assignmentInfo = {
        district,
        state: shoData.assignedState,
        type: strategy.isDense ? 'dense' : 'sparse',
        areas: areaOptions,
        requiresAreaSelection: strategy.isDense
      };
    }
    
    // Check which areas are already assigned
    const existingRHOs = await RegionalHealthOfficer.find({
      assignedDistrict: district,
      assignedState: shoData.assignedState,
      isActive: true
    }).select('assignedAreas officerId fullName');

    const assignedAreas = [];
    existingRHOs.forEach(rho => {
      if (rho.assignedAreas && rho.assignedAreas.length > 0) {
        rho.assignedAreas.forEach(area => {
          assignedAreas.push({
            areaName: area.name,
            areaCode: area.code,
            assignedTo: {
              officerId: rho.officerId,
              fullName: rho.fullName
            }
          });
        });
      }
    });

    // Mark which areas are available
    const availableAreaOptions = assignmentInfo.areas.map(area => ({
      ...area,
      isAssigned: assignedAreas.some(assigned => assigned.areaName === area.name),
      assignedTo: assignedAreas.find(assigned => assigned.areaName === area.name)?.assignedTo || null
    }));

    res.json({
      success: true,
      district,
      state: assignmentInfo.state,
      type: assignmentInfo.type,
      requiresAreaSelection: assignmentInfo.requiresAreaSelection,
      availableAreas: availableAreaOptions,
      currentAssignments: assignedAreas,
      subdistricts: assignmentInfo.subdistricts || [],
      recommendations: {
        canCreateNew: assignmentInfo.requiresAreaSelection ? 
          availableAreaOptions.some(area => !area.isAssigned) : 
          existingRHOs.length === 0,
        maxRHOsRecommended: assignmentInfo.areas.length,
        currentRHOCount: existingRHOs.length
      }
    });

  } catch (error) {
    console.error('Get district assignment info error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error getting district assignment information'
    });
  }
};

// Get area coverage details for a specific area
const getAreaCoverageDetails = async (req, res) => {
  try {
    const { district, areaName } = req.params;
    
    // Verify the SHO can access this district
    const shoData = await StateHealthOfficer.findById(req.sho.shoId);
    if (!shoData) {
      return res.status(404).json({
        success: false,
        message: 'SHO not found'
      });
    }

    const availableDistricts = getDistrictsByState(shoData.assignedState);
    if (!availableDistricts.includes(district)) {
      return res.status(400).json({
        success: false,
        message: `Invalid district for your state (${shoData.assignedState})`
      });
    }

    // Get area details
    const areaData = AreaAssignmentService.getAreaByName(district, areaName);
    if (!areaData) {
      return res.status(404).json({
        success: false,
        message: `Area '${areaName}' not found in district '${district}'`
      });
    }

    // Check if area is already assigned
    const isAssigned = await AreaAssignmentService.isAreaAssigned(district, areaName);
    const assignedRHO = isAssigned ? await RegionalHealthOfficer.findOne({
      assignedDistrict: district,
      'assignedAreas.name': areaName,
      isActive: true
    }).select('officerId fullName email phone') : null;

    res.json({
      success: true,
      area: areaData,
      assignment: {
        isAssigned,
        assignedTo: assignedRHO
      }
    });

  } catch (error) {
    console.error('Get area coverage details error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error getting area coverage details'
    });
  }
};

// Public endpoint for hospital registration - Get active RHOs without authentication
const getPublicRHOs = async (req, res) => {
  try {
    console.log('🔍 Fetching public RHO data for hospital registration...');
    
    // Get all active RHOs 
    const rhos = await RegionalHealthOfficer.find({ 
      isActive: true 
    }).select('officerId fullName assignedState assignedDistrict assignedAreas assignedRegion regionCode districtCode')
    .populate('parentSHO', 'fullName assignedState');

    console.log(`✅ Found ${rhos.length} active RHOs for public access`);

    res.json({
      success: true,
      rhos: rhos.map(rho => ({
        officerId: rho.officerId,
        fullName: rho.fullName,
        assignedState: rho.assignedState,
        assignedDistrict: rho.assignedDistrict,
        assignedAreas: (rho.assignedAreas || []).map(area => ({
          name: area.name,
          code: area.code,
          type: area.type,
          population: area.population,
          areaKm2: area.areaKm2,
          isDenselyPopulated: area.isDenselyPopulated,
          zoneAreaId: area.zoneAreaId
        })),
        assignedRegion: rho.assignedRegion,
        regionCode: rho.regionCode,
        districtCode: rho.districtCode,
        isActive: rho.isActive,
        parentSHO: rho.parentSHO ? {
          fullName: rho.parentSHO.fullName,
          assignedState: rho.parentSHO.assignedState
        } : null
      }))
    });

  } catch (error) {
    console.error('❌ Error fetching public RHO data:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch RHO data for hospital registration'
    });
  }
};

module.exports = {
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
};