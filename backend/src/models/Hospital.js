const mongoose = require('mongoose');

const hospitalSchema = new mongoose.Schema({
  hospitalId: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  name: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 200
  },
  location: {
    address: {
      type: String,
      required: true,
      trim: true
    },
    city: {
      type: String,
      required: true,
      trim: true
    },
    state: {
      type: String,
      required: true,
      enum: [
        'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
        'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
        'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
        'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
        'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
        'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
      ]
    },
    district: {
      type: String,
      required: true,
      trim: true
    },
    pincode: {
      type: String,
      required: true,
      match: [/^\d{6}$/, 'Please enter a valid 6-digit pincode']
    },
    coordinates: {
      latitude: { type: Number, min: -90, max: 90 },
      longitude: { type: Number, min: -180, max: 180 }
    }
  },
  contact: {
    phone: {
      type: String,
      required: true,
      match: [/^\+?[\d\s-()]{10,}$/, 'Please enter a valid phone number']
    },
    email: {
      type: String,
      lowercase: true,
      match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
    },
    website: {
      type: String,
      match: [/^https?:\/\/.+/, 'Please enter a valid website URL']
    },
    emergencyNumber: {
      type: String,
      required: true
    }
  },
  type: {
    type: String,
    required: true,
    enum: [
      'Government',
      'Private',
      'Semi-Government',
      'Specialty',
      'Teaching Hospital',
      'Research Institute',
      'Primary Health Center',
      'Community Health Center',
      'District Hospital',
      'Medical College Hospital'
    ]
  },
  classification: {
    type: String,
    enum: ['Primary', 'Secondary', 'Tertiary', 'Super Specialty'],
    default: 'Secondary'
  },
  capacity: {
    totalBeds: {
      type: Number,
      required: true,
      min: 1
    },
    icuBeds: {
      type: Number,
      default: 0,
      min: 0
    },
    emergencyBeds: {
      type: Number,
      default: 0,
      min: 0
    },
    operationTheaters: {
      type: Number,
      default: 0,
      min: 0
    },
    totalStaff: {
      type: Number,
      required: true,
      min: 1
    }
  },
  staff: {
    doctors: {
      type: Number,
      default: 0,
      min: 0
    },
    nurses: {
      type: Number,
      default: 0,
      min: 0
    },
    technicians: {
      type: Number,
      default: 0,
      min: 0
    },
    administrativeStaff: {
      type: Number,
      default: 0,
      min: 0
    },
    supportStaff: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  departments: [{
    name: {
      type: String,
      required: true,
      enum: [
        'General Medicine', 'General Surgery', 'Pediatrics', 'Gynecology',
        'Orthopedics', 'Cardiology', 'Neurology', 'Oncology', 'Dermatology',
        'Psychiatry', 'Radiology', 'Pathology', 'Emergency', 'ICU',
        'Anesthesiology', 'ENT', 'Ophthalmology', 'Dental', 'Physiotherapy'
      ]
    },
    headOfDepartment: String,
    staffCount: Number,
    bedCount: Number,
    isActive: { type: Boolean, default: true }
  }],
  services: [{
    type: String,
    enum: [
      '24x7 Emergency', 'Ambulance', 'Blood Bank', 'Laboratory',
      'Pharmacy', 'Radiology', 'CT Scan', 'MRI', 'Ultrasound',
      'Dialysis', 'Chemotherapy', 'Surgery', 'Vaccination',
      'Health Checkup', 'Maternity', 'Pediatric Care'
    ]
  }],
  licenses: {
    registrationNumber: {
      type: String,
      required: true,
      unique: true
    },
    issuingAuthority: {
      type: String,
      required: true
    },
    issueDate: {
      type: Date,
      required: true
    },
    expiryDate: {
      type: Date,
      required: true
    },
    renewalRequired: {
      type: Boolean,
      default: false
    }
  },
  accreditation: {
    nabh: {
      certified: { type: Boolean, default: false },
      grade: { type: String, enum: ['Entry Level', 'Full', 'Not Applicable'] },
      validUntil: Date
    },
    nabl: {
      certified: { type: Boolean, default: false },
      validUntil: Date
    },
    iso: {
      certified: { type: Boolean, default: false },
      version: String,
      validUntil: Date
    }
  },
  statistics: {
    totalPatients: {
      type: Number,
      default: 0,
      min: 0
    },
    monthlyPatients: {
      type: Number,
      default: 0,
      min: 0
    },
    occupancyRate: {
      type: Number,
      default: 0,
      min: 0,
      max: 100
    },
    averageStayDuration: {
      type: Number,
      default: 0,
      min: 0
    },
    successRate: {
      type: Number,
      default: 0,
      min: 0,
      max: 100
    }
  },
  rating: {
    overall: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    cleanliness: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    staffBehavior: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    facilities: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    totalReviews: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  managedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'RegionalOfficer',
    required: false // Change to false as it will be assigned upon approval
  },
  supervisedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'WhoAdmin',
    default: null
  },
  approval: {
    status: {
      type: String,
      enum: ['Pending', 'Approved', 'Rejected', 'Under Review'],
      default: 'Pending'
    },
    submittedAt: {
      type: Date,
      default: Date.now
    },
    reviewedAt: {
      type: Date
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'RegionalHealthOfficer'
    },
    reviewComments: {
      type: String,
      maxlength: 1000
    },
    documents: [{
      name: String,
      url: String,
      uploadedAt: { type: Date, default: Date.now }
    }]
  },
  region: {
    state: {
      type: String,
      required: true,
      enum: [
        'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
        'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
        'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
        'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
        'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
        'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
      ]
    },
    district: {
      type: String,
      required: true
    }
  },
  // Zone assignment for dense districts with multiple RHOs
  zoneAssignment: {
    area: {
      type: String,
      trim: true
      // e.g., "Kothamangalam", "Thrikkakara", "Paravur", "Aluva" 
      // This maps to zone.areas.areaName for RHO assignment
    },
    zoneId: {
      type: String,
      ref: 'Zone'
      // Reference to the zone this hospital belongs to
    },
    zoneName: {
      type: String,
      trim: true
    },
    assignedRHO: {
      type: String,
      ref: 'RegionalHealthOfficer'
      // Auto-populated based on zone assignment
    },
    assignmentMethod: {
      type: String,
      enum: ['automatic', 'manual', 'pincode-based'],
      default: 'automatic'
    },
    lastUpdated: {
      type: Date,
      default: Date.now
    }
  },
  status: {
    type: String,
    enum: ['Active', 'Inactive', 'Under Review', 'Suspended', 'Closed'],
    default: 'Under Review' // Changed default to Under Review for new hospitals
  },
  operationalStatus: {
    type: String,
    enum: ['Fully Operational', 'Partially Operational', 'Emergency Only', 'Maintenance', 'Closed'],
    default: 'Fully Operational'
  },
  establishedDate: {
    type: Date,
    required: true
  },
  lastInspection: {
    date: Date,
    inspectedBy: String,
    report: String,
    grade: {
      type: String,
      enum: ['A', 'B', 'C', 'D', 'F']
    }
  },
  emergencyPreparedness: {
    hasAmbulance: { type: Boolean, default: false },
    hasFireSafety: { type: Boolean, default: false },
    hasBackupPower: { type: Boolean, default: false },
    hasOxygenSupply: { type: Boolean, default: false },
    emergencyContactsUpdated: { type: Boolean, default: false }
  },
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
}, {
  timestamps: true,
  toJSON: {
    transform: function(doc, ret) {
      delete ret.__v;
      return ret;
    }
  }
});

// Indexes
hospitalSchema.index({ hospitalId: 1 });
hospitalSchema.index({ name: 1 });
hospitalSchema.index({ 'location.state': 1 });
hospitalSchema.index({ 'location.district': 1 });
hospitalSchema.index({ type: 1 });
hospitalSchema.index({ managedBy: 1 });
hospitalSchema.index({ status: 1 });
hospitalSchema.index({ isActive: 1 });
hospitalSchema.index({ 'licenses.registrationNumber': 1 });

// Virtual for full location
hospitalSchema.virtual('fullLocation').get(function() {
  return `${this.location.address}, ${this.location.city}, ${this.location.state} - ${this.location.pincode}`;
});

// Static methods
hospitalSchema.statics.findByState = function(state) {
  return this.find({ 'location.state': state, isActive: true });
};

hospitalSchema.statics.findByManager = function(managerId) {
  return this.find({ managedBy: managerId, isActive: true });
};

hospitalSchema.statics.findActiveHospitals = function() {
  return this.find({ isActive: true, status: 'Active' });
};

hospitalSchema.statics.findByType = function(type) {
  return this.find({ type, isActive: true });
};

hospitalSchema.statics.findPendingApprovals = function(rhoId) {
  return this.find({ 
    'approval.status': 'Pending', 
    isActive: true 
  }).populate('approval.reviewedBy', 'name email');
};

hospitalSchema.statics.findByRegion = function(state, district) {
  return this.find({ 
    'region.state': state,
    'region.district': district,
    isActive: true 
  });
};

hospitalSchema.statics.findPendingInRegion = function(state, district) {
  return this.find({
    'region.state': state,
    'region.district': district,
    'approval.status': 'Pending',
    isActive: true
  });
};

// Method to calculate bed occupancy
hospitalSchema.methods.calculateOccupancy = function(currentPatients) {
  if (this.capacity.totalBeds === 0) return 0;
  return Math.round((currentPatients / this.capacity.totalBeds) * 100);
};

// Method to update statistics
hospitalSchema.methods.updateStatistics = function(stats) {
  Object.assign(this.statistics, stats);
  return this.save();
};

// Method to approve hospital
hospitalSchema.methods.approve = function(rhoId, comments) {
  this.approval.status = 'Approved';
  this.approval.reviewedAt = new Date();
  this.approval.reviewedBy = rhoId;
  this.approval.reviewComments = comments || 'Hospital approved';
  this.status = 'Active';
  return this.save();
};

// Method to reject hospital
hospitalSchema.methods.reject = function(rhoId, comments) {
  this.approval.status = 'Rejected';
  this.approval.reviewedAt = new Date();
  this.approval.reviewedBy = rhoId;
  this.approval.reviewComments = comments || 'Hospital registration rejected';
  this.status = 'Inactive';
  return this.save();
};

module.exports = mongoose.model('Hospital', hospitalSchema);