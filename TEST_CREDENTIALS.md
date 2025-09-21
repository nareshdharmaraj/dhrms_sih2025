# DHRMS Test Credentials

## Hospital: Apollo Hospital Bangalore
- **Hospital ID:** HOSP-KA-BLR-001
- **Location:** Bangalore, Karnataka
- **Type:** Multi-Specialty Corporate Hospital

## Hospital Admin
- **Name:** Priya Sharma
- **Username:** priya.admin
- **Password:** admin123
- **Email:** priya.sharma@apollohospitals.com
- **Admin ID:** ADMIN-HOSP-KA-BLR-001-001

## Doctor
- **Name:** Dr. Arun Patel
- **Username:** arun.doctor
- **Password:** doctor123
- **Specialization:** Cardiology
- **Email:** arun.patel@apollohospitals.com
- **Doctor ID:** DOC-HOSP-KA-BLR-001-001
- **Registration Number:** KMC67890

## Hospital Assistant/Nurse
- **Name:** Sunita Rao
- **Username:** sunita.assistant
- **Password:** assistant123
- **Department:** Cardiology
- **Email:** sunita.rao@apollohospitals.com
- **Assistant ID:** ASST-HOSP-KA-BLR-001-001

## Regional Officer (Reference)
- **Name:** Dr. Rajesh Kumar
- **Username:** rajesh.kumar
- **Employee ID:** EMP-RO-2024-001
- **Region:** South Zone (Karnataka)
- **Email:** rajesh.kumar@health.gov.in

## Backend Server Status
- **Status:** ✅ Running on port 3000
- **Database:** ✅ Connected to MongoDB Atlas
- **API Endpoints:** ✅ All routes working
- **Test Data:** ✅ Successfully created in database

## Usage Instructions
1. Click "Hospital Staff" from main role selection
2. Choose your role: Admin, Doctor, or Assistant  
3. Use the credentials above to login
4. Backend server should be running at: http://localhost:3000

## Notes
- All passwords in the backend are properly hashed with bcrypt
- For testing, you can use the plain text passwords above
- The backend automatically validates and authenticates users
- Database contains complete hospital, admin, doctor, and assistant records