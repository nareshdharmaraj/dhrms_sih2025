const express = require('express');
const router = express.Router();
const HospitalAppointment = require('../models/HospitalAppointment');

/**
 * @desc    Get doctor appointment statistics
 * @route   GET /api/doctor-appointments/stats/:doctorId
 * @access  Private (Doctor)
 */
router.get('/stats/:doctorId', async (req, res) => {
  try {
    const { doctorId } = req.params;
    
    console.log(`📊 Fetching appointment statistics for doctor: ${doctorId}`);
    
    // Get counts by status for this doctor
    const stats = await HospitalAppointment.aggregate([
      { $match: { hospitalStaffId: doctorId } },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 }
        }
      }
    ]);
    
    // Format the response
    const formattedStats = {
      pending: 0,
      approved: 0,
      rejected: 0,
      completed: 0,
      total: 0
    };
    
    stats.forEach(stat => {
      formattedStats[stat._id] = stat.count;
      formattedStats.total += stat.count;
    });
    
    // Get rejected appointments from last 2 days (for rejected tab display)
    const twoDaysAgo = new Date();
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
    
    const recentlyRejected = await HospitalAppointment.countDocuments({
      hospitalStaffId: doctorId,
      status: 'rejected',
      updatedAt: { $gte: twoDaysAgo }
    });
    
    formattedStats.recentlyRejected = recentlyRejected;
    
    console.log('✅ Appointment statistics retrieved');
    
    res.json({
      success: true,
      data: formattedStats
    });
    
  } catch (error) {
    console.error('❌ Error fetching appointment statistics:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching statistics',
      error: error.message
    });
  }
});

/**
 * @desc    Get appointment details for doctor view
 * @route   GET /api/doctor-appointments/view/:appointmentId
 * @access  Private (Doctor)
 */
router.get('/view/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    console.log(`👁️ Doctor viewing appointment: ${appointmentId}`);
    
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    console.log('✅ Appointment details retrieved');
    
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
 * @desc    Approve appointment request
 * @route   PUT /api/doctor-appointments/approve/:appointmentId
 * @access  Private (Doctor)
 */
router.put('/approve/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    console.log(`✅ Approving appointment: ${appointmentId}`);
    
    // Find the appointment
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    // Check if appointment is in pending status
    if (appointment.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Cannot approve appointment. Current status: ${appointment.status}`
      });
    }
    
    // Update to approved status
    const updatedAppointment = await HospitalAppointment.findOneAndUpdate(
      { appointmentId },
      { 
        status: 'approved',
        updatedAt: new Date()
      },
      { new: true }
    );
    
    console.log(`✅ Appointment approved successfully: ${appointmentId}`);
    
    res.json({
      success: true,
      message: 'Appointment approved successfully',
      data: updatedAppointment
    });
    
  } catch (error) {
    console.error('❌ Error approving appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while approving appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Reject appointment request
 * @route   PUT /api/doctor-appointments/reject/:appointmentId
 * @access  Private (Doctor)
 */
router.put('/reject/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const { reason } = req.body; // Optional rejection reason
    
    console.log(`❌ Rejecting appointment: ${appointmentId}`);
    
    // Find the appointment
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    // Check if appointment can be rejected
    if (appointment.status === 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Cannot reject completed appointment'
      });
    }
    
    // Update to rejected status
    const updateData = { 
      status: 'rejected',
      updatedAt: new Date()
    };
    
    // Add rejection reason if provided
    if (reason) {
      updateData.rejectionReason = reason;
    }
    
    const updatedAppointment = await HospitalAppointment.findOneAndUpdate(
      { appointmentId },
      updateData,
      { new: true }
    );
    
    console.log(`❌ Appointment rejected successfully: ${appointmentId}`);
    
    res.json({
      success: true,
      message: 'Appointment rejected successfully',
      data: updatedAppointment
    });
    
  } catch (error) {
    console.error('❌ Error rejecting appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while rejecting appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Accept previously rejected appointment (within 1 day rule)
 * @route   PUT /api/doctor-appointments/accept-rejected/:appointmentId
 * @access  Private (Doctor)
 */
router.put('/accept-rejected/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    console.log(`🔄 Attempting to accept rejected appointment: ${appointmentId}`);
    
    // Find the appointment
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    // Check if appointment is rejected
    if (appointment.status !== 'rejected') {
      return res.status(400).json({
        success: false,
        message: `Cannot accept appointment. Current status: ${appointment.status}`
      });
    }
    
    // Check 1-day rule from rejection date
    const oneDayInMs = 24 * 60 * 60 * 1000;
    const rejectionTime = new Date(appointment.updatedAt);
    const currentTime = new Date();
    const timeSinceRejection = currentTime - rejectionTime;
    
    if (timeSinceRejection > oneDayInMs) {
      return res.status(403).json({
        success: false,
        message: 'Cannot accept rejected appointment after 1 day from rejection date',
        rejectionDate: appointment.updatedAt,
        timeRemaining: 0
      });
    }
    
    // Check if appointment time hasn't passed
    const [day, month, year] = appointment.appointmentDate.split('/');
    const appointmentDate = new Date(year, month - 1, day);
    
    // Parse appointment time
    const [time, period] = appointment.appointmentTime.split(' ');
    const [hours, minutes] = time.split(':');
    let hour24 = parseInt(hours);
    if (period === 'PM' && hour24 !== 12) hour24 += 12;
    if (period === 'AM' && hour24 === 12) hour24 = 0;
    appointmentDate.setHours(hour24, parseInt(minutes));
    
    if (appointmentDate <= currentTime) {
      return res.status(403).json({
        success: false,
        message: 'Cannot accept appointment - appointment time has passed'
      });
    }
    
    // Accept the appointment (change status to approved)
    const updatedAppointment = await HospitalAppointment.findOneAndUpdate(
      { appointmentId },
      { 
        status: 'approved',
        updatedAt: new Date(),
        $unset: { rejectionReason: 1 } // Remove rejection reason
      },
      { new: true }
    );
    
    console.log(`✅ Rejected appointment accepted successfully: ${appointmentId}`);
    
    res.json({
      success: true,
      message: 'Rejected appointment accepted successfully',
      data: updatedAppointment
    });
    
  } catch (error) {
    console.error('❌ Error accepting rejected appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while accepting appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Get doctor's appointments with tab-based filtering
 * @route   GET /api/doctor-appointments/:doctorId/:tab
 * @access  Private (Doctor)
 */
router.get('/:doctorId/:tab', async (req, res) => {
  try {
    const { doctorId, tab } = req.params;
    
    console.log(`👨‍⚕️ Fetching ${tab} appointments for doctor: ${doctorId}`);
    
    let filterQuery = { hospitalStaffId: doctorId };
    let appointments;
    
    switch (tab) {
      case 'requests':
        // Show only pending appointments (requests from patients)
        filterQuery.status = 'pending';
        appointments = await HospitalAppointment.find(filterQuery)
          .sort({ bookedAt: -1 }); // Latest requests first
        break;
        
      case 'current':
        // Show approved appointments (current confirmed appointments)
        filterQuery.status = 'approved';
        appointments = await HospitalAppointment.find(filterQuery)
          .sort({ appointmentDate: 1, appointmentTime: 1 }); // Chronological order
        break;
        
      case 'rejected':
        // Show rejected appointments from last 2 days only, where appointment is still in future
        const twoDaysAgo = new Date();
        twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
        
        filterQuery.status = 'rejected';
        filterQuery.updatedAt = { $gte: twoDaysAgo };
        
        // Get all rejected appointments first
        const allRejected = await HospitalAppointment.find(filterQuery);
        
        // Filter to only show appointments that haven't passed yet
        const now = new Date();
        appointments = allRejected.filter(apt => {
          const [day, month, year] = apt.appointmentDate.split('/');
          const appointmentDateTime = new Date(year, month - 1, day);
          
          // Parse time (assuming format like "02:00 PM")
          const [time, period] = apt.appointmentTime.split(' ');
          const [hours, minutes] = time.split(':');
          let hour24 = parseInt(hours);
          if (period === 'PM' && hour24 !== 12) hour24 += 12;
          if (period === 'AM' && hour24 === 12) hour24 = 0;
          
          appointmentDateTime.setHours(hour24, parseInt(minutes));
          
          return appointmentDateTime > now;
        });
        
        appointments.sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));
        break;
        
      case 'completed':
        // Show completed appointments (patients with prescriptions)
        filterQuery.status = 'completed';
        appointments = await HospitalAppointment.find(filterQuery)
          .sort({ updatedAt: -1 }); // Latest completed first
        break;
        
      default:
        return res.status(400).json({
          success: false,
          message: 'Invalid tab. Must be: requests, current, rejected, or completed'
        });
    }
    
    console.log(`✅ Found ${appointments.length} ${tab} appointments`);
    
    res.json({
      success: true,
      tab: tab,
      count: appointments.length,
      data: appointments
    });
    
  } catch (error) {
    console.error('❌ Error fetching doctor appointments:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while fetching appointments',
      error: error.message
    });
  }
});

/**
 * @desc    Get appointment details for doctor view
 * @route   GET /api/doctor-appointments/view/:appointmentId
 * @access  Private (Doctor)
 */
router.get('/view/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    console.log(`👁️ Doctor viewing appointment: ${appointmentId}`);
    
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    console.log('✅ Appointment details retrieved');
    
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
 * @desc    Approve appointment request
 * @route   PUT /api/doctor-appointments/approve/:appointmentId
 * @access  Private (Doctor)
 */
router.put('/approve/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    console.log(`✅ Approving appointment: ${appointmentId}`);
    
    // Find the appointment
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    // Check if appointment is in pending status
    if (appointment.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: `Cannot approve appointment. Current status: ${appointment.status}`
      });
    }
    
    // Update to approved status
    const updatedAppointment = await HospitalAppointment.findOneAndUpdate(
      { appointmentId },
      { 
        status: 'approved',
        updatedAt: new Date()
      },
      { new: true }
    );
    
    console.log(`✅ Appointment approved successfully: ${appointmentId}`);
    
    res.json({
      success: true,
      message: 'Appointment approved successfully',
      data: updatedAppointment
    });
    
  } catch (error) {
    console.error('❌ Error approving appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while approving appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Reject appointment request
 * @route   PUT /api/doctor-appointments/reject/:appointmentId
 * @access  Private (Doctor)
 */
router.put('/reject/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const { reason } = req.body; // Optional rejection reason
    
    console.log(`❌ Rejecting appointment: ${appointmentId}`);
    
    // Find the appointment
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    // Check if appointment can be rejected
    if (appointment.status === 'completed') {
      return res.status(400).json({
        success: false,
        message: 'Cannot reject completed appointment'
      });
    }
    
    // Update to rejected status
    const updateData = { 
      status: 'rejected',
      updatedAt: new Date()
    };
    
    // Add rejection reason if provided
    if (reason) {
      updateData.rejectionReason = reason;
    }
    
    const updatedAppointment = await HospitalAppointment.findOneAndUpdate(
      { appointmentId },
      updateData,
      { new: true }
    );
    
    console.log(`❌ Appointment rejected successfully: ${appointmentId}`);
    
    res.json({
      success: true,
      message: 'Appointment rejected successfully',
      data: updatedAppointment
    });
    
  } catch (error) {
    console.error('❌ Error rejecting appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while rejecting appointment',
      error: error.message
    });
  }
});

/**
 * @desc    Accept previously rejected appointment (within 1 day rule)
 * @route   PUT /api/doctor-appointments/accept-rejected/:appointmentId
 * @access  Private (Doctor)
 */
router.put('/accept-rejected/:appointmentId', async (req, res) => {
  try {
    const { appointmentId } = req.params;
    
    console.log(`🔄 Attempting to accept rejected appointment: ${appointmentId}`);
    
    // Find the appointment
    const appointment = await HospitalAppointment.findOne({ appointmentId });
    
    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }
    
    // Check if appointment is rejected
    if (appointment.status !== 'rejected') {
      return res.status(400).json({
        success: false,
        message: `Cannot accept appointment. Current status: ${appointment.status}`
      });
    }
    
    // Check 1-day rule from rejection date
    const oneDayInMs = 24 * 60 * 60 * 1000;
    const rejectionTime = new Date(appointment.updatedAt);
    const currentTime = new Date();
    const timeSinceRejection = currentTime - rejectionTime;
    
    if (timeSinceRejection > oneDayInMs) {
      return res.status(403).json({
        success: false,
        message: 'Cannot accept rejected appointment after 1 day from rejection date',
        rejectionDate: appointment.updatedAt,
        timeRemaining: 0
      });
    }
    
    // Check if appointment time hasn't passed
    const [day, month, year] = appointment.appointmentDate.split('/');
    const appointmentDate = new Date(year, month - 1, day);
    
    // Parse appointment time
    const [time, period] = appointment.appointmentTime.split(' ');
    const [hours, minutes] = time.split(':');
    let hour24 = parseInt(hours);
    if (period === 'PM' && hour24 !== 12) hour24 += 12;
    if (period === 'AM' && hour24 === 12) hour24 = 0;
    appointmentDate.setHours(hour24, parseInt(minutes));
    
    if (appointmentDate <= currentTime) {
      return res.status(403).json({
        success: false,
        message: 'Cannot accept appointment - appointment time has passed'
      });
    }
    
    // Accept the appointment (change status to approved)
    const updatedAppointment = await HospitalAppointment.findOneAndUpdate(
      { appointmentId },
      { 
        status: 'approved',
        updatedAt: new Date(),
        $unset: { rejectionReason: 1 } // Remove rejection reason
      },
      { new: true }
    );
    
    console.log(`✅ Rejected appointment accepted successfully: ${appointmentId}`);
    
    res.json({
      success: true,
      message: 'Rejected appointment accepted successfully',
      data: updatedAppointment
    });
    
  } catch (error) {
    console.error('❌ Error accepting rejected appointment:', error);
    res.status(500).json({
      success: false,
      message: 'Server error while accepting appointment',
      error: error.message
    });
  }
});

module.exports = router;