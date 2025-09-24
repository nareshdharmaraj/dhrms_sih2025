const express = require('express');
const mongoose = require('mongoose');
const HospitalPrescription = require('../models/HospitalPrescription');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Test route
router.get('/test', (req, res) => {
  res.json({ success: true, message: 'Prescription routes are working!' });
});

// Create a new prescription
router.post('/', authenticateToken, async (req, res) => {
  try {
    console.log('🔄 Creating new prescription...');
    console.log('Request body:', req.body);
    
    const {
      appointmentId,
      doctorId,
      patientId,
      hospitalId,
      patientName,
      patientUHID,
      doctorName,
      doctorIdentifier,
      hospitalName,
      hospitalAddress,
      hospitalContact,
      appointmentNumber,
      diseaseName,
      diseaseType,
      expectedRecoveryDays,
      medicines,
      nextVisitDate,
      nextVisitMandatory,
      isConfirmed
    } = req.body;

    // Basic validation
    if (!appointmentId || !doctorId || !patientId || !hospitalId || !patientName) {
      return res.status(400).json({
        success: false,
        message: 'Required fields missing'
      });
    }

    // Create the prescription
    const prescription = new HospitalPrescription({
      appointmentId,
      doctorId,
      patientId,
      hospitalId,
      patientName,
      patientUHID: patientUHID || 'TEMP-UHID',
      doctorName: doctorName || 'Unknown Doctor',
      doctorId: doctorIdentifier || 'TEMP-DOC-ID',
      hospitalName: hospitalName || 'Unknown Hospital',
      hospitalAddress: hospitalAddress || '',
      hospitalContact: hospitalContact || {},
      appointmentNumber: appointmentNumber || 'TEMP-APT',
      diseaseName: diseaseName || 'Not Specified',
      diseaseType: diseaseType || 'not_communicable',
      expectedRecoveryDays: expectedRecoveryDays,
      medicines: medicines || [],
      nextVisitDate: nextVisitDate ? new Date(nextVisitDate) : undefined,
      nextVisitMandatory: nextVisitMandatory || false,
      isConfirmed: isConfirmed || false,
      confirmedAt: isConfirmed ? new Date() : undefined
    });

    await prescription.save();
    console.log('✅ Prescription created successfully:', prescription._id);

    res.status(201).json({
      success: true,
      message: 'Prescription created successfully',
      data: prescription
    });

  } catch (error) {
    console.error('❌ Error creating prescription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create prescription',
      error: error.message
    });
  }
});

// Get prescriptions by doctor ID
router.get('/doctor/:doctorId', authenticateToken, async (req, res) => {
  try {
    const { doctorId } = req.params;
    
    const prescriptions = await HospitalPrescription.find({ doctorId })
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({
      success: true,
      data: prescriptions
    });
  } catch (error) {
    console.error('❌ Error fetching doctor prescriptions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch prescriptions',
      error: error.message
    });
  }
});

module.exports = router;