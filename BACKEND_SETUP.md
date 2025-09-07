# 🏥 MyHealth DHRMS Backend Setup Guide

## 📋 Prerequisites

### 1. **Java Development Kit (JDK) 17+**
- Download from: https://adoptium.net/
- Verify installation: `java -version`

### 2. **Apache Maven 3.6+**
- Download from: https://maven.apache.org/download.cgi
- Verify installation: `mvn -version`

### 3. **MongoDB Community Server**
- Download from: https://www.mongodb.com/try/download/community
- MongoDB Compass should already be installed

### 4. **MongoDB Configuration**
- **Database Name**: `myhealth`
- **Username**: `naresh`
- **Password**: `123456789`
- **Host**: `localhost`
- **Port**: `27017`

## 🚀 Quick Start

### Step 1: Verify MongoDB Connection
1. Open MongoDB Compass
2. Connect to your `myhealth` database
3. Ensure the connection with username `naresh` and password `123456789` works

### Step 2: Start the Backend
```bash
# Option 1: Use the startup script (Windows)
double-click start-backend.bat

# Option 2: Use the startup script (Linux/Mac)
chmod +x start-backend.sh
./start-backend.sh

# Option 3: Manual startup
cd backend
mvn clean install
mvn spring-boot:run
```

### Step 3: Verify Backend is Running
Open your browser and visit:

- **Health Check**: http://localhost:8080/api/test/health
- **Database Connection Test**: http://localhost:8080/api/test/db-connection
- **Create Collections**: http://localhost:8080/api/test/create-collections

## 🧪 Testing the Setup

### 1. **Health Check**
```bash
curl http://localhost:8080/api/test/health
```

Expected Response:
```json
{
  "status": "UP",
  "service": "MyHealth DHRMS Backend",
  "timestamp": "2024-01-20T10:30:00",
  "database": "myhealth"
}
```

### 2. **Database Connection Test**
```bash
curl http://localhost:8080/api/test/db-connection
```

Expected Response:
```json
{
  "status": "SUCCESS",
  "message": "MongoDB connection established successfully!",
  "database": "myhealth",
  "timestamp": "2024-01-20T10:30:00",
  "collections": [],
  "testDocument": {
    "_id": "...",
    "testMessage": "Database connection successful!",
    "timestamp": "2024-01-20T10:30:00",
    "database": "myhealth",
    "user": "naresh"
  }
}
```

### 3. **Create Database Collections**
```bash
curl -X POST http://localhost:8080/api/test/create-collections
```

Expected Response:
```json
{
  "status": "SUCCESS",
  "message": "All collections created successfully!",
  "collections": [
    "users",
    "patients", 
    "doctors",
    "hospitals",
    "prescriptions",
    "medical_records",
    "health_vitals",
    "appointments",
    "emergency_contacts",
    "audit_logs"
  ],
  "timestamp": "2024-01-20T10:30:00"
}
```

## 🗄️ Database Schema Overview

The following collections will be created for DHRMS:

- **users**: User authentication and basic info
- **patients**: Patient profiles and demographics
- **doctors**: Doctor profiles and credentials
- **hospitals**: Hospital information and management
- **prescriptions**: Digital prescriptions and medications
- **medical_records**: Patient medical history and records
- **health_vitals**: Real-time health monitoring data
- **appointments**: Appointment scheduling and management
- **emergency_contacts**: Emergency contact information
- **audit_logs**: System audit trail and security logs

## 🔧 Configuration

### MongoDB Connection String
```
mongodb://naresh:123456789@localhost:27017/myhealth?authSource=admin
```

### Application Properties
Located in: `backend/src/main/resources/application.properties`

Key configurations:
- Server port: 8080
- API context path: /api
- JWT secret key for authentication
- CORS configuration for frontend integration

## 🚨 Troubleshooting

### Common Issues:

1. **MongoDB Connection Failed**
   - Verify MongoDB service is running
   - Check username/password in MongoDB Compass
   - Ensure the `myhealth` database exists

2. **Port 8080 Already in Use**
   - Change port in `application.properties`: `server.port=8081`
   - Or kill the process using port 8080

3. **Maven Dependencies Not Resolved**
   - Run: `mvn clean install -U`
   - Check internet connection for dependency downloads

4. **Java Version Issues**
   - Ensure Java 17+ is installed and set as JAVA_HOME
   - Check: `java -version` and `mvn -version`

## 📊 API Endpoints

### Test Endpoints
- `GET /api/test/health` - Health check
- `GET /api/test/db-connection` - Database connection test
- `POST /api/test/create-collections` - Create initial collections

### Production Endpoints (To be implemented)
- `/api/auth/*` - Authentication endpoints
- `/api/users/*` - User management
- `/api/patients/*` - Patient management
- `/api/doctors/*` - Doctor management
- `/api/hospitals/*` - Hospital management
- `/api/prescriptions/*` - Prescription management
- `/api/medical-records/*` - Medical records
- `/api/appointments/*` - Appointment management

## 🎯 Next Steps

1. **Test the database connection** using the endpoints above
2. **Verify all collections are created** successfully
3. **Implement authentication module** (Users, Login, JWT)
4. **Create patient management APIs** step by step
5. **Add doctor and hospital management** modules
6. **Implement prescription system** integration

## ✅ Success Criteria

The setup is successful when:
- ✅ Backend starts without errors
- ✅ Health check returns "UP" status
- ✅ Database connection test returns "SUCCESS"
- ✅ All 10 collections are created in MongoDB
- ✅ Test document is inserted and retrieved successfully

Once all these criteria are met, we can proceed with implementing the full backend modules step by step.
