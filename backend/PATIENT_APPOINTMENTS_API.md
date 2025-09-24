# Patient Appointment Management API Documentation

## Base URL
```
/api/patient-appointments
```

## Endpoints

### 1. Get Patient Appointments (with filtering)
**GET** `/api/patient-appointments/:patientId`

Fetches all appointments for a specific patient with optional filtering and pagination.

#### Parameters:
- `patientId` (path): Patient ID

#### Query Parameters (all optional):
- `doctorName`: Filter by doctor name (case-insensitive, partial match)
- `appointmentId`: Filter by appointment ID (case-insensitive, partial match)
- `appointmentDate`: Filter by exact date (DD/MM/YYYY format)
- `appointmentTime`: Filter by time (case-insensitive, partial match)
- `status`: Filter by status (`pending`, `approved`, `rejected`, `completed`)
- `hospitalName`: Filter by hospital name (case-insensitive, partial match)
- `page`: Page number for pagination (default: 1)
- `limit`: Number of items per page (default: 10)

#### Example Request:
```bash
GET /api/patient-appointments/NARE523407?doctorName=John&status=pending&page=1&limit=5
```

#### Response:
```json
{
  "success": true,
  "count": 2,
  "totalCount": 5,
  "currentPage": 1,
  "totalPages": 1,
  "data": [
    {
      "_id": "...",
      "appointmentId": "APT_1758633778835_21w6sx9jz",
      "patientId": "NARE523407",
      "patientName": "NARESHD NARESHD",
      "doctorName": "Dr. John Smith",
      "hospitalName": "Apollo Main Hospital",
      "appointmentDate": "25/9/2025",
      "appointmentTime": "02:00 PM",
      "reason": "heart attack",
      "consultationFee": 100,
      "status": "pending",
      "bookedAt": "2025-09-23T13:22:58.838Z"
    }
  ]
}
```

---

### 2. View Appointment Details
**GET** `/api/patient-appointments/view/:appointmentId`

Gets detailed information for a specific appointment.

#### Parameters:
- `appointmentId` (path): Appointment ID

#### Example Request:
```bash
GET /api/patient-appointments/view/APT_1758633778835_21w6sx9jz
```

#### Response:
```json
{
  "success": true,
  "data": {
    "_id": "...",
    "appointmentId": "APT_1758633778835_21w6sx9jz",
    "patientId": "NARE523407",
    "patientName": "NARESHD NARESHD",
    "patientUhid": "NARE523407",
    "patientGender": "male",
    "patientAge": 25,
    "hospitalStaffId": "H001QWER",
    "doctorName": "qwerty",
    "hospitalId": "HOSP-001",
    "hospitalName": "Apollo Main Hospital",
    "appointmentDate": "25/9/2025",
    "appointmentTime": "02:00 PM",
    "reason": "heart attack",
    "consultationFee": 100,
    "status": "pending",
    "bookedAt": "2025-09-23T13:22:58.838Z",
    "updatedAt": "2025-09-23T13:22:58.841Z"
  }
}
```

---

### 3. Edit Appointment
**PUT** `/api/patient-appointments/edit/:appointmentId`

Edits an appointment with business rule validation.

#### Business Rules:
- Can only edit within 2 hours of booking time
- Can only edit before doctor approval (status must be `pending` or `rejected`)
- Cannot edit if status is `approved` or `completed`

#### Parameters:
- `appointmentId` (path): Appointment ID

#### Request Body (all fields optional):
```json
{
  "appointmentDate": "26/9/2025",
  "appointmentTime": "3:00 PM",
  "reason": "Updated consultation reason"
}
```

#### Example Request:
```bash
PUT /api/patient-appointments/edit/APT_1758633778835_21w6sx9jz
Content-Type: application/json

{
  "appointmentTime": "4:00 PM",
  "reason": "Emergency consultation"
}
```

#### Success Response:
```json
{
  "success": true,
  "message": "Appointment updated successfully",
  "data": {
    // Updated appointment object
  }
}
```

#### Error Responses:
```json
// Time limit exceeded
{
  "success": false,
  "message": "Appointment can only be edited within 2 hours of booking",
  "bookingTime": "2025-09-23T13:22:58.838Z",
  "timeRemaining": 0
}

// Already approved/completed
{
  "success": false,
  "message": "Cannot edit appointment after doctor approval or completion"
}
```

---

### 4. Delete Appointment
**DELETE** `/api/patient-appointments/delete/:appointmentId`

Deletes an appointment with business rule validation.

#### Business Rules:
- Can delete anytime before doctor visit/completion
- Cannot delete if status is `completed` (after doctor treatment)

#### Parameters:
- `appointmentId` (path): Appointment ID

#### Example Request:
```bash
DELETE /api/patient-appointments/delete/APT_1758633778835_21w6sx9jz
```

#### Success Response:
```json
{
  "success": true,
  "message": "Appointment deleted successfully",
  "deletedAppointment": {
    "appointmentId": "APT_1758633778835_21w6sx9jz",
    "patientName": "NARESHD NARESHD",
    "doctorName": "qwerty",
    "appointmentDate": "25/9/2025",
    "appointmentTime": "02:00 PM"
  }
}
```

#### Error Response:
```json
{
  "success": false,
  "message": "Cannot delete appointment after doctor visit and treatment"
}
```

---

### 5. Get Appointment Statistics
**GET** `/api/patient-appointments/stats/:patientId`

Gets appointment count statistics for a patient grouped by status.

#### Parameters:
- `patientId` (path): Patient ID

#### Example Request:
```bash
GET /api/patient-appointments/stats/NARE523407
```

#### Response:
```json
{
  "success": true,
  "data": {
    "total": 5,
    "pending": 2,
    "approved": 1,
    "rejected": 0,
    "completed": 2
  }
}
```

---

## Status Values
- `pending`: Appointment booked, waiting for doctor approval
- `approved`: Doctor approved the appointment
- `rejected`: Doctor rejected the appointment
- `completed`: Patient visited doctor and treatment completed

## Error Handling
All endpoints return consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Technical error details (in development mode)"
}
```

## Common HTTP Status Codes
- `200`: Success
- `400`: Bad Request (validation errors)
- `403`: Forbidden (business rule violation)
- `404`: Not Found (appointment not found)
- `500`: Internal Server Error

## Usage Examples

### Filter appointments by multiple criteria:
```bash
GET /api/patient-appointments/NARE523407?doctorName=Smith&status=pending&hospitalName=Apollo&page=1&limit=5
```

### Get appointments for a specific date:
```bash
GET /api/patient-appointments/NARE523407?appointmentDate=25/9/2025
```

### Get recent appointments (sorted by booking time):
```bash
GET /api/patient-appointments/NARE523407?limit=10
```