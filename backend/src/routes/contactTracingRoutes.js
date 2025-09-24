const express = require('express');
const router = express.Router();
const { ContactTracing, ContactExposure } = require('../models/ContactTracing');
const HospitalPrescription = require('../models/HospitalPrescription');

// @route   GET /api/contact-tracing/infected-ids
// @desc    Get list of infected device IDs for BLE scanning
// @access  Public (for contact tracing functionality)
router.get('/infected-ids', async (req, res) => {
  try {
    console.log('📡 Fetching infected device IDs...');
    
    const infectedDevices = await ContactTracing.find(
      { isInfected: true },
      'deviceId communicableDiseases.diseaseName communicableDiseases.isActive lastActiveDate'
    ).lean();

    // Filter only active infections and recently active devices (last 30 days)
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const activeInfectedIds = infectedDevices
      .filter(device => {
        const hasActiveDiseases = device.communicableDiseases?.some(d => d.isActive);
        const isRecentlyActive = device.lastActiveDate > thirtyDaysAgo;
        return hasActiveDiseases && isRecentlyActive;
      })
      .map(device => device.deviceId);

    console.log(`✅ Found ${activeInfectedIds.length} active infected device IDs`);

    res.json({
      success: true,
      infected_ids: activeInfectedIds,
      count: activeInfectedIds.length,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Error fetching infected IDs:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch infected device IDs',
      error: error.message
    });
  }
});

// @route   POST /api/contact-tracing/register-device
// @desc    Register a device ID for contact tracing
// @access  Private (requires patient authentication)
router.post('/register-device', async (req, res) => {
  try {
    const { deviceId, patientId, uhid, deviceInfo, location } = req.body;

    console.log(`📱 Registering device: ${deviceId} for patient: ${uhid}`);

    // Check if device already exists
    let contactTracing = await ContactTracing.findOne({ deviceId });

    if (contactTracing) {
      // Update existing device registration
      contactTracing.lastActiveDate = new Date();
      contactTracing.metadata.deviceInfo = deviceInfo || contactTracing.metadata.deviceInfo;
      contactTracing.metadata.location = location || contactTracing.metadata.location;
      await contactTracing.save();
    } else {
      // Create new device registration
      contactTracing = new ContactTracing({
        deviceId,
        patientId,
        uhid,
        metadata: {
          deviceInfo: deviceInfo || {},
          location: location || {}
        }
      });
      await contactTracing.save();
    }

    res.json({
      success: true,
      message: 'Device registered successfully',
      deviceId: contactTracing.deviceId,
      isInfected: contactTracing.isInfected
    });

  } catch (error) {
    console.error('❌ Error registering device:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register device',
      error: error.message
    });
  }
});

// @route   POST /api/contact-tracing/report-infection
// @desc    Report a positive case (called when prescription has communicable disease)
// @access  Private (requires doctor/hospital authentication)
router.post('/report-infection', async (req, res) => {
  try {
    const { 
      deviceId, 
      patientId, 
      uhid, 
      diseaseName, 
      expectedRecoveryDays, 
      prescriptionId,
      healthAuthorityCode 
    } = req.body;

    console.log(`🚨 Reporting infection: ${diseaseName} for device: ${deviceId}`);

    // Find or create contact tracing record
    let contactTracing = await ContactTracing.findOne({ deviceId });
    
    if (!contactTracing) {
      contactTracing = new ContactTracing({
        deviceId,
        patientId,
        uhid
      });
    }

    // Calculate expected recovery date
    const diagnosisDate = new Date();
    const expectedRecoveryDate = new Date();
    expectedRecoveryDate.setDate(diagnosisDate.getDate() + expectedRecoveryDays);

    // Add communicable disease
    const diseaseData = {
      diseaseName,
      diagnosisDate,
      expectedRecoveryDate,
      prescriptionId,
      isActive: true
    };

    await contactTracing.addCommunicableDisease(diseaseData);

    console.log(`✅ Infection reported successfully for device: ${deviceId}`);

    // TODO: Notify health authorities if required
    if (healthAuthorityCode) {
      console.log(`📫 Health authority notification required: ${healthAuthorityCode}`);
    }

    res.json({
      success: true,
      message: 'Infection reported successfully',
      deviceId: contactTracing.deviceId,
      infectionStatus: contactTracing.infectionStatus
    });

  } catch (error) {
    console.error('❌ Error reporting infection:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to report infection',
      error: error.message
    });
  }
});

// @route   POST /api/contact-tracing/report-exposure
// @desc    Report BLE proximity exposure between devices
// @access  Public (for contact tracing functionality)
router.post('/report-exposure', async (req, res) => {
  try {
    const {
      sourceDeviceId,
      targetDeviceId,
      duration,
      proximity,
      riskLevel,
      location
    } = req.body;

    console.log(`⚠️ Reporting exposure: ${sourceDeviceId} -> ${targetDeviceId} (${proximity}m, ${duration}min)`);

    // Create exposure record
    const exposure = new ContactExposure({
      sourceDeviceId,
      targetDeviceId,
      exposureDate: new Date(),
      duration,
      proximity,
      riskLevel,
      location
    });

    await exposure.save();

    // Check if source device is infected
    const sourceDevice = await ContactTracing.findOne({ 
      deviceId: sourceDeviceId, 
      isInfected: true 
    });

    if (sourceDevice) {
      console.log(`🚨 HIGH RISK: Exposure to infected device detected!`);
      
      // Mark exposure as high priority
      exposure.isReported = true;
      exposure.healthAuthorityNotified = true;
      await exposure.save();

      // TODO: Send notification to target device
      // TODO: Alert health authorities
    }

    res.json({
      success: true,
      message: 'Exposure reported successfully',
      exposureId: exposure._id,
      riskLevel: exposure.riskLevel,
      requiresNotification: sourceDevice ? true : false
    });

  } catch (error) {
    console.error('❌ Error reporting exposure:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to report exposure',
      error: error.message
    });
  }
});

// @route   GET /api/contact-tracing/exposure-history/:deviceId
// @desc    Get exposure history for a device
// @access  Private (requires authentication)
router.get('/exposure-history/:deviceId', async (req, res) => {
  try {
    const { deviceId } = req.params;
    const { days = 14 } = req.query; // Default to 14 days

    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    const exposures = await ContactExposure.find({
      targetDeviceId: deviceId,
      exposureDate: { $gte: startDate }
    }).sort({ exposureDate: -1 });

    // Get infection status of exposed devices
    const sourceDeviceIds = [...new Set(exposures.map(e => e.sourceDeviceId))];
    const infectedSources = await ContactTracing.find({
      deviceId: { $in: sourceDeviceIds },
      isInfected: true
    }, 'deviceId communicableDiseases');

    const infectedSourceIds = infectedSources.map(d => d.deviceId);

    // Mark high-risk exposures
    const enrichedExposures = exposures.map(exposure => ({
      ...exposure.toObject(),
      wasInfected: infectedSourceIds.includes(exposure.sourceDeviceId),
      diseases: infectedSources
        .find(d => d.deviceId === exposure.sourceDeviceId)
        ?.communicableDiseases?.filter(d => d.isActive) || []
    }));

    res.json({
      success: true,
      exposures: enrichedExposures,
      totalExposures: exposures.length,
      highRiskExposures: enrichedExposures.filter(e => e.wasInfected).length,
      period: `${days} days`
    });

  } catch (error) {
    console.error('❌ Error fetching exposure history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch exposure history',
      error: error.message
    });
  }
});

// @route   PUT /api/contact-tracing/update-recovery
// @desc    Mark a patient as recovered from communicable disease
// @access  Private (requires doctor/hospital authentication)
router.put('/update-recovery', async (req, res) => {
  try {
    const { deviceId, diseaseName, recoveryDate } = req.body;

    console.log(`🩺 Marking recovery: ${diseaseName} for device: ${deviceId}`);

    const contactTracing = await ContactTracing.findOne({ deviceId });
    
    if (!contactTracing) {
      return res.status(404).json({
        success: false,
        message: 'Device not found in contact tracing system'
      });
    }

    await contactTracing.markRecovered(diseaseName);

    console.log(`✅ Recovery updated for device: ${deviceId}`);

    res.json({
      success: true,
      message: 'Recovery status updated successfully',
      infectionStatus: contactTracing.infectionStatus
    });

  } catch (error) {
    console.error('❌ Error updating recovery:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update recovery status',
      error: error.message
    });
  }
});

// @route   GET /api/contact-tracing/statistics
// @desc    Get contact tracing statistics
// @access  Private (requires health authority authentication)
router.get('/statistics', async (req, res) => {
  try {
    const { state, district, days = 30 } = req.query;
    
    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    // Build location filter
    const locationFilter = {};
    if (state) locationFilter['metadata.location.state'] = state;
    if (district) locationFilter['metadata.location.district'] = district;

    const [
      totalDevices,
      infectedDevices,
      recoveredDevices,
      recentExposures
    ] = await Promise.all([
      ContactTracing.countDocuments(locationFilter),
      ContactTracing.countDocuments({ ...locationFilter, isInfected: true }),
      ContactTracing.countDocuments({ ...locationFilter, infectionStatus: 'recovered' }),
      ContactExposure.countDocuments({ exposureDate: { $gte: startDate } })
    ]);

    // Disease breakdown
    const diseaseStats = await ContactTracing.aggregate([
      { $match: { ...locationFilter, isInfected: true } },
      { $unwind: '$communicableDiseases' },
      { $match: { 'communicableDiseases.isActive': true } },
      { $group: {
        _id: '$communicableDiseases.diseaseName',
        count: { $sum: 1 }
      }},
      { $sort: { count: -1 } }
    ]);

    res.json({
      success: true,
      statistics: {
        totalDevices,
        infectedDevices,
        recoveredDevices,
        recentExposures,
        diseaseBreakdown: diseaseStats,
        period: `${days} days`,
        location: { state, district }
      }
    });

  } catch (error) {
    console.error('❌ Error fetching statistics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch statistics',
      error: error.message
    });
  }
});

module.exports = router;
