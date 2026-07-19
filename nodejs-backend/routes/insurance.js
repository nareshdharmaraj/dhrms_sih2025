const express = require('express');
const { body, query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const Patient = require('../models/Patient');
const { authenticate, authenticatePatient, authenticateDoctor } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// Insurance Policy Schema
const InsurancePolicySchema = new mongoose.Schema({
  patient: {
    type: mongoose.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  policyNumber: {
    type: String,
    required: true,
    unique: true
  },
  insuranceProvider: {
    name: { type: String, required: true },
    code: String,
    contactInfo: {
      phone: String,
      email: String,
      website: String,
      address: {
        street: String,
        city: String,
        state: String,
        pincode: String
      }
    }
  },
  policyDetails: {
    policyType: {
      type: String,
      enum: ['individual', 'family', 'group', 'senior_citizen', 'critical_illness'],
      required: true
    },
    planName: String,
    sumInsured: {
      type: Number,
      required: true
    },
    premium: {
      annual: Number,
      monthly: Number,
      paymentFrequency: {
        type: String,
        enum: ['monthly', 'quarterly', 'half_yearly', 'annual'],
        default: 'annual'
      }
    },
    deductible: {
      type: Number,
      default: 0
    },
    coPayment: {
      percentage: Number,
      fixedAmount: Number
    }
  },
  coverage: {
    hospitalization: {
      covered: { type: Boolean, default: true },
      limit: Number,
      conditions: [String]
    },
    outpatientTreatment: {
      covered: { type: Boolean, default: false },
      limit: Number,
      conditions: [String]
    },
    emergencyServices: {
      covered: { type: Boolean, default: true },
      limit: Number,
      conditions: [String]
    },
    maternityBenefits: {
      covered: { type: Boolean, default: false },
      limit: Number,
      waitingPeriod: Number // in months
    },
    dentalCare: {
      covered: { type: Boolean, default: false },
      limit: Number
    },
    mentalHealth: {
      covered: { type: Boolean, default: false },
      limit: Number
    },
    preventiveCare: {
      covered: { type: Boolean, default: true },
      services: [String]
    },
    prescriptionDrugs: {
      covered: { type: Boolean, default: true },
      limit: Number,
      copayPercentage: Number
    }
  },
  beneficiaries: [{
    name: String,
    relationship: String,
    dateOfBirth: Date,
    aadharNumber: String,
    sumInsured: Number
  }],
  policyDates: {
    startDate: {
      type: Date,
      required: true
    },
    endDate: {
      type: Date,
      required: true
    },
    renewalDate: Date,
    lastRenewalDate: Date
  },
  status: {
    type: String,
    enum: ['active', 'expired', 'cancelled', 'suspended', 'pending_renewal'],
    default: 'active'
  },
  documents: [{
    type: {
      type: String,
      enum: ['policy_document', 'id_proof', 'medical_certificate', 'claim_form', 'other']
    },
    fileName: String,
    fileUrl: String,
    uploadDate: {
      type: Date,
      default: Date.now
    }
  }],
  claimsHistory: [{
    claimId: String,
    claimDate: Date,
    amount: Number,
    status: String,
    description: String
  }]
}, {
  timestamps: true
});

// Insurance Claim Schema
const InsuranceClaimSchema = new mongoose.Schema({
  patient: {
    type: mongoose.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  policy: {
    type: mongoose.Types.ObjectId,
    ref: 'InsurancePolicy',
    required: true
  },
  claimNumber: {
    type: String,
    required: true,
    unique: true
  },
  claimType: {
    type: String,
    enum: ['hospitalization', 'outpatient', 'emergency', 'maternity', 'dental', 'mental_health', 'preventive'],
    required: true
  },
  treatmentDetails: {
    hospital: {
      name: String,
      uhid: String,
      address: String
    },
    doctor: {
      name: String,
      specialization: String,
      registrationNumber: String
    },
    admissionDate: Date,
    dischargeDate: Date,
    diagnosis: [String],
    procedures: [String],
    treatmentSummary: String
  },
  financialDetails: {
    totalBillAmount: {
      type: Number,
      required: true
    },
    claimedAmount: {
      type: Number,
      required: true
    },
    approvedAmount: Number,
    settledAmount: Number,
    deductibleApplied: Number,
    coPaymentApplied: Number,
    rejectedAmount: Number,
    rejectionReason: String
  },
  documents: [{
    type: {
      type: String,
      enum: ['discharge_summary', 'bills', 'prescriptions', 'investigation_reports', 'claim_form', 'other'],
      required: true
    },
    fileName: String,
    fileUrl: String,
    uploadDate: {
      type: Date,
      default: Date.now
    },
    verified: {
      type: Boolean,
      default: false
    }
  }],
  status: {
    type: String,
    enum: ['draft', 'submitted', 'under_review', 'approved', 'partially_approved', 'rejected', 'settled'],
    default: 'draft'
  },
  timeline: [{
    status: String,
    date: Date,
    notes: String,
    updatedBy: {
      userId: String,
      userType: String,
      name: String
    }
  }],
  reviewDetails: {
    reviewer: {
      name: String,
      employeeId: String
    },
    reviewDate: Date,
    reviewNotes: String,
    approvalLevel: String
  },
  settlementDetails: {
    settlementDate: Date,
    paymentMethod: String,
    transactionId: String,
    bankDetails: {
      accountNumber: String,
      ifscCode: String,
      bankName: String
    }
  }
}, {
  timestamps: true
});

// Pre-authorization Schema
const PreAuthorizationSchema = new mongoose.Schema({
  patient: {
    type: mongoose.Types.ObjectId,
    ref: 'Patient',
    required: true
  },
  policy: {
    type: mongoose.Types.ObjectId,
    ref: 'InsurancePolicy',
    required: true
  },
  preAuthNumber: {
    type: String,
    required: true,
    unique: true
  },
  hospital: {
    name: String,
    uhid: String,
    registrationNumber: String,
    address: String
  },
  doctor: {
    name: String,
    specialization: String,
    registrationNumber: String
  },
  treatmentDetails: {
    proposedTreatment: String,
    diagnosis: [String],
    estimatedCost: Number,
    expectedAdmissionDate: Date,
    expectedLengthOfStay: Number,
    roomType: String,
    urgency: {
      type: String,
      enum: ['emergency', 'urgent', 'planned'],
      default: 'planned'
    }
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'partially_approved', 'rejected', 'expired'],
    default: 'pending'
  },
  approvalDetails: {
    approvedAmount: Number,
    validityPeriod: Number, // in days
    conditions: [String],
    approvedBy: String,
    approvalDate: Date
  },
  documents: [{
    type: String,
    fileName: String,
    fileUrl: String,
    uploadDate: {
      type: Date,
      default: Date.now
    }
  }]
}, {
  timestamps: true
});

// Create models
const InsurancePolicy = mongoose.model('InsurancePolicy', InsurancePolicySchema);
const InsuranceClaim = mongoose.model('InsuranceClaim', InsuranceClaimSchema);
const PreAuthorization = mongoose.model('PreAuthorization', PreAuthorizationSchema);

// @route   POST /api/v1/insurance/policies
// @desc    Add new insurance policy
// @access  Private (Patient)
router.post('/policies', authenticatePatient, [
  body('policyNumber').notEmpty().withMessage('Policy number is required'),
  body('insuranceProvider.name').notEmpty().withMessage('Insurance provider name is required'),
  body('policyDetails.policyType').isIn(['individual', 'family', 'group', 'senior_citizen', 'critical_illness']),
  body('policyDetails.sumInsured').isNumeric().withMessage('Sum insured must be a number'),
  body('policyDates.startDate').isISO8601().withMessage('Valid start date is required'),
  body('policyDates.endDate').isISO8601().withMessage('Valid end date is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const patientId = req.user.id;

    // Check if policy number already exists
    const existingPolicy = await InsurancePolicy.findOne({
      policyNumber: req.body.policyNumber
    });

    if (existingPolicy) {
      return res.status(400).json({
        status: 'error',
        message: 'Policy number already exists'
      });
    }

    const policyData = {
      ...req.body,
      patient: patientId
    };

    const policy = new InsurancePolicy(policyData);
    await policy.save();

    // Update patient record with insurance info
    await Patient.findByIdAndUpdate(patientId, {
      $push: {
        'insurance.policies': {
          policyId: policy._id,
          policyNumber: policy.policyNumber,
          provider: policy.insuranceProvider.name,
          status: policy.status
        }
      }
    });

    logger.info(`New insurance policy added for patient: ${patientId}`, {
      policyId: policy._id,
      policyNumber: policy.policyNumber
    });

    res.status(201).json({
      status: 'success',
      message: 'Insurance policy added successfully',
      data: { policy }
    });

  } catch (error) {
    logger.error('Add insurance policy error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error adding insurance policy'
    });
  }
});

// @route   GET /api/v1/insurance/policies
// @desc    Get patient's insurance policies
// @access  Private (Patient)
router.get('/policies', authenticatePatient, [
  query('status').optional().isIn(['active', 'expired', 'cancelled', 'suspended', 'pending_renewal'])
], async (req, res) => {
  try {
    const patientId = req.user.id;
    
    let query = { patient: patientId };
    if (req.query.status) {
      query.status = req.query.status;
    }

    const policies = await InsurancePolicy.find(query)
      .sort({ createdAt: -1 });

    // Calculate policy statistics
    const stats = {
      totalPolicies: policies.length,
      activePolicies: policies.filter(p => p.status === 'active').length,
      totalSumInsured: policies.reduce((sum, p) => sum + (p.policyDetails.sumInsured || 0), 0),
      expiringPolicies: policies.filter(p => {
        const daysToExpiry = Math.ceil((new Date(p.policyDates.endDate) - new Date()) / (1000 * 60 * 60 * 24));
        return daysToExpiry <= 30 && daysToExpiry > 0;
      }).length
    };

    res.json({
      status: 'success',
      data: {
        policies,
        statistics: stats
      }
    });

  } catch (error) {
    logger.error('Get insurance policies error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching insurance policies'
    });
  }
});

// @route   GET /api/v1/insurance/policies/:policyId
// @desc    Get specific insurance policy details
// @access  Private (Patient)
router.get('/policies/:policyId', authenticatePatient, async (req, res) => {
  try {
    const { policyId } = req.params;
    const patientId = req.user.id;

    const policy = await InsurancePolicy.findOne({
      _id: policyId,
      patient: patientId
    });

    if (!policy) {
      return res.status(404).json({
        status: 'error',
        message: 'Insurance policy not found'
      });
    }

    // Get related claims
    const claims = await InsuranceClaim.find({
      policy: policyId
    }).sort({ createdAt: -1 });

    // Calculate policy utilization
    const utilization = {
      totalClaimed: claims.reduce((sum, claim) => sum + (claim.financialDetails.claimedAmount || 0), 0),
      totalApproved: claims.reduce((sum, claim) => sum + (claim.financialDetails.approvedAmount || 0), 0),
      totalSettled: claims.reduce((sum, claim) => sum + (claim.financialDetails.settledAmount || 0), 0),
      remainingCoverage: policy.policyDetails.sumInsured - claims.reduce((sum, claim) => sum + (claim.financialDetails.settledAmount || 0), 0)
    };

    res.json({
      status: 'success',
      data: {
        policy,
        claims,
        utilization
      }
    });

  } catch (error) {
    logger.error('Get insurance policy details error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching policy details'
    });
  }
});

// @route   POST /api/v1/insurance/claims
// @desc    Submit new insurance claim
// @access  Private (Patient)
router.post('/claims', authenticatePatient, [
  body('policyId').notEmpty().withMessage('Policy ID is required'),
  body('claimType').isIn(['hospitalization', 'outpatient', 'emergency', 'maternity', 'dental', 'mental_health', 'preventive']),
  body('financialDetails.totalBillAmount').isNumeric().withMessage('Total bill amount must be a number'),
  body('financialDetails.claimedAmount').isNumeric().withMessage('Claimed amount must be a number')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const patientId = req.user.id;
    const { policyId } = req.body;

    // Verify policy belongs to patient
    const policy = await InsurancePolicy.findOne({
      _id: policyId,
      patient: patientId,
      status: 'active'
    });

    if (!policy) {
      return res.status(404).json({
        status: 'error',
        message: 'Active insurance policy not found'
      });
    }

    // Generate claim number
    const claimNumber = `CLM${Date.now()}${Math.random().toString(36).substr(2, 4).toUpperCase()}`;

    const claimData = {
      ...req.body,
      patient: patientId,
      policy: policyId,
      claimNumber,
      timeline: [{
        status: 'draft',
        date: new Date(),
        notes: 'Claim created',
        updatedBy: {
          userId: patientId,
          userType: 'patient',
          name: req.user.name
        }
      }]
    };

    const claim = new InsuranceClaim(claimData);
    await claim.save();

    // Update policy with claim reference
    await InsurancePolicy.findByIdAndUpdate(policyId, {
      $push: {
        claimsHistory: {
          claimId: claim._id,
          claimDate: new Date(),
          amount: claim.financialDetails.claimedAmount,
          status: 'submitted',
          description: claim.treatmentDetails.treatmentSummary
        }
      }
    });

    logger.info(`New insurance claim submitted for patient: ${patientId}`, {
      claimId: claim._id,
      claimNumber: claim.claimNumber,
      amount: claim.financialDetails.claimedAmount
    });

    res.status(201).json({
      status: 'success',
      message: 'Insurance claim submitted successfully',
      data: { claim }
    });

  } catch (error) {
    logger.error('Submit insurance claim error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error submitting insurance claim'
    });
  }
});

// @route   GET /api/v1/insurance/claims
// @desc    Get patient's insurance claims
// @access  Private (Patient)
router.get('/claims', authenticatePatient, [
  query('status').optional().isIn(['draft', 'submitted', 'under_review', 'approved', 'partially_approved', 'rejected', 'settled']),
  query('claimType').optional().isIn(['hospitalization', 'outpatient', 'emergency', 'maternity', 'dental', 'mental_health', 'preventive']),
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 50 })
], async (req, res) => {
  try {
    const patientId = req.user.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    let query = { patient: patientId };
    if (req.query.status) query.status = req.query.status;
    if (req.query.claimType) query.claimType = req.query.claimType;

    const [claims, total] = await Promise.all([
      InsuranceClaim.find(query)
        .populate('policy', 'policyNumber insuranceProvider.name')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      InsuranceClaim.countDocuments(query)
    ]);

    // Calculate claim statistics
    const allClaims = await InsuranceClaim.find({ patient: patientId });
    const stats = {
      totalClaims: allClaims.length,
      approvedClaims: allClaims.filter(c => c.status === 'approved' || c.status === 'settled').length,
      rejectedClaims: allClaims.filter(c => c.status === 'rejected').length,
      pendingClaims: allClaims.filter(c => ['draft', 'submitted', 'under_review'].includes(c.status)).length,
      totalClaimedAmount: allClaims.reduce((sum, c) => sum + (c.financialDetails.claimedAmount || 0), 0),
      totalSettledAmount: allClaims.reduce((sum, c) => sum + (c.financialDetails.settledAmount || 0), 0)
    };

    res.json({
      status: 'success',
      data: {
        claims,
        statistics: stats,
        pagination: {
          currentPage: page,
          totalPages: Math.ceil(total / limit),
          totalClaims: total,
          hasNext: page < Math.ceil(total / limit),
          hasPrev: page > 1
        }
      }
    });

  } catch (error) {
    logger.error('Get insurance claims error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching insurance claims'
    });
  }
});

// @route   POST /api/v1/insurance/pre-authorization
// @desc    Submit pre-authorization request
// @access  Private (Patient or Doctor)
router.post('/pre-authorization', authenticate, [
  body('policyId').notEmpty().withMessage('Policy ID is required'),
  body('treatmentDetails.proposedTreatment').notEmpty().withMessage('Proposed treatment is required'),
  body('treatmentDetails.estimatedCost').isNumeric().withMessage('Estimated cost must be a number'),
  body('hospital.name').notEmpty().withMessage('Hospital name is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        status: 'error',
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { policyId } = req.body;
    let patientId;

    // Handle both patient and doctor submissions
    if (req.user.role === 'patient') {
      patientId = req.user.id;
    } else if (req.user.role === 'doctor' && req.body.patientId) {
      patientId = req.body.patientId;
    } else {
      return res.status(400).json({
        status: 'error',
        message: 'Patient ID is required for doctor submissions'
      });
    }

    // Verify policy
    const policy = await InsurancePolicy.findOne({
      _id: policyId,
      patient: patientId,
      status: 'active'
    });

    if (!policy) {
      return res.status(404).json({
        status: 'error',
        message: 'Active insurance policy not found'
      });
    }

    // Generate pre-auth number
    const preAuthNumber = `PRE${Date.now()}${Math.random().toString(36).substr(2, 4).toUpperCase()}`;

    const preAuthData = {
      ...req.body,
      patient: patientId,
      policy: policyId,
      preAuthNumber
    };

    const preAuth = new PreAuthorization(preAuthData);
    await preAuth.save();

    logger.info(`Pre-authorization request submitted for patient: ${patientId}`, {
      preAuthId: preAuth._id,
      preAuthNumber: preAuth.preAuthNumber,
      estimatedCost: preAuth.treatmentDetails.estimatedCost
    });

    res.status(201).json({
      status: 'success',
      message: 'Pre-authorization request submitted successfully',
      data: { preAuthorization: preAuth }
    });

  } catch (error) {
    logger.error('Submit pre-authorization error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error submitting pre-authorization request'
    });
  }
});

// @route   GET /api/v1/insurance/pre-authorization
// @desc    Get pre-authorization requests
// @access  Private (Patient)
router.get('/pre-authorization', authenticatePatient, [
  query('status').optional().isIn(['pending', 'approved', 'partially_approved', 'rejected', 'expired'])
], async (req, res) => {
  try {
    const patientId = req.user.id;
    
    let query = { patient: patientId };
    if (req.query.status) {
      query.status = req.query.status;
    }

    const preAuths = await PreAuthorization.find(query)
      .populate('policy', 'policyNumber insuranceProvider.name')
      .sort({ createdAt: -1 });

    res.json({
      status: 'success',
      data: { preAuthorizations: preAuths }
    });

  } catch (error) {
    logger.error('Get pre-authorization requests error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching pre-authorization requests'
    });
  }
});

// @route   GET /api/v1/insurance/eligibility/:policyId
// @desc    Check insurance eligibility for treatment
// @access  Private (Patient or Doctor)
router.get('/eligibility/:policyId', authenticate, [
  query('treatmentType').optional().isString(),
  query('estimatedCost').optional().isNumeric()
], async (req, res) => {
  try {
    const { policyId } = req.params;
    const { treatmentType, estimatedCost } = req.query;

    let patientId;
    if (req.user.role === 'patient') {
      patientId = req.user.id;
    } else if (req.user.role === 'doctor' && req.query.patientId) {
      patientId = req.query.patientId;
    } else {
      return res.status(400).json({
        status: 'error',
        message: 'Patient ID is required for doctor queries'
      });
    }

    const policy = await InsurancePolicy.findOne({
      _id: policyId,
      patient: patientId
    });

    if (!policy) {
      return res.status(404).json({
        status: 'error',
        message: 'Insurance policy not found'
      });
    }

    // Calculate eligibility
    const claims = await InsuranceClaim.find({
      policy: policyId,
      status: { $in: ['approved', 'settled'] }
    });

    const usedAmount = claims.reduce((sum, claim) => sum + (claim.financialDetails.settledAmount || 0), 0);
    const remainingCoverage = policy.policyDetails.sumInsured - usedAmount;

    const eligibility = {
      policyStatus: policy.status,
      isEligible: policy.status === 'active' && remainingCoverage > 0,
      coverageDetails: {
        sumInsured: policy.policyDetails.sumInsured,
        usedAmount,
        remainingCoverage,
        utilisationPercentage: (usedAmount / policy.policyDetails.sumInsured) * 100
      },
      treatmentCoverage: null
    };

    // Check specific treatment coverage
    if (treatmentType) {
      const coverage = checkTreatmentCoverage(policy.coverage, treatmentType);
      eligibility.treatmentCoverage = coverage;
      
      if (estimatedCost && coverage.covered) {
        const applicableAmount = Math.min(estimatedCost, coverage.limit || remainingCoverage);
        const deductible = policy.policyDetails.deductible || 0;
        const coPayment = calculateCoPayment(applicableAmount, policy.policyDetails.coPayment);
        
        eligibility.estimatedCoverage = {
          estimatedCost: parseFloat(estimatedCost),
          applicableAmount,
          deductible,
          coPayment,
          estimatedPayable: Math.max(0, applicableAmount - deductible - coPayment),
          patientLiability: estimatedCost - Math.max(0, applicableAmount - deductible - coPayment)
        };
      }
    }

    res.json({
      status: 'success',
      data: { eligibility }
    });

  } catch (error) {
    logger.error('Check insurance eligibility error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error checking insurance eligibility'
    });
  }
});

// @route   GET /api/v1/insurance/network-hospitals
// @desc    Get list of network hospitals for insurance
// @access  Private
router.get('/network-hospitals', authenticate, [
  query('insuranceProvider').optional().isString(),
  query('city').optional().isString(),
  query('specialization').optional().isString()
], async (req, res) => {
  try {
    // Mock network hospitals data (in real app, would be from database)
    const networkHospitals = [
      {
        id: 'NH001',
        name: 'Apollo Hospitals',
        city: 'Delhi',
        address: 'Mathura Road, Sarita Vihar, Delhi',
        phone: '+91-11-26925858',
        specializations: ['Cardiology', 'Neurology', 'Oncology', 'Orthopaedics'],
        facilities: ['Emergency', 'ICU', 'Operation Theatre', 'Diagnostic Center'],
        cashlessAvailable: true,
        preAuthRequired: true,
        insuranceProviders: ['Star Health', 'HDFC ERGO', 'ICICI Lombard']
      },
      {
        id: 'NH002',
        name: 'Fortis Hospital',
        city: 'Mumbai',
        address: 'Mulund-Goregaon Link Rd, Mumbai',
        phone: '+91-22-67914444',
        specializations: ['Gastroenterology', 'Nephrology', 'Pulmonology'],
        facilities: ['Emergency', 'ICU', 'Dialysis Center'],
        cashlessAvailable: true,
        preAuthRequired: false,
        insuranceProviders: ['Star Health', 'Bajaj Allianz']
      },
      {
        id: 'NH003',
        name: 'Max Healthcare',
        city: 'Bangalore',
        address: 'Nagarbhavi, Bangalore',
        phone: '+91-80-26699999',
        specializations: ['Cardiology', 'Oncology', 'Neurosurgery'],
        facilities: ['Emergency', 'ICU', 'Cancer Center'],
        cashlessAvailable: true,
        preAuthRequired: true,
        insuranceProviders: ['HDFC ERGO', 'ICICI Lombard', 'Reliance General']
      }
    ];

    let filteredHospitals = networkHospitals;

    // Apply filters
    if (req.query.city) {
      filteredHospitals = filteredHospitals.filter(h => 
        h.city.toLowerCase().includes(req.query.city.toLowerCase())
      );
    }

    if (req.query.specialization) {
      filteredHospitals = filteredHospitals.filter(h => 
        h.specializations.some(s => 
          s.toLowerCase().includes(req.query.specialization.toLowerCase())
        )
      );
    }

    if (req.query.insuranceProvider) {
      filteredHospitals = filteredHospitals.filter(h => 
        h.insuranceProviders.some(p => 
          p.toLowerCase().includes(req.query.insuranceProvider.toLowerCase())
        )
      );
    }

    res.json({
      status: 'success',
      data: {
        hospitals: filteredHospitals,
        total: filteredHospitals.length,
        filters: {
          city: req.query.city,
          specialization: req.query.specialization,
          insuranceProvider: req.query.insuranceProvider
        }
      }
    });

  } catch (error) {
    logger.error('Get network hospitals error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching network hospitals'
    });
  }
});

// Helper functions
function checkTreatmentCoverage(coverage, treatmentType) {
  const treatmentMap = {
    'hospitalization': coverage.hospitalization,
    'outpatient': coverage.outpatientTreatment,
    'emergency': coverage.emergencyServices,
    'maternity': coverage.maternityBenefits,
    'dental': coverage.dentalCare,
    'mental_health': coverage.mentalHealth,
    'preventive': coverage.preventiveCare,
    'prescription': coverage.prescriptionDrugs
  };

  return treatmentMap[treatmentType] || { covered: false };
}

function calculateCoPayment(amount, coPaymentConfig) {
  if (!coPaymentConfig) return 0;
  
  if (coPaymentConfig.percentage) {
    return (amount * coPaymentConfig.percentage) / 100;
  }
  
  if (coPaymentConfig.fixedAmount) {
    return Math.min(coPaymentConfig.fixedAmount, amount);
  }
  
  return 0;
}

module.exports = router;
