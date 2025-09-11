const express = require('express');
const router = express.Router();
const wearableController = require('../controllers/wearableController');

// Device management routes
router.post('/devices/register', wearableController.registerDevice);
router.get('/devices/patient/:patientId', wearableController.getPatientDevices);
router.put('/devices/:deviceId/status', wearableController.updateDeviceStatus);
router.delete('/devices/:deviceId', wearableController.deleteDevice);

// Data storage routes
router.post('/data/store', wearableController.storeWearableData);
router.get('/data/latest/:patientId', wearableController.getLatestData);
router.get('/data/hourly/:patientId', wearableController.getHourlyData);

// Alert and monitoring routes
router.get('/alerts/:patientId', wearableController.getAlerts);
router.get('/dashboard/:patientId', wearableController.getHealthDashboard);

module.exports = router;
