const mongoose = require('mongoose');

const hospitalAssistantSchema = new mongoose.Schema({
  assistantId: {
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
  
  assistantName: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
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
    degree: {
      type: String,
      required: true,
      trim: true
    },
    university: {
      type: String,
      trim: true
    },
    yearOfPassing: {
      type: Number,
      min: 1980,
      max: new Date().getFullYear()
    },
    additionalCertifications: [{
      type: String,
      trim: true
    }]
  },
  
  assignedDepartment: {
    type: String,
    required: true,
    enum: [
      'General Medicine', 'Cardiology', 'Neurology', 'Orthopedics', 
      'Pediatrics', 'Gynecology', 'Dermatology', 'Psychiatry',
      'ENT', 'Ophthalmology', 'Emergency Medicine', 'Anesthesia',
      'Radiology', 'Pathology', 'Surgery', 'Urology',
      'Oncology', 'Nephrology', 'Gastroenterology', 'Pulmonology',
      'Endocrinology', 'Rheumatology', 'Hematology', 'Infectious Disease',
      'Administration', 'Pharmacy', 'Laboratory', 'Nursing',
      'Reception', 'OPD', 'IPD', 'ICU', 'OT'
    ]
  },
  
  assignedDoctor: {
    doctorId: {
      type: String,
      ref: 'HospitalDoctor'
    },
    doctorName: {
      type: String
    }
  },
  
  designation: {
    type: String,
    enum: [
      'Nursing Assistant', 'Medical Assistant', 'Administrative Assistant',
      'Lab Technician', 'Pharmacy Assistant', 'Reception Assistant',
      'OT Assistant', 'Ward Assistant', 'Emergency Assistant'
    ],
    default: 'Medical Assistant'
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
    workingHours: {
      start: String,
      end: String
    }
  },
  
  responsibilities: [{
    type: String,
    trim: true
  }],
  
  permissions: {
    canUpdatePatientInfo: {
      type: Boolean,
      default: true
    },
    canScheduleAppointments: {
      type: Boolean,
      default: true
    },
    canAccessPatientRecords: {
      type: Boolean,
      default: true
    },
    canManageInventory: {
      type: Boolean,
      default: false
    },
    canProcessPayments: {
      type: Boolean,
      default: false
    }
  },
  
  experience: {
    totalYears: {
      type: Number,
      min: 0,
      default: 0
    },
    previousWorkplace: [{
      organizationName: String,
      duration: String,
      position: String
    }]
  },
  
  lastLogin: {
    type: Date
  },
  
  loginAttempts: {
    type: Number,
    default: 0
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
hospitalAssistantSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

// Indexes
hospitalAssistantSchema.index({ assistantId: 1 });
hospitalAssistantSchema.index({ hospitalId: 1 });
hospitalAssistantSchema.index({ username: 1 });
hospitalAssistantSchema.index({ email: 1 });
hospitalAssistantSchema.index({ assignedDepartment: 1 });
hospitalAssistantSchema.index({ 'assignedDoctor.doctorId': 1 });
hospitalAssistantSchema.index({ isActive: 1 });

// Static methods
hospitalAssistantSchema.statics.findByHospital = function(hospitalId) {
  return this.find({ hospitalId, isActive: true });
};

hospitalAssistantSchema.statics.findByDepartment = function(department, hospitalId) {
  return this.find({ assignedDepartment: department, hospitalId, isActive: true });
};

hospitalAssistantSchema.statics.findByDoctor = function(doctorId, hospitalId) {
  return this.find({ 'assignedDoctor.doctorId': doctorId, hospitalId, isActive: true });
};

hospitalAssistantSchema.statics.findByUsername = function(username) {
  return this.findOne({ username, isActive: true });
};

hospitalAssistantSchema.statics.findOnDutyAssistants = function(hospitalId) {
  return this.find({ hospitalId, isOnDuty: true, isActive: true });
};

// Instance methods
hospitalAssistantSchema.methods.updateLastLogin = function() {
  this.lastLogin = new Date();
  this.loginAttempts = 0;
  return this.save();
};

hospitalAssistantSchema.methods.incrementLoginAttempts = function() {
  this.loginAttempts += 1;
  if (this.loginAttempts >= 5) {
    this.isLocked = true;
  }
  return this.save();
};

hospitalAssistantSchema.methods.setDutyStatus = function(status) {
  this.isOnDuty = status;
  return this.save();
};

hospitalAssistantSchema.methods.assignToDoctor = function(doctorId, doctorName) {
  this.assignedDoctor = { doctorId, doctorName };
  return this.save();
};

module.exports = mongoose.model('HospitalAssistant', hospitalAssistantSchema);