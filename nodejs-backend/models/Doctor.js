const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const doctorSchema = new mongoose.Schema({
  doctorId: {
    type: String,
    unique: true,
    required: true
  },
  hospital: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hospital',
    required: true
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
      required: true,
      unique: true,
      lowercase: true
    },
    phone: {
      type: String,
      required: true
    },
    dateOfBirth: Date,
    gender: {
      type: String,
      enum: ['male', 'female', 'other']
    },
    address: {
      street: String,
      city: String,
      state: String,
      pincode: String
    }
  },
  professionalInfo: {
    medicalLicenseNumber: {
      type: String,
      required: true,
      unique: true
    },
    specialization: [{
      type: String,
      required: true
    }],
    qualification: [{
      degree: String,
      institution: String,
      year: Number
    }],
    experience: {
      type: Number,
      required: true
    },
    department: {
      type: String,
      required: true
    },
    position: {
      type: String,
      enum: ['junior', 'senior', 'consultant', 'head', 'chief'],
      default: 'junior'
    }
  },
  credentials: {
    username: {
      type: String,
      required: true,
      unique: true
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
  schedule: {
    monday: { start: String, end: String, available: Boolean },
    tuesday: { start: String, end: String, available: Boolean },
    wednesday: { start: String, end: String, available: Boolean },
    thursday: { start: String, end: String, available: Boolean },
    friday: { start: String, end: String, available: Boolean },
    saturday: { start: String, end: String, available: Boolean },
    sunday: { start: String, end: String, available: Boolean }
  },
  statistics: {
    totalPatients: {
      type: Number,
      default: 0
    },
    totalPrescriptions: {
      type: Number,
      default: 0
    },
    totalConsultations: {
      type: Number,
      default: 0
    },
    rating: {
      average: {
        type: Number,
        default: 0
      },
      count: {
        type: Number,
        default: 0
      }
    }
  },
  patients: [{
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Patient'
    },
    firstConsultation: Date,
    lastConsultation: Date,
    status: {
      type: String,
      enum: ['active', 'inactive', 'transferred'],
      default: 'active'
    }
  }],
  availability: {
    isAvailable: {
      type: Boolean,
      default: true
    },
    nextAvailableSlot: Date,
    consultationFee: Number
  }
}, {
  timestamps: true
});

// Pre-save middleware to hash password
doctorSchema.pre('save', async function(next) {
  if (!this.isModified('credentials.password')) return next();
  
  this.credentials.password = await bcrypt.hash(this.credentials.password, 12);
  next();
});

// Method to check password
doctorSchema.methods.comparePassword = async function(password) {
  return await bcrypt.compare(password, this.credentials.password);
};

// Generate doctor ID
doctorSchema.pre('save', async function(next) {
  if (!this.doctorId) {
    const prefix = 'DOC';
    const randomNum = Math.floor(Math.random() * 90000) + 10000;
    this.doctorId = `${prefix}${randomNum}`;
  }
  next();
});

// Virtual for full name
doctorSchema.virtual('fullName').get(function() {
  return `${this.personalInfo.firstName} ${this.personalInfo.lastName}`;
});

module.exports = mongoose.model('Doctor', doctorSchema);
