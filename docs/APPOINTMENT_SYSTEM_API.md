# 📅 DHRMS Appointment System API Documentation

## Overview
The DHRMS Appointment System provides comprehensive appointment booking and management functionality for patients and healthcare providers.

## Base URL
```
http://localhost:3000/api
```

## 🏥 Hospital Endpoints

### Get All Hospitals
Retrieve list of all active hospitals for appointment booking.

```http
GET /hospital/list
```

**Response:**
```json
[
  {
    "_id": "hospital_id",
    "hospitalId": "HOSP001",
    "name": "City General Hospital",
    "address": "123 Health Street",
    "contactNumber": "+1234567890",
    "email": "contact@hospital.com",
    "isActive": true
  }
]
```

## 👨‍⚕️ Doctor Endpoints

### Get Doctors by Hospital
Retrieve all active doctors for a specific hospital.

```http
GET /appointments/hospitals/{hospitalId}/doctors
```

**Parameters:**
- `hospitalId` (path): Hospital ID

**Response:**
```json
[
  {
    "_id": "doctor_id",
    "doctorId": "DOC001", 
    "doctorName": "Dr. John Smith",
    "specialization": "Cardiology",
    "department": "Cardiology",
    "designation": "Senior Consultant",
    "experienceYears": 15,
    "consultationFee": 500,
    "availableTimings": "9:00 AM - 5:00 PM",
    "isActive": true
  }
]
```

## 📅 Appointment Endpoints

### Create Appointment
Book a new appointment for a patient.

```http
POST /appointments
```

**Request Body:**
```json
{
  "appointmentId": "APT1234567890",
  "patientId": "patient_id",
  "patientName": "John Doe",
  "patientUhid": "UHID001",
  "patientGender": "Male",
  "patientAge": 30,
  "patientState": "California",
  "doctorId": "doctor_id",
  "doctorName": "Dr. Smith",
  "hospitalId": "hospital_id", 
  "hospitalName": "City Hospital",
  "appointmentDate": "2024-01-15",
  "appointmentTime": "10:00 AM",
  "reason": "Regular checkup",
  "consultationFee": 500
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Appointment booked successfully",
  "data": {
    "appointmentId": "APT1234567890",
    "status": "pending",
    "bookedAt": "2024-01-10T10:30:00.000Z",
    // ... other appointment data
  }
}
```

### Get Doctor's Appointments
Retrieve all appointments for a specific doctor.

```http
GET /appointments/doctor/{doctorId}
```

**Parameters:**
- `doctorId` (path): Doctor ID

**Response:**
```json
[
  {
    "appointmentId": "APT1234567890",
    "patientName": "John Doe",
    "patientUhid": "UHID001",
    "appointmentDate": "2024-01-15", 
    "appointmentTime": "10:00 AM",
    "status": "pending",
    "reason": "Regular checkup",
    "consultationFee": 500,
    "bookedAt": "2024-01-10T10:30:00.000Z"
  }
]
```

### Get Patient's Appointments  
Retrieve all appointments for a specific patient.

```http
GET /appointments/patient/{patientId}
```

**Parameters:**
- `patientId` (path): Patient ID

**Response:**
```json
[
  {
    "appointmentId": "APT1234567890",
    "doctorName": "Dr. Smith",
    "hospitalName": "City Hospital", 
    "appointmentDate": "2024-01-15",
    "appointmentTime": "10:00 AM",
    "status": "approved",
    "reason": "Regular checkup",
    "consultationFee": 500
  }
]
```

### Update Appointment Status
Update the status of an existing appointment.

```http
PUT /appointments/{appointmentId}/status
```

**Parameters:**
- `appointmentId` (path): Appointment ID

**Request Body:**
```json
{
  "status": "approved"
}
```

**Valid Status Values:**
- `pending` - Initial status when appointment is booked
- `approved` - Doctor has approved the appointment  
- `rejected` - Doctor has rejected the appointment
- `completed` - Appointment has been completed

**Response (200):**
```json
{
  "success": true,
  "message": "Appointment status updated successfully",
  "data": {
    "appointmentId": "APT1234567890",
    "status": "approved",
    "updatedAt": "2024-01-10T11:00:00.000Z"
  }
}
```

### Get Specific Appointment
Retrieve details of a specific appointment.

```http
GET /appointments/{appointmentId}
```

**Parameters:**
- `appointmentId` (path): Appointment ID

**Response:**
```json
{
  "success": true,
  "data": {
    "appointmentId": "APT1234567890",
    "patientName": "John Doe",
    "doctorName": "Dr. Smith",
    "hospitalName": "City Hospital",
    "appointmentDate": "2024-01-15",
    "appointmentTime": "10:00 AM", 
    "status": "pending",
    "reason": "Regular checkup",
    "consultationFee": 500,
    "bookedAt": "2024-01-10T10:30:00.000Z"
  }
}
```

## 🔒 Authentication
Some endpoints require authentication. Include the Bearer token in the Authorization header:

```http
Authorization: Bearer <token>
```

## 📋 Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Missing required field: patientName"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Appointment not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Server error while creating appointment",
  "error": "Database connection failed"
}
```

## 🧪 Testing
Use the provided test scripts to verify the appointment system:

### Backend Test
```bash
# Start backend server
cd backend
npm start

# In another terminal, run tests
node test-appointment-api.js
```

### Windows Batch Test
```bash
cd backend
test-appointment-system.bat
```

## 📱 Frontend Integration

### Patient Appointment Booking
- **Screen**: `patient_appointment_booking_screen.dart`
- **Flow**: Hospital Selection → Doctor Selection → Date/Time → Booking Confirmation

### Doctor Appointment Management  
- **Screen**: `hospital_doctor_appointment_screen.dart`
- **Features**: View appointments, Approve/Reject, Mark Complete, Search & Filter

### Hospital Staff Dashboard
- **Screen**: `hospital_staff_dashboard.dart` 
- **Features**: Tabbed interface with Dashboard, Appointments, and Patients tabs

## 🗄️ Database Schema
The appointment data is stored using the `HospitalAppointment` model with the following structure:

```javascript
{
  appointmentId: String,        // Unique appointment identifier
  patientId: String,           // Reference to patient
  patientName: String,         // Patient's full name
  patientUhid: String,         // Patient's UHID
  patientGender: String,       // Patient's gender
  patientAge: Number,          // Patient's age
  patientState: String,        // Patient's state
  doctorId: String,           // Reference to doctor
  doctorName: String,         // Doctor's name
  hospitalId: String,         // Reference to hospital
  hospitalName: String,       // Hospital name
  appointmentDate: String,    // Date (YYYY-MM-DD)
  appointmentTime: String,    // Time (HH:MM AM/PM)
  reason: String,             // Appointment reason
  consultationFee: Number,    // Fee amount
  status: String,             // pending/approved/rejected/completed
  bookedAt: Date,             // Booking timestamp
  updatedAt: Date             // Last update timestamp
}
```

## 🚀 Usage Examples

### Booking Workflow
1. Patient opens booking screen
2. Selects hospital from list
3. Views available doctors with filters (specialization, fee range, name search)
4. Selects doctor and appointment slot
5. Provides reason and confirms booking
6. Receives appointment ID confirmation

### Doctor Management Workflow  
1. Doctor logs into dashboard
2. Views appointments tab with date-wise listing
3. Sees patient details and appointment info
4. Approves/rejects pending appointments
5. Marks completed appointments as done
6. Uses search/filter to find specific appointments

This comprehensive appointment system provides seamless integration between patient booking and doctor management workflows with robust API endpoints and proper error handling.