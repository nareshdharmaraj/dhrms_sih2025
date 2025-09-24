const WhoAdmin = require('../models/WhoAdmin');
const RegionalOfficer = require('../models/RegionalOfficer');
const Hospital = require('../models/Hospital');
// Import Patient model with error handling
let Patient;
try {
  Patient = require('../models/Patient');
} catch (error) {
  console.warn('Patient model not found, using mock data for patient statistics');
  Patient = null;
}
const { validationResult } = require('express-validator');

// Get dashboard statistics
const getDashboardStats = async (req, res) => {
  try {
    const adminId = req.admin.adminId;
    const admin = await WhoAdmin.findById(adminId);

    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }

    // Get statistics based on admin's managed states
    let stateFilter = {};
    if (admin.managedStates && admin.managedStates.length > 0) {
      stateFilter = { 'location.state': { $in: admin.managedStates } };
    }

    // Parallel queries for better performance
    const [
      totalHospitals,
      activeHospitals,
      totalRegionalOfficers,
      activeRegionalOfficers,
      totalPatients,
      recentPatients
    ] = await Promise.all([
      Hospital.countDocuments({ ...stateFilter, isActive: true }),
      Hospital.countDocuments({ ...stateFilter, isActive: true, status: 'Active' }),
      RegionalOfficer.countDocuments({ isActive: true }),
      RegionalOfficer.countDocuments({ isActive: true, status: 'Active' }),
      Patient ? Patient.countDocuments({}) : Promise.resolve(0),
      Patient ? Patient.countDocuments({
        createdAt: { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }
      }) : Promise.resolve(0)
    ]);

    // Calculate percentages
    const hospitalActivePercentage = totalHospitals > 0 ? 
      Math.round((activeHospitals / totalHospitals) * 100) : 0;
    
    const officerActivePercentage = totalRegionalOfficers > 0 ? 
      Math.round((activeRegionalOfficers / totalRegionalOfficers) * 100) : 0;

    const stats = {
      totalHospitals,
      activeHospitals,
      hospitalActivePercentage,
      totalRegionalOfficers,
      activeRegionalOfficers,
      officerActivePercentage,
      totalPatients,
      recentPatients,
      managedStates: admin.managedStates || [],
      lastUpdated: new Date()
    };

    // For now, return empty stateStats array until we implement state-wise statistics
    const stateStats = [];

    const responseData = {
      success: true,
      statistics: stats,    // Changed from 'stats' to 'statistics'
      stateStats: stateStats // Added missing stateStats
    };

    console.log('🔍 Dashboard response data:', JSON.stringify(responseData, null, 2));
    res.status(200).json(responseData);

  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching dashboard statistics'
    });
  }
};

// Get all states statistics
const getAllStatesStatistics = async (req, res) => {
  try {
    const states = [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
      'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
      'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
      'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
    ];

    const stateStats = await Promise.all(
      states.map(async (state) => {
        const [hospitals, officers, patients] = await Promise.all([
          Hospital.find({ 'location.state': state, isActive: true }),
          RegionalOfficer.countDocuments({ state, isActive: true }),
          Patient ? Patient.countDocuments({}) : Promise.resolve(0) // You might want to add state filtering for patients
        ]);

        // Calculate average patient age (simplified - you might need to adjust based on your Patient model)
        const averageAge = 35; // Placeholder - implement actual calculation

        return {
          state,
          totalHospitals: hospitals.length,
          totalPatients: patients,
          totalRegionalOfficers: officers,
          averagePatientAge: averageAge,
          hospitals: hospitals.map(h => ({
            id: h._id,
            name: h.name,
            type: h.type,
            totalBeds: h.capacity.totalBeds,
            totalStaff: h.capacity.totalStaff,
            rating: h.rating.overall
          }))
        };
      })
    );

    res.status(200).json({
      success: true,
      stateStats: stateStats.filter(stat => stat.totalHospitals > 0 || stat.totalRegionalOfficers > 0)
    });

  } catch (error) {
    console.error('Get all states statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching state statistics'
    });
  }
};

// Get regional officers
const getRegionalOfficers = async (req, res) => {
  try {
    const { state, status, page = 1, limit = 10, search } = req.query;
    
    // Build filter
    let filter = { isActive: true };
    
    if (state && state !== 'ALL') {
      filter.state = state;
    }
    
    if (status) {
      filter.status = status;
    }

    if (search) {
      filter.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { officerId: { $regex: search, $options: 'i' } }
      ];
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Get officers with pagination
    const [officers, total] = await Promise.all([
      RegionalOfficer.find(filter)
        .select('-password')
        .skip(skip)
        .limit(parseInt(limit))
        .sort({ createdAt: -1 }),
      RegionalOfficer.countDocuments(filter)
    ]);

    res.status(200).json({
      success: true,
      officers,
      pagination: {
        current: parseInt(page),
        total: Math.ceil(total / parseInt(limit)),
        count: total
      }
    });

  } catch (error) {
    console.error('Get regional officers error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching regional officers'
    });
  }
};

// Add regional officer
const addRegionalOfficer = async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const adminId = req.admin.adminId;
    const officerData = {
      ...req.body,
      managedBy: adminId,
      isActive: true
    };

    const officer = new RegionalOfficer(officerData);
    await officer.save();

    res.status(201).json({
      success: true,
      message: 'Regional officer added successfully',
      officer: officer.toJSON()
    });

  } catch (error) {
    console.error('Add regional officer error:', error);
    
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Officer ID or email already exists'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Server error adding regional officer'
    });
  }
};

// Update regional officer
const updateRegionalOfficer = async (req, res) => {
  try {
    const { officerId } = req.params;
    const updateData = { ...req.body, updatedAt: new Date() };

    // Remove fields that shouldn't be updated
    delete updateData.managedBy;
    delete updateData._id;
    delete updateData.__v;

    const officer = await RegionalOfficer.findByIdAndUpdate(
      officerId,
      updateData,
      { new: true, runValidators: true }
    );

    if (!officer) {
      return res.status(404).json({
        success: false,
        message: 'Regional officer not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Regional officer updated successfully',
      officer: officer.toJSON()
    });

  } catch (error) {
    console.error('Update regional officer error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error updating regional officer'
    });
  }
};

// Deactivate regional officer
const deactivateRegionalOfficer = async (req, res) => {
  try {
    const { officerId } = req.params;

    const officer = await RegionalOfficer.findByIdAndUpdate(
      officerId,
      { 
        isActive: false, 
        status: 'Inactive',
        updatedAt: new Date()
      },
      { new: true }
    );

    if (!officer) {
      return res.status(404).json({
        success: false,
        message: 'Regional officer not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Regional officer deactivated successfully',
      officer: officer.toJSON()
    });

  } catch (error) {
    console.error('Deactivate regional officer error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error deactivating regional officer'
    });
  }
};

// Get all hospitals (view-only for WHO admins)
const getAllHospitals = async (req, res) => {
  try {
    const { state, status, type, page = 1, limit = 10, search } = req.query;
    
    // Build filter
    let filter = { isActive: true };
    
    if (state && state !== 'ALL') {
      filter['location.state'] = state;
    }
    
    if (status) {
      filter.status = status;
    }

    if (type) {
      filter.type = type;
    }

    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { 'location.city': { $regex: search, $options: 'i' } },
        { hospitalId: { $regex: search, $options: 'i' } }
      ];
    }

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Get hospitals with pagination
    const [hospitals, total] = await Promise.all([
      Hospital.find(filter)
        .populate('managedBy', 'fullName officerId')
        .skip(skip)
        .limit(parseInt(limit))
        .sort({ createdAt: -1 }),
      Hospital.countDocuments(filter)
    ]);

    res.status(200).json({
      success: true,
      hospitals,
      pagination: {
        current: parseInt(page),
        total: Math.ceil(total / parseInt(limit)),
        count: total
      }
    });

  } catch (error) {
    console.error('Get all hospitals error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching hospitals'
    });
  }
};

// Export data
const exportData = async (req, res) => {
  try {
    const { type, format, state } = req.query;
    
    let data = [];
    let filename = '';

    switch (type) {
      case 'hospitals':
        const hospitalFilter = state ? { 'location.state': state, isActive: true } : { isActive: true };
        data = await Hospital.find(hospitalFilter)
          .populate('managedBy', 'fullName officerId')
          .select('-__v')
          .lean();
        filename = `hospitals_${state || 'all'}_${Date.now()}`;
        break;

      case 'officers':
        const officerFilter = state ? { state, isActive: true } : { isActive: true };
        data = await RegionalOfficer.find(officerFilter)
          .select('-password -__v')
          .lean();
        filename = `regional_officers_${state || 'all'}_${Date.now()}`;
        break;

      case 'statistics':
        // Export state-wise statistics
        data = await getAllStatesStatistics(req, res);
        return; // This function already sends response

      default:
        return res.status(400).json({
          success: false,
          message: 'Invalid export type'
        });
    }

    // Set appropriate headers for download
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', `attachment; filename=${filename}.json`);
    
    res.status(200).json({
      success: true,
      data,
      exportInfo: {
        type,
        format,
        count: data.length,
        exportedAt: new Date(),
        filename: `${filename}.${format || 'json'}`
      }
    });

  } catch (error) {
    console.error('Export data error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error exporting data'
    });
  }
};

// Get comprehensive analytics with hierarchy data
const getComprehensiveAnalytics = async (req, res) => {
  try {
    const adminId = req.admin.adminId;
    const admin = await WhoAdmin.findById(adminId);

    if (!admin) {
      return res.status(404).json({
        success: false,
        message: 'Admin not found'
      });
    }

    // Get comprehensive hierarchy data
    const states = [
      'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
      'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
      'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
      'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
      'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
      'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
    ];

    // Get state-wise detailed analytics
    const stateAnalytics = await Promise.all(
      states.map(async (state) => {
        const [hospitals, officers, patients] = await Promise.all([
          Hospital.find({ 'location.state': state, isActive: true }),
          RegionalOfficer.countDocuments({ state, isActive: true }),
          Patient ? Patient.countDocuments({}) : Promise.resolve(0)
        ]);

        // Calculate doctors and assistants for each hospital in the state
        let totalDoctors = 0;
        let totalAssistants = 0;
        
        for (const hospital of hospitals) {
          // Simulate doctor and assistant counts based on hospital capacity
          const doctorCount = Math.floor((hospital.capacity?.totalBeds || 50) * 0.15); // ~15% of beds
          const assistantCount = Math.floor((hospital.capacity?.totalBeds || 50) * 0.10); // ~10% of beds
          
          totalDoctors += doctorCount;
          totalAssistants += assistantCount;
        }

        // Calculate performance metrics (simulated)
        const hospitalEfficiency = Math.min(95, 70 + Math.random() * 25);
        const staffSatisfaction = Math.min(95, 75 + Math.random() * 20);

        return {
          state,
          shos: 1, // One SHO per state
          rhos: officers,
          hospitals: hospitals.length,
          doctors: totalDoctors,
          assistants: totalAssistants,
          totalPatients: patients,
          hospitalEfficiency: Math.round(hospitalEfficiency * 10) / 10,
          staffSatisfaction: Math.round(staffSatisfaction * 10) / 10,
          hospitalDetails: hospitals.map(h => ({
            id: h._id,
            name: h.name,
            type: h.type,
            beds: h.capacity?.totalBeds || 0,
            occupancyRate: Math.round((60 + Math.random() * 35) * 10) / 10,
            rating: h.rating?.overall || 0
          }))
        };
      })
    );

    // Filter out states with no data
    const filteredStateAnalytics = stateAnalytics.filter(
      stat => stat.hospitals > 0 || stat.rhos > 0
    );

    // Calculate totals
    const totals = filteredStateAnalytics.reduce(
      (acc, state) => ({
        totalSHOs: acc.totalSHOs + state.shos,
        totalRHOs: acc.totalRHOs + state.rhos,
        totalHospitals: acc.totalHospitals + state.hospitals,
        totalDoctors: acc.totalDoctors + state.doctors,
        totalAssistants: acc.totalAssistants + state.assistants,
        totalPatients: acc.totalPatients + state.totalPatients,
      }),
      {
        totalSHOs: 0,
        totalRHOs: 0,
        totalHospitals: 0,
        totalDoctors: 0,
        totalAssistants: 0,
        totalPatients: 0,
      }
    );

    // Generate chart data
    const hospitalDistribution = [
      { name: 'Government', value: 45.2, color: '#2196F3' },
      { name: 'Private', value: 38.5, color: '#4CAF50' },
      { name: 'Trust', value: 12.8, color: '#FF9800' },
      { name: 'Corporate', value: 3.5, color: '#9C27B0' },
    ];

    const staffDistribution = [
      { name: 'Doctors', value: 42.8, color: '#F44336' },
      { name: 'Nurses', value: 35.2, color: '#2196F3' },
      { name: 'Technicians', value: 15.5, color: '#4CAF50' },
      { name: 'Assistants', value: 6.5, color: '#FF9800' },
    ];

    // Generate health trends (last 6 months)
    const healthTrends = [];
    for (let i = 5; i >= 0; i--) {
      const date = new Date();
      date.setMonth(date.getMonth() - i);
      healthTrends.push({
        date: date.toISOString(),
        value: Math.floor(800 + Math.random() * 400 + i * 50)
      });
    }

    res.status(200).json({
      success: true,
      analytics: {
        hierarchy: {
          totals,
          stateBreakdown: filteredStateAnalytics
        },
        charts: {
          hospitalDistribution,
          staffDistribution
        },
        trends: {
          healthTrends
        },
        performance: {
          averageHospitalEfficiency: filteredStateAnalytics.reduce(
            (sum, state) => sum + state.hospitalEfficiency, 0
          ) / filteredStateAnalytics.length,
          averageStaffSatisfaction: filteredStateAnalytics.reduce(
            (sum, state) => sum + state.staffSatisfaction, 0
          ) / filteredStateAnalytics.length,
          totalCoverage: 95.8 // Simulated coverage percentage
        },
        lastUpdated: new Date()
      }
    });

  } catch (error) {
    console.error('Get comprehensive analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error fetching comprehensive analytics'
    });
  }
};

module.exports = {
  getDashboardStats,
  getAllStatesStatistics,
  getRegionalOfficers,
  addRegionalOfficer,
  updateRegionalOfficer,
  deactivateRegionalOfficer,
  getAllHospitals,
  exportData,
  getComprehensiveAnalytics
};