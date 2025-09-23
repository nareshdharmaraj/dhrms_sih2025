const Hospital = require('../models/Hospital');
const RegionalHealthOfficer = require('../models/RegionalHealthOfficer');
const Zone = require('../models/Zone');
const HospitalZoneAssignmentService = require('../services/HospitalZoneAssignmentService');

// ==================== RHO HOSPITAL APPROVAL CONTROLLERS ====================

/**
 * @desc    Get pending hospital approvals for RHO's specific zone assignments
 * @route   GET /api/rho/hospitals/pending
 * @access  Private (RHO)
 */
const getPendingHospitals = async (req, res) => {
  try {
    const { rhoId } = req.rho; // This is actually officerId from auth middleware

    // Get RHO details to find their assigned district and areas
    const rho = await RegionalHealthOfficer.findOne({ officerId: rhoId });

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'RHO not found'
      });
    }

    console.log(`🔍 Finding pending hospitals for RHO: ${rho.fullName} (${rho.officerId})`);
    console.log(`📍 RHO assigned to: ${rho.assignedState}/${rho.assignedDistrict}`);
    console.log(`📋 RHO assigned areas: ${rho.assignedAreas.map(a => a.name).join(', ')}`);

    // Find zones assigned to this RHO
    const assignedZones = await Zone.find({
      state: rho.assignedState,
      district: rho.assignedDistrict,
      'assignedRHO.rhoId': rho._id,
      isActive: true
    });

    console.log(`🏢 Found ${assignedZones.length} zones assigned to this RHO`);

    let pendingHospitals = [];

    if (assignedZones.length > 0) {
      // Dense district with zone-based assignment
      const zoneIds = assignedZones.map(zone => zone.zoneId);
      const zoneAreaNames = assignedZones.flatMap(zone => zone.areas.map(area => area.areaName));
      
      console.log(`🎯 Zone-based filtering - Zone IDs: ${zoneIds.join(', ')}`);
      console.log(`🎯 Zone areas: ${zoneAreaNames.join(', ')}`);

      // Get hospitals assigned to these specific zones
      const hospitalQuery = {
        'region.state': rho.assignedState,
        'region.district': rho.assignedDistrict,
        'approval.status': 'Pending',
        isActive: true,
        $or: [
          // Hospitals with zone assignment matching this RHO's zones
          { 'zoneAssignment.zoneId': { $in: zoneIds } },
          { 'zoneAssignment.assignedRHO': rho._id },
          // Hospitals with area matching this RHO's zone areas
          { 'zoneAssignment.area': { $in: zoneAreaNames } },
          // Fallback: Hospitals without zone assignment in RHO's areas (for migration)
          {
            'zoneAssignment.area': { $exists: false },
            $or: [
              { 'location.city': { $in: zoneAreaNames } },
              // Address contains any of the zone area names
              { 'location.address': { $regex: zoneAreaNames.join('|'), $options: 'i' } }
            ]
          }
        ]
      };

      pendingHospitals = await Hospital.find(hospitalQuery)
        .select('-__v')
        .sort({ 'approval.submittedAt': 1 });

      // Auto-assign zone for hospitals without zone assignment
      for (let hospital of pendingHospitals) {
        if (!hospital.zoneAssignment || !hospital.zoneAssignment.zoneId) {
          console.log(`🔄 Auto-assigning zone for hospital: ${hospital.name}`);
          try {
            await HospitalZoneAssignmentService.updateHospitalZoneAssignment(hospital);
          } catch (error) {
            console.warn(`⚠️ Failed to auto-assign zone for ${hospital.name}:`, error.message);
          }
        }
      }

    } else {
      // Non-dense district or no zone assignment - use traditional district-based approach
      console.log(`📍 District-based filtering (no zone assignment)`);
      
      const hospitalQuery = {
        'region.state': rho.assignedState,
        'region.district': rho.assignedDistrict,
        'approval.status': 'Pending',
        isActive: true
      };

      pendingHospitals = await Hospital.find(hospitalQuery)
        .select('-__v')
        .sort({ 'approval.submittedAt': 1 });
    }

    console.log(`📊 Found ${pendingHospitals.length} pending hospitals for RHO ${rho.fullName}`);

    // Log hospital details for debugging
    pendingHospitals.forEach(hospital => {
      console.log(`  📋 ${hospital.name} - Zone: ${hospital.zoneAssignment?.zoneName || 'Not assigned'} - Area: ${hospital.zoneAssignment?.area || 'Not assigned'}`);
    });

    res.json({
      success: true,
      data: pendingHospitals,
      meta: {
        total: pendingHospitals.length,
        rhoName: rho.fullName,
        rhoId: rho.officerId,
        assignedState: rho.assignedState,
        assignedDistrict: rho.assignedDistrict,
        assignedAreas: rho.assignedAreas.map(a => a.name),
        assignedZones: assignedZones.length > 0 ? assignedZones.map(z => ({ 
          zoneId: z.zoneId, 
          zoneName: z.zoneName,
          areas: z.areas.map(a => a.areaName)
        })) : null,
        assignmentType: assignedZones.length > 0 ? 'zone-based' : 'district-based'
      }
    });

  } catch (error) {
    console.error('Get pending hospitals error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching pending hospitals'
    });
  }
};

/**
 * @desc    Get all hospitals in RHO's specific zone assignments with their approval status
 * @route   GET /api/rho/hospitals/all
 * @access  Private (RHO)
 */
const getAllHospitalsInRegion = async (req, res) => {
  try {
    const { rhoId } = req.rho; // This is actually officerId from auth middleware
    const { status, page = 1, limit = 10 } = req.query;

    // Get RHO details to find their assigned district
    const rho = await RegionalHealthOfficer.findOne({ officerId: rhoId });

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'RHO not found'
      });
    }

    console.log(`🔍 Getting all hospitals for RHO: ${rho.fullName} (${rho.officerId})`);
    console.log(`📍 RHO region: ${rho.assignedState}/${rho.assignedDistrict}`);

    // Find zones assigned to this RHO
    const assignedZones = await Zone.find({
      state: rho.assignedState,
      district: rho.assignedDistrict,
      'assignedRHO.rhoId': rho.officerId,
      isActive: true
    });

    console.log(`🏢 Found ${assignedZones.length} zones assigned to this RHO`);

    // Build base query
    let query = {
      'region.state': rho.assignedState,
      'region.district': rho.assignedDistrict,
      isActive: true
    };

    if (assignedZones.length > 0) {
      // Zone-based filtering for dense districts
      const zoneIds = assignedZones.map(zone => zone.zoneId);
      const zoneAreaNames = assignedZones.flatMap(zone => zone.areas.map(area => area.areaName));
      
      console.log(`🎯 Zone-based filtering - Zones: ${zoneIds.join(', ')}`);

      query.$or = [
        // Hospitals with zone assignment matching this RHO's zones
        { 'zoneAssignment.zoneId': { $in: zoneIds } },
        { 'zoneAssignment.assignedRHO': rho.officerId },
        // Hospitals with area matching this RHO's zone areas
        { 'zoneAssignment.area': { $in: zoneAreaNames } },
        // Fallback: Hospitals without zone assignment in RHO's areas
        {
          'zoneAssignment.area': { $exists: false },
          $or: [
            { 'location.city': { $in: zoneAreaNames } },
            { 'location.address': { $regex: zoneAreaNames.join('|'), $options: 'i' } }
          ]
        }
      ];
    }

    if (status) {
      query['approval.status'] = status;
    }

    console.log(`🔍 Finding hospitals in ${rho.assignedState}/${rho.assignedDistrict} with status: ${status || 'all'}`);

    // Execute query with pagination
    const skip = (page - 1) * limit;
    const hospitals = await Hospital.find(query)
      .select('-__v')
      .sort({ 'approval.submittedAt': -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const totalCount = await Hospital.countDocuments(query);

    console.log(`📊 Found ${hospitals.length} hospitals (${totalCount} total) for RHO ${rho.fullName}`);

    res.json({
      success: true,
      data: hospitals,
      meta: {
        total: totalCount,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(totalCount / limit),
        rhoName: rho.fullName,
        rhoId: rho.officerId,
        assignedState: rho.assignedState,
        assignedDistrict: rho.assignedDistrict,
        assignedZones: assignedZones.length > 0 ? assignedZones.map(z => ({ 
          zoneId: z.zoneId, 
          zoneName: z.zoneName,
          areas: z.areas.map(a => a.areaName)
        })) : null,
        assignmentType: assignedZones.length > 0 ? 'zone-based' : 'district-based'
      }
    });

  } catch (error) {
    console.error('Get hospitals in region error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching hospitals'
    });
  }
};

/**
 * @desc    Get specific hospital details for review
 * @route   GET /api/rho/hospitals/:hospitalId/details
 * @access  Private (RHO)
 */
const getHospitalDetails = async (req, res) => {
  try {
    const { rhoId } = req.rho; // This is actually officerId from auth middleware
    const { hospitalId } = req.params;

    // Get RHO details to verify district access
    const rho = await RegionalHealthOfficer.findOne({ officerId: rhoId });

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'RHO not found'
      });
    }

    // Get hospital details
    const hospital = await Hospital.findOne({ 
      hospitalId,
      isActive: true 
    }).populate('approval.reviewedBy', 'fullName email phone');

    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found'
      });
    }

    // Verify RHO has access to this hospital's region
    const hasAccess = hospital.region.state === rho.assignedState &&
                      hospital.region.district === rho.assignedDistrict;

    if (!hasAccess) {
      return res.status(403).json({
        success: false,
        message: `You do not have access to hospitals in ${hospital.region.state}/${hospital.region.district}. Your jurisdiction is ${rho.assignedState}/${rho.assignedDistrict}.`
      });
    }

    console.log(`🏥 RHO ${rho.fullName} accessing hospital: ${hospital.name} (${hospital.hospitalId})`);

    res.json({
      success: true,
      data: hospital
    });

  } catch (error) {
    console.error('Get hospital details error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching hospital details'
    });
  }
};

/**
 * @desc    Approve hospital registration
 * @route   POST /api/rho/hospitals/:hospitalId/approve
 * @access  Private (RHO)
 */
const approveHospital = async (req, res) => {
  try {
    const { rhoId } = req.rho;
    const { hospitalId } = req.params;
    const { comments, assignedRO } = req.body;

    // Get RHO details
    const rho = await RegionalHealthOfficer.findOne({ rhoId })
      .populate('assignedAreas.district', 'name state');

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'RHO not found'
      });
    }

    // Get hospital
    const hospital = await Hospital.findOne({ 
      hospitalId,
      isActive: true 
    });

    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found'
      });
    }

    // Verify RHO has access to this hospital's region
    const hasAccess = rho.assignedAreas.some(area => 
      area.district.state === hospital.region.state &&
      area.district.name === hospital.region.district
    );

    if (!hasAccess) {
      return res.status(403).json({
        success: false,
        message: 'You do not have access to approve hospitals in this region'
      });
    }

    // Check if already approved or rejected
    if (hospital.approval.status !== 'Pending') {
      return res.status(400).json({
        success: false,
        message: `Hospital is already ${hospital.approval.status.toLowerCase()}`
      });
    }

    // Approve hospital
    await hospital.approve(rho._id, comments);

    // If assignedRO is provided, set managedBy
    if (assignedRO) {
      hospital.managedBy = assignedRO;
      await hospital.save();
    }

    res.json({
      success: true,
      message: 'Hospital approved successfully',
      data: {
        hospitalId: hospital.hospitalId,
        name: hospital.name,
        approvedAt: hospital.approval.reviewedAt,
        approvedBy: rho.name
      }
    });

  } catch (error) {
    console.error('Approve hospital error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while approving hospital'
    });
  }
};

/**
 * @desc    Reject hospital registration
 * @route   POST /api/rho/hospitals/:hospitalId/reject
 * @access  Private (RHO)
 */
const rejectHospital = async (req, res) => {
  try {
    const { rhoId } = req.rho;
    const { hospitalId } = req.params;
    const { comments } = req.body;

    if (!comments || comments.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Rejection comments are required'
      });
    }

    // Get RHO details
    const rho = await RegionalHealthOfficer.findOne({ rhoId })
      .populate('assignedAreas.district', 'name state');

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'RHO not found'
      });
    }

    // Get hospital
    const hospital = await Hospital.findOne({ 
      hospitalId,
      isActive: true 
    });

    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found'
      });
    }

    // Verify RHO has access to this hospital's region
    const hasAccess = rho.assignedAreas.some(area => 
      area.district.state === hospital.region.state &&
      area.district.name === hospital.region.district
    );

    if (!hasAccess) {
      return res.status(403).json({
        success: false,
        message: 'You do not have access to reject hospitals in this region'
      });
    }

    // Check if already approved or rejected
    if (hospital.approval.status !== 'Pending') {
      return res.status(400).json({
        success: false,
        message: `Hospital is already ${hospital.approval.status.toLowerCase()}`
      });
    }

    // Reject hospital
    await hospital.reject(rho._id, comments);

    res.json({
      success: true,
      message: 'Hospital registration rejected',
      data: {
        hospitalId: hospital.hospitalId,
        name: hospital.name,
        rejectedAt: hospital.approval.reviewedAt,
        rejectedBy: rho.name,
        reason: comments
      }
    });

  } catch (error) {
    console.error('Reject hospital error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while rejecting hospital'
    });
  }
};

/**
 * @desc    Get hospital approval statistics for RHO dashboard
 * @route   GET /api/rho/hospitals/statistics
 * @access  Private (RHO)
 */
const getHospitalStatistics = async (req, res) => {
  try {
    const { rhoId } = req.rho;

    // Get RHO details
    const rho = await RegionalHealthOfficer.findOne({ rhoId })
      .populate('assignedAreas.district', 'name state');

    if (!rho) {
      return res.status(404).json({
        success: false,
        message: 'RHO not found'
      });
    }

    // Build queries for all areas
    const areaQueries = rho.assignedAreas.map(area => ({
      'region.state': area.district.state,
      'region.district': area.district.name,
      isActive: true
    }));

    let statistics = {
      pending: 0,
      approved: 0,
      rejected: 0,
      total: 0,
      recentApprovals: []
    };

    if (areaQueries.length > 0) {
      // Get counts by status
      const [pending, approved, rejected, total] = await Promise.all([
        Hospital.countDocuments({ 
          $or: areaQueries, 
          'approval.status': 'Pending' 
        }),
        Hospital.countDocuments({ 
          $or: areaQueries, 
          'approval.status': 'Approved' 
        }),
        Hospital.countDocuments({ 
          $or: areaQueries, 
          'approval.status': 'Rejected' 
        }),
        Hospital.countDocuments({ $or: areaQueries })
      ]);

      // Get recent approvals
      const recentApprovals = await Hospital.find({
        $or: areaQueries,
        'approval.status': 'Approved',
        'approval.reviewedBy': rho._id
      })
      .select('hospitalId name approval.reviewedAt location.city location.state')
      .sort({ 'approval.reviewedAt': -1 })
      .limit(5);

      statistics = {
        pending,
        approved,
        rejected,
        total,
        recentApprovals
      };
    }

    res.json({
      success: true,
      data: statistics,
      meta: {
        rhoName: rho.name,
        assignedAreas: rho.assignedAreas.length
      }
    });

  } catch (error) {
    console.error('Get hospital statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching statistics'
    });
  }
};

module.exports = {
  getPendingHospitals,
  getAllHospitalsInRegion,
  getHospitalDetails,
  approveHospital,
  rejectHospital,
  getHospitalStatistics
};