const mongoose = require('mongoose');

const healthStatisticsSchema = new mongoose.Schema({
  region: {
    type: String,
    required: true
  },
  district: {
    type: String,
    required: true
  },
  reportingPeriod: {
    type: String,
    required: true // e.g., "2024-Q1", "2024-January"
  },
  statistics: {
    totalPopulation: Number,
    migrantWorkerPopulation: Number,
    totalPatients: Number,
    newRegistrations: Number,
    activeCases: Number,
    resolvedCases: Number,
    emergencyCases: Number,
    
    // Disease statistics
    commonDiseases: [{
      diseaseName: String,
      caseCount: Number,
      severity: String
    }],
    
    // Vaccination statistics
    vaccinationData: [{
      vaccineName: String,
      administeredCount: Number,
      targetPopulation: Number
    }],
    
    // Hospital utilization
    hospitalUtilization: [{
      hospitalName: String,
      bedOccupancy: Number,
      totalBeds: Number,
      averageStayDuration: Number
    }],
    
    // Resource allocation
    resourceAllocation: {
      medicalStaff: Number,
      availableDoctors: Number,
      availableNurses: Number,
      medicalSupplies: String,
      budgetUtilization: Number
    }
  },
  trends: [{
    metric: String,
    currentValue: Number,
    previousValue: Number,
    changePercentage: Number,
    trend: String // 'increasing', 'decreasing', 'stable'
  }],
  alerts: [{
    alertType: String,
    severity: String,
    description: String,
    actionRequired: Boolean
  }],
  generatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'RegionalOfficer',
    required: true
  },
  generatedAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('HealthStatistics', healthStatisticsSchema);
