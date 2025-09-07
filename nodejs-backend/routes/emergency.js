const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'Emergency API endpoint'
  });
});

module.exports = router;
