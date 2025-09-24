const express = require('express');
const mongoose = require('mongoose');
const HospitalPrescription = require('../models/HospitalPrescription');
const HospitalAppointment = require('../models/HospitalAppointment');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Create a new prescription
router.post('/', authenticateToken, async (req, res) => {
  try {
    console.log('\n🔄 === PRESCRIPTION CREATION REQUEST ===');
    console.log('🚨 UPDATED VALIDATION CODE IS ACTIVE 🚨');
    console.log('📋 Request body received:', JSON.stringify(req.body, null, 2));
    
    // Basic validation - updated to match new requirements
    const requiredFields = [
      'appointmentId', 'doctorId', 'patientId', 'hospitalId', 
      'patientName', 'patientUHID', 'doctorName', 'doctorIdentifier', 
      'hospitalName', 'appointmentNumber', 'diseases', 'diseaseType', 
      'medicines', 'nextVisitMandatory', 'isConfirmed'
      // Note: nextVisitDate and hospitalContact are now optional
    ];
    
    console.log('🔍 Checking required fields...');
    for (const field of requiredFields) {
      if (!req.body[field]) {
        console.log(`❌ Missing required field: ${field}`);
        return res.status(400).json({
          success: false,
          message: `${field} is required`
        });
      } else {
        console.log(`✅ Field present: ${field}`);
      }
    }

    // Handle expectedRecoveryDays based on disease type
    if (req.body.diseaseType === 'not_communicable') {
      // Set default value for non-communicable diseases
      if (!req.body.expectedRecoveryDays) {
        req.body.expectedRecoveryDays = 0;
        console.log('✅ Set expectedRecoveryDays = 0 for non-communicable disease');
      }
    } else if (req.body.diseaseType === 'communicable') {
      // Validate that expectedRecoveryDays is provided for communicable diseases
      if (!req.body.expectedRecoveryDays || req.body.expectedRecoveryDays <= 0) {
        console.log('❌ Missing or invalid expectedRecoveryDays for communicable disease');
        return res.status(400).json({
          success: false,
          message: 'expectedRecoveryDays is required and must be greater than 0 for communicable diseases'
        });
      }
    }

    // Conditional validation for nextVisitDate based on nextVisitMandatory
    if (req.body.nextVisitMandatory === true) {
      if (!req.body.nextVisitDate) {
        console.log('❌ nextVisitDate is required when nextVisitMandatory is true');
        return res.status(400).json({
          success: false,
          message: 'nextVisitDate is required when next visit is mandatory'
        });
      }
      console.log(`✅ nextVisitDate provided for mandatory visit: ${req.body.nextVisitDate}`);
    } else {
      console.log('✅ nextVisitDate validation skipped - not mandatory');
    }

    // Flexible validation for hospitalContact - allow empty fields
    if (req.body.hospitalContact && typeof req.body.hospitalContact === 'object') {
      console.log(`✅ hospitalContact structure validated: ${JSON.stringify(req.body.hospitalContact)}`);
    } else {
      // If hospitalContact is not provided, create default empty structure
      req.body.hospitalContact = { phone: '', email: '' };
      console.log('✅ Created default hospitalContact structure');
    }

    // Special validation for diseases array
    if (req.body.diseases && Array.isArray(req.body.diseases)) {
      if (req.body.diseases.length === 0) {
        console.log('❌ At least one disease must be selected');
        return res.status(400).json({
          success: false,
          message: 'At least one disease must be selected'
        });
      }
      
      for (let i = 0; i < req.body.diseases.length; i++) {
        const disease = req.body.diseases[i];
        if (!disease.name || disease.name.trim().length === 0) {
          console.log(`❌ Disease at index ${i} must have a name`);
          return res.status(400).json({
            success: false,
            message: `Disease at index ${i} must have a valid name`
          });
        }
      }
      
      // Auto-generate diseaseName from diseases array for backward compatibility
      req.body.diseaseName = req.body.diseases.map(d => d.name).join(', ');
      console.log(`✅ Generated diseaseName: ${req.body.diseaseName}`);
    } else {
      console.log('❌ diseases must be a non-empty array');
      return res.status(400).json({
        success: false,
        message: 'diseases must be a non-empty array of disease objects'
      });
    }

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

    // Check if prescription already exists for this appointment
    const existingPrescription = await HospitalPrescription.findOne({ appointmentId });
    if (existingPrescription) {
      return res.status(409).json({
        success: false,
        message: 'Prescription already exists for this appointment'
      });
    }

    // Validate that the appointment exists and is approved
    const appointment = await HospitalAppointment.findById(appointmentId);
    if (!appointment) {
      console.log('❌ Appointment not found');
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    console.log(`📋 Appointment status: ${appointment.status}`);
    if (appointment.status !== 'approved') {
      console.log('❌ Appointment is not approved for prescription creation');
      return res.status(400).json({
        success: false,
        message: 'Can only create prescription for approved appointments'
      });
    }
    console.log('✅ Appointment is approved for prescription creation');

    // Validate medicines array
    if (!Array.isArray(medicines) || medicines.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'At least one medicine is required'
      });
    }

    for (const medicine of medicines) {
      if (!medicine.type || !['tablet', 'tonic', 'injection'].includes(medicine.type)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid medicine type. Must be tablet, tonic, or injection'
        });
      }

      if (!medicine.name || medicine.name.trim() === '') {
        return res.status(400).json({
          success: false,
          message: 'Medicine name is required'
        });
      }
    }

    // Create the prescription with updated field handling
    const prescription = new HospitalPrescription({
      appointmentId,
      doctorId,
      patientId,
      hospitalId,
      patientName,
      patientUHID,
      doctorName,
      doctorIdentifier,
      hospitalName,
      hospitalAddress: hospitalAddress || '',
      hospitalContact: hospitalContact || { phone: '', email: '' },
      appointmentNumber,
      diseaseName: req.body.diseaseName, // Generated from diseases array
      diseases: req.body.diseases, // New array field for multiple diseases
      diseaseType,
      expectedRecoveryDays: diseaseType === 'communicable' ? expectedRecoveryDays : null,
      medicines,
      nextVisitDate: nextVisitDate || null,
      nextVisitMandatory: nextVisitMandatory || false,
      isConfirmed
      // Note: Removed confirmedAt as it's not in the schema validation
    });

    console.log('💾 Attempting to save prescription to database...');
    console.log('📋 Prescription object to save:', JSON.stringify(prescription.toObject(), null, 2));
    
    // Additional validation logging
    console.log('🔍 Field validation check:');
    console.log(`- appointmentId type: ${typeof prescription.appointmentId} (${prescription.appointmentId})`);
    console.log(`- nextVisitDate type: ${typeof prescription.nextVisitDate} (${prescription.nextVisitDate})`);
    console.log(`- expectedRecoveryDays type: ${typeof prescription.expectedRecoveryDays} (${prescription.expectedRecoveryDays})`);
    console.log(`- medicines count: ${prescription.medicines.length}`);
    
    await prescription.save();
    console.log('✅ Prescription created successfully:', prescription._id);

    // Update appointment status to completed after successful prescription creation
    try {
      await HospitalAppointment.findByIdAndUpdate(appointmentId, { 
        status: 'completed',
        updatedAt: new Date()
      });
      console.log('✅ Appointment status updated to completed');
    } catch (updateError) {
      console.log('⚠️ Warning: Could not update appointment status:', updateError.message);
      // Don't fail the prescription creation if status update fails
    }

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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get prescription by appointment ID
router.get('/appointment/:appointmentId', authenticateToken, async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    const prescription = await HospitalPrescription.findOne({ appointmentId })
      .populate('doctorId', 'name specialization')
      .populate('hospitalId', 'name address contact');
    
    if (!prescription) {
      return res.status(404).json({
        success: false,
        message: 'Prescription not found for this appointment'
      });
    }

    res.json({
      success: true,
      data: prescription
    });
  } catch (error) {
    console.error('❌ Error fetching prescription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch prescription',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get prescriptions by doctor ID
router.get('/doctor/:doctorId', authenticateToken, async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { page = 1, limit = 10, confirmed } = req.query;
    
    const query = { doctorId };
    if (confirmed !== undefined) {
      query.isConfirmed = confirmed === 'true';
    }
    
    const prescriptions = await HospitalPrescription.find(query)
      .populate('hospitalId', 'name address')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await HospitalPrescription.countDocuments(query);

    res.json({
      success: true,
      data: prescriptions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('❌ Error fetching doctor prescriptions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch prescriptions',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get prescriptions by patient ID
router.get('/patient/:patientId', authenticateToken, async (req, res) => {
  try {
    const { patientId } = req.params;
    const { page = 1, limit = 10 } = req.query;
    
    const prescriptions = await HospitalPrescription.find({ 
      patientId,
      isConfirmed: true 
    })
      .populate('doctorId', 'name specialization')
      .populate('hospitalId', 'name address')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await HospitalPrescription.countDocuments({ 
      patientId,
      isConfirmed: true 
    });

    res.json({
      success: true,
      data: prescriptions,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('❌ Error fetching patient prescriptions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch prescriptions',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get single prescription by ID
router.get('/:prescriptionId', authenticateToken, async (req, res) => {
  try {
    const { prescriptionId } = req.params;
    
    const prescription = await HospitalPrescription.findById(prescriptionId)
      .populate('doctorId', 'name specialization contact')
      .populate('hospitalId', 'name address contact');
    
    if (!prescription) {
      return res.status(404).json({
        success: false,
        message: 'Prescription not found'
      });
    }

    res.json({
      success: true,
      data: prescription
    });
  } catch (error) {
    console.error('❌ Error fetching prescription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch prescription',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Delete prescription (only if not confirmed)
router.delete('/:prescriptionId', authenticateToken, async (req, res) => {
  try {
    const { prescriptionId } = req.params;
    
    const prescription = await HospitalPrescription.findById(prescriptionId);
    
    if (!prescription) {
      return res.status(404).json({
        success: false,
        message: 'Prescription not found'
      });
    }

    if (prescription.isConfirmed) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete confirmed prescription'
      });
    }

    await HospitalPrescription.findByIdAndDelete(prescriptionId);
    
    res.json({
      success: true,
      message: 'Prescription deleted successfully'
    });
  } catch (error) {
    console.error('❌ Error deleting prescription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete prescription',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get prescription statistics for doctor
router.get('/stats/doctor/:doctorId', authenticateToken, async (req, res) => {
  try {
    const { doctorId } = req.params;
    
    const stats = await HospitalPrescription.aggregate([
      { $match: { doctorId: new mongoose.Types.ObjectId(doctorId) } },
      {
        $group: {
          _id: null,
          totalPrescriptions: { $sum: 1 },
          confirmedPrescriptions: {
            $sum: { $cond: [{ $eq: ['$isConfirmed', true] }, 1, 0] }
          },
          pendingPrescriptions: {
            $sum: { $cond: [{ $eq: ['$isConfirmed', false] }, 1, 0] }
          },
          communicableDiseases: {
            $sum: { $cond: [{ $eq: ['$diseaseType', 'communicable'] }, 1, 0] }
          },
          nonCommunicableDiseases: {
            $sum: { $cond: [{ $eq: ['$diseaseType', 'not_communicable'] }, 1, 0] }
          }
        }
      }
    ]);

    res.json({
      success: true,
      data: stats[0] || {
        totalPrescriptions: 0,
        confirmedPrescriptions: 0,
        pendingPrescriptions: 0,
        communicableDiseases: 0,
        nonCommunicableDiseases: 0
      }
    });
  } catch (error) {
    console.error('❌ Error fetching prescription stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch prescription statistics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;