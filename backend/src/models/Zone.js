const mongoose = require('mongoose');

const zoneSchema = new mongoose.Schema({
  zoneId: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  zoneName: {
    type: String,
    required: true,
    trim: true
  },
  state: {
    type: String,
    required: true,
    trim: true
  },
  district: {
    type: String,
    required: true,
    trim: true
  },
  areas: [{
    areaName: {
      type: String,
      required: true,
      trim: true
    },
    areaCode: {
      type: String,
      trim: true
    },
    population: {
      type: Number,
      min: 0,
      default: 0
    },
    areaKm2: {
      type: Number,
      min: 0,
      default: 0
    },
    isDenselyPopulated: {
      type: Boolean,
      default: false
    }
  }],
  assignedRHO: {
    rhoId: {
      type: String,
      ref: 'RegionalHealthOfficer'
    },
    rhoName: {
      type: String,
      trim: true
    },
    assignedDate: {
      type: Date,
      default: Date.now
    },
    assignedBy: {
      type: String, // SHO ID who assigned this RHO
      required: function() {
        // Only require assignedBy when rhoId is present (RHO is actually assigned)
        return !!(this.assignedRHO && this.assignedRHO.rhoId && this.assignedRHO.rhoId.trim() !== '');
      }
    }
  },
  zoneType: {
    type: String,
    enum: ['urban', 'rural', 'semi-urban', 'metropolitan'],
    default: 'urban'
  },
  priority: {
    type: String,
    enum: ['high', 'medium', 'low'],
    default: 'medium'
  },
  coverage: {
    totalAreas: {
      type: Number,
      default: 0
    },
    coveredAreas: {
      type: Number,
      default: 0
    },
    coveragePercentage: {
      type: Number,
      default: 0,
      min: 0,
      max: 100
    }
  },
  createdBy: {
    shoId: {
      type: String,
      required: true,
      ref: 'StateHealthOfficer'
    },
    shoName: {
      type: String,
      required: true,
      trim: true
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  metadata: {
    description: {
      type: String,
      trim: true,
      maxlength: 500
    },
    specialRequirements: [{
      type: String,
      trim: true
    }],
    contactInfo: {
      phone: {
        type: String,
        trim: true
      },
      email: {
        type: String,
        trim: true,
        lowercase: true
      }
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better query performance
zoneSchema.index({ state: 1, district: 1 });
zoneSchema.index({ 'assignedRHO.rhoId': 1 });
zoneSchema.index({ 'createdBy.shoId': 1 });
zoneSchema.index({ zoneId: 1 }, { unique: true });
zoneSchema.index({ isActive: 1 });

// Virtual for calculating coverage percentage
zoneSchema.virtual('calculatedCoverage').get(function() {
  if (this.coverage.totalAreas === 0) return 0;
  return Math.round((this.coverage.coveredAreas / this.coverage.totalAreas) * 100);
});

// Pre-save middleware to update coverage
zoneSchema.pre('save', function(next) {
  if (this.areas) {
    this.coverage.totalAreas = this.areas.length;
    // Calculate covered areas (areas with assigned RHO)
    if (this.assignedRHO && this.assignedRHO.rhoId) {
      this.coverage.coveredAreas = this.areas.length;
      this.coverage.coveragePercentage = 100;
    } else {
      this.coverage.coveredAreas = 0;
      this.coverage.coveragePercentage = 0;
    }
  }
  next();
});

// Static method to find zones by district
zoneSchema.statics.findByDistrict = function(state, district) {
  return this.find({ 
    state: state, 
    district: district, 
    isActive: true 
  }).sort({ zoneName: 1 });
};

// Static method to find zones by RHO
zoneSchema.statics.findByRHO = function(rhoId) {
  return this.find({ 
    'assignedRHO.rhoId': rhoId, 
    isActive: true 
  }).sort({ zoneName: 1 });
};

// Static method to find unassigned zones
zoneSchema.statics.findUnassigned = function(state, district) {
  return this.find({ 
    state: state,
    district: district,
    $or: [
      { 'assignedRHO.rhoId': { $exists: false } },
      { 'assignedRHO.rhoId': null },
      { 'assignedRHO.rhoId': '' }
    ],
    isActive: true 
  }).sort({ priority: -1, zoneName: 1 });
};

// Static method to get zone statistics for a district
zoneSchema.statics.getDistrictStats = function(state, district) {
  return this.aggregate([
    { 
      $match: { 
        state: state, 
        district: district, 
        isActive: true 
      } 
    },
    {
      $group: {
        _id: null,
        totalZones: { $sum: 1 },
        assignedZones: {
          $sum: {
            $cond: [
              { $ne: ["$assignedRHO.rhoId", null] },
              1,
              0
            ]
          }
        },
        unassignedZones: {
          $sum: {
            $cond: [
              { $eq: ["$assignedRHO.rhoId", null] },
              1,
              0
            ]
          }
        },
        totalAreas: { $sum: "$coverage.totalAreas" },
        coveredAreas: { $sum: "$coverage.coveredAreas" }
      }
    },
    {
      $addFields: {
        assignmentPercentage: {
          $cond: [
            { $eq: ["$totalZones", 0] },
            0,
            { $multiply: [{ $divide: ["$assignedZones", "$totalZones"] }, 100] }
          ]
        },
        coveragePercentage: {
          $cond: [
            { $eq: ["$totalAreas", 0] },
            0,
            { $multiply: [{ $divide: ["$coveredAreas", "$totalAreas"] }, 100] }
          ]
        }
      }
    }
  ]);
};

// Instance method to assign RHO
zoneSchema.methods.assignRHO = function(rhoId, rhoName, assignedBy) {
  this.assignedRHO = {
    rhoId: rhoId,
    rhoName: rhoName,
    assignedDate: new Date(),
    assignedBy: assignedBy
  };
  return this.save();
};

// Instance method to unassign RHO
zoneSchema.methods.unassignRHO = function() {
  this.assignedRHO = {
    rhoId: null,
    rhoName: null,
    assignedDate: null,
    assignedBy: null
  };
  return this.save();
};

// Instance method to add area to zone
zoneSchema.methods.addArea = function(area) {
  this.areas.push(area);
  return this.save();
};

// Instance method to remove area from zone
zoneSchema.methods.removeArea = function(areaName) {
  this.areas = this.areas.filter(area => area.areaName !== areaName);
  return this.save();
};

const Zone = mongoose.model('Zone', zoneSchema);

module.exports = Zone;