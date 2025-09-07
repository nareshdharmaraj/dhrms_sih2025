# Patient Schema Documentation

## Collection: patients

### Schema Structure

```javascript
{
  _id: ObjectId,
  patientId: String, // Unique identifier (PAT123456789)
  uhi: String, // Universal Health Identifier (UHI123456789)
  
  personalInfo: {
    firstName: String,
    lastName: String,
    email: String,
    phone: String,
    aadhaarNumber: String, // Unique 12-digit number
    dateOfBirth: Date,
    gender: String, // enum: ["male", "female", "other"]
    bloodGroup: String, // A+, B+, AB+, O+, A-, B-, AB-, O-
    address: {
      street: String,
      city: String,
      state: String,
      pincode: String,
      country: String
    },
    emergencyContact: {
      name: String,
      relationship: String,
      phone: String
    },
    uniqueHealthId: String
  },
  
  credentials: {
    username: String, // Unique
    password: String, // Hashed
    email: String,
    isActive: Boolean,
    createdAt: Date,
    lastLogin: Date
  },
  
  medicalInfo: {
    bloodGroup: String,
    allergies: [String],
    chronicConditions: [String],
    medications: [{
      name: String,
      dosage: String,
      frequency: String,
      startDate: Date,
      endDate: Date
    }],
    surgicalHistory: [{
      procedure: String,
      date: Date,
      hospital: String,
      doctor: String
    }],
    familyHistory: [{
      condition: String,
      relation: String
    }],
    vaccinations: [{
      vaccine: String,
      date: Date,
      nextDue: Date
    }]
  },
  
  insuranceInfo: {
    provider: String,
    policyNumber: String,
    validUntil: Date,
    coverageAmount: Number
  },
  
  vitalSigns: {
    height: Number, // in cm
    weight: Number, // in kg
    bmi: Number,
    bloodPressure: {
      systolic: Number,
      diastolic: Number
    },
    heartRate: Number,
    temperature: Number,
    respiratoryRate: Number,
    oxygenSaturation: Number
  },
  
  preferences: {
    language: String,
    notifications: {
      email: Boolean,
      sms: Boolean,
      push: Boolean
    },
    shareDataWithResearch: Boolean
  },
  
  createdAt: Date,
  updatedAt: Date
}
```

### Indexes

- `patientId` (unique)
- `uhi` (unique)  
- `credentials.username` (unique)
- `credentials.email`
- `personalInfo.phone`
- `personalInfo.aadhaarNumber` (unique)

### Validation Rules

1. **patientId**: Must start with "PAT" followed by numbers
2. **uhi**: Must start with "UHI" followed by numbers
3. **aadhaarNumber**: Must be exactly 12 digits
4. **gender**: Must be one of ["male", "female", "other"]
5. **bloodGroup**: Must be valid blood group (A+, B+, etc.)
6. **email**: Must be valid email format
7. **phone**: Must be valid phone number format

### Sample Queries

```javascript
// Find patient by UHI
db.patients.findOne({ "uhi": "UHI123456789" })

// Find patients by blood group
db.patients.find({ "medicalInfo.bloodGroup": "O+" })

// Find patients with specific allergy
db.patients.find({ "medicalInfo.allergies": "Penicillin" })

// Update patient vital signs
db.patients.updateOne(
  { "patientId": "PAT123456789" },
  { 
    $set: { 
      "vitalSigns.weight": 75,
      "vitalSigns.bmi": 24.2,
      "updatedAt": new Date()
    }
  }
)

// Find patients for vaccination reminder
db.patients.find({
  "medicalInfo.vaccinations.nextDue": {
    $lte: new Date(Date.now() + 30*24*60*60*1000) // Next 30 days
  }
})
```
