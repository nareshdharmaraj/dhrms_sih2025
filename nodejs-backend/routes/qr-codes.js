const express = require('express');
const { body, query, validationResult } = require('express-validator');
const mongoose = require('mongoose');
const QRCode = require('qrcode');
const jimp = require('jimp');
const multer = require('multer');
const fs = require('fs').promises;
const path = require('path');
const Patient = require('../models/Patient');
const QRCodeModel = require('../models/QRCode');
const { authenticate, authenticatePatient, authenticateDoctor, authenticateHospital } = require('../middleware/auth');
const logger = require('../utils/logger');

const router = express.Router();

// @route   POST /api/v1/qr/generate
// @desc    Generate QR code for patient health data
// @access  Private (Patient, Doctor, Hospital)
router.post('/generate', authenticate, [
  body('type').isIn(['health_record', 'prescription', 'appointment', 'emergency', 'profile']),
  body('patientId').isMongoId().withMessage('Valid patient ID is required'),
  body('data').optional().isObject(),
  body('accessSettings').optional().isObject(),
  body('expirationDays').optional().isInt({ min: 1, max: 365 })
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

    const { type, patientId, data, accessSettings, expirationDays = 30 } = req.body;

    // Check access permissions
    const canGenerate = 
      (req.user.userType === 'patient' && req.user.id === patientId) ||
      (req.user.userType === 'doctor') ||
      (req.user.userType === 'hospital');

    if (!canGenerate) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Get patient data
    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    // Generate QR code ID
    const qrCodeId = QRCodeModel.generateQRId();

    // Prepare patient data for QR code
    const patientData = {
      patientId: patient.patientId,
      name: patient.fullName,
      age: patient.age,
      bloodType: patient.medicalInfo?.bloodType || 'Unknown',
      emergencyContact: patient.emergencyContact?.phone || '',
      allergies: patient.medicalInfo?.allergies || [],
      chronicConditions: patient.medicalInfo?.chronicConditions || []
    };

    // Create comprehensive QR data based on type
    let qrData = {
      type: type.toUpperCase(),
      id: qrCodeId,
      patient: patientData.patientId,
      timestamp: new Date().toISOString(),
      verification: 'DHRMS_VERIFIED',
      version: '1.0'
    };

    // Add type-specific data
    switch (type) {
      case 'health_record':
        qrData = {
          ...qrData,
          name: patientData.name,
          age: patientData.age,
          bloodType: patientData.bloodType,
          emergencyContact: patientData.emergencyContact,
          allergies: patientData.allergies,
          chronicConditions: patientData.chronicConditions,
          ...data
        };
        break;
      
      case 'emergency':
        qrData = {
          ...qrData,
          name: patientData.name,
          bloodType: patientData.bloodType,
          allergies: patientData.allergies,
          emergencyContacts: [patientData.emergencyContact],
          medicalAlerts: patientData.chronicConditions,
          location: data?.location || null,
          severity: data?.severity || 'medium'
        };
        break;
      
      case 'prescription':
      case 'appointment':
      case 'profile':
        qrData = { ...qrData, ...data };
        break;
    }

    // Create QR code document
    const qrCodeDoc = new QRCodeModel({
      qrCodeId,
      patient: patientId,
      type,
      data: {
        patientInfo: patientData,
        specificData: data || {}
      },
      qrCodeData: {
        qrString: JSON.stringify(qrData),
        format: 'json',
        size: accessSettings?.size || 'medium',
        errorCorrection: accessSettings?.errorCorrection || 'M'
      },
      accessSettings: {
        isPublic: accessSettings?.isPublic || false,
        expiresAt: new Date(Date.now() + expirationDays * 24 * 60 * 60 * 1000),
        maxAccess: accessSettings?.maxAccess || null,
        authorizedRoles: accessSettings?.authorizedRoles || ['doctor', 'hospital', 'emergency']
      },
      security: {
        encryptionLevel: 'basic',
        verificationCode: Math.random().toString(36).substr(2, 8).toUpperCase(),
        isActive: true
      }
    });

    await qrCodeDoc.save();

    // Generate actual QR code image
    const qrOptions = {
      errorCorrectionLevel: qrCodeDoc.qrCodeData.errorCorrection,
      type: 'image/png',
      quality: 0.92,
      margin: 1,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      },
      width: getSizeInPixels(qrCodeDoc.qrCodeData.size)
    };

    const qrCodeDataURL = await QRCode.toDataURL(qrCodeDoc.qrCodeData.qrString, qrOptions);

    logger.info(`QR code generated: ${qrCodeId}`, {
      type,
      patientId: patient.patientId,
      generatedBy: req.user.userType
    });

    res.status(201).json({
      status: 'success',
      message: 'QR code generated successfully',
      data: {
        qrCode: {
          id: qrCodeId,
          type,
          patient: {
            patientId: patient.patientId,
            name: patient.fullName
          },
          qrCodeImage: qrCodeDataURL,
          qrString: qrCodeDoc.qrCodeData.qrString,
          expiresAt: qrCodeDoc.accessSettings.expiresAt,
          verificationCode: qrCodeDoc.security.verificationCode,
          accessSettings: {
            isPublic: qrCodeDoc.accessSettings.isPublic,
            authorizedRoles: qrCodeDoc.accessSettings.authorizedRoles,
            maxAccess: qrCodeDoc.accessSettings.maxAccess
          }
        }
      }
    });

  } catch (error) {
    logger.error('Generate QR code error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error generating QR code'
    });
  }
});

// @route   POST /api/v1/qr/scan
// @desc    Scan and validate QR code
// @access  Public (with validation)
router.post('/scan', [
  body('qrData').notEmpty().withMessage('QR code data is required'),
  body('scannerInfo').optional().isObject()
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

    const { qrData, scannerInfo } = req.body;

    // Parse QR data
    let parsedData;
    try {
      parsedData = typeof qrData === 'string' ? JSON.parse(qrData) : qrData;
    } catch (parseError) {
      return res.status(400).json({
        status: 'error',
        message: 'Invalid QR code format'
      });
    }

    // Validate QR data structure
    if (!parsedData.id || !parsedData.type || !parsedData.verification) {
      return res.status(400).json({
        status: 'error',
        message: 'Invalid QR code structure'
      });
    }

    // Check verification
    if (parsedData.verification !== 'DHRMS_VERIFIED') {
      return res.status(400).json({
        status: 'error',
        message: 'Unverified QR code'
      });
    }

    // Find QR code document
    const qrCodeDoc = await QRCodeModel.findOne({ qrCodeId: parsedData.id })
      .populate('patient', 'patientId personalInfo medicalInfo emergencyContact');

    if (!qrCodeDoc) {
      return res.status(404).json({
        status: 'error',
        message: 'QR code not found'
      });
    }

    // Check if QR code is active and not expired
    if (!qrCodeDoc.security.isActive) {
      return res.status(403).json({
        status: 'error',
        message: 'QR code has been revoked'
      });
    }

    if (qrCodeDoc.isExpired()) {
      return res.status(403).json({
        status: 'error',
        message: 'QR code has expired'
      });
    }

    // Check access permissions
    const scannerRole = scannerInfo?.role || 'anonymous';
    if (!qrCodeDoc.canAccess(scannerRole)) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied for this role'
      });
    }

    // Record scan
    qrCodeDoc.recordScan({
      scannedBy: scannerInfo?.scannedBy || 'anonymous',
      scannerType: scannerRole,
      location: scannerInfo?.location,
      scanResult: 'success'
    });

    await qrCodeDoc.save();

    // Prepare response data based on access level
    let responseData = {
      qrCodeId: qrCodeDoc.qrCodeId,
      type: qrCodeDoc.type,
      scannedAt: new Date(),
      patient: {
        patientId: qrCodeDoc.patient.patientId,
        name: qrCodeDoc.patient.fullName
      }
    };

    // Add detailed data based on type and access level
    if (parsedData.type === 'EMERGENCY' || scannerRole === 'emergency') {
      responseData.emergencyData = {
        bloodType: parsedData.bloodType,
        allergies: parsedData.allergies,
        emergencyContacts: parsedData.emergencyContacts,
        medicalAlerts: parsedData.medicalAlerts,
        chronicConditions: parsedData.chronicConditions
      };
    } else if (scannerRole === 'doctor' || scannerRole === 'hospital') {
      responseData.medicalData = {
        bloodType: parsedData.bloodType,
        allergies: parsedData.allergies,
        chronicConditions: parsedData.chronicConditions,
        age: parsedData.age,
        lastUpdated: parsedData.timestamp
      };
    } else {
      responseData.basicInfo = {
        name: parsedData.name,
        patientId: parsedData.patient,
        verificationStatus: 'verified'
      };
    }

    logger.info(`QR code scanned: ${qrCodeDoc.qrCodeId}`, {
      scannerRole,
      scanCount: qrCodeDoc.usage.scanCount,
      patient: qrCodeDoc.patient.patientId
    });

    res.json({
      status: 'success',
      message: 'QR code scanned successfully',
      data: responseData
    });

  } catch (error) {
    logger.error('Scan QR code error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error scanning QR code'
    });
  }
});

// @route   GET /api/v1/qr/patient/:patientId
// @desc    Get all QR codes for a patient
// @access  Private (Patient, Doctor, Hospital)
router.get('/patient/:patientId', authenticate, [
  query('type').optional().isIn(['health_record', 'prescription', 'appointment', 'emergency', 'profile']),
  query('status').optional().isIn(['active', 'expired', 'revoked', 'all'])
], async (req, res) => {
  try {
    const { patientId } = req.params;
    const { type, status = 'active' } = req.query;

    // Check access permissions
    const hasAccess = 
      (req.user.userType === 'patient' && req.user.id === patientId) ||
      (req.user.userType === 'doctor') ||
      (req.user.userType === 'hospital');

    if (!hasAccess) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Build query
    let query = { patient: patientId };
    
    if (type) {
      query.type = type;
    }

    if (status !== 'all') {
      const now = new Date();
      switch (status) {
        case 'active':
          query['security.isActive'] = true;
          query['accessSettings.expiresAt'] = { $gt: now };
          break;
        case 'expired':
          query['accessSettings.expiresAt'] = { $lte: now };
          break;
        case 'revoked':
          query['security.isActive'] = false;
          break;
      }
    }

    const qrCodes = await QRCodeModel.find(query)
      .populate('patient', 'patientId personalInfo')
      .sort({ createdAt: -1 });

    const processedQRCodes = qrCodes.map(qr => ({
      id: qr.qrCodeId,
      type: qr.type,
      createdAt: qr.createdAt,
      expiresAt: qr.accessSettings.expiresAt,
      scanCount: qr.usage.scanCount,
      lastScanned: qr.usage.lastScanned,
      status: qr.security.isActive ? (qr.isExpired() ? 'expired' : 'active') : 'revoked',
      isPublic: qr.accessSettings.isPublic,
      authorizedRoles: qr.accessSettings.authorizedRoles,
      verificationCode: qr.security.verificationCode
    }));

    res.json({
      status: 'success',
      data: {
        qrCodes: processedQRCodes,
        summary: {
          total: processedQRCodes.length,
          active: processedQRCodes.filter(qr => qr.status === 'active').length,
          expired: processedQRCodes.filter(qr => qr.status === 'expired').length,
          revoked: processedQRCodes.filter(qr => qr.status === 'revoked').length
        }
      }
    });

  } catch (error) {
    logger.error('Get patient QR codes error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching QR codes'
    });
  }
});

// @route   PUT /api/v1/qr/:qrCodeId/revoke
// @desc    Revoke a QR code
// @access  Private (Patient, Doctor, Hospital)
router.put('/:qrCodeId/revoke', authenticate, async (req, res) => {
  try {
    const { qrCodeId } = req.params;

    const qrCode = await QRCodeModel.findOne({ qrCodeId })
      .populate('patient', 'patientId');

    if (!qrCode) {
      return res.status(404).json({
        status: 'error',
        message: 'QR code not found'
      });
    }

    // Check permissions
    const canRevoke = 
      (req.user.userType === 'patient' && req.user.id === qrCode.patient._id.toString()) ||
      (req.user.userType === 'doctor') ||
      (req.user.userType === 'hospital');

    if (!canRevoke) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    qrCode.security.isActive = false;
    qrCode.security.revokedAt = new Date();
    qrCode.security.revokedBy = req.user.id;

    await qrCode.save();

    logger.info(`QR code revoked: ${qrCodeId}`, {
      revokedBy: req.user.userType,
      patient: qrCode.patient.patientId
    });

    res.json({
      status: 'success',
      message: 'QR code revoked successfully',
      data: {
        qrCodeId,
        revokedAt: qrCode.security.revokedAt
      }
    });

  } catch (error) {
    logger.error('Revoke QR code error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error revoking QR code'
    });
  }
});

// @route   GET /api/v1/qr/:qrCodeId/analytics
// @desc    Get QR code usage analytics
// @access  Private (Patient, Doctor, Hospital)
router.get('/:qrCodeId/analytics', authenticate, async (req, res) => {
  try {
    const { qrCodeId } = req.params;

    const qrCode = await QRCodeModel.findOne({ qrCodeId })
      .populate('patient', 'patientId personalInfo');

    if (!qrCode) {
      return res.status(404).json({
        status: 'error',
        message: 'QR code not found'
      });
    }

    // Check permissions
    const hasAccess = 
      (req.user.userType === 'patient' && req.user.id === qrCode.patient._id.toString()) ||
      (req.user.userType === 'doctor') ||
      (req.user.userType === 'hospital');

    if (!hasAccess) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    // Process scan history
    const scansByRole = {};
    const scansByDate = {};
    
    qrCode.usage.scanHistory.forEach(scan => {
      // Group by role
      scansByRole[scan.scannerType] = (scansByRole[scan.scannerType] || 0) + 1;
      
      // Group by date
      const date = scan.timestamp.toISOString().split('T')[0];
      scansByDate[date] = (scansByDate[date] || 0) + 1;
    });

    const analytics = {
      qrCodeId,
      type: qrCode.type,
      createdAt: qrCode.createdAt,
      usage: {
        totalScans: qrCode.usage.scanCount,
        lastScanned: qrCode.usage.lastScanned,
        scansByRole,
        scansByDate,
        averageScansPerDay: qrCode.usage.scanCount / Math.max(1, 
          Math.ceil((new Date() - qrCode.createdAt) / (1000 * 60 * 60 * 24))
        )
      },
      access: {
        isActive: qrCode.security.isActive,
        isExpired: qrCode.isExpired(),
        expiresAt: qrCode.accessSettings.expiresAt,
        accessCount: qrCode.accessSettings.accessCount,
        maxAccess: qrCode.accessSettings.maxAccess
      },
      recentScans: qrCode.usage.scanHistory
        .slice(-10)
        .map(scan => ({
          scannerType: scan.scannerType,
          timestamp: scan.timestamp,
          location: scan.location,
          result: scan.scanResult
        }))
    };

    res.json({
      status: 'success',
      data: { analytics }
    });

  } catch (error) {
    logger.error('Get QR code analytics error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error fetching QR code analytics'
    });
  }
});

// @route   POST /api/v1/qr/batch-generate
// @desc    Generate multiple QR codes for different purposes
// @access  Private (Patient, Doctor, Hospital)
router.post('/batch-generate', authenticate, [
  body('patientId').isMongoId().withMessage('Valid patient ID is required'),
  body('types').isArray().withMessage('Types must be an array'),
  body('types.*').isIn(['health_record', 'prescription', 'appointment', 'emergency', 'profile'])
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

    const { patientId, types, commonSettings = {} } = req.body;

    // Check access permissions
    const canGenerate = 
      (req.user.userType === 'patient' && req.user.id === patientId) ||
      (req.user.userType === 'doctor') ||
      (req.user.userType === 'hospital');

    if (!canGenerate) {
      return res.status(403).json({
        status: 'error',
        message: 'Access denied'
      });
    }

    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        status: 'error',
        message: 'Patient not found'
      });
    }

    const generatedQRCodes = [];

    for (const type of types) {
      try {
        // Generate QR code for each type
        const qrCodeId = QRCodeModel.generateQRId();
        
        const patientData = {
          patientId: patient.patientId,
          name: patient.fullName,
          age: patient.age,
          bloodType: patient.medicalInfo?.bloodType || 'Unknown',
          emergencyContact: patient.emergencyContact?.phone || '',
          allergies: patient.medicalInfo?.allergies || [],
          chronicConditions: patient.medicalInfo?.chronicConditions || []
        };

        const qrData = {
          type: type.toUpperCase(),
          id: qrCodeId,
          patient: patientData.patientId,
          name: patientData.name,
          timestamp: new Date().toISOString(),
          verification: 'DHRMS_VERIFIED'
        };

        const qrCodeDoc = new QRCodeModel({
          qrCodeId,
          patient: patientId,
          type,
          data: {
            patientInfo: patientData,
            specificData: {}
          },
          qrCodeData: {
            qrString: JSON.stringify(qrData),
            format: 'json',
            size: commonSettings.size || 'medium'
          },
          accessSettings: {
            isPublic: commonSettings.isPublic || false,
            expiresAt: new Date(Date.now() + (commonSettings.expirationDays || 30) * 24 * 60 * 60 * 1000),
            authorizedRoles: commonSettings.authorizedRoles || ['doctor', 'hospital', 'emergency']
          },
          security: {
            encryptionLevel: 'basic',
            verificationCode: Math.random().toString(36).substr(2, 8).toUpperCase(),
            isActive: true
          }
        });

        await qrCodeDoc.save();

        const qrCodeDataURL = await QRCode.toDataURL(qrCodeDoc.qrCodeData.qrString, {
          errorCorrectionLevel: 'M',
          width: getSizeInPixels(qrCodeDoc.qrCodeData.size)
        });

        generatedQRCodes.push({
          id: qrCodeId,
          type,
          qrCodeImage: qrCodeDataURL,
          verificationCode: qrCodeDoc.security.verificationCode,
          expiresAt: qrCodeDoc.accessSettings.expiresAt
        });

      } catch (error) {
        logger.error(`Error generating QR code for type ${type}:`, error);
      }
    }

    logger.info(`Batch QR codes generated: ${generatedQRCodes.length}`, {
      patientId: patient.patientId,
      types,
      generatedBy: req.user.userType
    });

    res.status(201).json({
      status: 'success',
      message: `${generatedQRCodes.length} QR codes generated successfully`,
      data: {
        qrCodes: generatedQRCodes,
        patient: {
          patientId: patient.patientId,
          name: patient.fullName
        }
      }
    });

  } catch (error) {
    logger.error('Batch generate QR codes error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Error generating QR codes'
    });
  }
});

// Helper function to get QR code size in pixels
function getSizeInPixels(size) {
  switch (size) {
    case 'small': return 150;
    case 'large': return 300;
    default: return 200; // medium
  }
}

module.exports = router;
