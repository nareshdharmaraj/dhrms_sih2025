const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const hospitalSchema = new mongoose.Schema({
  hospitalId: {
    type: String,
    unique: true,
    required: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  type: {
    type: String,
    enum: ['government', 'private', 'trust', 'corporate'],
    required: true
  },
  registrationNumber: {
    type: String,
    required: true,
    unique: true
  },
  address: {
    street: String,
    city: String,
    state: String,
    pincode: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  contactInfo: {
    phone: {
      type: String,
      required: true
    },
    email: {
      type: String,
      required: true,
      lowercase: true
    },
    website: String,
    emergencyContact: String
  },
  facilities: [{
    name: String,
    description: String,
    available: Boolean
  }],
  departments: [{
    name: String,
    headDoctor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Doctor'
    },
    bedCount: Number,
    availableBeds: Number
  }],
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
    }
  },
  statistics: {
    totalDoctors: {
      type: Number,
      default: 0
    },
    totalPatients: {
      type: Number,
      default: 0
    },
    totalBeds: {
      type: Number,
      default: 0
    },
    availableBeds: {
      type: Number,
      default: 0
    }
  },
  certification: {
    accreditation: String,
    validUntil: Date,
    isVerified: {
      type: Boolean,
      default: false
    }
  },
  operatingHours: {
    monday: { open: String, close: String },
    tuesday: { open: String, close: String },
    wednesday: { open: String, close: String },
    thursday: { open: String, close: String },
    friday: { open: String, close: String },
    saturday: { open: String, close: String },
    sunday: { open: String, close: String }
  }
}, {
  timestamps: true
});

// Pre-save middleware to hash password
hospitalSchema.pre('save', async function(next) {
  if (!this.isModified('credentials.password')) return next();
  
  this.credentials.password = await bcrypt.hash(this.credentials.password, 12);
  next();
});

// Method to check password
hospitalSchema.methods.comparePassword = async function(password) {
  return await bcrypt.compare(password, this.credentials.password);
};

// Generate hospital ID
hospitalSchema.pre('save', async function(next) {
  if (!this.hospitalId) {
    const prefix = 'HSP';
    const randomNum = Math.floor(Math.random() * 90000) + 10000;
    this.hospitalId = `${prefix}${randomNum}`;
  }
  next();
});

module.exports = mongoose.model('Hospital', hospitalSchema);
