const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema({
  // Authentication credentials
  username: {
    type: String,
    required: false, // Will be auto-generated after registration
    unique: true,
    sparse: true, // Allows null values temporarily
    trim: true
  },
  password: {
    type: String,
    required: true
  },
  
  // Universal Health Identity (UHID) - Auto-generated
  uhid: {
    type: String,
    unique: true,
    trim: true
  },
  
  // Personal Information
  firstName: {
    type: String,
    required: true,
    trim: true
  },
  lastName: {
    type: String,
    required: true,
    trim: true
  },
  fullName: {
    type: String,
    trim: true
  },
  aadhaarNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    validate: {
      validator: function(v) {
        return /^\d{12}$/.test(v);
      },
      message: 'Aadhaar number must be exactly 12 digits'
    }
  },
  email: {
    type: String,
    unique: true,
    sparse: true, // Allows multiple null/undefined values since email is optional
    trim: true,
    default: undefined // Explicitly set default to undefined instead of null
  },
  photo: {
    type: String, // Base64 encoded image or file path
    required: false
  },
  phone: {
    type: String,
    required: true,
    trim: true
  },
  dateOfBirth: {
    type: Date,
    required: true
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other'],
    required: true
  },
  bloodGroup: {
    type: String,
    enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
    required: true
  },
  
  // Address Information
  address: {
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    zipCode: { type: String, required: true },
    country: { type: String, default: 'India' }
  },
  
  // Emergency Contact
  emergencyContact: {
    name: { type: String, required: true },
    relationship: { type: String, required: true },
    phone: { type: String, required: true }
  },
  
  // Medical Information
  medicalHistory: [{
    condition: String,
    diagnosedDate: Date,
    notes: String
  }],
  allergies: [String],
  currentMedications: [{
    name: String,
    dosage: String,
    frequency: String
  }],
  
  // Migrant Worker Specific
  isMigrant: {
    type: Boolean,
    default: false
  },
  migrantDetails: {
    currentState: String,
    currentCity: String,
    registeredHospital: String,
    migrationDate: Date,
    workLocation: String,
    employerName: String,
    workPermitNumber: String
  },
  homeState: {
    type: String,
    required: true
  },
  
  // Digital Health Card
  digitalCard: {
    qrCode: String, // QR code data for quick access
    cardNumber: String, // Same as UHID
    issueDate: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true }
  },
  
  // System fields
  isActive: {
    type: Boolean,
    default: true
  },
  registrationDate: {
    type: Date,
    default: Date.now
  },
  lastLogin: {
    type: Date
  }
});

// Pre-save middleware to generate UHID, username and set fullName
patientSchema.pre('save', async function(next) {
  // Generate fullName
  if (this.firstName && this.lastName) {
    this.fullName = `${this.firstName} ${this.lastName}`;
  }
  
  // Generate UHID if not exists
  if (!this.uhid && this.firstName && this.lastName && this.aadhaarNumber) {
    let uhid = generateUHID(this.firstName, this.lastName, this.aadhaarNumber);
    
    // Ensure UHID is unique
    let counter = 0;
    while (await mongoose.models.Patient.findOne({ uhid }) && counter < 10) {
      // If UHID exists, regenerate with slight modification
      uhid = generateUHID(this.firstName, this.lastName, this.aadhaarNumber);
      counter++;
    }
    
    this.uhid = uhid;
  }
  
  // Generate username if not exists and UHID is available
  if (!this.username && this.uhid) {
    // Username should be same as UHID
    this.username = this.uhid;
  }
  
  // Set digital card details
  if (!this.digitalCard.cardNumber && this.uhid) {
    this.digitalCard.cardNumber = this.uhid;
    this.digitalCard.qrCode = generateQRCodeData(this.uhid);
  }
  
  next();
});

// Function to generate UHID
function generateUHID(firstName, lastName, aadhaarNumber) {
  // Combine first and last name and clean them
  const fullName = (firstName + lastName).replace(/[^A-Za-z]/g, '').toUpperCase();
  
  // Get first 4 letters from name
  let nameCode = '';
  if (fullName.length >= 4) {
    nameCode = fullName.substring(0, 4);
  } else {
    // If name is shorter than 4 characters, pad with random letters
    nameCode = fullName;
    const randomLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    while (nameCode.length < 4) {
      nameCode += randomLetters.charAt(Math.floor(Math.random() * randomLetters.length));
    }
  }
  
  // Get last 4 digits of Aadhaar number
  const aadhaarCode = aadhaarNumber.substring(8, 12);
  
  // Combine to create 8-character UHID: ABCD1234
  return nameCode + aadhaarCode;
}

// Function to generate QR code data
function generateQRCodeData(uhid) {
  return JSON.stringify({
    uhid: uhid,
    type: 'DHRMS_PATIENT_CARD',
    timestamp: new Date().toISOString()
  });
}

module.exports = mongoose.model('Patient', patientSchema);
