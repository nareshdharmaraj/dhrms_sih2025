const express = require('express');
const mongoose = require('mongoose');
const HospitalPrescription = require('../models/HospitalPrescription');
const HospitalAppointment = require('../models/HospitalAppointment');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

// Create a new prescription
router.post('/', authenticateToken, async (req, res) => {
  try {
    console.log('🔄 Creating new prescription...');
    
    // Basic validation
    const requiredFields = [
      'appointmentId', 'doctorId', 'patientId', 'hospitalId', 
      'patientName', 'patientUHID', 'doctorName', 'doctorIdentifier', 
      'hospitalName', 'appointmentNumber', 'diseaseName', 'diseaseType', 
      'medicines', 'isConfirmed'
    ];
    
    for (const field of requiredFields) {
      if (!req.body[field]) {
        return res.status(400).json({
          success: false,
          message: `${field} is required`
        });
      }
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

    // Validate that the appointment exists and is confirmed
    const appointment = await HospitalAppointment.findById(appointmentId);
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    if (appointment.status !== 'confirmed') {
      return res.status(400).json({
        success: false,
        message: 'Can only create prescription for confirmed appointments'
      });
    }

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

    // Create the prescription
    const prescription = new HospitalPrescription({
      appointmentId,
      doctorId,
      patientId,
      hospitalId,
      patientName,
      patientUHID,
      doctorName,
      doctorId: doctorIdentifier,
      hospitalName,
      hospitalAddress: hospitalAddress || '',
      hospitalContact: hospitalContact || {},
      appointmentNumber,
      diseaseName,
      diseaseType,
      expectedRecoveryDays: diseaseType === 'communicable' ? expectedRecoveryDays : undefined,
      medicines,
      nextVisitDate: nextVisitDate ? new Date(nextVisitDate) : undefined,
      nextVisitMandatory: nextVisitMandatory || false,
      isConfirmed,
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