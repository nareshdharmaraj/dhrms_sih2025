const express = require('express');
const router = express.Router();

// Placeholder routes for other features
router.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'Prescriptions API endpoint',
    endpoints: {
      'GET /': 'Get all prescriptions',
      'POST /': 'Create new prescription',
      'GET /:id': 'Get prescription by ID',
      'PUT /:id': 'Update prescription',
      'DELETE /:id': 'Delete prescription'
    }
  });
});

module.exports = router;
