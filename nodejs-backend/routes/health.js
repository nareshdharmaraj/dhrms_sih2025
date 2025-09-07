const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'Health monitoring API endpoint'
  });
});

module.exports = router;
