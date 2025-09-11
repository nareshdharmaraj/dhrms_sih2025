const WearableDevice = require('../models/WearableDevice');
const WearableData = require('../models/WearableData');
const Patient = require('../models/Patient');
const mongoose = require('mongoose');

// Register a new wearable device
const registerDevice = async (req, res) => {
  try {
    const {
      patientId,
      deviceName,
      deviceType,
      manufacturer,
      model,
      macAddress,
      bluetoothId,
      firmwareVersion,
      capabilities
    } = req.body;

    // Validate patient exists
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Check if device already exists
    const existingDevice = await WearableDevice.findOne({
      $or: [
        { macAddress },
        { bluetoothId }
      ]
    });

    if (existingDevice) {
      return res.status(409).json({
        success: false,
        message: 'Device already registered'
      });
    }

    // Create new device
    const device = new WearableDevice({
      patientId,
      deviceName,
      deviceType,
      manufacturer,
      model,
      macAddress,
      bluetoothId,
      firmwareVersion,
      capabilities: capabilities || []
    });

    await device.save();

    res.status(201).json({
      success: true,
      message: 'Device registered successfully',
      data: {
        device
      }
    });

  } catch (error) {
    console.error('Register device error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register device',
      error: error.message
    });
  }
};

// Get all devices for a patient
const getPatientDevices = async (req, res) => {
  try {
    const { patientId } = req.params;

    const devices = await WearableDevice.findByPatient(patientId);

    res.json({
      success: true,
      data: {
        devices,
        count: devices.length
      }
    });

  } catch (error) {
    console.error('Get patient devices error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch devices',
      error: error.message
    });
  }
};

// Update device connection status
const updateDeviceStatus = async (req, res) => {
  try {
    const { deviceId } = req.params;
    const { connectionStatus, batteryLevel, isConnected } = req.body;

    const device = await WearableDevice.findById(deviceId);
    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'Device not found'
      });
    }

    // Update device status
    if (connectionStatus) {
      await device.updateConnectionStatus(connectionStatus);
    }
    
    if (batteryLevel !== undefined) {
      device.batteryLevel = batteryLevel;
    }

    if (isConnected !== undefined) {
      device.isConnected = isConnected;
    }

    await device.save();

    res.json({
      success: true,
      message: 'Device status updated',
      data: { device }
    });

  } catch (error) {
    console.error('Update device status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update device status',
      error: error.message
    });
  }
};

// Store wearable data (single or batch)
const storeWearableData = async (req, res) => {
  try {
    const { data } = req.body; // Expecting array of data points

    if (!Array.isArray(data) || data.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Data array is required'
      });
    }

    // Validate all data points
    const validatedData = [];
    for (const dataPoint of data) {
      const {
        patientId,
        deviceId,
        dataType,
        timestamp,
        value,
        secondaryValue,
        unit,
        quality,
        metadata,
        source
      } = dataPoint;

      // Validate required fields
      if (!patientId || !deviceId || !dataType || !value || !unit) {
        continue; // Skip invalid data points
      }

      validatedData.push({
        patientId: new mongoose.Types.ObjectId(patientId),
        deviceId: new mongoose.Types.ObjectId(deviceId),
        dataType,
        timestamp: timestamp ? new Date(timestamp) : new Date(),
        value: parseFloat(value),
        secondaryValue: secondaryValue ? parseFloat(secondaryValue) : undefined,
        unit,
        quality: quality || 100,
        metadata: metadata || {},
        source: source || 'real_time'
      });
    }

    if (validatedData.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No valid data points found'
      });
    }

    // Insert data points
    const savedData = await WearableData.insertMany(validatedData);

    // Check for critical alerts
    const criticalData = savedData.filter(item => item.triggerAlert && item.alertLevel === 'critical');
    
    if (criticalData.length > 0) {
      // Trigger real-time alerts (you can add WebSocket or push notification logic here)
      console.log(`Critical alert: ${criticalData.length} critical readings detected`);
    }

    res.status(201).json({
      success: true,
      message: `${savedData.length} data points stored successfully`,
      data: {
        stored: savedData.length,
        criticalAlerts: criticalData.length
      }
    });

  } catch (error) {
    console.error('Store wearable data error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to store wearable data',
      error: error.message
    });
  }
};

// Get latest wearable data for a patient
const getLatestData = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { dataType, limit = 10 } = req.query;

    let query = { patientId };
    if (dataType) {
      query.dataType = dataType;
    }

    const latestData = await WearableData.find(query)
      .sort({ timestamp: -1 })
      .limit(parseInt(limit))
      .populate('deviceId', 'deviceName deviceType manufacturer model');

    res.json({
      success: true,
      data: {
        readings: latestData
      }
    });

  } catch (error) {
    console.error('Get latest data error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch latest data',
      error: error.message
    });
  }
};

// Get hourly aggregated data
const getHourlyData = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { dataType, startDate, endDate, timezone = 'UTC' } = req.query;

    if (!dataType) {
      return res.status(400).json({
        success: false,
        message: 'dataType is required'
      });
    }

    const start = startDate ? new Date(startDate) : new Date(Date.now() - 24 * 60 * 60 * 1000); // Default: 24 hours ago
    const end = endDate ? new Date(endDate) : new Date(); // Default: now

    const hourlyData = await WearableData.getHourlyData(patientId, dataType, start, end);

    res.json({
      success: true,
      data: {
        dataType,
        period: { start, end },
        hourlyReadings: hourlyData
      }
    });

  } catch (error) {
    console.error('Get hourly data error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch hourly data',
      error: error.message
    });
  }
};

// Get alerts for a patient
const getAlerts = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { alertLevel, limit = 50 } = req.query;

    const alerts = await WearableData.getAlerts(patientId, alertLevel, parseInt(limit));

    res.json({
      success: true,
      data: {
        alerts,
        count: alerts.length
      }
    });

  } catch (error) {
    console.error('Get alerts error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch alerts',
      error: error.message
    });
  }
};

// Get patient health dashboard data
const getHealthDashboard = async (req, res) => {
  try {
    const { patientId } = req.params;

    // Get connected devices
    const connectedDevices = await WearableDevice.findConnectedDevices(patientId);

    // Get latest readings for each vital sign
    const vitalTypes = ['heart_rate', 'blood_pressure', 'oxygen_saturation', 'temperature', 'steps'];
    const latestReadings = {};

    for (const type of vitalTypes) {
      const reading = await WearableData.getLatestByType(patientId, type, 1);
      if (reading.length > 0) {
        latestReadings[type] = reading[0];
      }
    }

    // Get recent alerts
    const recentAlerts = await WearableData.getAlerts(patientId, null, 10);

    // Get today's activity summary
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const todaySteps = await WearableData.find({
      patientId,
      dataType: 'steps',
      timestamp: { $gte: today, $lt: tomorrow }
    }).sort({ timestamp: -1 }).limit(1);

    const todayCalories = await WearableData.find({
      patientId,
      dataType: 'calories',
      timestamp: { $gte: today, $lt: tomorrow }
    }).sort({ timestamp: -1 }).limit(1);

    res.json({
      success: true,
      data: {
        connectedDevices,
        latestReadings,
        recentAlerts,
        todayActivity: {
          steps: todaySteps.length > 0 ? todaySteps[0].value : 0,
          calories: todayCalories.length > 0 ? todayCalories[0].value : 0
        }
      }
    });

  } catch (error) {
    console.error('Get health dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch health dashboard data',
      error: error.message
    });
  }
};

// Delete device and its data
const deleteDevice = async (req, res) => {
  try {
    const { deviceId } = req.params;
    const { deleteData = false } = req.query;

    const device = await WearableDevice.findById(deviceId);
    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'Device not found'
      });
    }

    // Delete device data if requested
    if (deleteData === 'true') {
      await WearableData.deleteMany({ deviceId });
    }

    // Delete device
    await WearableDevice.findByIdAndDelete(deviceId);

    res.json({
      success: true,
      message: 'Device deleted successfully'
    });

  } catch (error) {
    console.error('Delete device error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete device',
      error: error.message
    });
  }
};

module.exports = {
  registerDevice,
  getPatientDevices,
  updateDeviceStatus,
  storeWearableData,
  getLatestData,
  getHourlyData,
  getAlerts,
  getHealthDashboard,
  deleteDevice
};
