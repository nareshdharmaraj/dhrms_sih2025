# Hospital Schema Documentation

## Collection: hospitals

### Schema Structure

```javascript
{
  _id: ObjectId,
  hospitalId: String, // Unique identifier (HOSP123456789)
  
  name: String,
  type: String, // enum: ["government", "private", "charitable", "corporate"]
  registrationNumber: String, // Government registration number
  
  address: {
    street: String,
    city: String,
    state: String,
    pincode: String,
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  
  contactInfo: {
    phone: String,
    email: String,
    website: String,
    emergencyContact: String,
    fax: String
  },
  
  credentials: {
    username: String, // Unique
    password: String, // Hashed
    email: String,
    isActive: Boolean,
    createdAt: Date,
    lastLogin: Date
  },
  
  facilities: [{
    name: String, // ICU, Emergency, OT, etc.
    capacity: Number,
    available: Number,
    equipment: [String],
    isActive: Boolean
  }],
  
  departments: [{
    name: String, // Cardiology, Neurology, etc.
    head: String, // Doctor ID
    doctors: [String], // Array of doctor IDs
    beds: Number,
    availableBeds: Number,
    services: [String]
  }],
  
  statistics: {
    totalDoctors: Number,
    totalPatients: Number,
    totalBeds: Number,
    availableBeds: Number,
    occupancyRate: Number, // Percentage
    averageRating: Number,
    totalRatings: Number
  },
  
  services: [{
    name: String,
    description: String,
    cost: Number,
    duration: String, // Expected duration
    department: String
  }],
  
  certification: {
    accreditation: String, // NABH, JCI, etc.
    validUntil: Date,
    isVerified: Boolean,
    certifyingBody: String
  },
  
  insurance: {
    acceptedProviders: [String],
    cashlessAvailable: Boolean,
    emergencyCoverage: Boolean
  },
  
  operatingHours: {
    general: {
      startTime: String,
      endTime: String
    },
    emergency: {
      available24x7: Boolean,
      startTime: String,
      endTime: String
    },
    pharmacy: {
      startTime: String,
      endTime: String,
      available24x7: Boolean
    }
  },
  
  amenities: [String], // Parking, Cafeteria, WiFi, etc.
  
  reviews: [{
    patientId: String,
    rating: Number, // 1-5
    comment: String,
    service: String, // Which service was reviewed
    date: Date,
    verified: Boolean
  }],
  
  emergencyServices: {
    ambulance: Boolean,
    traumaCenter: Boolean,
    bloodBank: Boolean,
    burnUnit: Boolean,
    emergencyOT: Boolean
  },
  
  createdAt: Date,
  updatedAt: Date
}
```

### Indexes

- `hospitalId` (unique)
- `credentials.username` (unique)
- `name`
- `type`
- `address.city`
- `address.state`
- `address.pincode`
- `departments.name`
- `certification.accreditation`

### Validation Rules

1. **hospitalId**: Must start with "HOSP" followed by numbers
2. **type**: Must be one of ["government", "private", "charitable", "corporate"]
3. **registrationNumber**: Must be unique government registration number
4. **occupancyRate**: Must be between 0-100
5. **rating**: Must be between 1-5
6. **coordinates**: Must be valid latitude/longitude

### Sample Queries

```javascript
// Find hospitals by type
db.hospitals.find({ "type": "government" })

// Find hospitals in a city
db.hospitals.find({ "address.city": "Delhi" })

// Find hospitals with specific department
db.hospitals.find({ "departments.name": "Cardiology" })

// Find hospitals with available beds
db.hospitals.find({ "statistics.availableBeds": { $gt: 0 } })

// Find hospitals with 24x7 emergency
db.hospitals.find({ "operatingHours.emergency.available24x7": true })

// Find hospitals near coordinates (within 10km)
db.hospitals.find({
  "address.coordinates": {
    $near: {
      $geometry: { type: "Point", coordinates: [77.2090, 28.6139] },
      $maxDistance: 10000
    }
  }
})

// Update bed availability
db.hospitals.updateOne(
  { "hospitalId": "HOSP123456789" },
  {
    $inc: { "statistics.availableBeds": -1 },
    $set: { "updatedAt": new Date() }
  }
)

// Find top-rated hospitals
db.hospitals.find({ "statistics.averageRating": { $gte: 4.0 } })
  .sort({ "statistics.averageRating": -1 })
  .limit(10)

// Find hospitals accepting specific insurance
db.hospitals.find({ "insurance.acceptedProviders": "LIC Health" })

// Update department doctor list
db.hospitals.updateOne(
  { "hospitalId": "HOSP123456789", "departments.name": "Cardiology" },
  {
    $addToSet: { "departments.$.doctors": "DOC123456789" },
    $set: { "updatedAt": new Date() }
  }
)
```
