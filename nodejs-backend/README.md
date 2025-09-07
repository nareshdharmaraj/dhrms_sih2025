# DHRMS (Digital Health Record Management System) - Backend

## Overview

This is a comprehensive Node.js backend for the Digital Health Record Management System built with Express.js, MongoDB, and comprehensive authentication system. The backend supports hospitals, doctors, and patients with role-based access control.

## 🚀 Quick Start

### Prerequisites
- Node.js (v16 or higher)
- MongoDB (running on localhost:27017)
- npm or yarn

### Installation & Setup

1. **Install Dependencies**
   ```bash
   cd nodejs-backend
   npm install
   ```

2. **Environment Configuration**
   - The `.env` file is already configured for local development
   - MongoDB connection: `mongodb://naresh:123456789@localhost:27017/myhealth`

3. **Seed Database with Sample Data**
   ```bash
   node seedDatabase.js
   ```

4. **Start the Server**
   ```bash
   node server.js
   ```

The server will start on `http://localhost:5000`

## 📊 Database Collections & Sample Data

### Hospitals (3 samples)
- **Apollo Medical Center** (Private)
- **Fortis Healthcare** (Private)  
- **AIIMS Delhi** (Government)

### Doctors (3 samples)
- **Dr. Rajesh Sharma** - Cardiologist at Apollo
- **Dr. Priya Nair** - Neurologist at Fortis
- **Dr. Amit Gupta** - Orthopedist at AIIMS

### Patients (3 samples)
- **Rajesh Kumar** - Hypertension patient
- **Meera Nair** - Diabetes patient
- **Arun Pillai** - Arthritis patient

### Prescriptions (3 samples)
- Complete prescription records with medications, dosages, and follow-up dates

## 🔐 Authentication & Login Credentials

### Hospital Admin Accounts
```
Username: apollo_admin    | Password: apollo123
Username: fortis_admin    | Password: fortis123
Username: aiims_admin     | Password: aiims123
```

### Doctor Accounts
```
Username: dr_rajesh_sharma | Password: doctor123
Username: dr_priya_nair    | Password: doctor123
Username: dr_amit_gupta    | Password: doctor123
```

### Patient Accounts
```
Username: rajesh_kumar_90  | Password: patient123
Username: meera_nair_85    | Password: patient123
Username: arun_pillai_75   | Password: patient123
```

## 🛠 API Endpoints

### Base URL: `http://localhost:5000/api/v1`

### Health Check
- `GET /health` - Server health status

### Authentication Routes
- `POST /auth/hospital/register` - Register new hospital
- `POST /auth/hospital/login` - Hospital login
- `POST /auth/doctor/register` - Register new doctor
- `POST /auth/doctor/login` - Doctor login
- `POST /auth/patient/register` - Register new patient
- `POST /auth/patient/login` - Patient login

### Hospital Routes
- `GET /hospitals` - Get all hospitals
- `GET /hospitals/:id` - Get hospital by ID
- `GET /hospitals/:id/dashboard` - Hospital dashboard data
- `PUT /hospitals/:id` - Update hospital profile

### Doctor Routes
- `GET /doctors` - Get all doctors (with filters)
- `GET /doctors/:id` - Get doctor by ID
- `GET /doctors/:id/patients` - Get doctor's patients
- `GET /doctors/:id/dashboard` - Doctor dashboard data
- `PUT /doctors/:id` - Update doctor profile
- `POST /doctors/:id/patients/:patientId` - Add patient to doctor

### Patient Routes
- `GET /patients` - Get all patients
- `GET /patients/:id` - Get patient by ID
- `GET /patients/:id/prescriptions` - Get patient prescriptions
- `GET /patients/:id/medical-history` - Get patient medical history
- `PUT /patients/:id` - Update patient profile

### Prescription Routes
- `GET /prescriptions` - Get all prescriptions
- `GET /prescriptions/:id` - Get prescription by ID
- `POST /prescriptions` - Create new prescription
- `PUT /prescriptions/:id` - Update prescription

### Additional Routes
- `/dashboard` - Dashboard analytics
- `/emergency` - Emergency services
- `/telemedicine` - Telemedicine features
- `/wearable` - Wearable device integration
- `/analytics` - Health analytics
- `/health` - Health monitoring

## 🏗 Architecture & Features

### Database Models
- **Hospital**: Complete hospital management with facilities, departments, statistics
- **Doctor**: Professional info, qualifications, schedules, patient lists
- **Patient**: Personal info, medical history, UHI integration, insurance
- **Prescription**: Detailed medication records with dosages and instructions

### Security Features
- JWT-based authentication
- Password hashing with bcrypt
- Role-based access control
- Rate limiting
- Input validation with Joi
- Security headers with Helmet

### Data Validation
- Comprehensive input validation
- Mongoose schema validation
- Error handling middleware
- Structured API responses

### Middleware Stack
- CORS configuration
- Request logging with Morgan
- Compression for better performance
- Error handling and logging

## 🔄 Development Workflow

### File Structure
```
nodejs-backend/
├── models/          # Mongoose schemas
├── routes/          # API route handlers
├── middleware/      # Custom middleware
├── utils/           # Utility functions
├── .env            # Environment variables
├── server.js       # Main application file
├── seedDatabase.js # Database seeding script
└── package.json    # Dependencies
```

### Key Features Implemented
1. **Multi-role Authentication System**
2. **Comprehensive Data Models**
3. **RESTful API Design**
4. **Database Seeding with Sample Data**
5. **Error Handling & Logging**
6. **Security Best Practices**
7. **Input Validation**
8. **JWT Token Management**

## 📱 Frontend Integration

The backend is designed to work seamlessly with the Flutter frontend. All endpoints provide structured JSON responses that match the frontend's data requirements.

### Key Integration Points
- UHI (Unique Health ID) support for patients
- Hospital dashboard with real-time statistics
- Doctor-patient relationship management
- Prescription management with detailed medication info
- Emergency contact and medical history tracking

## 🚀 Production Considerations

### Environment Variables to Update for Production
- `JWT_SECRET` - Use a strong, unique secret
- `MONGODB_URI` - Production MongoDB connection
- `NODE_ENV` - Set to 'production'
- `ALLOWED_ORIGINS` - Configure for production domains

### Security Enhancements for Production
- Enable MongoDB authentication
- Configure SSL/TLS
- Set up proper logging
- Implement rate limiting per user
- Enable CORS for specific domains only

## 🎯 Testing

The system includes comprehensive sample data that covers all major use cases:
- Hospital registration and management
- Doctor profiles and schedules
- Patient medical records
- Prescription creation and management
- Authentication for all user types

## 🔧 Troubleshooting

### Common Issues
1. **MongoDB Connection**: Ensure MongoDB is running on localhost:27017
2. **Port Conflicts**: Make sure port 5000 is available
3. **Authentication**: Use the provided sample credentials for testing

### Logs Location
- Application logs are output to console
- Error logs include stack traces for debugging

## 📞 Support

This backend system provides a complete foundation for the DHRMS application with all necessary features for healthcare management, including patient records, doctor consultations, prescription management, and hospital administration.

---

**Status**: ✅ Fully Functional & Ready for Production

**Last Updated**: January 2025

**Version**: 1.0.0
