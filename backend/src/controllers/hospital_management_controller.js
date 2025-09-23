const Hospital = require('../models/Hospital');
const HospitalAdmin = require('../models/HospitalAdmin');
const { AreaAssignmentService } = require('../services/areaAssignmentService');

// ==================== HOSPITAL MANAGEMENT CONTROLLERS ====================

/**
 * @desc    Get all hospitals for admin login selection
 * @route   GET /api/hospital/list
 * @access  Public
 */
const getAllHospitals = async (req, res) => {
  try {
    const hospitals = await Hospital.find({ 
      isActive: true,
      status: 'Active' 
    }).select('hospitalId name location.city location.state');
    
    res.json({
      success: true,
      count: hospitals.length,
      data: hospitals
    });
  } catch (error) {
    console.error('Get all hospitals error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching hospitals'
    });
  }
};

/**
 * @desc    Search hospitals by name or location
 * @route   GET /api/hospital/search
 * @access  Public
 */
const searchHospitals = async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query) {
      return res.status(400).json({
        success: false,
        message: 'Search query is required'
      });
    }
    
    const hospitals = await Hospital.find({
      isActive: true,
      status: 'Active',
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { 'location.city': { $regex: query, $options: 'i' } },
        { 'location.state': { $regex: query, $options: 'i' } }
      ]
    }).select('hospitalId name location.city location.state');
    
    res.json({
      success: true,
      count: hospitals.length,
      data: hospitals
    });
  } catch (error) {
    console.error('Search hospitals error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while searching hospitals'
    });
  }
};

/**
 * @desc    Get hospital details by ID
 * @route   GET /api/hospital/:hospitalId
 * @access  Public
 */
const getHospitalById = async (req, res) => {
  try {
    const { hospitalId } = req.params;
    
    const hospital = await Hospital.findOne({ 
      hospitalId, 
      isActive: true 
    }).select('-__v');
    
    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found'
      });
    }
    
    res.json({
      success: true,
      data: hospital
    });
  } catch (error) {
    console.error('Get hospital by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching hospital details'
    });
  }
};

/**
 * @desc    Register new hospital with admin
 * @route   POST /api/hospital/register
 * @access  Public
 */
const registerHospital = async (req, res) => {
  try {
    const {
      hospitalName,
      address,
      contactNumber,
      email,
      registrationNumber,
      licenseId,
      hospitalType,
      specialties,
      totalBeds,
      emergencyServices,
      ambulanceServices,
      website,
      establishedYear,
      adminDetails,
      rhoAssignment // Add RHO assignment data
    } = req.body;

    // Check if registration number or license ID already exists
    const existingHospital = await Hospital.findOne({
      $or: [
        { 'licenses.registrationNumber': registrationNumber },
        { 'licenses.licenseNumber': licenseId }
      ]
    });

    if (existingHospital) {
      return res.status(400).json({
        success: false,
        message: 'Hospital with this registration number or license ID already exists'
      });
    }

    // Check if admin username or email already exists
    const existingAdmin = await HospitalAdmin.findOne({
      $or: [
        { username: adminDetails.username },
        { email: adminDetails.email }
      ]
    });

    if (existingAdmin) {
      return res.status(400).json({
        success: false,
        message: 'Admin username or email already exists'
      });
    }

    // Validate location data against JSON data
    try {
      const availableStates = AreaAssignmentService.getAvailableStates();
      const stateExists = availableStates.find(s => s.name === address.state);
      
      if (!stateExists) {
        return res.status(400).json({
          success: false,
          message: `Invalid state: ${address.state}. Please check the state name.`
        });
      }

      const districtsForState = AreaAssignmentService.getDistrictsForState(address.state);
      const districtExists = districtsForState.find(d => d.name === (address.district || address.city));
      
      if (!districtExists) {
        return res.status(400).json({
          success: false,
          message: `Invalid district: ${address.district || address.city} for state ${address.state}. Please check the district name.`
        });
      }

      console.log(`✅ Location validation passed: ${address.state}, ${address.district || address.city}`);
      
    } catch (locationError) {
      console.error('Location validation error:', locationError);
      return res.status(400).json({
        success: false,
        message: 'Location validation failed. Please check state and district names.',
        details: locationError.message
      });
    }

    // Generate unique hospital ID
    const hospitalId = `HOSP_${address.state.substring(0, 2).toUpperCase()}_${Date.now()}`;

    // Map frontend service names to schema enum values
    const serviceMapping = {
      'General Medicine': 'Laboratory',
      'Cardiology': 'Health Checkup',
      'Neurology': 'Laboratory',
      'Orthopedics': 'Surgery',
      'Dermatology': 'Laboratory',
      'Gynecology': 'Maternity',
      'Pediatrics': 'Pediatric Care',
      'Emergency Medicine': '24x7 Emergency',
      'Surgery': 'Surgery',
      'Radiology': 'Radiology',
      'Pathology': 'Laboratory'
    };

    // Map specialties to valid services
    const validServices = specialties ? specialties.map(specialty => {
      return serviceMapping[specialty] || 'Health Checkup';
    }).filter((service, index, arr) => arr.indexOf(service) === index) : ['Health Checkup'];

    // Calculate total staff (estimate based on bed count)
    const estimatedTotalStaff = Math.max(Math.round((totalBeds || 50) * 0.6), 10);

    // Create hospital
    const hospital = new Hospital({
      hospitalId: hospitalId,
      name: hospitalName,
      location: {
        address: address.street,
        city: address.city,
        state: address.state,
        district: address.district || address.city,
        pincode: address.pincode
      },
      region: {
        state: address.state,
        district: address.district || address.city
      },
      contact: {
        phone: contactNumber,
        email: email,
        website,
        emergencyNumber: contactNumber
      },
      licenses: {
        registrationNumber,
        licenseNumber: licenseId,
        issuingAuthority: 'State Medical Board',
        issueDate: new Date(),
        expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year from now
        renewalRequired: false
      },
      type: hospitalType,
      services: validServices,
      capacity: {
        totalBeds: totalBeds || 50,
        totalStaff: estimatedTotalStaff
      },
      facilities: {
        emergencyServices: emergencyServices !== false,
        ambulanceService: ambulanceServices !== false
      },
      establishedDate: establishedYear ? new Date(establishedYear, 0, 1) : new Date(),
      // Remove status: 'Active' as it defaults to 'Under Review' for new hospitals
      // status will be set to 'Active' only after RHO approval
    });

    // Process RHO assignment if provided
    if (rhoAssignment && rhoAssignment.assignedRHOId) {
      // Find the RHO by officerId (which is what the frontend sends)
      const RegionalHealthOfficer = require('../models/RegionalHealthOfficer');
      const assignedRHO = await RegionalHealthOfficer.findOne({ 
        officerId: rhoAssignment.assignedRHOId 
      });
      
      if (assignedRHO) {
        hospital.managedBy = assignedRHO._id;
        console.log(`✅ Hospital assigned to RHO: ${rhoAssignment.assignedRHOId}`);
      } else {
        console.log(`⚠️ RHO not found: ${rhoAssignment.assignedRHOId}`);
      }
    }

    await hospital.save();

    // Create hospital admin using the hospitalId we generated
    const admin = new HospitalAdmin({
      adminId: `${hospitalId}_ADMIN`,
      hospitalId: hospitalId,
      username: adminDetails.username,
      password: adminDetails.password, // Plain text as requested
      adminName: adminDetails.adminName,
      email: adminDetails.adminEmail,
      contactNumber: adminDetails.adminPhone
    });

    await admin.save();

    res.status(201).json({
      success: true,
      message: 'Hospital registration submitted successfully. Your registration is now pending approval from your Regional Health Officer. You will be able to login once approved.',
      data: {
        hospital: {
          hospitalId: hospital.hospitalId,
          name: hospital.name,
          location: hospital.location,
          approval: {
            status: hospital.approval.status,
            submittedAt: hospital.approval.submittedAt
          }
        },
        admin: {
          adminId: admin.adminId,
          username: admin.username,
          adminName: admin.adminName
        }
      }
    });

  } catch (error) {
    console.error('Register hospital error:', error);
    
    if (error.name === 'ValidationError') {
      const errors = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Server error during hospital registration'
    });
  }
};

/**
 * @desc    Update hospital details
 * @route   PUT /api/hospital/:hospitalId
 * @access  Private (Hospital Admin)
 */
const updateHospital = async (req, res) => {
  try {
    const { hospitalId } = req.params;
    const updates = req.body;
    
    const hospital = await Hospital.findOneAndUpdate(
      { hospitalId, isActive: true },
      { ...updates, updatedAt: new Date() },
      { new: true, runValidators: true }
    );
    
    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Hospital updated successfully',
      data: hospital
    });
  } catch (error) {
    console.error('Update hospital error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating hospital'
    });
  }
};

/**
 * @desc    Delete/deactivate hospital
 * @route   DELETE /api/hospital/:hospitalId
 * @access  Private (System Admin)
 */
const deleteHospital = async (req, res) => {
  try {
    const { hospitalId } = req.params;
    
    const hospital = await Hospital.findOneAndUpdate(
      { hospitalId },
      { isActive: false, updatedAt: new Date() },
      { new: true }
    );
    
    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found'
      });
    }
    
    // Also deactivate admin
    await HospitalAdmin.updateOne(
      { hospitalId },
      { isActive: false, updatedAt: new Date() }
    );
    
    res.json({
      success: true,
      message: 'Hospital deactivated successfully'
    });
  } catch (error) {
    console.error('Delete hospital error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deactivating hospital'
    });
  }
};

module.exports = {
  getAllHospitals,
  getHospitalById,
  registerHospital,
  updateHospital,
  deleteHospital,
  searchHospitals
};