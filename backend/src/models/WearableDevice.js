const mongoose = require('mongoose');

const WearableDeviceSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  deviceName: {
    type: String,
    required: true,
    trim: true
  },
  deviceType: {
    type: String,
    enum: ['smartwatch', 'fitness_band', 'heart_monitor', 'blood_pressure_monitor', 'pulse_oximeter'],
    required: true
  },
  manufacturer: {
    type: String,
    required: true,
    trim: true
  },
  model: {
    type: String,
    required: true,
    trim: true
  },
  macAddress: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  bluetoothId: {
    type: String,
    required: true,
    trim: true
  },
  isConnected: {
    type: Boolean,
    default: false
  },
  batteryLevel: {
    type: Number,
    min: 0,
    max: 100,
    default: 100
  },
  firmwareVersion: {
    type: String,
    trim: true
  },
  capabilities: [{
    type: String,
    enum: ['heart_rate', 'blood_pressure', 'oxygen_saturation', 'temperature', 'steps', 'calories', 'sleep', 'ecg', 'stress']
  }],
  lastSyncTime: {
    type: Date,
    default: Date.now
  },
  connectionStatus: {
    type: String,
    enum: ['connected', 'disconnected', 'syncing', 'error'],
    default: 'disconnected'
  },
  autoSync: {
    type: Boolean,
    default: true
  },
  syncInterval: {
    type: Number,
    default: 300, // 5 minutes in seconds
    min: 60 // minimum 1 minute
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better performance
WearableDeviceSchema.index({ patientId: 1, isConnected: 1 });
WearableDeviceSchema.index({ macAddress: 1 });
WearableDeviceSchema.index({ bluetoothId: 1 });

// Virtual for device status
WearableDeviceSchema.virtual('isOnline').get(function() {
  if (!this.lastSyncTime) return false;
  const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
  return this.isConnected && this.lastSyncTime > fiveMinutesAgo;
});

// Virtual for battery status
WearableDeviceSchema.virtual('batteryStatus').get(function() {
  if (this.batteryLevel > 50) return 'good';
  if (this.batteryLevel > 20) return 'medium';
  return 'low';
});

// Method to update connection status
WearableDeviceSchema.methods.updateConnectionStatus = function(status) {
  this.connectionStatus = status;
  this.isConnected = status === 'connected';
  if (status === 'connected') {
    this.lastSyncTime = new Date();
  }
  return this.save();
};

// Method to check if device supports a capability
WearableDeviceSchema.methods.supportsCapability = function(capability) {
  return this.capabilities.includes(capability);
};

// Static method to find devices by patient
WearableDeviceSchema.statics.findByPatient = function(patientId) {
  return this.find({ patientId }).sort({ createdAt: -1 });
};

// Static method to find connected devices
WearableDeviceSchema.statics.findConnectedDevices = function(patientId) {
  return this.find({ 
    patientId, 
    isConnected: true,
    connectionStatus: 'connected'
  });
};

module.exports = mongoose.model('WearableDevice', WearableDeviceSchema);
