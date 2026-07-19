const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema({
  patientId: {
    type: String,
    unique: true,
    required: true
  },
  uhi: {
    type: String,
    unique: true,
    required: true,
    uppercase: true
  },
  personalInfo: {
    firstName: {
      type: String,
      required: true,
      trim: true
    },
    lastName: {
      type: String,
      required: true,
      trim: true
    },
    email: {
      type: String,
      lowercase: true
    },
    phone: {
      type: String,
      required: true
    },
    aadhaarNumber: {
      type: String,
      required: true,
      unique: true
    },
    dateOfBirth: {
      type: Date,
      required: true
    },
    gender: {
      type: String,
      enum: ['male', 'female', 'other'],
      required: true
    },
    bloodGroup: {
      type: String,
      enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
    },
    maritalStatus: {
      type: String,
      enum: ['single', 'married', 'divorced', 'widowed']
    }
  },
  address: {
    current: {
      street: String,
      city: String,
      state: String,
      pincode: String,
      coordinates: {
        latitude: Number,
        longitude: Number
      }
    },
    permanent: {
      street: String,
      city: String,
      state: String,
      pincode: String
    }
  },
  credentials: {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true
    },
    password: {
      type: String,
      required: true,
      minlength: 6
    },
    lastLogin: Date,
    isActive: {
      type: Boolean,
      default: true
    },
    isVerified: {
      type: Boolean,
      default: false
    }
  },
  medicalHistory: {
    allergies: [{
      allergen: String,
      severity: {
        type: String,
        enum: ['mild', 'moderate', 'severe']
      },
      description: String
    }],
    chronicConditions: [{
      condition: String,
      diagnosedDate: Date,
      status: {
        type: String,
        enum: ['active', 'controlled', 'resolved']
      }
    }],
    surgicalHistory: [{
      surgery: String,
      date: Date,
      hospital: String,
      surgeon: String
    }],
    familyHistory: [{
      relation: String,
      condition: String,
      ageOfOnset: Number
    }],
    vaccinations: [{
      vaccine: String,
      date: Date,
      nextDue: Date,
      batch: String
    }]
  },
  currentHealth: {
    vitals: {
      height: Number,
      weight: Number,
      bmi: Number,
      bloodPressure: {
        systolic: Number,
        diastolic: Number
      },
      heartRate: Number,
      temperature: Number,
      oxygenSaturation: Number
    },
    currentMedications: [{
      medication: String,
      dosage: String,
      frequency: String,
      startDate: Date,
      prescribedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor'
      }
    }],
    riskFactors: [{
      factor: String,
      level: {
        type: String,
        enum: ['low', 'moderate', 'high']
      }
    }]
  },
  emergencyContacts: [{
    name: {
      type: String,
      required: true
    },
    relationship: String,
    phone: {
      type: String,
      required: true
    },
    email: String,
    isPrimary: {
      type: Boolean,
      default: false
    }
  }],
  insurance: {
    provider: String,
    policyNumber: String,
    validUntil: Date,
    coverageAmount: Number,
    ayushmanBharat: {
      isEnrolled: {
        type: Boolean,
        default: false
      },
      cardNumber: String
    }
  },
  employment: {
    employer: String,
    occupation: String,
    workLocation: {
      city: String,
      state: String
    },
    employmentType: {
      type: String,
      enum: ['permanent', 'contract', 'migrant', 'daily_wage']
    }
  },
  healthRecords: [{
    type: {
      type: String,
      enum: ['consultation', 'test_result', 'prescription', 'vaccination', 'emergency']
    },
    date: Date,
    hospital: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Hospital'
    },
    doctor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Doctor'
    },
    description: String,
    documents: [String],
    severity: {
      type: String,
      enum: ['low', 'medium', 'high', 'critical']
    }
  }],
  wearableData: {
    deviceId: String,
    isConnected: {
      type: Boolean,
      default: false
    },
    lastSync: Date,
    preferences: {
      alertsEnabled: {
        type: Boolean,
        default: true
      },
      proximityAlerts: {
        type: Boolean,
        default: true
      }
    }
  },
  healthScore: {
    overall: {
      type: Number,
      default: 100,
      min: 0,
      max: 100
    },
    lastCalculated: Date,
    factors: [{
      factor: String,
      score: Number,
      weight: Number
    }]
  }
}, {
  timestamps: true
});

// Pre-save middleware (password hashing removed - plaintext)
patientSchema.pre('save', async function(next) {
  // Skip password hashing - store as plaintext
  next();
});

// Method to check password (plaintext comparison)
patientSchema.methods.comparePassword = async function(password) {
  return password === this.credentials.password;
};

// Generate patient ID and UHI
patientSchema.pre('save', async function(next) {
  if (!this.patientId) {
    // Patient ID format: FIRSTNAME + 4 random digits
    const firstName = this.personalInfo.firstName.toUpperCase().replace(/\s/g, '');
    const randomNum = Math.floor(Math.random() * 9000) + 1000;
    this.patientId = `${firstName}${randomNum}`;
  }
  
  if (!this.uhi && this.aadhaarNumber) {
    // UHI format: Short name + Last 4 digits of Aadhaar
    const shortName = this.personalInfo.firstName.substring(0, 4).toUpperCase();
    const aadhaarLast4 = this.aadhaarNumber.slice(-4);
    this.uhi = `${shortName}${aadhaarLast4}`;
  }
  
  // Calculate BMI if height and weight are provided
  if (this.currentHealth.vitals.height && this.currentHealth.vitals.weight) {
    const heightInMeters = this.currentHealth.vitals.height / 100;
    this.currentHealth.vitals.bmi = parseFloat(
      (this.currentHealth.vitals.weight / (heightInMeters * heightInMeters)).toFixed(2)
    );
  }
  
  next();
});

// Virtual for full name
patientSchema.virtual('fullName').get(function() {
  return `${this.personalInfo.firstName} ${this.personalInfo.lastName}`;
});

// Virtual for age
patientSchema.virtual('age').get(function() {
  if (this.personalInfo.dateOfBirth) {
    const today = new Date();
    const birthDate = new Date(this.personalInfo.dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  }
  return null;
});

module.exports = mongoose.model('Patient', patientSchema);
