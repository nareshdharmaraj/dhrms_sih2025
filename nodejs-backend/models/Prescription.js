const mongoose = require('mongoose');

const prescriptionSchema = new mongoose.Schema({
  prescriptionId: {
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
  consultation: {
    date: {
      type: Date,
      default: Date.now
    },
    symptoms: [String],
    diagnosis: {
      primary: {
        type: String,
        required: true
      },
      secondary: [String],
      icdCode: String
    },
    notes: String,
    followUpDate: Date
  },
  medications: [{
    name: {
      type: String,
      required: true
    },
    genericName: String,
    dosage: {
      type: String,
      required: true
    },
    frequency: {
      type: String,
      required: true
    },
    duration: {
      value: {
        type: Number,
        required: true
      },
      unit: {
        type: String,
        enum: ['days', 'weeks', 'months'],
        default: 'days'
      }
    },
    instructions: {
      beforeFood: Boolean,
      afterFood: Boolean,
      timing: [String],
      specialInstructions: String
    },
    quantity: {
      prescribed: Number,
      unit: String
    }
  }],
  tests: [{
    testName: {
      type: String,
      required: true
    },
    instructions: String,
    urgency: {
      type: String,
      enum: ['routine', 'urgent', 'stat'],
      default: 'routine'
    },
    estimatedCost: Number
  }],
  status: {
    type: String,
    enum: ['active', 'completed', 'cancelled', 'expired'],
    default: 'active'
  },
  validity: {
    startDate: {
      type: Date,
      default: Date.now
    },
    endDate: Date,
    isValid: {
      type: Boolean,
      default: true
    }
  },
  pharmacy: {
    dispensedAt: String,
    dispensedDate: Date,
    pharmacistName: String,
    isDispensed: {
      type: Boolean,
      default: false
    }
  },
  digitalSignature: {
    doctorSignature: String,
    timestamp: Date,
    verified: {
      type: Boolean,
      default: false
    }
  },
  billing: {
    consultationFee: Number,
    medicationCost: Number,
    testCost: Number,
    totalAmount: Number,
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'insurance_claimed'],
      default: 'pending'
    }
  },
  reminders: [{
    medicationName: String,
    reminderTime: [String],
    isActive: {
      type: Boolean,
      default: true
    },
    lastReminded: Date
  }],
  adherence: {
    totalDoses: Number,
    takenDoses: Number,
    missedDoses: Number,
    adherencePercentage: Number
  }
}, {
  timestamps: true
});

// Generate prescription ID
prescriptionSchema.pre('save', async function(next) {
  if (!this.prescriptionId) {
    const prefix = 'RX';
    const date = new Date();
    const year = date.getFullYear().toString().slice(-2);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const randomNum = Math.floor(Math.random() * 90000) + 10000;
    this.prescriptionId = `${prefix}${year}${month}${randomNum}`;
  }
  
  // Calculate total amount
  if (this.billing.consultationFee || this.billing.medicationCost || this.billing.testCost) {
    this.billing.totalAmount = 
      (this.billing.consultationFee || 0) + 
      (this.billing.medicationCost || 0) + 
      (this.billing.testCost || 0);
  }
  
  // Set validity end date based on longest medication duration
  if (this.medications.length > 0 && !this.validity.endDate) {
    const maxDuration = Math.max(...this.medications.map(med => {
      const daysMultiplier = med.duration.unit === 'weeks' ? 7 : 
                           med.duration.unit === 'months' ? 30 : 1;
      return med.duration.value * daysMultiplier;
    }));
    
    this.validity.endDate = new Date(this.validity.startDate);
    this.validity.endDate.setDate(this.validity.endDate.getDate() + maxDuration);
  }
  
  next();
});

// Method to check if prescription is expired
prescriptionSchema.methods.isExpired = function() {
  return this.validity.endDate && new Date() > this.validity.endDate;
};

// Method to calculate adherence percentage
prescriptionSchema.methods.calculateAdherence = function() {
  if (this.adherence.totalDoses > 0) {
    this.adherence.adherencePercentage = Math.round(
      (this.adherence.takenDoses / this.adherence.totalDoses) * 100
    );
  }
  return this.adherence.adherencePercentage;
};

module.exports = mongoose.model('Prescription', prescriptionSchema);
