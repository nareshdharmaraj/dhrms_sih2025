const mongoose = require('mongoose');

const healthReminderSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  
  description: {
    type: String,
    trim: true,
    maxlength: 500
  },
  
  reminderType: {
    type: String,
    enum: ['medication', 'appointment', 'exercise', 'diet', 'vitals', 'other'],
    default: 'medication'
  },
  
  reminderTime: {
    type: String, // Format: "HH:MM" (24-hour format)
    required: true,
    validate: {
      validator: function(v) {
        return /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/.test(v);
      },
      message: 'Reminder time must be in HH:MM format'
    }
  },
  
  frequency: {
    type: String,
    enum: ['daily', 'weekly', 'monthly', 'custom'],
    default: 'daily'
  },
  
  // For custom frequency patterns
  customFrequency: {
    days: [{
      type: String,
      enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    }],
    interval: {
      type: Number, // For every X days/weeks/months
      min: 1,
      default: 1
    }
  },
  
  // Medication specific fields
  medicationDetails: {
    medicationName: String,
    dosage: String,
    instructions: String
  },
  
  // Appointment specific fields
  appointmentDetails: {
    doctorName: String,
    hospitalName: String,
    appointmentType: String,
    location: String
  },
  
  isEnabled: {
    type: Boolean,
    default: true
  },
  
  // Reminder tracking
  lastTriggered: {
    type: Date
  },
  
  nextReminder: {
    type: Date
  },
  
  reminderCount: {
    type: Number,
    default: 0
  },
  
  // System fields
  isActive: {
    type: Boolean,
    default: true
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

// Update the updatedAt field before saving
healthReminderSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  
  // Calculate next reminder time based on frequency
  if (this.isModified('reminderTime') || this.isModified('frequency')) {
    this.calculateNextReminder();
  }
  
  next();
});

// Method to calculate next reminder time
healthReminderSchema.methods.calculateNextReminder = function() {
  const now = new Date();
  const [hours, minutes] = this.reminderTime.split(':');
  
  let nextReminder = new Date();
  nextReminder.setHours(parseInt(hours), parseInt(minutes), 0, 0);
  
  // If the time has passed today, set for tomorrow
  if (nextReminder <= now) {
    nextReminder.setDate(nextReminder.getDate() + 1);
  }
  
  // Adjust based on frequency
  switch (this.frequency) {
    case 'weekly':
      nextReminder.setDate(nextReminder.getDate() + 7);
      break;
    case 'monthly':
      nextReminder.setMonth(nextReminder.getMonth() + 1);
      break;
    case 'custom':
      // Handle custom frequency logic here
      break;
    // 'daily' is default - no adjustment needed
  }
  
  this.nextReminder = nextReminder;
};

// Static method to get due reminders
healthReminderSchema.statics.getDueReminders = function() {
  return this.find({
    isActive: true,
    isEnabled: true,
    nextReminder: { $lte: new Date() }
  }).populate('patientId', 'fullName email phone');
};

// Indexes for better performance
healthReminderSchema.index({ patientId: 1, isActive: 1 });
healthReminderSchema.index({ nextReminder: 1, isEnabled: 1, isActive: 1 });
healthReminderSchema.index({ reminderType: 1 });

module.exports = mongoose.model('HealthReminder', healthReminderSchema);