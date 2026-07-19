# Doctor Schema Documentation

## Collection: doctors

### Schema Structure

```javascript
{
  _id: ObjectId,
  doctorId: String, // Unique identifier (DOC123456789)
  
  personalInfo: {
    firstName: String,
    lastName: String,
    email: String,
    phone: String,
    dateOfBirth: Date,
    gender: String, // enum: ["male", "female", "other"]
    address: {
      street: String,
      city: String,
      state: String,
      pincode: String
    }
  },
  
  professionalInfo: {
    specialization: String, // Cardiology, Neurology, etc.
    qualification: String, // MBBS, MD, MS, etc.
    experience: Number, // Years of experience
    licenseNumber: String, // Medical license number (unique)
    registrationDate: Date,
    medicalCouncil: String, // State/National medical council
    currentPosition: String, // Consultant, Senior Resident, etc.
    department: String
  },
  
  credentials: {
    username: String, // Unique
    password: String, // Hashed
    email: String,
    isActive: Boolean,
    createdAt: Date,
    lastLogin: Date
  },
  
  hospitalAffiliation: {
    primaryHospital: String, // Hospital ID
    otherHospitals: [String], // Array of hospital IDs
    consultationType: String // full-time, part-time, visiting
  },
  
  consultationFee: {
    regular: Number,
    emergency: Number,
    followUp: Number,
    online: Number
  },
  
  availability: {
    schedule: [{
      day: String, // Monday, Tuesday, etc.
      startTime: String, // HH:MM format
      endTime: String, // HH:MM format
      isAvailable: Boolean,
      maxPatients: Number
    }],
    emergencyAvailable: Boolean,
    onlineConsultation: Boolean,
    homeVisit: Boolean
  },
  
  statistics: {
    totalPatients: Number,
    totalConsultations: Number,
    averageRating: Number,
    reviews: [{
      patientId: String,
      rating: Number, // 1-5
      comment: String,
      date: Date
    }]
  },
  
  certifications: [{
    name: String,
    issuingBody: String,
    issueDate: Date,
    expiryDate: Date,
    certificateNumber: String
  }],
  
  research: [{
    title: String,
    journal: String,
    publicationDate: Date,
    coAuthors: [String]
  }],
  
  preferences: {
    language: String,
    notifications: {
      email: Boolean,
      sms: Boolean,
      push: Boolean
    },
    autoAcceptAppointments: Boolean
  },
  
  createdAt: Date,
  updatedAt: Date
}
```

### Indexes

- `doctorId` (unique)
- `credentials.username` (unique)
- `professionalInfo.licenseNumber` (unique)
- `professionalInfo.specialization`
- `hospitalAffiliation.primaryHospital`
- `availability.schedule.day`

### Validation Rules

1. **doctorId**: Must start with "DOC" followed by numbers
2. **licenseNumber**: Must be unique and follow medical council format
3. **specialization**: Must be from predefined list of medical specializations
4. **experience**: Must be non-negative number
5. **consultationFee**: All fee values must be positive numbers
6. **rating**: Must be between 1-5

### Sample Queries

```javascript
// Find doctors by specialization
db.doctors.find({ "professionalInfo.specialization": "Cardiology" })

// Find available doctors for today
const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
db.doctors.find({
  "availability.schedule": {
    $elemMatch: {
      "day": today,
      "isAvailable": true
    }
  }
})

// Find doctors with online consultation
db.doctors.find({ "availability.onlineConsultation": true })

// Update doctor's availability
db.doctors.updateOne(
  { "doctorId": "DOC123456789" },
  {
    $set: {
      "availability.schedule.$[elem].isAvailable": false,
      "updatedAt": new Date()
    }
  },
  {
    arrayFilters: [{ "elem.day": "Monday" }]
  }
)

// Find top-rated doctors
db.doctors.find({ "statistics.averageRating": { $gte: 4.5 } })
  .sort({ "statistics.averageRating": -1 })
  .limit(10)

// Find doctors by hospital
db.doctors.find({ "hospitalAffiliation.primaryHospital": "HOSP123456789" })
```
