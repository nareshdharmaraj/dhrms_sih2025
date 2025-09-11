const express = require('express');
const router = express.Router();
const {
  registerPatient,
  getPatientByUHID,
  registerMigration,
  getDigitalCard,
  getMigrantPatients
} = require('../controllers/patientController');

// Patient Registration
router.post('/register', registerPatient);

// Get Patient by UHID (for QR code scanning)
router.get('/uhid/:uhid', getPatientByUHID);

// Register Migration
router.post('/migrate/:uhid', registerMigration);

// Get Digital Health Card
router.get('/digital-card/:uhid', getDigitalCard);

// Get Migrant Patients (for hospitals/regional officers)
router.get('/migrants', getMigrantPatients);

module.exports = router;
