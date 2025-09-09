const express = require('express');
const router = express.Router();
const databaseService = require('../services/databaseService');

// Universal login endpoint for all roles
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username and password are required'
      });
    }

    const result = await databaseService.validateUserCredentials(username, password);
    
    if (result.success) {
      res.status(200).json(result);
    } else {
      res.status(401).json(result);
    }
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get all patients
router.get('/patients', async (req, res) => {
  try {
    const patients = await databaseService.getAllPatients();
    res.status(200).json({
      success: true,
      patients: patients
    });
  } catch (error) {
    console.error('Get patients error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get patient by ID
router.get('/patients/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const patient = await databaseService.getPatientById(id);
    
    if (patient) {
      res.status(200).json({
        success: true,
        patient: patient
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }
  } catch (error) {
    console.error('Get patient error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Create new patient
router.post('/patients', async (req, res) => {
  try {
    const result = await databaseService.createPatient(req.body);
    
    if (result.success) {
      res.status(201).json(result);
    } else {
      res.status(400).json(result);
    }
  } catch (error) {
    console.error('Create patient error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get all hospital staff
router.get('/hospital-staff', async (req, res) => {
  try {
    const staff = await databaseService.getAllHospitalStaff();
    res.status(200).json({
      success: true,
      hospitalStaff: staff
    });
  } catch (error) {
    console.error('Get hospital staff error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get hospital staff by ID
router.get('/hospital-staff/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const staff = await databaseService.getHospitalStaffById(id);
    
    if (staff) {
      res.status(200).json({
        success: true,
        staff: staff
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'Hospital staff not found'
      });
    }
  } catch (error) {
    console.error('Get hospital staff error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Create new hospital staff
router.post('/hospital-staff', async (req, res) => {
  try {
    const result = await databaseService.createHospitalStaff(req.body);
    
    if (result.success) {
      res.status(201).json(result);
    } else {
      res.status(400).json(result);
    }
  } catch (error) {
    console.error('Create hospital staff error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get all regional officers
router.get('/regional-officers', async (req, res) => {
  try {
    const officers = await databaseService.getAllRegionalOfficers();
    res.status(200).json({
      success: true,
      regionalOfficers: officers
    });
  } catch (error) {
    console.error('Get regional officers error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get regional officer by ID
router.get('/regional-officers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const officer = await databaseService.getRegionalOfficerById(id);
    
    if (officer) {
      res.status(200).json({
        success: true,
        officer: officer
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'Regional officer not found'
      });
    }
  } catch (error) {
    console.error('Get regional officer error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Create new regional officer
router.post('/regional-officers', async (req, res) => {
  try {
    const result = await databaseService.createRegionalOfficer(req.body);
    
    if (result.success) {
      res.status(201).json(result);
    } else {
      res.status(400).json(result);
    }
  } catch (error) {
    console.error('Create regional officer error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Search user by username across all collections
router.get('/search/:username', async (req, res) => {
  try {
    const { username } = req.params;
    const user = await databaseService.searchUserByUsername(username);
    
    if (user) {
      res.status(200).json({
        success: true,
        user: user
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
  } catch (error) {
    console.error('Search user error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get database statistics
router.get('/stats', async (req, res) => {
  try {
    const stats = await databaseService.getDatabaseStats();
    res.status(200).json({
      success: true,
      statistics: stats
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

module.exports = router;
