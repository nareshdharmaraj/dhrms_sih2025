const express = require('express');
const router = express.Router();
const MedicalRecord = require('../models/MedicalRecord');
const Appointment = require('../models/Appointment');
const HealthStatistics = require('../models/HealthStatistics');

// Get medical records for a specific patient
router.get('/medical-records/:patientId', async (req, res) => {
  try {
    const records = await MedicalRecord.find({ patientId: req.params.patientId })
      .populate('hospitalStaffId', 'fullName staffRole department')
      .sort({ visitDate: -1 });
    res.json(records);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get medical records created by a specific staff member
router.get('/medical-records/staff/:staffId', async (req, res) => {
  try {
    const records = await MedicalRecord.find({ hospitalStaffId: req.params.staffId })
      .populate('patientId', 'fullName bloodGroup phone')
      .sort({ visitDate: -1 });
    res.json(records);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get appointments for a specific patient
router.get('/appointments/patient/:patientId', async (req, res) => {
  try {
    const appointments = await Appointment.find({ patientId: req.params.patientId })
      .populate('hospitalStaffId', 'fullName staffRole department')
      .sort({ appointmentDate: 1 });
    res.json(appointments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get appointments for a specific staff member
router.get('/appointments/staff/:staffId', async (req, res) => {
  try {
    const appointments = await Appointment.find({ hospitalStaffId: req.params.staffId })
      .populate('patientId', 'fullName bloodGroup phone')
      .sort({ appointmentDate: 1 });
    res.json(appointments);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all hospital staff
router.get('/hospital-staff', async (req, res) => {
  try {
    const HospitalStaff = require('../models/HospitalStaff');
    const staff = await HospitalStaff.find({});
    res.json(staff);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all patients
router.get('/patients', async (req, res) => {
  try {
    const Patient = require('../models/Patient');
    const patients = await Patient.find({});
    res.json(patients);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all health statistics
router.get('/health-statistics', async (req, res) => {
  try {
    const stats = await HealthStatistics.find({})
      .populate('generatedBy', 'fullName officerRank')
      .sort({ generatedAt: -1 });
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Create a new medical record
router.post('/medical-records', async (req, res) => {
  try {
    const record = new MedicalRecord(req.body);
    await record.save();
    const populatedRecord = await MedicalRecord.findById(record._id)
      .populate('patientId', 'fullName')
      .populate('hospitalStaffId', 'fullName');
    res.status(201).json(populatedRecord);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Create a new appointment
router.post('/appointments', async (req, res) => {
  try {
    const appointment = new Appointment(req.body);
    await appointment.save();
    const populatedAppointment = await Appointment.findById(appointment._id)
      .populate('patientId', 'fullName')
      .populate('hospitalStaffId', 'fullName');
    res.status(201).json(populatedAppointment);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Update appointment status
router.patch('/appointments/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const appointment = await Appointment.findByIdAndUpdate(
      req.params.id,
      { status, updatedAt: new Date() },
      { new: true }
    ).populate('patientId', 'fullName')
     .populate('hospitalStaffId', 'fullName');
    
    if (!appointment) {
      return res.status(404).json({ error: 'Appointment not found' });
    }
    
    res.json(appointment);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
