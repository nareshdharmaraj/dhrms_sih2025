const Patient = require('../models/Patient');
const Migration = require('../models/Migration');
const QRCode = require('qrcode');

// Patient Registration
const registerPatient = async (req, res) => {
  try {
    const {
      uhid, // UHID should come from auth controller
      firstName,
      lastName,
      aadhaarNumber,
      phone,
      address,
      photo,
      email, // Optional
      password, // Required for registration
      dateOfBirth,
      gender,
      bloodGroup,
      emergencyContact,
      homeState,
      medicalHistory,
      allergies,
      currentMedications
    } = req.body;

    // Validate required fields including UHID
    if (!uhid || !firstName || !lastName || !aadhaarNumber || !phone || !address || !password || !dateOfBirth || !gender || !bloodGroup || !homeState) {
      return res.status(400).json({
        success: false,
        message: 'Missing required fields including UHID and password'
      });
    }

    // Check if Aadhaar number already exists
    const existingPatient = await Patient.findOne({ aadhaarNumber });
    if (existingPatient) {
      return res.status(400).json({
        success: false,
        message: 'Patient with this Aadhaar number already exists'
      });
    }

    // Check if email exists (if provided)
    if (email) {
      const existingEmail = await Patient.findOne({ email });
      if (existingEmail) {
        return res.status(400).json({
          success: false,
          message: 'Patient with this email already exists'
        });
      }
    }

    // Create new patient with provided UHID
    const patientData = {
      uhid, // Use provided UHID from auth controller
      firstName,
      lastName,
      aadhaarNumber,
      phone,
      address,
      photo,
      password,
      dateOfBirth,
      gender,
      bloodGroup,
      emergencyContact,
      homeState,
      medicalHistory: medicalHistory || [],
      allergies: allergies || [],
      currentMedications: currentMedications || []
    };

    // Add email only if provided and not empty
    if (email && email.trim() !== '') {
      patientData.email = email.trim();
    }

    const newPatient = new Patient(patientData);
    
    // Save patient (username and digital card will be auto-generated in pre-save middleware)
    await newPatient.save();

    // Generate comprehensive QR Code for digital card with all required data
    const comprehensiveQRData = JSON.stringify({
      uhid: newPatient.uhid,
      name: newPatient.fullName,
      address: {
        street: newPatient.address?.street || '',
        city: newPatient.address?.city || '',
        state: newPatient.address?.state || '',
        zipCode: newPatient.address?.zipCode || '',
        country: newPatient.address?.country || 'India'
      },
      homeState: newPatient.homeState,
      bloodGroup: newPatient.bloodGroup,
      emergencyContact: {
        name: newPatient.emergencyContact?.name || '',
        phone: newPatient.emergencyContact?.phone || ''
      },
      type: 'DHRMS_PATIENT_CARD',
      version: '2.0',
      timestamp: new Date().toISOString(),
      verificationURL: `https://dhrms.gov.in/verify/${newPatient.uhid}`
    });

    const qrCodeDataURL = await QRCode.toDataURL(comprehensiveQRData);

    // Prepare response
    const response = {
      success: true,
      message: 'Patient registered successfully',
      patient: {
        uhid: newPatient.uhid,
        username: newPatient.username, // Auto-generated username (same as UHID)
        firstName: newPatient.firstName,
        lastName: newPatient.lastName,
        fullName: newPatient.fullName,
        aadhaarNumber: newPatient.aadhaarNumber,
        phone: newPatient.phone,
        email: newPatient.email,
        address: newPatient.address,
        homeState: newPatient.homeState,
        digitalCard: {
          cardNumber: newPatient.digitalCard.cardNumber,
          qrCode: qrCodeDataURL,
          issueDate: newPatient.digitalCard.issueDate
        }
      }
    };

    res.status(201).json(response);

  } catch (error) {
    console.error('Patient registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error during registration',
      error: error.message
    });
  }
};

// Get Patient by UHID or QR Code scan
const getPatientByUHID = async (req, res) => {
  try {
    const { uhid } = req.params;

    const patient = await Patient.findOne({ uhid }).select('-password');
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Get migration history
    const migrations = await Migration.find({ uhid }).sort({ migrationDate: -1 });

    res.json({
      success: true,
      patient: {
        uhid: patient.uhid,
        fullName: patient.fullName,
        aadhaarNumber: patient.aadhaarNumber,
        phone: patient.phone,
        email: patient.email,
        address: patient.address,
        dateOfBirth: patient.dateOfBirth,
        gender: patient.gender,
        bloodGroup: patient.bloodGroup,
        emergencyContact: patient.emergencyContact,
        medicalHistory: patient.medicalHistory,
        allergies: patient.allergies,
        currentMedications: patient.currentMedications,
        isMigrant: patient.isMigrant,
        migrantDetails: patient.migrantDetails,
        homeState: patient.homeState,
        photo: patient.photo
      },
      migrations: migrations
    });

  } catch (error) {
    console.error('Error fetching patient:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

// Register Migration (when patient moves to another state)
const registerMigration = async (req, res) => {
  try {
    const { uhid } = req.params;
    const {
      toState,
      toCity,
      toHospital,
      migrationReason,
      expectedDuration,
      employmentDetails,
      healthStatusAtMigration
    } = req.body;

    // Find patient
    const patient = await Patient.findOne({ uhid });
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Get current location (from last migration or home state)
    const lastMigration = await Migration.findOne({ uhid, status: 'active' }).sort({ migrationDate: -1 });
    const fromState = lastMigration ? lastMigration.toState : patient.homeState;
    const fromCity = lastMigration ? lastMigration.toCity : patient.address.city;

    // Create migration record
    const migration = new Migration({
      patientId: patient._id,
      uhid: patient.uhid,
      fromState,
      fromCity,
      fromHospital: lastMigration ? lastMigration.toHospital : null,
      toState,
      toCity,
      toHospital,
      migrationReason,
      expectedDuration,
      employmentDetails: employmentDetails || {},
      healthStatusAtMigration: healthStatusAtMigration || {}
    });

    await migration.save();

    // Update patient as migrant
    await Patient.findByIdAndUpdate(patient._id, {
      isMigrant: true,
      'migrantDetails.currentState': toState,
      'migrantDetails.currentCity': toCity,
      'migrantDetails.registeredHospital': toHospital,
      'migrantDetails.migrationDate': new Date(),
      'migrantDetails.workLocation': employmentDetails?.workLocation,
      'migrantDetails.employerName': employmentDetails?.employerName,
      'migrantDetails.workPermitNumber': employmentDetails?.workPermitNumber
    });

    // Mark previous migration as completed
    if (lastMigration) {
      await Migration.findByIdAndUpdate(lastMigration._id, { status: 'completed' });
    }

    res.status(201).json({
      success: true,
      message: 'Migration registered successfully',
      migration: {
        migrationId: migration._id,
        fromState,
        fromCity,
        toState,
        toCity,
        toHospital,
        migrationDate: migration.migrationDate,
        status: migration.status
      }
    });

  } catch (error) {
    console.error('Migration registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error during migration registration',
      error: error.message
    });
  }
};

// Get Digital Health Card
const getDigitalCard = async (req, res) => {
  try {
    const { uhid } = req.params;

    const patient = await Patient.findOne({ uhid });
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: 'Patient not found'
      });
    }

    // Generate fresh QR code with comprehensive data
    const comprehensiveQRData = JSON.stringify({
      uhid: patient.uhid,
      name: patient.fullName,
      address: {
        street: patient.address?.street || '',
        city: patient.address?.city || '',
        state: patient.address?.state || '',
        zipCode: patient.address?.zipCode || '',
        country: patient.address?.country || 'India'
      },
      homeState: patient.homeState,
      bloodGroup: patient.bloodGroup,
      emergencyContact: {
        name: patient.emergencyContact?.name || '',
        phone: patient.emergencyContact?.phone || ''
      },
      type: 'DHRMS_PATIENT_CARD',
      version: '2.0',
      timestamp: new Date().toISOString(),
      verificationURL: `https://dhrms.gov.in/verify/${patient.uhid}`
    });
    
    const qrCodeDataURL = await QRCode.toDataURL(comprehensiveQRData);

    res.json({
      success: true,
      digitalCard: {
        uhid: patient.uhid,
        cardNumber: patient.digitalCard.cardNumber,
        patientName: patient.fullName,
        bloodGroup: patient.bloodGroup,
        emergencyContact: patient.emergencyContact?.phone || 'Not provided',
        emergencyContactName: patient.emergencyContact?.name || 'Not provided',
        address: {
          street: patient.address?.street || '',
          city: patient.address?.city || '',
          state: patient.address?.state || '',
          zipCode: patient.address?.zipCode || '',
          country: patient.address?.country || 'India',
          fullAddress: `${patient.address?.street || ''}, ${patient.address?.city || ''}, ${patient.address?.state || ''} - ${patient.address?.zipCode || ''}`
        },
        homeState: patient.homeState,
        dateOfBirth: patient.dateOfBirth,
        gender: patient.gender,
        phone: patient.phone,
        issueDate: patient.digitalCard.issueDate,
        qrCode: qrCodeDataURL,
        qrCodeData: comprehensiveQRData, // Raw QR data for verification
        photo: patient.photo,
        isActive: patient.digitalCard.isActive
      }
    });

  } catch (error) {
    console.error('Error generating digital card:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

// Get Migrant Patients by Hospital/Region
const getMigrantPatients = async (req, res) => {
  try {
    const { state, city, hospital } = req.query;

    let query = { isMigrant: true };
    
    if (state) {
      query['migrantDetails.currentState'] = state;
    }
    if (city) {
      query['migrantDetails.currentCity'] = city;
    }
    if (hospital) {
      query['migrantDetails.registeredHospital'] = hospital;
    }

    const migrants = await Patient.find(query)
      .select('uhid fullName phone migrantDetails homeState registrationDate')
      .sort({ 'migrantDetails.migrationDate': -1 });

    res.json({
      success: true,
      count: migrants.length,
      migrants: migrants
    });

  } catch (error) {
    console.error('Error fetching migrant patients:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

module.exports = {
  registerPatient,
  getPatientByUHID,
  registerMigration,
  getDigitalCard,
  getMigrantPatients
};
