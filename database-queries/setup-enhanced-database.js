// Database Setup Script for DHRMS Feature Implementation
// Run this script in MongoDB to create the enhanced database structure

// Switch to DHRMS database
use dhrms;

// Drop existing collections if they exist (for fresh setup)
// WARNING: Uncomment only for development environment
// db.approvalRequests.drop();
// db.notifications.drop();
// db.passwordResetTokens.drop();
// db.auditLogs.drop();
// db.userSessions.drop();

print("Creating DHRMS Database Collections...");

// 1. Create Approval Requests Collection
db.createCollection("approvalRequests", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["requestId", "requestType", "requesterId", "currentStatus"],
      properties: {
        requestId: {
          bsonType: "string",
          description: "Unique request identifier"
        },
        requestType: {
          enum: ["hospital_registration", "doctor_registration"],
          description: "Type of approval request"
        },
        requesterId: {
          bsonType: "objectId",
          description: "User ID of the requester"
        },
        currentStatus: {
          enum: ["pending", "approved", "rejected"],
          description: "Current status of the request"
        },
        priority: {
          enum: ["low", "normal", "high", "urgent"],
          description: "Priority level of the request"
        }
      }
    }
  }
});

print("✓ Approval Requests collection created");

// 2. Create Notifications Collection
db.createCollection("notifications", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["notificationId", "recipientId", "title", "message", "type", "priority"],
      properties: {
        notificationId: {
          bsonType: "string",
          description: "Unique notification identifier"
        },
        recipientId: {
          bsonType: "objectId",
          description: "User ID of notification recipient"
        },
        title: {
          bsonType: "string",
          minLength: 1,
          maxLength: 200,
          description: "Notification title"
        },
        message: {
          bsonType: "string",
          minLength: 1,
          maxLength: 1000,
          description: "Notification message"
        },
        type: {
          enum: ["general", "approval", "rejection", "reminder", "alert", "system", "appointment", "medication", "emergency"],
          description: "Type of notification"
        },
        priority: {
          enum: ["low", "normal", "high", "critical"],
          description: "Priority level"
        },
        isRead: {
          bsonType: "bool",
          description: "Whether notification has been read"
        }
      }
    }
  }
});

print("✓ Notifications collection created");

// 3. Create Password Reset Tokens Collection
db.createCollection("passwordResetTokens", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "token", "tokenHash", "expiresAt"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "User ID for password reset"
        },
        token: {
          bsonType: "string",
          minLength: 32,
          description: "Password reset token"
        },
        tokenHash: {
          bsonType: "string",
          description: "Hashed version of token"
        },
        isUsed: {
          bsonType: "bool",
          description: "Whether token has been used"
        },
        expiresAt: {
          bsonType: "date",
          description: "Token expiry time"
        }
      }
    }
  }
});

print("✓ Password Reset Tokens collection created");

// 4. Create Audit Logs Collection
db.createCollection("auditLogs", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "action", "timestamp"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "User who performed the action"
        },
        action: {
          bsonType: "string",
          description: "Action performed"
        },
        resource: {
          bsonType: "string",
          description: "Resource affected"
        },
        success: {
          bsonType: "bool",
          description: "Whether action was successful"
        },
        timestamp: {
          bsonType: "date",
          description: "When action occurred"
        }
      }
    }
  }
});

print("✓ Audit Logs collection created");

// 5. Create User Sessions Collection
db.createCollection("userSessions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["sessionId", "userId", "isActive"],
      properties: {
        sessionId: {
          bsonType: "string",
          description: "Unique session identifier"
        },
        userId: {
          bsonType: "objectId",
          description: "User ID for the session"
        },
        isActive: {
          bsonType: "bool",
          description: "Whether session is active"
        },
        loginTime: {
          bsonType: "date",
          description: "Session start time"
        },
        expiresAt: {
          bsonType: "date",
          description: "Session expiry time"
        }
      }
    }
  }
});

print("✓ User Sessions collection created");

print("\nCreating Indexes...");

// Create indexes for Users collection (enhanced)
db.users.createIndex({ "email": 1 }, { unique: true, name: "email_unique" });
db.users.createIndex({ "userId": 1 }, { unique: true, sparse: true, name: "userId_unique" });
db.users.createIndex({ "role": 1, "status": 1 }, { name: "role_status" });
db.users.createIndex({ "patientData.aadhaarNumber": 1 }, { sparse: true, name: "aadhaar_lookup" });
db.users.createIndex({ "hospitalData.registrationNumber": 1 }, { sparse: true, name: "hospital_reg" });
db.users.createIndex({ "doctorData.medicalLicenseNumber": 1 }, { sparse: true, name: "doctor_license" });
db.users.createIndex({ "lastLogin": 1 }, { name: "last_login" });
db.users.createIndex({ "createdAt": 1 }, { name: "created_date" });

print("✓ Users collection indexes created");

// Create indexes for Approval Requests
db.approvalRequests.createIndex({ "requestId": 1 }, { unique: true, name: "requestId_unique" });
db.approvalRequests.createIndex({ "requesterId": 1 }, { name: "requester_lookup" });
db.approvalRequests.createIndex({ "currentStatus": 1, "currentApprover": 1 }, { name: "status_approver" });
db.approvalRequests.createIndex({ "requestType": 1, "currentStatus": 1 }, { name: "type_status" });
db.approvalRequests.createIndex({ "submittedAt": 1 }, { name: "submitted_date" });

print("✓ Approval Requests indexes created");

// Create indexes for Notifications
db.notifications.createIndex({ "notificationId": 1 }, { unique: true, name: "notificationId_unique" });
db.notifications.createIndex({ "recipientId": 1, "isRead": 1, "createdAt": -1 }, { name: "recipient_read_date" });
db.notifications.createIndex({ "type": 1, "priority": 1 }, { name: "type_priority" });
db.notifications.createIndex({ "createdAt": 1 }, { expireAfterSeconds: 7776000, name: "ttl_90days" }); // 90 days
db.notifications.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0, name: "custom_expiry" });

print("✓ Notifications indexes created");

// Create indexes for Password Reset Tokens
db.passwordResetTokens.createIndex({ "userId": 1 }, { name: "user_lookup" });
db.passwordResetTokens.createIndex({ "token": 1 }, { unique: true, name: "token_unique" });
db.passwordResetTokens.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0, name: "token_expiry" });
db.passwordResetTokens.createIndex({ "createdAt": 1 }, { expireAfterSeconds: 86400, name: "ttl_24hours" }); // 24 hours

print("✓ Password Reset Tokens indexes created");

// Create indexes for Audit Logs
db.auditLogs.createIndex({ "userId": 1, "timestamp": -1 }, { name: "user_timeline" });
db.auditLogs.createIndex({ "action": 1, "timestamp": -1 }, { name: "action_timeline" });
db.auditLogs.createIndex({ "resourceId": 1 }, { name: "resource_lookup" });
db.auditLogs.createIndex({ "timestamp": 1 }, { expireAfterSeconds: 31536000, name: "ttl_1year" }); // 1 year

print("✓ Audit Logs indexes created");

// Create indexes for User Sessions
db.userSessions.createIndex({ "sessionId": 1 }, { unique: true, name: "sessionId_unique" });
db.userSessions.createIndex({ "userId": 1, "isActive": 1 }, { name: "user_active_sessions" });
db.userSessions.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0, name: "session_expiry" });
db.userSessions.createIndex({ "lastActivity": 1 }, { name: "activity_tracking" });

print("✓ User Sessions indexes created");

print("\nUpdating existing Users collection...");

// Update existing users with new required fields
db.users.updateMany(
  { status: { $exists: false } },
  {
    $set: {
      status: "active",
      failedLoginAttempts: 0,
      accountLocked: false,
      updatedAt: new Date()
    }
  }
);

print("✓ Existing users updated with new fields");

print("\nInserting sample data...");

// Insert sample approval requests
const sampleApprovalRequests = [
  {
    requestId: "REQ001",
    requestType: "hospital_registration",
    requesterId: new ObjectId(),
    requesterData: {
      hospitalName: "City General Hospital",
      registrationNumber: "HOSP001",
      hospitalType: "General",
      bedCapacity: 150,
      contactPerson: {
        name: "Dr. Admin",
        designation: "Chief Administrator",
        phoneNumber: "+91-9876543210"
      }
    },
    approvalChain: [
      {
        approverId: new ObjectId(),
        approverRole: "regional_officer",
        status: "pending",
        comments: "",
        actionDate: null
      }
    ],
    currentStatus: "pending",
    currentApprover: new ObjectId(),
    submittedAt: new Date(),
    lastUpdated: new Date(),
    priority: "normal"
  },
  {
    requestId: "REQ002",
    requestType: "doctor_registration",
    requesterId: new ObjectId(),
    requesterData: {
      firstName: "Dr. Sarah",
      lastName: "Johnson",
      medicalLicenseNumber: "MED12345",
      specialization: "Cardiology",
      qualifications: ["MBBS", "MD Cardiology"],
      experience: 8
    },
    approvalChain: [
      {
        approverId: new ObjectId(),
        approverRole: "hospital_admin",
        status: "pending",
        comments: "",
        actionDate: null
      }
    ],
    currentStatus: "pending",
    currentApprover: new ObjectId(),
    submittedAt: new Date(),
    lastUpdated: new Date(),
    priority: "normal"
  }
];

db.approvalRequests.insertMany(sampleApprovalRequests);
print("✓ Sample approval requests inserted");

// Insert sample notifications
const sampleNotifications = [
  {
    notificationId: "NOTIF_" + new Date().getTime() + "_001",
    recipientId: new ObjectId(),
    title: "Welcome to DHRMS",
    message: "Your account has been successfully created. You can now access all features of the Digital Health Records Management System.",
    type: "general",
    priority: "normal",
    isRead: false,
    actionRequired: false,
    actionTaken: false,
    createdAt: new Date(),
    delivered: true,
    deliveredAt: new Date(),
    deliveryAttempts: 1,
    metadata: {
      source: "system",
      category: "welcome"
    }
  },
  {
    notificationId: "NOTIF_" + new Date().getTime() + "_002",
    recipientId: new ObjectId(),
    title: "Registration Under Review",
    message: "Your hospital registration is currently under review by the Regional Health Officer. You will be notified once the review is complete.",
    type: "approval",
    priority: "high",
    isRead: false,
    actionRequired: false,
    actionTaken: false,
    createdAt: new Date(),
    delivered: true,
    deliveredAt: new Date(),
    deliveryAttempts: 1,
    metadata: {
      requestId: "REQ001",
      requestType: "hospital_registration"
    }
  },
  {
    notificationId: "NOTIF_" + new Date().getTime() + "_003",
    recipientId: new ObjectId(),
    title: "System Maintenance Notice",
    message: "Scheduled maintenance will be performed tonight from 12:00 AM to 2:00 AM. Some features may be temporarily unavailable.",
    type: "system",
    priority: "normal",
    isRead: false,
    actionRequired: false,
    actionTaken: false,
    createdAt: new Date(),
    scheduledFor: new Date(Date.now() + 24 * 60 * 60 * 1000), // Tomorrow
    delivered: true,
    deliveredAt: new Date(),
    deliveryAttempts: 1,
    metadata: {
      maintenanceWindow: "2024-01-15T00:00:00Z to 2024-01-15T02:00:00Z",
      affectedServices: ["user_registration", "data_sync"]
    }
  }
];

db.notifications.insertMany(sampleNotifications);
print("✓ Sample notifications inserted");

print("\n🎉 Database setup completed successfully!");
print("\nDatabase Collections Created:");
print("- users (enhanced with new fields)");
print("- approvalRequests");
print("- notifications");
print("- passwordResetTokens");
print("- auditLogs");
print("- userSessions");
print("\nIndexes created for optimal performance");
print("Sample data inserted for development and testing");
print("\nNext Steps:");
print("1. Update your backend API to use these new collections");
print("2. Implement the authentication and authorization logic");
print("3. Set up proper backup and monitoring");
print("4. Configure appropriate security measures");

// Display database statistics
print("\nDatabase Statistics:");
print("Total Collections: " + db.getCollectionNames().length);
print("Total Indexes: " + db.stats().indexes);

// Show collection counts
const collections = ["users", "approvalRequests", "notifications", "passwordResetTokens", "auditLogs", "userSessions"];
collections.forEach(function(collectionName) {
  const count = db[collectionName].countDocuments();
  print("- " + collectionName + ": " + count + " documents");
});

print("\n✅ DHRMS Database Setup Complete!");
