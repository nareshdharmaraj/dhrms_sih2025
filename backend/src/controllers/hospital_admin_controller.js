const HospitalAdmin = require('../models/HospitalAdmin');
const HospitalDoctor = require('../models/HospitalDoctor');
const HospitalAssistant = require('../models/HospitalAssistant');
const Hospital = require('../models/Hospital');
const jwt = require('jsonwebtoken');

// ==================== HOSPITAL ADMIN CONTROLLERS ====================

/**
 * @desc    Hospital admin login
 * @route   POST /api/hospital-admin/login
 * @access  Public
 */
const adminLogin = async (req, res) => {
  try {
    const { hospitalId, username, password } = req.body;

    if (!hospitalId || !username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Hospital ID, username, and password are required'
      });
    }

    // Check if hospital exists and is active
    const hospital = await Hospital.findOne({ 
      hospitalId, 
      isActive: true,
      status: 'Active' 
    });

    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found or inactive'
      });
    }

    // Find admin for this hospital
    const admin = await HospitalAdmin.findOne({
      hospitalId,
      username,
      isActive: true
    });

    if (!admin) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Check account lock
    if (admin.accountLocked && admin.lockUntil > new Date()) {
      return res.status(423).json({
        success: false,
        message: 'Account is temporarily locked due to multiple failed login attempts'
      });
    }

    // Validate password (plain text comparison as requested)
    if (admin.password !== password) {
      // Increment failed login attempts
      admin.failedLoginAttempts += 1;
      
      if (admin.failedLoginAttempts >= 5) {
        admin.accountLocked = true;
        admin.lockUntil = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes
      }
      
      await admin.save();
      
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Reset failed attempts on successful login
    admin.failedLoginAttempts = 0;
    admin.accountLocked = false;
    admin.lockUntil = null;
    admin.lastLoginAt = new Date();
    await admin.save();

    // Create JWT token
    const token = jwt.sign(
      { 
        adminId: admin.adminId,
        hospitalId: admin.hospitalId,
        role: 'hospital_admin'
      },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '24h' }
    );

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        admin: {
          adminId: admin.adminId,
          adminName: admin.adminName,
          username: admin.username,
          email: admin.email,
          hospitalId: admin.hospitalId,
          hospitalName: hospital.name,
          permissions: admin.permissions
        }
      }
    });

  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error during login'
    });
  }
};

/**
 * @desc    Get admin dashboard data
 * @route   GET /api/hospital-admin/dashboard
 * @access  Private (Hospital Admin)
 */
const getAdminDashboard = async (req, res) => {
  try {
    const { hospitalId, adminId } = req.admin;

    // Get hospital information
    const hospital = await Hospital.findOne({ hospitalId });
    if (!hospital) {
      return res.status(404).json({
        success: false,
        message: 'Hospital not found'
      });
    }

    // Get admin information
    const admin = await HospitalAdmin.findOne({ adminId, hospitalId });
    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }

    // Get all doctors
    const doctors = await HospitalDoctor.find({ hospitalId })
      .select('-password')
      .sort({ createdAt: -1 });

    // Get all assistants with populated doctor info
    const assistants = await HospitalAssistant.find({ hospitalId })
      .populate('assignedDoctor', 'doctorName specialization')
      .select('-password')
      .sort({ createdAt: -1 });

    // Calculate stats
    const totalDoctors = await HospitalDoctor.countDocuments({ hospitalId });
    const totalAssistants = await HospitalAssistant.countDocuments({ hospitalId });
    const activeDoctors = await HospitalDoctor.countDocuments({ hospitalId, isActive: true });
    const activeAssistants = await HospitalAssistant.countDocuments({ hospitalId, isActive: true });

    res.json({
      success: true,
      data: {
        hospital: {
          hospitalId: hospital.hospitalId,
          hospitalName: hospital.name,
          hospitalType: hospital.type,
          contactNumber: hospital.contactNumber,
          email: hospital.email,
          totalBeds: hospital.totalBeds,
          emergencyServices: hospital.emergencyServices,
          ambulanceServices: hospital.ambulanceServices
        },
        admin: {
          adminId: admin.adminId,
          adminName: admin.adminName,
          username: admin.username,
          email: admin.email
        },
        stats: {
          totalDoctors,
          totalAssistants,
          activeDoctors,
          activeAssistants
        },
        doctors,
        assistants
      }
    });

  } catch (error) {
    console.error('Get admin dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching dashboard data'
    });
  }
};

/**
 * @desc    Create new doctor
 * @route   POST /api/hospital-admin/doctors
 * @access  Private (Hospital Admin)
 */
const createDoctor = async (req, res) => {
  try {
    const { hospitalId } = req.admin;
    const {
      doctorName,
      username,
      password,
      email,
      contactNumber,
      specialization,
      qualifications,
      department,
      dutySchedule,
      emergencyContact
    } = req.body;

    // Check if username or email already exists
    const existingDoctor = await HospitalDoctor.findOne({
      $or: [
        { username },
        { email }
      ]
    });

    if (existingDoctor) {
      return res.status(400).json({
        success: false,
        message: 'Doctor with this username or email already exists'
      });
    }

    // Create doctor
    const doctor = new HospitalDoctor({
      hospitalId,
      doctorName,
      username,
      password, // Plain text as requested
      email,
      contactNumber,
      specialization,
      qualifications: qualifications || [],
      department,
      dutySchedule: dutySchedule || {},
      emergencyContact,
      joiningDate: new Date()
    });

    await doctor.save();

    res.status(201).json({
      success: true,
      message: 'Doctor created successfully',
      data: {
        doctorId: doctor.doctorId,
        doctorName: doctor.doctorName,
        username: doctor.username,
        email: doctor.email,
        specialization: doctor.specialization,
        department: doctor.department
      }
    });

  } catch (error) {
    console.error('Create doctor error:', error);
    
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
      message: 'Server error while creating doctor'
    });
  }
};

/**
 * @desc    Get all doctors
 * @route   GET /api/hospital-admin/doctors
 * @access  Private (Hospital Admin)
 */
const getAllDoctors = async (req, res) => {
  try {
    const { hospitalId } = req.admin;
    const { page = 1, limit = 10, search = '', specialization = '' } = req.query;

    const query = {
      hospitalId,
      isActive: true
    };

    if (search) {
      query.$or = [
        { doctorName: { $regex: search, $options: 'i' } },
        { doctorId: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    if (specialization) {
      query.specialization = specialization;
    }

    const doctors = await HospitalDoctor.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await HospitalDoctor.countDocuments(query);

    res.json({
      success: true,
      data: doctors,
      pagination: {
        page: parseInt(page),
        pages: Math.ceil(total / limit),
        total
      }
    });

  } catch (error) {
    console.error('Get all doctors error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching doctors'
    });
  }
};

/**
 * @desc    Create new assistant
 * @route   POST /api/hospital-admin/assistants
 * @access  Private (Hospital Admin)
 */
const createAssistant = async (req, res) => {
  try {
    const { hospitalId } = req.admin;
    const {
      assistantName,
      username,
      password,
      email,
      contactNumber,
      designation,
      department,
      assignedDoctorId,
      dutySchedule,
      emergencyContact
    } = req.body;

    // Check if username or email already exists
    const existingAssistant = await HospitalAssistant.findOne({
      $or: [
        { username },
        { email }
      ]
    });

    if (existingAssistant) {
      return res.status(400).json({
        success: false,
        message: 'Assistant with this username or email already exists'
      });
    }

    // Validate assigned doctor if provided
    if (assignedDoctorId) {
      const doctor = await HospitalDoctor.findOne({
        doctorId: assignedDoctorId,
        hospitalId,
        isActive: true
      });

      if (!doctor) {
        return res.status(404).json({
          success: false,
          message: 'Assigned doctor not found'
        });
      }
    }

    // Create assistant
    const assistant = new HospitalAssistant({
      hospitalId,
      assistantName,
      username,
      password, // Plain text as requested
      email,
      contactNumber,
      designation,
      department,
      assignedDoctorId,
      dutySchedule: dutySchedule || {},
      emergencyContact,
      joiningDate: new Date()
    });

    await assistant.save();

    res.status(201).json({
      success: true,
      message: 'Assistant created successfully',
      data: {
        assistantId: assistant.assistantId,
        assistantName: assistant.assistantName,
        username: assistant.username,
        email: assistant.email,
        designation: assistant.designation,
        department: assistant.department,
        assignedDoctorId: assistant.assignedDoctorId
      }
    });

  } catch (error) {
    console.error('Create assistant error:', error);
    
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
      message: 'Server error while creating assistant'
    });
  }
};

/**
 * @desc    Get all assistants
 * @route   GET /api/hospital-admin/assistants
 * @access  Private (Hospital Admin)
 */
const getAllAssistants = async (req, res) => {
  try {
    const { hospitalId } = req.admin;
    const { page = 1, limit = 10, search = '', department = '' } = req.query;

    const query = {
      hospitalId,
      isActive: true
    };

    if (search) {
      query.$or = [
        { assistantName: { $regex: search, $options: 'i' } },
        { assistantId: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    if (department) {
      query.department = department;
    }

    const assistants = await HospitalAssistant.find(query)
      .select('-password')
      .populate('assignedDoctorId', 'doctorName specialization')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await HospitalAssistant.countDocuments(query);

    res.json({
      success: true,
      data: assistants,
      pagination: {
        page: parseInt(page),
        pages: Math.ceil(total / limit),
        total
      }
    });

  } catch (error) {
    console.error('Get all assistants error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching assistants'
    });
  }
};

/**
 * @desc    Update doctor details
 * @route   PUT /api/hospital-admin/doctors/:doctorId
 * @access  Private (Hospital Admin)
 */
const updateDoctor = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { hospitalId } = req.admin;
    const updates = req.body;

    const doctor = await HospitalDoctor.findOneAndUpdate(
      { doctorId, hospitalId, isActive: true },
      { ...updates, updatedAt: new Date() },
      { new: true, runValidators: true }
    ).select('-password');

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    res.json({
      success: true,
      message: 'Doctor updated successfully',
      data: doctor
    });

  } catch (error) {
    console.error('Update doctor error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating doctor'
    });
  }
};

/**
 * @desc    Delete/deactivate doctor
 * @route   DELETE /api/hospital-admin/doctors/:doctorId
 * @access  Private (Hospital Admin)
 */
const deleteDoctor = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { hospitalId } = req.admin;

    const doctor = await HospitalDoctor.findOneAndUpdate(
      { doctorId, hospitalId },
      { isActive: false, updatedAt: new Date() },
      { new: true }
    );

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    // Also update assistants assigned to this doctor
    await HospitalAssistant.updateMany(
      { assignedDoctorId: doctorId, hospitalId },
      { assignedDoctorId: null, updatedAt: new Date() }
    );

    res.json({
      success: true,
      message: 'Doctor deactivated successfully'
    });

  } catch (error) {
    console.error('Delete doctor error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deactivating doctor'
    });
  }
};

/**
 * @desc    Update doctor status (active/inactive)
 * @route   PATCH /api/hospital/admin/doctor/:doctorId/status
 * @access  Private (Hospital Admin)
 */
const updateDoctorStatus = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { isActive } = req.body;
    const { hospitalId } = req.admin;

    if (typeof isActive !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'isActive must be a boolean value'
      });
    }

    const doctor = await HospitalDoctor.findOneAndUpdate(
      { _id: doctorId, hospitalId },
      { 
        isActive,
        updatedAt: new Date()
      },
      { new: true }
    );

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    res.json({
      success: true,
      message: `Doctor ${isActive ? 'activated' : 'deactivated'} successfully`,
      data: doctor
    });

  } catch (error) {
    console.error('Update doctor status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating doctor status'
    });
  }
};

/**
 * @desc    Update assistant status (active/inactive)
 * @route   PATCH /api/hospital/admin/assistant/:assistantId/status
 * @access  Private (Hospital Admin)
 */
const updateAssistantStatus = async (req, res) => {
  try {
    const { assistantId } = req.params;
    const { isActive } = req.body;
    const { hospitalId } = req.admin;

    if (typeof isActive !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'isActive must be a boolean value'
      });
    }

    const assistant = await HospitalAssistant.findOneAndUpdate(
      { _id: assistantId, hospitalId },
      { 
        isActive,
        updatedAt: new Date()
      },
      { new: true }
    );

    if (!assistant) {
      return res.status(404).json({
        success: false,
        message: 'Assistant not found'
      });
    }

    res.json({
      success: true,
      message: `Assistant ${isActive ? 'activated' : 'deactivated'} successfully`,
      data: assistant
    });

  } catch (error) {
    console.error('Update assistant status error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating assistant status'
    });
  }
};

module.exports = {
  adminLogin,
  getAdminDashboard,
  createDoctor,
  getAllDoctors,
  updateDoctor,
  deleteDoctor,
  createAssistant,
  getAllAssistants,
  updateDoctorStatus,
  updateAssistantStatus
};