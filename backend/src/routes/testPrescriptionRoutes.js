const express = require('express');
const mongoose = require('mongoose');
const HospitalPrescription = require('../models/HospitalPrescription');

const router = express.Router();

// Test route without authentication
router.post('/test-no-auth', async (req, res) => {
  try {
    console.log('\n🔄 === TEST PRESCRIPTION CREATION (NO AUTH) ===');
    console.log('📋 Request body received:', JSON.stringify(req.body, null, 2));
    
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

    console.log('💾 Creating prescription object...');
    
    // Create the prescription
    const prescription = new HospitalPrescription({
      appointmentId: appointmentId || new mongoose.Types.ObjectId(),
      doctorId: doctorId || new mongoose.Types.ObjectId(),
      patientId: patientId || new mongoose.Types.ObjectId(),
      hospitalId: hospitalId || new mongoose.Types.ObjectId(),
      patientName: patientName || 'Test Patient',
      patientUHID: patientUHID || 'TEST-UHID',
      doctorName: doctorName || 'Test Doctor',
      doctorIdentifier: doctorIdentifier || 'TEST-DOC',
      hospitalName: hospitalName || 'Test Hospital',
      hospitalAddress: hospitalAddress || 'Test Address',
      hospitalContact: hospitalContact || { phone: '1234567890', email: 'test@test.com' },
      appointmentNumber: appointmentNumber || 'TEST-APT',
      diseaseName: diseaseName || 'Test Disease',
      diseaseType: diseaseType || 'not_communicable',
      expectedRecoveryDays: expectedRecoveryDays,
      medicines: medicines || [],
      nextVisitDate: nextVisitDate ? new Date(nextVisitDate) : undefined,
      nextVisitMandatory: nextVisitMandatory || false,
      isConfirmed: isConfirmed || false,
      confirmedAt: isConfirmed ? new Date() : undefined
    });

    console.log('💾 Attempting to save prescription...');
    const savedPrescription = await prescription.save();
    console.log('✅ Prescription saved with ID:', savedPrescription._id);

    res.status(201).json({
      success: true,
      message: 'Test prescription created successfully',
      data: savedPrescription
    });

  } catch (error) {
    console.error('\n❌ === TEST PRESCRIPTION ERROR ===');
    console.error('Error type:', error.constructor.name);
    console.error('Error message:', error.message);
    console.error('Full error:', error);
    
    res.status(500).json({
      success: false,
      message: 'Failed to create test prescription',
      error: error.message
    });
  }
});

module.exports = router;