const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'Analytics API endpoint'
  });
});

module.exports = router;
