# Database Schema Updates for DHRMS Feature Implementation

## Overview
This document outlines the database schema changes required to support the new features:
- Separate Account Creation Forms
- Password Management
- Notifications System
- Dashboard Access Rules

## New Collections/Tables

### 1. Users Collection (Enhanced)
```javascript
{
  _id: ObjectId,
  userId: String, // Unique patient ID for patients (e.g., "PATEJEEV1234")
  email: String, // Unique email address
  passwordHash: String, // Hashed password
  salt: String, // Salt for password hashing
  role: String, // "patient", "hospital", "doctor", "regional_officer"
  status: String, // "active", "pending", "suspended", "rejected"
  
  // Profile Information
  profile: {
    firstName: String,
    lastName: String,
    phoneNumber: String,
    dateOfBirth: Date,
    gender: String,
    address: {
      street: String,
      city: String,
      state: String,
      pincode: String,
      country: String
    }
  },
  
  // Role-specific data
  patientData: {
    aadhaarNumber: String, // Encrypted
    emergencyContact: {
      name: String,
      relationship: String,
      phoneNumber: String
    },
    medicalHistory: Array,
    allergies: Array
  },
  
  hospitalData: {
    hospitalName: String,
    registrationNumber: String,
    hospitalType: String,
    bedCapacity: Number,
    specialties: Array,
    contactPerson: {
      name: String,
      designation: String,
      phoneNumber: String
    }
  },
  
  doctorData: {
    medicalLicenseNumber: String,
    specialization: String,
    qualifications: Array,
    experience: Number,
    hospitalId: ObjectId, // Reference to hospital
    consultationFee: Number
  },
  
  // Security and Access
  lastLogin: Date,
  failedLoginAttempts: Number,
  accountLocked: Boolean,
  lockoutUntil: Date,
  
  // Audit Trail
  createdAt: Date,
  updatedAt: Date,
  createdBy: ObjectId,
  lastModifiedBy: ObjectId
}
```

### 2. Approval Requests Collection
```javascript
{
  _id: ObjectId,
  requestId: String, // Unique request ID (e.g., "REQ001")
  requestType: String, // "hospital_registration", "doctor_registration"
  
  // Requester Information
  requesterId: ObjectId, // User ID of the requester
  requesterData: Object, // Copy of submitted data
  
  // Approval Chain
  approvalChain: [
    {
      approverId: ObjectId, // User ID of approver
      approverRole: String, // "regional_officer", "hospital_admin"
      status: String, // "pending", "approved", "rejected"
      comments: String,
      actionDate: Date
    }
  ],
  
  // Current Status
  currentStatus: String, // "pending", "approved", "rejected"
  currentApprover: ObjectId, // Current person responsible for approval
  
  // Metadata
  submittedAt: Date,
  lastUpdated: Date,
  priority: String, // "low", "normal", "high", "urgent"
}
```

### 3. Notifications Collection
```javascript
{
  _id: ObjectId,
  notificationId: String, // Unique notification ID
  
  // Recipient Information
  recipientId: ObjectId, // User ID of recipient
  recipientRole: String, // For role-based notifications
  
  // Notification Content
  title: String,
  message: String,
  type: String, // "approval", "rejection", "reminder", "alert", "system", "appointment", "medication", "emergency"
  priority: String, // "low", "normal", "high", "critical"
  
  // Status
  isRead: Boolean,
  readAt: Date,
  
  // Action Information
  actionUrl: String, // Optional URL for action
  actionRequired: Boolean,
  actionTaken: Boolean,
  actionTakenAt: Date,
  
  // Metadata
  metadata: Object, // Additional context data
  
  // Timing
  createdAt: Date,
  scheduledFor: Date, // For scheduled notifications
  expiresAt: Date, // For time-sensitive notifications
  
  // Tracking
  delivered: Boolean,
  deliveredAt: Date,
  deliveryAttempts: Number
}
```

### 4. Password Reset Tokens Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId, // Reference to user
  token: String, // Secure random token
  tokenHash: String, // Hashed version of token
  
  // Validity
  isUsed: Boolean,
  usedAt: Date,
  expiresAt: Date,
  
  // Security
  ipAddress: String,
  userAgent: String,
  
  // Audit
  createdAt: Date,
  requestedBy: String, // Email address
}
```

### 5. Audit Logs Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId, // User who performed the action
  action: String, // "login", "logout", "password_change", "profile_update", etc.
  resource: String, // What was affected
  resourceId: ObjectId, // ID of affected resource
  
  // Details
  oldValues: Object, // Previous state (for updates)
  newValues: Object, // New state (for updates)
  
  // Context
  ipAddress: String,
  userAgent: String,
  sessionId: String,
  
  // Result
  success: Boolean,
  errorMessage: String,
  
  // Timing
  timestamp: Date,
  duration: Number // How long the action took (ms)
}
```

### 6. User Sessions Collection
```javascript
{
  _id: ObjectId,
  sessionId: String, // Unique session identifier
  userId: ObjectId, // Reference to user
  
  // Session Details
  isActive: Boolean,
  loginTime: Date,
  lastActivity: Date,
  logoutTime: Date,
  
  // Device Information
  ipAddress: String,
  userAgent: String,
  deviceType: String, // "mobile", "tablet", "desktop"
  location: {
    country: String,
    state: String,
    city: String
  },
  
  // Security
  tokenHash: String, // Hashed session token
  refreshTokenHash: String,
  
  // Expiry
  expiresAt: Date,
  refreshExpiresAt: Date
}
```

## Database Indexes

### Users Collection Indexes
```javascript
// Unique indexes
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "userId": 1 }, { unique: true, sparse: true })

// Performance indexes
db.users.createIndex({ "role": 1, "status": 1 })
db.users.createIndex({ "patientData.aadhaarNumber": 1 }, { sparse: true })
db.users.createIndex({ "hospitalData.registrationNumber": 1 }, { sparse: true })
db.users.createIndex({ "doctorData.medicalLicenseNumber": 1 }, { sparse: true })
db.users.createIndex({ "lastLogin": 1 })
db.users.createIndex({ "createdAt": 1 })
```

### Approval Requests Collection Indexes
```javascript
db.approvalRequests.createIndex({ "requestId": 1 }, { unique: true })
db.approvalRequests.createIndex({ "requesterId": 1 })
db.approvalRequests.createIndex({ "currentStatus": 1, "currentApprover": 1 })
db.approvalRequests.createIndex({ "requestType": 1, "currentStatus": 1 })
db.approvalRequests.createIndex({ "submittedAt": 1 })
```

### Notifications Collection Indexes
```javascript
db.notifications.createIndex({ "notificationId": 1 }, { unique: true })
db.notifications.createIndex({ "recipientId": 1, "isRead": 1, "createdAt": -1 })
db.notifications.createIndex({ "type": 1, "priority": 1 })
db.notifications.createIndex({ "createdAt": 1 }, { expireAfterSeconds: 7776000 }) // 90 days TTL
db.notifications.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 })
```

### Password Reset Tokens Collection Indexes
```javascript
db.passwordResetTokens.createIndex({ "userId": 1 })
db.passwordResetTokens.createIndex({ "token": 1 }, { unique: true })
db.passwordResetTokens.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 })
db.passwordResetTokens.createIndex({ "createdAt": 1 }, { expireAfterSeconds: 86400 }) // 24 hours TTL
```

### Audit Logs Collection Indexes
```javascript
db.auditLogs.createIndex({ "userId": 1, "timestamp": -1 })
db.auditLogs.createIndex({ "action": 1, "timestamp": -1 })
db.auditLogs.createIndex({ "resourceId": 1 })
db.auditLogs.createIndex({ "timestamp": 1 }, { expireAfterSeconds: 31536000 }) // 1 year TTL
```

### User Sessions Collection Indexes
```javascript
db.userSessions.createIndex({ "sessionId": 1 }, { unique: true })
db.userSessions.createIndex({ "userId": 1, "isActive": 1 })
db.userSessions.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 })
db.userSessions.createIndex({ "lastActivity": 1 })
```

## Migration Scripts

### Step 1: Create New Collections
```javascript
// Create collections with validation
db.createCollection("approvalRequests", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["requestId", "requestType", "requesterId", "currentStatus"],
      properties: {
        requestId: { bsonType: "string" },
        requestType: { enum: ["hospital_registration", "doctor_registration"] },
        currentStatus: { enum: ["pending", "approved", "rejected"] }
      }
    }
  }
})

db.createCollection("notifications", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["notificationId", "recipientId", "title", "message", "type", "priority"],
      properties: {
        type: { enum: ["approval", "rejection", "reminder", "alert", "system", "appointment", "medication", "emergency"] },
        priority: { enum: ["low", "normal", "high", "critical"] }
      }
    }
  }
})
```

### Step 2: Update Existing Users
```javascript
// Add new fields to existing users
db.users.updateMany({}, {
  $set: {
    status: "active",
    failedLoginAttempts: 0,
    accountLocked: false,
    updatedAt: new Date()
  }
})

// Generate unique patient IDs for existing patients
db.users.find({ role: "patient", userId: { $exists: false } }).forEach(function(user) {
  const firstName = user.profile?.firstName || "USER";
  const lastName = user.profile?.lastName || "";
  const aadhaar = user.patientData?.aadhaarNumber || "0000";
  const last4 = aadhaar.slice(-4);
  const patientId = "PAT" + firstName.substring(0, 4).toUpperCase() + last4;
  
  db.users.updateOne(
    { _id: user._id },
    { $set: { userId: patientId } }
  );
});
```

### Step 3: Create Sample Data
```javascript
// Insert sample approval request
db.approvalRequests.insertOne({
  requestId: "REQ001",
  requestType: "hospital_registration",
  requesterId: ObjectId(), // Replace with actual user ID
  requesterData: {
    hospitalName: "Sample Hospital",
    registrationNumber: "HOSP001"
  },
  approvalChain: [
    {
      approverId: ObjectId(), // Regional officer ID
      approverRole: "regional_officer",
      status: "pending",
      comments: "",
      actionDate: null
    }
  ],
  currentStatus: "pending",
  currentApprover: ObjectId(),
  submittedAt: new Date(),
  lastUpdated: new Date(),
  priority: "normal"
})

// Insert sample notifications
db.notifications.insertMany([
  {
    notificationId: "NOTIF001",
    recipientId: ObjectId(),
    title: "Registration Approved",
    message: "Your hospital registration has been approved.",
    type: "approval",
    priority: "high",
    isRead: false,
    actionRequired: false,
    actionTaken: false,
    createdAt: new Date(),
    delivered: true,
    deliveredAt: new Date(),
    deliveryAttempts: 1
  }
])
```

## API Endpoints to Update

### Authentication Endpoints
- `POST /api/auth/forgot-password` - Send password reset email
- `POST /api/auth/reset-password` - Reset password with token
- `POST /api/auth/change-password` - Change password (authenticated)
- `POST /api/auth/register/patient` - Patient self-registration
- `POST /api/auth/register/hospital` - Hospital registration (requires approval)
- `POST /api/auth/register/doctor` - Doctor registration (requires approval)

### Approval Endpoints
- `GET /api/approvals/pending` - Get pending approvals for user
- `POST /api/approvals/{requestId}/approve` - Approve a request
- `POST /api/approvals/{requestId}/reject` - Reject a request
- `GET /api/approvals/history` - Get approval history

### Notification Endpoints
- `GET /api/notifications` - Get user notifications
- `POST /api/notifications/mark-read/{notificationId}` - Mark as read
- `POST /api/notifications/mark-all-read` - Mark all as read
- `DELETE /api/notifications/{notificationId}` - Delete notification
- `POST /api/notifications/send` - Send notification (admin)

## Security Considerations

1. **Password Security**
   - Use bcrypt or Argon2 for password hashing
   - Implement salt rounds ≥ 12
   - Store salt separately from hash

2. **Token Security**
   - Use cryptographically secure random tokens
   - Implement short expiry times (15 minutes for reset tokens)
   - Hash tokens before storage

3. **Access Control**
   - Implement role-based access control (RBAC)
   - Validate user permissions on every request
   - Log all sensitive operations

4. **Data Encryption**
   - Encrypt sensitive fields (Aadhaar numbers)
   - Use AES-256 encryption
   - Implement field-level encryption

5. **Rate Limiting**
   - Implement rate limiting for authentication endpoints
   - Use exponential backoff for failed attempts
   - Monitor for suspicious activity

## Backup and Recovery

1. **Daily Backups**
   - Automated daily database backups
   - Point-in-time recovery capability
   - Cross-region backup storage

2. **Data Retention**
   - Audit logs: 1 year
   - Notifications: 90 days
   - Sessions: 30 days
   - Password reset tokens: 24 hours

This schema update provides a robust foundation for all the requested features while maintaining security, performance, and scalability.
