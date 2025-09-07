const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  appointmentId: {
    type: String,
    unique: true,
    required: true
  },
  patient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  doctor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Doctor',
    required: true
  },
  hospital: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hospital',
    required: true
  },
  appointmentDetails: {
    type: {
      type: String,
      enum: ['regular', 'emergency', 'follow-up', 'consultation', 'procedure'],
      default: 'regular'
    },
    specialty: {
      type: String,
      required: true
    },
    reasonForVisit: {
      type: String,
      required: true,
      maxlength: 500
    },
    priority: {
      type: String,
      enum: ['low', 'medium', 'high', 'emergency'],
      default: 'medium'
    }
  },
  scheduling: {
    preferredDate: {
      type: Date,
      required: true
    },
    preferredTime: {
      type: String,
      required: true
    },
    duration: {
      type: Number, // in minutes
      default: 30
    },
    timeSlot: {
      startTime: Date,
      endTime: Date
    }
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'in-progress', 'completed', 'cancelled', 'no-show', 'rescheduled'],
    default: 'pending'
  },
  bookingInfo: {
    bookedBy: {
      type: String,
      enum: ['patient', 'doctor', 'hospital', 'system'],
      default: 'patient'
    },
    bookingDate: {
      type: Date,
      default: Date.now
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'partially-paid', 'refunded'],
      default: 'pending'
    },
    consultationFee: {
      type: Number,
      required: true
    }
  },
  notifications: {
    patientNotified: {
      type: Boolean,
      default: false
    },
    doctorNotified: {
      type: Boolean,
      default: false
    },
    remindersSent: [{
      type: {
        type: String,
        enum: ['sms', 'email', 'push']
      },
      sentAt: Date,
      status: {
        type: String,
        enum: ['sent', 'delivered', 'failed']
      }
    }]
  },
  consultation: {
    actualStartTime: Date,
    actualEndTime: Date,
    consultationNotes: String,
    diagnosis: String,
    treatmentPlan: String,
    followUpRequired: {
      type: Boolean,
      default: false
    },
    followUpDate: Date,
    prescription: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Prescription'
    }
  },
  telemedicine: {
    isTelemedicine: {
      type: Boolean,
      default: false
    },
    sessionLink: String,
    sessionId: String,
    recordingUrl: String
  },
  history: [{
    action: {
      type: String,
      enum: ['created', 'confirmed', 'rescheduled', 'cancelled', 'completed', 'no-show']
    },
    timestamp: {
      type: Date,
      default: Date.now
    },
    reason: String,
    updatedBy: {
      userId: mongoose.Schema.Types.ObjectId,
      userType: {
        type: String,
        enum: ['patient', 'doctor', 'hospital', 'system']
      }
    }
  }],
  cancellation: {
    cancelledBy: {
      type: String,
      enum: ['patient', 'doctor', 'hospital', 'system']
    },
    cancellationDate: Date,
    reason: String,
    refundAmount: Number,
    refundStatus: {
      type: String,
      enum: ['pending', 'processed', 'failed']
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for appointment duration in human readable format
appointmentSchema.virtual('formattedDuration').get(function() {
  const hours = Math.floor(this.scheduling.duration / 60);
  const minutes = this.scheduling.duration % 60;
  return hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
});

// Virtual for time until appointment
appointmentSchema.virtual('timeUntilAppointment').get(function() {
  if (!this.scheduling.timeSlot.startTime) return null;
  const now = new Date();
  const appointmentTime = new Date(this.scheduling.timeSlot.startTime);
  const diffMs = appointmentTime - now;
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
  const diffMinutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
  
  if (diffMs < 0) return 'Past';
  if (diffHours > 24) return `${Math.floor(diffHours / 24)} days`;
  if (diffHours > 0) return `${diffHours}h ${diffMinutes}m`;
  return `${diffMinutes}m`;
});

// Indexes for performance
appointmentSchema.index({ appointmentId: 1 });
appointmentSchema.index({ patient: 1, 'scheduling.preferredDate': 1 });
appointmentSchema.index({ doctor: 1, 'scheduling.preferredDate': 1 });
appointmentSchema.index({ hospital: 1, 'scheduling.preferredDate': 1 });
appointmentSchema.index({ status: 1 });
appointmentSchema.index({ 'scheduling.timeSlot.startTime': 1, 'scheduling.timeSlot.endTime': 1 });
appointmentSchema.index({ 'appointmentDetails.specialty': 1 });

// Pre-save middleware to generate appointmentId
appointmentSchema.pre('save', async function(next) {
  if (!this.appointmentId) {
    const count = await mongoose.model('Appointment').countDocuments();
    this.appointmentId = `APT${String(count + 1).padStart(8, '0')}`;
  }
  next();
});

// Pre-save middleware to set time slot if not provided
appointmentSchema.pre('save', function(next) {
  if (!this.scheduling.timeSlot.startTime && this.scheduling.preferredDate && this.scheduling.preferredTime) {
    const [hours, minutes] = this.scheduling.preferredTime.split(':');
    const startTime = new Date(this.scheduling.preferredDate);
    startTime.setHours(parseInt(hours), parseInt(minutes), 0, 0);
    
    const endTime = new Date(startTime);
    endTime.setMinutes(endTime.getMinutes() + this.scheduling.duration);
    
    this.scheduling.timeSlot = {
      startTime,
      endTime
    };
  }
  next();
});

// Method to check if appointment can be cancelled
appointmentSchema.methods.canBeCancelled = function() {
  const now = new Date();
  const appointmentTime = new Date(this.scheduling.timeSlot.startTime);
  const hoursDifference = (appointmentTime - now) / (1000 * 60 * 60);
  
  return this.status === 'confirmed' && hoursDifference >= 24; // 24 hour cancellation policy
};

// Method to check if appointment can be rescheduled
appointmentSchema.methods.canBeRescheduled = function() {
  const now = new Date();
  const appointmentTime = new Date(this.scheduling.timeSlot.startTime);
  const hoursDifference = (appointmentTime - now) / (1000 * 60 * 60);
  
  return ['pending', 'confirmed'].includes(this.status) && hoursDifference >= 12; // 12 hour reschedule policy
};

// Static method to find conflicts
appointmentSchema.statics.findConflicts = async function(doctorId, startTime, endTime, excludeId = null) {
  const query = {
    doctor: doctorId,
    status: { $in: ['confirmed', 'in-progress'] },
    $or: [
      {
        'scheduling.timeSlot.startTime': { $lt: endTime },
        'scheduling.timeSlot.endTime': { $gt: startTime }
      }
    ]
  };
  
  if (excludeId) {
    query._id = { $ne: excludeId };
  }
  
  return await this.find(query);
};

module.exports = mongoose.model('Appointment', appointmentSchema);
