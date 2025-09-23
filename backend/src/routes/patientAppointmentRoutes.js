const express = require('express');
const router = express.Router();
const HospitalAppointment = require('../models/HospitalAppointment');

/**
 * @desc    Get all appointments for a specific patient with filtering
 * @route   GET /api/patient-appointments/:patientId
 * @access  Private (Patient)
 */
router.get('/:patientId', async (req, res) => {
  try {
    const { patientId } = req.params;
    const { 
      doctorName, 
      appointmentId, 
      appointmentDate, 
      appointmentTime, 
      status, 
      hospitalName,
      page = 1,
      limit = 10
    } = req.query;

    console.log(`📋 Fetching appointments for patient: ${patientId}`);
    
    // Build filter query
    let filterQuery = { patientId: patientId };
    
    // Apply filters if provided
    if (doctorName) {
      filterQuery.doctorName = { $regex: doctorName, $options: 'i' };
    }
    
    if (appointmentId) {
      filterQuery.appointmentId = { $regex: appointmentId, $options: 'i' };
    }
    
    if (appointmentDate) {
      filterQuery.appointmentDate = appointmentDate;
    }
    
    if (appointmentTime) {
      filterQuery.appointmentTime = { $regex: appointmentTime, $options: 'i' };
    }
    
    if (status) {
      filterQuery.status = status;
    }
    
    if (hospitalName) {
      filterQuery.hospitalName = { $regex: hospitalName, $options: 'i' };
    }

    console.log('🔍 Filter query:', JSON.stringify(filterQuery, null, 2));

    // Calculate pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Fetch appointments with filters and pagination
    const appointments = await HospitalAppointment.find(filterQuery)
      .sort({ bookedAt: -1 }) // Latest bookings first
      .skip(skip)
      .limit(parseInt(limit));

    // Get total count for pagination
    const totalCount = await HospitalAppointment.countDocuments(filterQuery);
    
    console.log(`✅ Found ${appointments.length} appointments for patient ${patientId}`);
    
    res.json({
      success: true,
      count: appointments.length,
      totalCount,
      currentPage: parseInt(page),
      totalPages: Math.ceil(totalCount / parseInt(limit)),
      data: appointments
    });
    
  } catch (error) {
    console.error('❌ Error fetching patient appointments:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching patient appointments',
      error: error.message
    });
  }
});

/**
 * @desc    Get detailed view of a specific appointment
 * @route   GET /api/patient-appointments/view/:appointmentId
 * @access  Private (Patient)
 */
router.get('/view/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    console.log(`👁️ Fetching appointment details: ${appointmentId}`);
    
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    console.log(`✅ Found appointment: ${appointment.appointmentId}`);
    
    res.json({
      success: true,
      data: appointment
    });
    
  } catch (error) {
    console.error('❌ Error fetching appointment details:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointment details',
      error: error.message
    });
  }
});

/**
 * @desc    Edit appointment (within 2 hours of booking and before approval)
 * @route   PUT /api/patient-appointments/edit/:appointmentId
 * @access  Private (Patient)
 */
router.put('/edit/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const updateData = req.body;
    
    console.log(`✏️ Editing appointment: ${appointmentId}`, updateData);
    
    // Find the appointment
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    // Check if appointment is already approved/completed
    if (appointment.status === 'approved' || appointment.status === 'completed') {
      return res.status(403).json({
        success: false,
        message: 'Cannot edit appointment after doctor approval or completion'
      });
    }
    
    // Check 2-hour editing window
    const bookingTime = new Date(appointment.bookedAt);
    const currentTime = new Date();
    const timeDifference = currentTime - bookingTime;
    const twoHoursInMs = 2 * 60 * 60 * 1000; // 2 hours in milliseconds
    
    if (timeDifference > twoHoursInMs) {
      return res.status(403).json({
        success: false,
        message: 'Appointment can only be edited within 2 hours of booking',
        bookingTime: appointment.bookedAt,
        timeRemaining: Math.max(0, twoHoursInMs - timeDifference)
      });
    }
    
    // Update allowed fields
    const allowedFields = [
      'appointmentDate', 'appointmentTime', 'reason'
    ];
    
    const filteredUpdateData = {};
    allowedFields.forEach(field => {
      if (updateData[field]) {
        filteredUpdateData[field] = updateData[field];
      }
    });
    
    // Update the appointment
    const updatedAppointment = await HospitalAppointment.findOneAndUpdate(
      { appointmentId },
      { 
        ...filteredUpdateData,
        updatedAt: new Date()
      },
      { new: true }
    );
    
    console.log(`✅ Appointment updated successfully: ${appointmentId}`);
    
    res.json({
      success: true,
      message: 'Appointment updated successfully',
      data: updatedAppointment
    });
    
  } catch (error) {
    console.error('❌ Error updating appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while updating appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Delete appointment (before doctor visit/completion)
 * @route   DELETE /api/patient-appointments/delete/:appointmentId
 * @access  Private (Patient)
 */
router.delete('/delete/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    console.log(`🗑️ Deleting appointment: ${appointmentId}`);
    
    // Find the appointment
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    // Check if appointment is completed (patient visited doctor)
    if (appointment.status === 'completed') {
      return res.status(403).json({
        success: false,
        message: 'Cannot delete appointment after doctor visit and treatment'
      });
    }
    
    // Delete the appointment
    await HospitalAppointment.findOneAndDelete({ appointmentId });
    
    console.log(`✅ Appointment deleted successfully: ${appointmentId}`);
    
    res.json({
      success: true,
      message: 'Appointment deleted successfully',
      deletedAppointment: {
        appointmentId: appointment.appointmentId,
        patientName: appointment.patientName,
        doctorName: appointment.doctorName,
        appointmentDate: appointment.appointmentDate,
        appointmentTime: appointment.appointmentTime
      }
    });
    
  } catch (error) {
    console.error('❌ Error deleting appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while deleting appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Get appointment statistics for a patient
 * @route   GET /api/patient-appointments/stats/:patientId
 * @access  Private (Patient)
 */
router.get('/stats/:patientId', async (req, res) => {
  try {
    const { patientId } = req.params;
    
    console.log(`📊 Fetching appointment statistics for patient: ${patientId}`);
    
    // Get counts by status
    const stats = await HospitalAppointment.aggregate([
      { $match: { patientId: patientId } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);
    
    // Get total count
    const totalAppointments = await HospitalAppointment.countDocuments({ patientId });
    
    // Format stats
    const formattedStats = {
      total: totalAppointments,
      pending: 0,
      approved: 0,
      rejected: 0,
      completed: 0
    };
    
    stats.forEach(stat => {
      formattedStats[stat._id] = stat.count;
    });
    
    console.log(`✅ Stats for patient ${patientId}:`, formattedStats);
    
    res.json({
      success: true,
      data: formattedStats
    });
    
  } catch (error) {
    console.error('❌ Error fetching appointment statistics:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointment statistics',
      error: error.message
    });
  }
});

module.exports = router;