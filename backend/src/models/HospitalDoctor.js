const mongoose = require('mongoose');

const hospitalDoctorSchema = new mongoose.Schema({
  doctorId: {
    type: String,
    required: true,
    unique: true
  },
  
  hospitalId: {
    type: String,
    required: true,
    ref: 'Hospital'
  },
  
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  
  name: {
    type: String,
    required: true,
    trim: true,
    minlength: 3,
    maxlength: 50
  },
  
  // Keep backwards compatibility
  doctorName: {
    type: String,
    trim: true,
    maxlength: 100
  },
  
  gender: {
    type: String,
    required: true,
    enum: ['Male', 'Female', 'Other']
  },
  
  dateOfBirth: {
    type: Date,
    required: true,
    validate: {
      validator: function(v) {
        const age = (new Date().getFullYear()) - (new Date(v).getFullYear());
        return age >= 18 && age <= 100;
      },
      message: 'Doctor must be at least 18 years old'
    }
  },
  
  specializations: [{
    type: String,
    required: true,
    trim: true,
    enum: [
      'General Medicine', 'Cardiology', 'Neurology', 'Orthopedics', 
      'Pediatrics', 'Gynecology', 'Dermatology', 'Psychiatry',
      'ENT', 'Ophthalmology', 'Emergency Medicine', 'Anesthesia',
      'Radiology', 'Pathology', 'Surgery', 'Urology',
      'Oncology', 'Nephrology', 'Gastroenterology', 'Pulmonology',
      'Endocrinology', 'Rheumatology', 'Hematology', 'Infectious Disease',
      'Family Medicine', 'Internal Medicine', 'Critical Care'
    ]
  }],
  
  // Keep backwards compatibility
  specialization: {
    type: String,
    trim: true,
    enum: [
      'General Medicine', 'Cardiology', 'Neurology', 'Orthopedics', 
      'Pediatrics', 'Gynecology', 'Dermatology', 'Psychiatry',
      'ENT', 'Ophthalmology', 'Emergency Medicine', 'Anesthesia',
      'Radiology', 'Pathology', 'Surgery', 'Urology',
      'Oncology', 'Nephrology', 'Gastroenterology', 'Pulmonology',
      'Endocrinology', 'Rheumatology', 'Hematology', 'Infectious Disease',
      'Family Medicine', 'Internal Medicine', 'Critical Care'
    ]
  },
  
  email: {
    type: String,
    required: true,
    lowercase: true,
    match: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  },
  
  contactNumber: {
    type: String,
    required: true,
    match: /^[6-9]\d{9}$/
  },
  
  qualification: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 30
  },
  
  // Keep old structure for backwards compatibility
  qualificationDetails: {
    degree: {
      type: String,
      trim: true
    },
    university: {
      type: String,
      trim: true
    },
    yearOfPassing: {
      type: Number,
      min: 1960,
      max: new Date().getFullYear()
    },
    additionalCertifications: [{
      type: String,
      trim: true
    }]
  },
  
  experienceYears: {
    type: Number,
    min: 0,
    max: 50,
    default: 0
  },
  
  availableTimings: {
    type: String,
    enum: ['9:00 AM - 12:00 PM', '12:00 PM - 3:00 PM', '3:00 PM - 6:00 PM', '6:00 PM - 9:00 PM', '24/7 Emergency', 'Flexible'],
    default: '9:00 AM - 12:00 PM'
  },
  
  consultationFee: {
    type: Number,
    min: 0,
    max: 99999,
    default: 0
  },
  
  // Keep old experience structure for backwards compatibility
  experienceDetails: {
    totalYears: {
      type: Number,
      min: 0,
      default: 0
    },
    previousHospitals: [{
      hospitalName: String,
      duration: String,
      position: String
    }]
  },
  
  registrationNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  
  department: {
    type: String,
    required: true,
    trim: true
  },
  
  designation: {
    type: String,
    enum: ['Junior Doctor', 'Senior Doctor', 'Consultant', 'Head of Department', 'Chief Medical Officer'],
    default: 'Junior Doctor'
  },
  
  dutySchedule: {
    shift: {
      type: String,
      enum: ['Morning', 'Evening', 'Night', 'Rotational'],
      default: 'Morning'
    },
    workingDays: [{
      type: String,
      enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    }],
    consultationHours: {
      start: String,
      end: String
    }
  },
  
  permissions: {
    canPrescribeMedicine: {
      type: Boolean,
      default: true
    },
    canOrderTests: {
      type: Boolean,
      default: true
    },
    canAdmitPatients: {
      type: Boolean,
      default: true
    },
    canDischargePatients: {
      type: Boolean,
      default: false
    },
    canAccessEmergency: {
      type: Boolean,
      default: true
    }
  },
  
  lastLogin: {
    type: Date
  },
  
  loginAttempts: {
    type: Number,
    default: 0
  },
  
  failedLoginAttempts: {
    type: Number,
    default: 0
  },
  
  accountLocked: {
    type: Boolean,
    default: false
  },
  
  lockUntil: {
    type: Date
  },
  
  lastLoginAt: {
    type: Date
  },
  
  isActive: {
    type: Boolean,
    default: true
  },
  
  isOnDuty: {
    type: Boolean,
    default: false
  },
  
  isLocked: {
    type: Boolean,
    default: false
  },
  
  createdAt: {
    type: Date,
    default: Date.now
  },
  
  updatedAt: {
    type: Date,
    default: Date.now
  },
  
  createdBy: {
    type: String,
    ref: 'HospitalAdmin'
  }
});

// Pre-save middleware
hospitalDoctorSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Indexes
hospitalDoctorSchema.index({ doctorId: 1 });
hospitalDoctorSchema.index({ hospitalId: 1 });
hospitalDoctorSchema.index({ username: 1 });
hospitalDoctorSchema.index({ email: 1 });
hospitalDoctorSchema.index({ specialization: 1 });
hospitalDoctorSchema.index({ department: 1 });
hospitalDoctorSchema.index({ isActive: 1 });
hospitalDoctorSchema.index({ registrationNumber: 1 });

// Static methods
hospitalDoctorSchema.statics.findByHospital = function(hospitalId) {
  return this.find({ hospitalId, isActive: true });
};

hospitalDoctorSchema.statics.findBySpecialization = function(specialization, hospitalId) {
  return this.find({ specialization, hospitalId, isActive: true });
};

hospitalDoctorSchema.statics.findByUsername = function(username) {
  return this.findOne({ username, isActive: true });
};

hospitalDoctorSchema.statics.findOnDutyDoctors = function(hospitalId) {
  return this.find({ hospitalId, isOnDuty: true, isActive: true });
};

// Instance methods
hospitalDoctorSchema.methods.updateLastLogin = function() {
  this.lastLogin = new Date();
  this.loginAttempts = 0;
  return this.save();
};

hospitalDoctorSchema.methods.incrementLoginAttempts = function() {
  this.loginAttempts += 1;
  if (this.loginAttempts >= 5) {
    this.isLocked = true;
  }
  return this.save();
};

hospitalDoctorSchema.methods.setDutyStatus = function(status) {
  this.isOnDuty = status;
  return this.save();
};

module.exports = mongoose.model('HospitalDoctor', hospitalDoctorSchema);