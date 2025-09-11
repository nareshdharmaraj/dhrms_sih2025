const mongoose = require('mongoose');

const WearableDataSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  deviceId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'WearableDevice',
    required: true
  },
  dataType: {
    type: String,
    enum: ['heart_rate', 'blood_pressure', 'oxygen_saturation', 'temperature', 'steps', 'calories', 'sleep', 'ecg', 'stress', 'activity'],
    required: true
  },
  timestamp: {
    type: Date,
    required: true,
    default: Date.now
  },
  // For hourly aggregated data
  hourlyTimestamp: {
    type: Date,
    required: true
  },
  // Main value (e.g., heart rate, steps count, temperature)
  value: {
    type: Number,
    required: true
  },
  // Secondary value (e.g., diastolic BP when value is systolic)
  secondaryValue: {
    type: Number
  },
  unit: {
    type: String,
    required: true,
    trim: true
  },
  // Quality indicator (0-100)
  quality: {
    type: Number,
    min: 0,
    max: 100,
    default: 100
  },
  // Status based on normal ranges
  status: {
    type: String,
    enum: ['normal', 'warning', 'critical', 'unknown'],
    default: 'normal'
  },
  // Additional metadata
  metadata: {
    // For activity data
    activityType: {
      type: String,
      enum: ['rest', 'light', 'moderate', 'vigorous', 'sleep']
    },
    // For sleep data
    sleepStage: {
      type: String,
      enum: ['awake', 'light', 'deep', 'rem']
    },
    // For ECG data
    ecgDuration: Number,
    ecgSampleRate: Number,
    // For stress data
    stressLevel: {
      type: String,
      enum: ['low', 'medium', 'high']
    },
    // Environmental factors
    ambientTemperature: Number,
    humidity: Number,
    // Device specific
    batteryLevel: Number,
    signalStrength: Number
  },
  // Flags for data processing
  isProcessed: {
    type: Boolean,
    default: false
  },
  isAggregated: {
    type: Boolean,
    default: false
  },
  // Alert flags
  triggerAlert: {
    type: Boolean,
    default: false
  },
  alertLevel: {
    type: String,
    enum: ['none', 'low', 'medium', 'high', 'critical'],
    default: 'none'
  },
  // Data source tracking
  source: {
    type: String,
    enum: ['real_time', 'batch_sync', 'manual_entry'],
    default: 'real_time'
  },
  syncBatchId: {
    type: String,
    trim: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Compound indexes for efficient querying
WearableDataSchema.index({ patientId: 1, dataType: 1, hourlyTimestamp: -1 });
WearableDataSchema.index({ deviceId: 1, timestamp: -1 });
WearableDataSchema.index({ hourlyTimestamp: -1, dataType: 1 });
WearableDataSchema.index({ patientId: 1, timestamp: -1 });
WearableDataSchema.index({ triggerAlert: 1, alertLevel: 1 });
WearableDataSchema.index({ isProcessed: 1, timestamp: 1 });

// TTL index for automatic data cleanup (optional - keep 1 year)
WearableDataSchema.index({ timestamp: 1 }, { expireAfterSeconds: 31536000 });

// Virtual for formatted value display
WearableDataSchema.virtual('formattedValue').get(function() {
  if (this.secondaryValue !== undefined) {
    return `${this.value}/${this.secondaryValue} ${this.unit}`;
  }
  return `${this.value} ${this.unit}`;
});

// Virtual for time ago
WearableDataSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diff = now - this.timestamp;
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);
  
  if (days > 0) return `${days}d ago`;
  if (hours > 0) return `${hours}h ago`;
  if (minutes > 0) return `${minutes}m ago`;
  return 'Just now';
});

// Method to determine if value is within normal range
WearableDataSchema.methods.checkNormalRange = function() {
  const normalRanges = {
    heart_rate: { min: 60, max: 100 },
    oxygen_saturation: { min: 95, max: 100 },
    temperature: { min: 36.1, max: 37.2 },
    blood_pressure: { 
      systolic: { min: 90, max: 140 },
      diastolic: { min: 60, max: 90 }
    }
  };

  const range = normalRanges[this.dataType];
  if (!range) return 'unknown';

  if (this.dataType === 'blood_pressure') {
    const systolicNormal = this.value >= range.systolic.min && this.value <= range.systolic.max;
    const diastolicNormal = this.secondaryValue >= range.diastolic.min && this.secondaryValue <= range.diastolic.max;
    
    if (systolicNormal && diastolicNormal) return 'normal';
    if (this.value > range.systolic.max || this.secondaryValue > range.diastolic.max) return 'critical';
    return 'warning';
  } else {
    if (this.value >= range.min && this.value <= range.max) return 'normal';
    if (this.value > range.max * 1.2 || this.value < range.min * 0.8) return 'critical';
    return 'warning';
  }
};

// Pre-save middleware to set hourly timestamp and status
WearableDataSchema.pre('save', function(next) {
  // Set hourly timestamp for aggregation
  const hour = new Date(this.timestamp);
  hour.setMinutes(0, 0, 0);
  this.hourlyTimestamp = hour;

  // Determine status based on value
  this.status = this.checkNormalRange();

  // Set alert flags for critical values
  if (this.status === 'critical') {
    this.triggerAlert = true;
    this.alertLevel = 'critical';
  } else if (this.status === 'warning') {
    this.triggerAlert = true;
    this.alertLevel = 'medium';
  }

  next();
});

// Static method to get latest data by type
WearableDataSchema.statics.getLatestByType = function(patientId, dataType, limit = 10) {
  return this.find({ patientId, dataType })
    .sort({ timestamp: -1 })
    .limit(limit)
    .populate('deviceId', 'deviceName deviceType');
};

// Static method to get hourly aggregated data
WearableDataSchema.statics.getHourlyData = function(patientId, dataType, startDate, endDate) {
  return this.aggregate([
    {
      $match: {
        patientId: new mongoose.Types.ObjectId(patientId),
        dataType,
        hourlyTimestamp: {
          $gte: startDate,
          $lte: endDate
        }
      }
    },
    {
      $group: {
        _id: '$hourlyTimestamp',
        avgValue: { $avg: '$value' },
        minValue: { $min: '$value' },
        maxValue: { $max: '$value' },
        count: { $sum: 1 },
        criticalCount: {
          $sum: { $cond: [{ $eq: ['$status', 'critical'] }, 1, 0] }
        }
      }
    },
    {
      $sort: { '_id': 1 }
    }
  ]);
};

// Static method to get alert data
WearableDataSchema.statics.getAlerts = function(patientId, alertLevel, limit = 50) {
  const match = { patientId, triggerAlert: true };
  if (alertLevel) match.alertLevel = alertLevel;

  return this.find(match)
    .sort({ timestamp: -1 })
    .limit(limit)
    .populate('deviceId', 'deviceName deviceType');
};

module.exports = mongoose.model('WearableData', WearableDataSchema);
