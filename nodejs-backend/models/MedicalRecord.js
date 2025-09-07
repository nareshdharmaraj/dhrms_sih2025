const mongoose = require('mongoose');

const medicalRecordSchema = new mongoose.Schema({
  recordId: {
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
  appointment: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Appointment'
  },
  visitInfo: {
    visitType: {
      type: String,
      enum: ['consultation', 'follow-up', 'emergency', 'procedure', 'surgery', 'therapy', 'diagnostic'],
      required: true
    },
    visitDate: {
      type: Date,
      required: true,
      default: Date.now
    },
    duration: {
      type: Number, // in minutes
      default: 30
    },
    department: {
      type: String,
      required: true
    },
    specialty: {
      type: String,
      required: true
    }
  },
  chiefComplaint: {
    symptoms: [{
      symptom: {
        type: String,
        required: true
      },
      duration: String,
      severity: {
        type: String,
        enum: ['mild', 'moderate', 'severe'],
        default: 'moderate'
      },
      description: String
    }],
    primaryComplaint: {
      type: String,
      required: true,
      maxlength: 1000
    },
    historyOfPresentIllness: {
      type: String,
      maxlength: 2000
    }
  },
  examination: {
    vitalSigns: {
      temperature: {
        value: Number,
        unit: {
          type: String,
          enum: ['celsius', 'fahrenheit'],
          default: 'celsius'
        }
      },
      bloodPressure: {
        systolic: Number,
        diastolic: Number,
        unit: {
          type: String,
          default: 'mmHg'
        }
      },
      heartRate: {
        value: Number,
        unit: {
          type: String,
          default: 'bpm'
        }
      },
      respiratoryRate: {
        value: Number,
        unit: {
          type: String,
          default: 'breaths/min'
        }
      },
      oxygenSaturation: {
        value: Number,
        unit: {
          type: String,
          default: '%'
        }
      },
      height: {
        value: Number,
        unit: {
          type: String,
          enum: ['cm', 'inches'],
          default: 'cm'
        }
      },
      weight: {
        value: Number,
        unit: {
          type: String,
          enum: ['kg', 'lbs'],
          default: 'kg'
        }
      },
      bmi: {
        value: Number,
        category: {
          type: String,
          enum: ['underweight', 'normal', 'overweight', 'obese']
        }
      }
    },
    physicalExamination: {
      general: String,
      cardiovascular: String,
      respiratory: String,
      gastrointestinal: String,
      neurological: String,
      musculoskeletal: String,
      dermatological: String,
      psychiatric: String
    },
    systemicExamination: [{
      system: String,
      findings: String,
      abnormal: {
        type: Boolean,
        default: false
      }
    }]
  },
  diagnosis: {
    primary: {
      condition: {
        type: String,
        required: true
      },
      icdCode: String,
      severity: {
        type: String,
        enum: ['mild', 'moderate', 'severe'],
        default: 'moderate'
      },
      certainty: {
        type: String,
        enum: ['confirmed', 'suspected', 'provisional'],
        default: 'confirmed'
      }
    },
    secondary: [{
      condition: String,
      icdCode: String,
      severity: {
        type: String,
        enum: ['mild', 'moderate', 'severe']
      }
    }],
    differentialDiagnosis: [{
      condition: String,
      probability: {
        type: String,
        enum: ['high', 'medium', 'low']
      },
      notes: String
    }]
  },
  investigations: {
    laboratoryTests: [{
      testName: {
        type: String,
        required: true
      },
      testCode: String,
      results: [{
        parameter: String,
        value: String,
        unit: String,
        referenceRange: String,
        status: {
          type: String,
          enum: ['normal', 'abnormal', 'critical']
        }
      }],
      reportDate: Date,
      laboratoryInfo: {
        name: String,
        location: String
      },
      reportUrl: String,
      notes: String
    }],
    imagingStudies: [{
      studyType: {
        type: String,
        required: true
      },
      bodyPart: String,
      findings: String,
      impression: String,
      reportDate: Date,
      radiologist: String,
      imageUrls: [String],
      reportUrl: String
    }],
    procedures: [{
      procedureName: {
        type: String,
        required: true
      },
      procedureCode: String,
      date: Date,
      performedBy: String,
      indication: String,
      findings: String,
      complications: String,
      outcome: String
    }]
  },
  treatment: {
    medications: [{
      medicationName: {
        type: String,
        required: true
      },
      dosage: String,
      frequency: String,
      duration: String,
      route: {
        type: String,
        enum: ['oral', 'intravenous', 'intramuscular', 'subcutaneous', 'topical', 'inhalation']
      },
      instructions: String,
      prescriptionRef: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Prescription'
      }
    }],
    procedures: [{
      name: String,
      date: Date,
      outcome: String,
      complications: String,
      notes: String
    }],
    therapies: [{
      type: String,
      sessions: Number,
      duration: String,
      therapist: String,
      notes: String
    }]
  },
  planAndAdvice: {
    treatmentPlan: {
      type: String,
      maxlength: 2000
    },
    lifestyle: {
      diet: String,
      exercise: String,
      restrictions: String
    },
    followUp: {
      required: {
        type: Boolean,
        default: false
      },
      date: Date,
      interval: String,
      instructions: String
    },
    referrals: [{
      specialty: String,
      doctor: String,
      reason: String,
      urgency: {
        type: String,
        enum: ['routine', 'urgent', 'emergency']
      }
    }],
    precautions: [String],
    emergencyInstructions: String
  },
  attachments: [{
    fileName: String,
    fileType: String,
    fileSize: Number,
    fileUrl: String,
    uploadDate: {
      type: Date,
      default: Date.now
    },
    description: String
  }],
  recordStatus: {
    status: {
      type: String,
      enum: ['draft', 'completed', 'verified', 'amended'],
      default: 'draft'
    },
    verifiedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Doctor'
    },
    verificationDate: Date,
    amendments: [{
      amendedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Doctor'
      },
      amendmentDate: {
        type: Date,
        default: Date.now
      },
      reason: String,
      changes: String
    }]
  },
  confidentiality: {
    level: {
      type: String,
      enum: ['normal', 'restricted', 'highly-confidential'],
      default: 'normal'
    },
    accessLog: [{
      accessedBy: {
        userId: mongoose.Schema.Types.ObjectId,
        userType: String,
        name: String
      },
      accessTime: {
        type: Date,
        default: Date.now
      },
      action: {
        type: String,
        enum: ['view', 'edit', 'download', 'share']
      },
      ipAddress: String
    }]
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for BMI calculation
medicalRecordSchema.virtual('calculatedBMI').get(function() {
  const height = this.examination?.vitalSigns?.height?.value;
  const weight = this.examination?.vitalSigns?.weight?.value;
  
  if (!height || !weight) return null;
  
  // Convert height to meters if in cm
  const heightInMeters = this.examination.vitalSigns.height.unit === 'cm' ? height / 100 : height * 0.0254;
  // Convert weight to kg if in lbs
  const weightInKg = this.examination.vitalSigns.weight.unit === 'kg' ? weight : weight * 0.453592;
  
  const bmi = weightInKg / (heightInMeters * heightInMeters);
  return Math.round(bmi * 10) / 10;
});

// Virtual for age at time of visit
medicalRecordSchema.virtual('patientAgeAtVisit').get(function() {
  if (!this.populated('patient') || !this.patient.personalInfo?.dateOfBirth) return null;
  
  const visitDate = this.visitInfo.visitDate;
  const birthDate = new Date(this.patient.personalInfo.dateOfBirth);
  const ageInMs = visitDate - birthDate;
  const ageInYears = Math.floor(ageInMs / (1000 * 60 * 60 * 24 * 365.25));
  
  return ageInYears;
});

// Indexes for performance
medicalRecordSchema.index({ recordId: 1 });
medicalRecordSchema.index({ patient: 1, 'visitInfo.visitDate': -1 });
medicalRecordSchema.index({ doctor: 1, 'visitInfo.visitDate': -1 });
medicalRecordSchema.index({ hospital: 1, 'visitInfo.visitDate': -1 });
medicalRecordSchema.index({ 'diagnosis.primary.condition': 1 });
medicalRecordSchema.index({ 'visitInfo.specialty': 1 });
medicalRecordSchema.index({ 'recordStatus.status': 1 });

// Pre-save middleware to generate recordId
medicalRecordSchema.pre('save', async function(next) {
  if (!this.recordId) {
    const count = await mongoose.model('MedicalRecord').countDocuments();
    this.recordId = `MR${String(count + 1).padStart(8, '0')}`;
  }
  next();
});

// Pre-save middleware to calculate BMI
medicalRecordSchema.pre('save', function(next) {
  if (this.examination?.vitalSigns?.height?.value && this.examination?.vitalSigns?.weight?.value) {
    const calculatedBMI = this.calculatedBMI;
    
    if (calculatedBMI) {
      this.examination.vitalSigns.bmi = {
        value: calculatedBMI,
        category: this.getBMICategory(calculatedBMI)
      };
    }
  }
  next();
});

// Method to get BMI category
medicalRecordSchema.methods.getBMICategory = function(bmi) {
  if (bmi < 18.5) return 'underweight';
  if (bmi < 25) return 'normal';
  if (bmi < 30) return 'overweight';
  return 'obese';
};

// Method to add access log entry
medicalRecordSchema.methods.logAccess = function(userId, userType, userName, action, ipAddress) {
  this.confidentiality.accessLog.push({
    accessedBy: {
      userId,
      userType,
      name: userName
    },
    action,
    ipAddress,
    accessTime: new Date()
  });
  return this.save();
};

// Static method to find records by diagnosis
medicalRecordSchema.statics.findByDiagnosis = function(condition, options = {}) {
  const query = {
    $or: [
      { 'diagnosis.primary.condition': new RegExp(condition, 'i') },
      { 'diagnosis.secondary.condition': new RegExp(condition, 'i') }
    ]
  };
  
  return this.find(query, null, options);
};

// Static method to get patient's medical history
medicalRecordSchema.statics.getPatientHistory = function(patientId, options = {}) {
  const limit = options.limit || 10;
  const skip = options.skip || 0;
  
  return this.find({ patient: patientId })
    .sort({ 'visitInfo.visitDate': -1 })
    .limit(limit)
    .skip(skip)
    .populate('doctor', 'personalInfo.firstName personalInfo.lastName specialization')
    .populate('hospital', 'name contactInfo');
};

module.exports = mongoose.model('MedicalRecord', medicalRecordSchema);
