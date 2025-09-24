const express = require('express');
const { ContactTracing, ContactExposure } = require('../models/ContactTracing');
const HospitalPrescription = require('../models/HospitalPrescription');
const router = express.Router();

// Real-time infected device IDs endpoint
// Called every 5 seconds by app for proximity scanning
router.get('/infected-devices', async (req, res) => {
  try {
    // Get all currently infected device IDs
    const infectedDevices = await ContactTracing.find(
      { 
        isInfected: true,
        infectionStatus: { $in: ['infected', 'quarantined'] },
        'communicableDiseases.isActive': true
      },
      { 
        deviceId: 1,
        communicableDiseases: 1,
        uhid: 1,
        _id: 0
      }
    ).lean();

    // Format for BLE scanning
    const deviceList = infectedDevices.map(device => ({
      deviceId: device.deviceId,
      uhid: device.uhid,
      diseases: device.communicableDiseases
        .filter(d => d.isActive)
        .map(d => ({
          name: d.diseaseName,
          diagnosisDate: d.diagnosisDate,
          expectedRecovery: d.expectedRecoveryDate
        }))
    }));

    console.log(`🔍 [${new Date().toISOString()}] Infected devices requested: ${deviceList.length} found`);
    
    res.json({
      success: true,
      count: deviceList.length,
      infectedDevices: deviceList,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('❌ Error fetching infected devices:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch infected devices',
      timestamp: new Date().toISOString()
    });
  }
});

// Log proximity encounter
// Called when infected device detected nearby
router.post('/proximity-encounter', async (req, res) => {
  try {
    const {
      myDeviceId,
      detectedDeviceId,
      rssi,
      estimatedDistance,
      duration = 5 // seconds
    } = req.body;

    if (!myDeviceId || !detectedDeviceId) {
      return res.status(400).json({
        success: false,
        error: 'Device IDs are required'
      });
    }

    // Calculate risk level based on distance
    let riskLevel = 'low';
    if (estimatedDistance <= 1.5) {
      riskLevel = 'high';
    } else if (estimatedDistance <= 3.0) {
      riskLevel = 'medium';
    }

    // Create contact exposure record
    const exposure = new ContactExposure({
      sourceDeviceId: detectedDeviceId, // infected device
      targetDeviceId: myDeviceId, // user's device
      exposureDate: new Date(),
      duration: duration / 60, // convert to minutes
      proximity: estimatedDistance,
      riskLevel: riskLevel,
      isReported: true
    });

    await exposure.save();

    console.log(`🚨 [${new Date().toISOString()}] PROXIMITY ALERT: ${myDeviceId} near infected ${detectedDeviceId} at ${estimatedDistance}m - Risk: ${riskLevel.toUpperCase()}`);

    res.json({
      success: true,
      exposure: {
        id: exposure._id,
        riskLevel: riskLevel,
        distance: estimatedDistance,
        timestamp: exposure.exposureDate
      }
    });

  } catch (error) {
    console.error('❌ Error logging proximity encounter:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to log proximity encounter'
    });
  }
});

// Register device for contact tracing
router.post('/register-device', async (req, res) => {
  try {
    const {
      deviceId,
      uhid,
      patientId,
      deviceInfo = {},
      location = {}
    } = req.body;

    if (!deviceId || !uhid) {
      return res.status(400).json({
        success: false,
        error: 'Device ID and UHID are required'
      });
    }

    // Check if device already registered
    let contactTracing = await ContactTracing.findOne({ deviceId });
    
    if (contactTracing) {
      // Update existing registration
      contactTracing.lastActiveDate = new Date();
      contactTracing.metadata = {
        deviceInfo,
        location
      };
      await contactTracing.save();
      
      console.log(`📱 Device updated: ${deviceId} (UHID: ${uhid})`);
    } else {
      // Create new registration
      contactTracing = new ContactTracing({
        deviceId,
        patientId,
        uhid,
        metadata: {
          deviceInfo,
          location
        }
      });
      await contactTracing.save();
      
      console.log(`📱 Device registered: ${deviceId} (UHID: ${uhid})`);
    }

    // Check if patient has any active communicable diseases
    const prescriptions = await HospitalPrescription.find({
      patientUHID: uhid,
      diseaseType: 'communicable',
      // Add date check for active infections
    }).sort({ createdAt: -1 }).limit(5);

    let isCurrentlyInfected = false;
    const activeDiseases = [];

    for (const prescription of prescriptions) {
      const diagnosisDate = new Date(prescription.diagnosisDate || prescription.createdAt);
      const recoveryDate = new Date(diagnosisDate);
      recoveryDate.setDate(recoveryDate.getDate() + (prescription.expectedRecoveryDays || 14));

      // Check if still in recovery period
      if (new Date() < recoveryDate) {
        isCurrentlyInfected = true;
        activeDiseases.push({
          diseaseName: prescription.diseaseName,
          diagnosisDate: diagnosisDate,
          expectedRecoveryDate: recoveryDate,
          prescriptionId: prescription._id,
          isActive: true
        });
      }
    }

    // Update infection status
    if (isCurrentlyInfected && activeDiseases.length > 0) {
      contactTracing.isInfected = true;
      contactTracing.infectionStatus = 'infected';
      contactTracing.communicableDiseases = activeDiseases;
      await contactTracing.save();
      
      console.log(`🦠 INFECTED DEVICE DETECTED: ${deviceId} - Diseases: ${activeDiseases.map(d => d.diseaseName).join(', ')}`);
    }

    res.json({
      success: true,
      device: {
        deviceId: contactTracing.deviceId,
        uhid: contactTracing.uhid,
        isInfected: contactTracing.isInfected,
        infectionStatus: contactTracing.infectionStatus,
        activeDiseases: contactTracing.communicableDiseases?.filter(d => d.isActive) || []
      }
    });

  } catch (error) {
    console.error('❌ Error registering device:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to register device'
    });
  }
});

// Get contact exposure history
router.get('/exposure-history/:deviceId', async (req, res) => {
  try {
    const { deviceId } = req.params;
    const { limit = 20, days = 14 } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const exposures = await ContactExposure.find({
      targetDeviceId: deviceId,
      exposureDate: { $gte: startDate }
    })
    .sort({ exposureDate: -1 })
    .limit(parseInt(limit))
    .lean();

    res.json({
      success: true,
      exposures,
      count: exposures.length
    });

  } catch (error) {
    console.error('❌ Error fetching exposure history:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch exposure history'
    });
  }
});

// Health check endpoint
router.get('/health', (req, res) => {
  res.json({
    success: true,
    service: 'Contact Tracing API',
    timestamp: new Date().toISOString(),
    status: 'operational'
  });
});

module.exports = router;
