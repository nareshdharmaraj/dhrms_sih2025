const express = require('express');
const router = express.Router();
const databaseService = require('../services/databaseService');

// Login endpoint - compare TextField data with database
router.post('/login', async (req, res) => {
  try {
    const { usernameOrEmail, password } = req.body;

    // Validate input
    if (!usernameOrEmail || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username/email and password are required'
      });
    }

    // Validate credentials using database service
    const result = await databaseService.validateUserCredentials(usernameOrEmail, password);
    
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

// Register endpoint - create new user
router.post('/register', async (req, res) => {
  try {
    const { username, email, password, fullName, phone, dateOfBirth, gender, address } = req.body;

    // Validate required fields
    if (!username || !email || !password || !fullName) {
      return res.status(400).json({
        success: false,
        message: 'Username, email, password, and full name are required'
      });
    }

    // Create user data object
    const userData = {
      username,
      email,
      password, // Stored as plain text as requested
      fullName,
      phone,
      dateOfBirth,
      gender,
      address
    };

    // Create user using database service
    const result = await databaseService.createUser(userData);
    
    if (result.success) {
      res.status(201).json(result);
    } else {
      res.status(400).json(result);
    }
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get user by username endpoint
router.get('/user/:username', async (req, res) => {
  try {
    const { username } = req.params;
    
    const user = await databaseService.findUserByUsername(username);
    
    if (user) {
      // Remove password from response
      const { password, ...userWithoutPassword } = user.toObject();
      res.status(200).json({
        success: true,
        user: userWithoutPassword
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Get all users endpoint
router.get('/users', async (req, res) => {
  try {
    const users = await databaseService.getAllUsers();
    res.status(200).json({
      success: true,
      users: users
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Update user endpoint
router.put('/user/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;
    
    // Remove password from update if it exists (for security)
    if (updateData.password) {
      // If updating password, store as plain text as requested
      // In production, you should hash passwords
    }
    
    const result = await databaseService.updateUser(id, updateData);
    
    if (result.success) {
      res.status(200).json(result);
    } else {
      res.status(404).json(result);
    }
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

// Delete user endpoint
router.delete('/user/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await databaseService.deleteUser(id);
    
    if (result.success) {
      res.status(200).json(result);
    } else {
      res.status(404).json(result);
    }
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

module.exports = router;
