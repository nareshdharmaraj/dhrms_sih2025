const express = require('express');
const { body, query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const SmartwatchPairing = require('../models/SmartwatchPairing');
const Patient = require('../models/Patient');
const { authenticate, authenticatePatient } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// @route   POST /api/v1/smartwatch/pair
// @desc    Initiate smartwatch pairing process
// @access  Private (Patient)
router.post('/pair', authenticatePatient, [
  body('device.deviceName').notEmpty().withMessage('Device name is required'),
  body('device.brand').isIn(['apple', 'samsung', 'fitbit', 'garmin', 'xiaomi', 'huawei', 'other']),
  body('device.model').notEmpty().withMessage('Device model is required'),
  body('bluetooth.bluetoothAddress').notEmpty().withMessage('Bluetooth address is required'),
  body('bluetooth.bluetoothName').optional().isString(),
  body('pairingMethod').optional().isIn(['pin', 'passkey', 'nfc', 'qr_code', 'automatic'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { device, bluetooth, pairingMethod = 'passkey', capabilities } = req.body;
    const patientId = req.user.id;

    // Check if device is already paired
    const existingPairing = await SmartwatchPairing.findOne({
      patient: patientId,
      'bluetooth.bluetoothAddress': bluetooth.bluetoothAddress,
      'pairing.status': { $in: ['paired', 'connected'] }
    });

    if (existingPairing) {
      return res.status(400).json({
        status: 'error',
        message: 'Device is already paired'
      });
    }

    // Generate pairing details
    const pairingId = SmartwatchPairing.generatePairingId();
    const pairingCode = SmartwatchPairing.generatePairingCode();
    const pairingToken = `${pairingId}_${Date.now()}`;

    // Create smartwatch pairing record
    const smartwatchPairing = new SmartwatchPairing({
      pairingId,
      patient: patientId,
      device: {
        deviceId: `${device.brand}_${device.model}_${Date.now()}`,
        deviceName: device.deviceName,
        brand: device.brand,
        model: device.model,
        osVersion: device.osVersion,
        firmwareVersion: device.firmwareVersion,
        hardwareVersion: device.hardwareVersion,
        serialNumber: device.serialNumber,
        macAddress: bluetooth.bluetoothAddress
      },
      bluetooth: {
        bluetoothAddress: bluetooth.bluetoothAddress,
        bluetoothName: bluetooth.bluetoothName || device.deviceName,
        bluetoothVersion: bluetooth.bluetoothVersion || '5.0',
        supportedProfiles: bluetooth.supportedProfiles || ['HID', 'A2DP', 'AVRCP'],
        connectionType: bluetooth.connectionType || 'ble'
      },
      pairing: {
        status: 'pending',
        pairingCode,
        pairingMethod,
        pairingToken,
        connectionAttempts: 0
      },
      capabilities: {
        sensors: capabilities?.sensors || [
          { type: 'heart_rate', available: true, accuracy: 'high', sampleRate: 1 },
          { type: 'accelerometer', available: true, accuracy: 'medium', sampleRate: 50 },
          { type: 'gyroscope', available: true, accuracy: 'medium', sampleRate: 50 }
        ],
        features: capabilities?.features || ['notifications', 'health_monitoring', 'emergency_sos'],
        batteryInfo: {
          level: capabilities?.batteryLevel || 100,
          isCharging: false,
          lastUpdated: new Date()
        }
      },
      healthMonitoring: {
        enabledSensors: ['heart_rate'],
        monitoringSchedule: {
          heartRate: {
            enabled: true,
            interval: 60, // 1 minute
            alertThresholds: {
              min: 60,
              max: 100
            }
          },
          activity: {
            enabled: true,
            stepGoal: 10000,
            calorieGoal: 2000
          },
          sleep: {
            enabled: true,
            bedtimeReminder: true,
            sleepGoal: 8
          }
        },
        emergencyFeatures: {
          fallDetection: device.brand === 'apple' || device.brand === 'samsung',
          sosButton: true,
          emergencyContacts: [],
          autoEmergencyCall: false
        }
      },
      notifications: {
        enabledTypes: ['health_alerts', 'medication_reminders', 'appointment_reminders'],
        vibrationPatterns: {
          health_alert: 'long-short-long',
          medication: 'short-short-short',
          emergency: 'long-long-long',
          general: 'short-long'
        },
        quietHours: {
          enabled: false,
          startTime: '22:00',
          endTime: '07:00'
        }
      },
      security: {
        encryptionEnabled: true,
        encryptionMethod: 'AES-256',
        trustedDevice: false
      }
    });

    await smartwatchPairing.save();

    logger.info(`Smartwatch pairing initiated: ${pairingId}`, {
      patientId: req.user.id,
      deviceBrand: device.brand,
      deviceModel: device.model,
      pairingMethod
    });

    res.status(201).json({
      status: 'success',
      message: 'Smartwatch pairing initiated',
      data: {
        pairing: {
          pairingId,
          pairingCode,
          pairingToken,
          status: 'pending',
          device: {
            name: device.deviceName,
            brand: device.brand,
            model: device.model
          },
          instructions: getPairingInstructions(device.brand, pairingMethod),
          expiresAt: new Date(Date.now() + 5 * 60 * 1000) // 5 minutes
        }
      }
    });

  } catch (error) {
    logger.error('Smartwatch pairing initiation error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error initiating smartwatch pairing'
    });
  }
});

// @route   POST /api/v1/smartwatch/confirm-pairing
// @desc    Confirm smartwatch pairing with code
// @access  Private (Patient)
router.post('/confirm-pairing', authenticatePatient, [
  body('pairingId').notEmpty().withMessage('Pairing ID is required'),
  body('pairingCode').notEmpty().withMessage('Pairing code is required'),
  body('deviceConfirmation').optional().isObject()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { pairingId, pairingCode, deviceConfirmation } = req.body;
    const patientId = req.user.id;

    // Find pairing record
    const pairing = await SmartwatchPairing.findOne({
      pairingId,
      patient: patientId,
      'pairing.status': 'pending'
    });

    if (!pairing) {
      return res.status(404).json({
        status: 'error',
        message: 'Pairing request not found or expired'
      });
    }

    // Verify pairing code
    if (pairing.pairing.pairingCode !== pairingCode) {
      pairing.pairing.connectionAttempts += 1;
      pairing.pairing.failureReasons.push('Invalid pairing code');
      await pairing.save();

      return res.status(400).json({
        status: 'error',
        message: 'Invalid pairing code'
      });
    }

    // Check if pairing has expired (5 minutes)
    const pairingAge = Date.now() - pairing.createdAt.getTime();
    if (pairingAge > 5 * 60 * 1000) {
      pairing.pairing.status = 'failed';
      pairing.pairing.failureReasons.push('Pairing timeout');
      await pairing.save();

      return res.status(400).json({
        status: 'error',
        message: 'Pairing request has expired'
      });
    }

    // Update pairing status
    pairing.pairing.status = 'paired';
    pairing.pairing.pairedAt = new Date();
    pairing.pairing.lastConnected = new Date();

    // Update device info if provided
    if (deviceConfirmation) {
      if (deviceConfirmation.batteryLevel) {
        pairing.capabilities.batteryInfo.level = deviceConfirmation.batteryLevel;
        pairing.capabilities.batteryInfo.lastUpdated = new Date();
      }
      
      if (deviceConfirmation.capabilities) {
        pairing.capabilities.sensors = deviceConfirmation.capabilities.sensors || pairing.capabilities.sensors;
        pairing.capabilities.features = deviceConfirmation.capabilities.features || pairing.capabilities.features;
      }
    }

    await pairing.save();

    logger.info(`Smartwatch paired successfully: ${pairingId}`, {
      patientId,
      deviceBrand: pairing.device.brand,
      deviceModel: pairing.device.model
    });

    res.json({
      status: 'success',
      message: 'Smartwatch paired successfully',
      data: {
        pairing: {
          pairingId,
          status: 'paired',
          pairedAt: pairing.pairing.pairedAt,
          device: {
            name: pairing.device.deviceName,
            brand: pairing.device.brand,
            model: pairing.device.model,
            batteryLevel: pairing.capabilities.batteryInfo.level
          },
          capabilities: {
            sensors: pairing.capabilities.sensors,
            features: pairing.capabilities.features
          },
          healthMonitoring: pairing.healthMonitoring
        }
      }
    });

  } catch (error) {
    logger.error('Confirm smartwatch pairing error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error confirming smartwatch pairing'
    });
  }
});

// @route   GET /api/v1/smartwatch/paired-devices
// @desc    Get all paired smartwatches for patient
// @access  Private (Patient)
router.get('/paired-devices', authenticatePatient, async (req, res) => {
  try {
    const patientId = req.user.id;

    const pairedDevices = await SmartwatchPairing.find({
      patient: patientId,
      'pairing.status': { $in: ['paired', 'connected'] }
    }).sort({ 'pairing.pairedAt': -1 });

    const devicesData = pairedDevices.map(device => ({
      pairingId: device.pairingId,
      device: {
        name: device.device.deviceName,
        brand: device.device.brand,
        model: device.device.model,
        firmwareVersion: device.device.firmwareVersion
      },
      status: device.pairing.status,
      pairedAt: device.pairing.pairedAt,
      lastConnected: device.pairing.lastConnected,
      battery: {
        level: device.capabilities.batteryInfo.level,
        isCharging: device.capabilities.batteryInfo.isCharging,
        lastUpdated: device.capabilities.batteryInfo.lastUpdated
      },
      capabilities: {
        sensors: device.capabilities.sensors.filter(s => s.available),
        features: device.capabilities.features
      },
      healthMonitoring: {
        enabled: device.healthMonitoring.enabledSensors.length > 0,
        activeSensors: device.healthMonitoring.enabledSensors
      },
      lastSync: device.dataSync.lastSyncAt
    }));

    res.json({
      status: 'success',
      data: {
        devices: devicesData,
        summary: {
          total: devicesData.length,
          connected: devicesData.filter(d => d.status === 'connected').length,
          lowBattery: devicesData.filter(d => d.battery.level < 20).length
        }
      }
    });

  } catch (error) {
    logger.error('Get paired devices error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching paired devices'
    });
  }
});

// @route   PUT /api/v1/smartwatch/:pairingId/connect
// @desc    Connect to a paired smartwatch
// @access  Private (Patient)
router.put('/:pairingId/connect', authenticatePatient, async (req, res) => {
  try {
    const { pairingId } = req.params;
    const patientId = req.user.id;

    const pairing = await SmartwatchPairing.findOne({
      pairingId,
      patient: patientId,
      'pairing.status': { $in: ['paired', 'disconnected'] }
    });

    if (!pairing) {
      return res.status(404).json({
        status: 'error',
        message: 'Device not found or not paired'
      });
    }

    // Update connection status
    pairing.updateConnectionStatus('connected');
    pairing.pairing.lastConnected = new Date();
    
    await pairing.save();

    logger.info(`Smartwatch connected: ${pairingId}`, {
      patientId,
      deviceBrand: pairing.device.brand
    });

    res.json({
      status: 'success',
      message: 'Smartwatch connected successfully',
      data: {
        pairingId,
        status: 'connected',
        connectedAt: pairing.pairing.lastConnected,
        device: {
          name: pairing.device.deviceName,
          brand: pairing.device.brand,
          model: pairing.device.model
        }
      }
    });

  } catch (error) {
    logger.error('Connect smartwatch error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error connecting to smartwatch'
    });
  }
});

// @route   PUT /api/v1/smartwatch/:pairingId/disconnect
// @desc    Disconnect from a smartwatch
// @access  Private (Patient)
router.put('/:pairingId/disconnect', authenticatePatient, async (req, res) => {
  try {
    const { pairingId } = req.params;
    const patientId = req.user.id;

    const pairing = await SmartwatchPairing.findOne({
      pairingId,
      patient: patientId,
      'pairing.status': 'connected'
    });

    if (!pairing) {
      return res.status(404).json({
        status: 'error',
        message: 'Device not found or not connected'
      });
    }

    pairing.updateConnectionStatus('disconnected');
    await pairing.save();

    logger.info(`Smartwatch disconnected: ${pairingId}`, {
      patientId,
      deviceBrand: pairing.device.brand
    });

    res.json({
      status: 'success',
      message: 'Smartwatch disconnected successfully',
      data: {
        pairingId,
        status: 'disconnected'
      }
    });

  } catch (error) {
    logger.error('Disconnect smartwatch error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error disconnecting from smartwatch'
    });
  }
});

// @route   POST /api/v1/smartwatch/:pairingId/sync
// @desc    Sync data from smartwatch
// @access  Private (Patient)
router.post('/:pairingId/sync', authenticatePatient, [
  body('data').isObject().withMessage('Sync data is required'),
  body('dataTypes').isArray().withMessage('Data types must be an array')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { pairingId } = req.params;
    const { data, dataTypes } = req.body;
    const patientId = req.user.id;

    const pairing = await SmartwatchPairing.findOne({
      pairingId,
      patient: patientId,
      'pairing.status': { $in: ['paired', 'connected'] }
    });

    if (!pairing) {
      return res.status(404).json({
        status: 'error',
        message: 'Device not found or not paired'
      });
    }

    // Record sync
    pairing.recordSync(dataTypes, true);

    // Update battery info if provided
    if (data.battery) {
      pairing.capabilities.batteryInfo.level = data.battery.level;
      pairing.capabilities.batteryInfo.isCharging = data.battery.isCharging;
      pairing.capabilities.batteryInfo.lastUpdated = new Date();
    }

    await pairing.save();

    // Process synced data (in real app, would store in health data collections)
    const processedData = {
      syncId: `sync_${Date.now()}`,
      syncedAt: new Date(),
      dataTypes,
      recordCount: Object.keys(data).length - (data.battery ? 1 : 0), // Exclude battery from count
      healthData: {
        heartRate: data.heartRate || [],
        steps: data.steps || [],
        sleep: data.sleep || [],
        workouts: data.workouts || []
      }
    };

    logger.info(`Smartwatch data synced: ${pairingId}`, {
      patientId,
      dataTypes,
      recordCount: processedData.recordCount
    });

    res.json({
      status: 'success',
      message: 'Data synced successfully',
      data: {
        sync: processedData,
        device: {
          pairingId,
          batteryLevel: pairing.capabilities.batteryInfo.level,
          lastSync: pairing.dataSync.lastSyncAt
        }
      }
    });

  } catch (error) {
    logger.error('Sync smartwatch data error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error syncing smartwatch data'
    });
  }
});

// @route   POST /api/v1/smartwatch/:pairingId/send-notification
// @desc    Send notification to smartwatch
// @access  Private (Patient, Doctor, Hospital)
router.post('/:pairingId/send-notification', authenticate, [
  body('type').isIn(['health_alert', 'medication_reminder', 'appointment_reminder', 'emergency_alert', 'system_notification']),
  body('message').notEmpty().withMessage('Message is required'),
  body('priority').optional().isIn(['low', 'medium', 'high', 'critical'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { pairingId } = req.params;
    const { type, message, priority = 'medium', vibrationPattern } = req.body;

    const pairing = await SmartwatchPairing.findOne({
      pairingId,
      'pairing.status': 'connected'
    }).populate('patient', 'patientId');

    if (!pairing) {
      return res.status(404).json({
        status: 'error',
        message: 'Device not found or not connected'
      });
    }

    // Check if user can send notifications to this device
    const canSend = 
      (req.user.userType === 'patient' && req.user.id === pairing.patient._id.toString()) ||
      (req.user.userType === 'doctor') ||
      (req.user.userType === 'hospital');

    if (!canSend) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Send notification
    const notificationResult = pairing.sendNotification(type, message, vibrationPattern);

    if (!notificationResult.sent) {
      return res.status(400).json({
        status: 'error',
        message: `Cannot send notification: ${notificationResult.reason}`
      });
    }

    logger.info(`Notification sent to smartwatch: ${pairingId}`, {
      type,
      priority,
      sentBy: req.user.userType,
      patient: pairing.patient.patientId
    });

    res.json({
      status: 'success',
      message: 'Notification sent successfully',
      data: {
        notification: {
          type,
          message,
          priority,
          sentAt: notificationResult.timestamp,
          vibrationPattern: notificationResult.vibrationPattern
        },
        device: {
          pairingId,
          deviceName: pairing.device.deviceName
        }
      }
    });

  } catch (error) {
    logger.error('Send smartwatch notification error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error sending notification to smartwatch'
    });
  }
});

// @route   PUT /api/v1/smartwatch/:pairingId/settings
// @desc    Update smartwatch settings
// @access  Private (Patient)
router.put('/:pairingId/settings', authenticatePatient, [
  body('healthMonitoring').optional().isObject(),
  body('notifications').optional().isObject(),
  body('sync').optional().isObject()
], async (req, res) => {
  try {
    const { pairingId } = req.params;
    const { healthMonitoring, notifications, sync } = req.body;
    const patientId = req.user.id;

    const pairing = await SmartwatchPairing.findOne({
      pairingId,
      patient: patientId
    });

    if (!pairing) {
      return res.status(404).json({
        status: 'error',
        message: 'Device not found'
      });
    }

    // Update settings
    if (healthMonitoring) {
      if (healthMonitoring.enabledSensors) {
        pairing.healthMonitoring.enabledSensors = healthMonitoring.enabledSensors;
      }
      if (healthMonitoring.monitoringSchedule) {
        pairing.healthMonitoring.monitoringSchedule = {
          ...pairing.healthMonitoring.monitoringSchedule,
          ...healthMonitoring.monitoringSchedule
        };
      }
    }

    if (notifications) {
      if (notifications.enabledTypes) {
        pairing.notifications.enabledTypes = notifications.enabledTypes;
      }
      if (notifications.quietHours) {
        pairing.notifications.quietHours = {
          ...pairing.notifications.quietHours,
          ...notifications.quietHours
        };
      }
    }

    if (sync) {
      if (sync.syncInterval) {
        pairing.dataSync.syncInterval = sync.syncInterval;
      }
      if (sync.autoSync !== undefined) {
        pairing.dataSync.autoSync = sync.autoSync;
      }
    }

    await pairing.save();

    logger.info(`Smartwatch settings updated: ${pairingId}`, {
      patientId,
      deviceBrand: pairing.device.brand
    });

    res.json({
      status: 'success',
      message: 'Smartwatch settings updated successfully',
      data: {
        settings: {
          healthMonitoring: pairing.healthMonitoring,
          notifications: pairing.notifications,
          sync: {
            syncInterval: pairing.dataSync.syncInterval,
            autoSync: pairing.dataSync.autoSync
          }
        }
      }
    });

  } catch (error) {
    logger.error('Update smartwatch settings error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error updating smartwatch settings'
    });
  }
});

// @route   DELETE /api/v1/smartwatch/:pairingId
// @desc    Unpair smartwatch
// @access  Private (Patient)
router.delete('/:pairingId', authenticatePatient, async (req, res) => {
  try {
    const { pairingId } = req.params;
    const patientId = req.user.id;

    const pairing = await SmartwatchPairing.findOne({
      pairingId,
      patient: patientId
    });

    if (!pairing) {
      return res.status(404).json({
        status: 'error',
        message: 'Device not found'
      });
    }

    // Update status to revoked instead of deleting
    pairing.pairing.status = 'revoked';
    pairing.security.trustedDevice = false;
    await pairing.save();

    logger.info(`Smartwatch unpaired: ${pairingId}`, {
      patientId,
      deviceBrand: pairing.device.brand
    });

    res.json({
      status: 'success',
      message: 'Smartwatch unpaired successfully',
      data: {
        pairingId,
        unpairedAt: new Date()
      }
    });

  } catch (error) {
    logger.error('Unpair smartwatch error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error unpairing smartwatch'
    });
  }
});

// Helper function to get pairing instructions based on device brand
function getPairingInstructions(brand, method) {
  const instructions = {
    apple: {
      passkey: "1. Open Watch app on iPhone\n2. Tap 'Pair New Watch'\n3. Enter the pairing code when prompted\n4. Follow on-screen instructions",
      automatic: "1. Bring Apple Watch close to iPhone\n2. Follow automatic pairing prompts\n3. Confirm on both devices"
    },
    samsung: {
      passkey: "1. Open Galaxy Watch app\n2. Tap 'Connect to new device'\n3. Enter pairing code\n4. Complete setup",
      automatic: "1. Enable Bluetooth on phone\n2. Open Galaxy Watch app\n3. Follow automatic detection"
    },
    fitbit: {
      passkey: "1. Open Fitbit app\n2. Tap profile > Set up a device\n3. Enter pairing code\n4. Complete setup process"
    },
    garmin: {
      passkey: "1. Open Garmin Connect app\n2. Add device\n3. Enter pairing code when prompted\n4. Follow setup wizard"
    }
  };

  return instructions[brand]?.[method] || instructions[brand]?.passkey || 
         "1. Open device companion app\n2. Follow pairing instructions\n3. Enter provided code when prompted";
}

module.exports = router;
