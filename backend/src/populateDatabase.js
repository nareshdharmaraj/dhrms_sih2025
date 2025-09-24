const mongoose = require('mongoose');
const Patient = require('./models/Patient');
const HospitalStaff = require('./models/HospitalStaff');
const RegionalOfficer = require('./models/RegionalOfficer');
const MedicalRecord = require('./models/MedicalRecord');
const HospitalAppointment = require('./models/HospitalAppointment');
const HealthStatistics = require('./models/HealthStatistics');

async function populateDatabase() {
  try {
    await mongoose.connect('mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });

    console.log('Connected to MongoDB');

    // Clear existing data
    await Patient.deleteMany({});
    await HospitalStaff.deleteMany({});
    await RegionalOfficer.deleteMany({});
    await MedicalRecord.deleteMany({});
    await HospitalAppointment.deleteMany({});
    await HealthStatistics.deleteMany({});
    
    console.log('Cleared existing data');

    // Create Patients
    const patients = await Patient.insertMany([
      {
        username: 'patient1',
        password: 'pass123',
        fullName: 'Ahmad Rahman',
        email: 'ahmad.rahman@email.com',
        phone: '+971501234567',
        dateOfBirth: new Date('1985-03-15'),
        gender: 'male',
        bloodGroup: 'A+',
        address: {
          street: 'Al Nahda Street',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '12345',
          country: 'UAE'
        },
        emergencyContact: {
          name: 'Fatima Rahman',
          relationship: 'Wife',
          phone: '+971507654321'
        },
        medicalHistory: [
          { condition: 'Diabetes Type 2', diagnosedDate: new Date('2020-05-15'), notes: 'Well controlled with medication' }
        ],
        allergies: ['Penicillin', 'Nuts'],
        currentMedications: [
          { name: 'Metformin', dosage: '500mg', frequency: 'Twice daily' },
          { name: 'Lisinopril', dosage: '10mg', frequency: 'Once daily' }
        ],
        workLocation: 'Dubai Construction Site A',
        employerName: 'Dubai Construction LLC',
        workPermitNumber: 'WP2024001',
        homeState: 'Punjab'
      },
      {
        username: 'patient2',
        password: 'pass123',
        fullName: 'Maria Santos',
        email: 'maria.santos@email.com',
        phone: '+971502345678',
        dateOfBirth: new Date('1992-07-22'),
        gender: 'female',
        bloodGroup: 'O-',
        address: {
          street: 'Jumeirah Beach Road',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '54321',
          country: 'UAE'
        },
        emergencyContact: {
          name: 'Rosa Santos',
          relationship: 'Mother',
          phone: '+971508765432'
        },
        medicalHistory: [],
        allergies: ['Latex'],
        currentMedications: [],
        workLocation: 'Healthcare Plus Hospital',
        employerName: 'Healthcare Plus Hospital',
        workPermitNumber: 'WP2024002',
        homeState: 'Manila'
      },
      {
        username: 'patient3',
        password: 'pass123',
        fullName: 'Rajesh Kumar',
        email: 'rajesh.kumar@email.com',
        phone: '+971503456789',
        dateOfBirth: new Date('1978-11-10'),
        gender: 'male',
        bloodGroup: 'B+',
        address: {
          street: 'Sheikh Mohammed Bin Rashid Boulevard',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '67890',
          country: 'UAE'
        },
        emergencyContact: {
          name: 'Priya Kumar',
          relationship: 'Wife',
          phone: '+971509876543'
        },
        medicalHistory: [
          { condition: 'Hypertension', diagnosedDate: new Date('2018-03-10'), notes: 'Controlled with medication' },
          { condition: 'High Cholesterol', diagnosedDate: new Date('2019-08-22'), notes: 'Diet and medication management' }
        ],
        allergies: ['Aspirin'],
        currentMedications: [
          { name: 'Amlodipine', dosage: '5mg', frequency: 'Once daily' },
          { name: 'Atorvastatin', dosage: '20mg', frequency: 'Once daily' }
        ],
        workLocation: 'Emirates Steel Plant',
        employerName: 'Emirates Steel Industries',
        workPermitNumber: 'WP2024003',
        homeState: 'Karnataka'
      },
      {
        username: 'patient4',
        password: 'pass123',
        fullName: 'Sarah Johnson',
        email: 'sarah.johnson@email.com',
        phone: '+971504567890',
        dateOfBirth: new Date('1988-02-14'),
        gender: 'female',
        bloodGroup: 'AB+',
        address: {
          street: 'The Walk, JBR',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '13579',
          country: 'UAE'
        },
        emergencyContact: {
          name: 'Michael Johnson',
          relationship: 'Husband',
          phone: '+971505678901'
        },
        medicalHistory: [
          { condition: 'Asthma', diagnosedDate: new Date('2010-06-05'), notes: 'Mild intermittent asthma' }
        ],
        allergies: [],
        currentMedications: [
          { name: 'Albuterol Inhaler', dosage: '90mcg', frequency: 'As needed' }
        ],
        workLocation: 'International School Dubai',
        employerName: 'International School Dubai',
        workPermitNumber: 'WP2024004',
        homeState: 'London'
      }
    ]);

    // Create Hospital Staff
    const hospitalStaff = await HospitalStaff.insertMany([
      {
        username: 'doctor1',
        password: 'doc123',
        fullName: 'Dr. Hassan Al-Mahmoud',
        email: 'hassan.mahmoud@hospital.ae',
        phone: '+971506789012',
        dateOfBirth: new Date('1975-05-12'),
        gender: 'male',
        staffRole: 'doctor',
        department: 'Cardiology',
        specialization: 'Cardiology',
        licenseNumber: 'DOH-CAR-2020-001',
        yearsOfExperience: 15,
        hospitalName: 'Dubai Hospital',
        hospitalId: 'DH001',
        hospitalAddress: {
          street: 'Al Khaleej Road',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '11111',
          country: 'UAE'
        },
        workingHours: {
          startTime: '08:00',
          endTime: '16:00',
          workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
        },
        permissions: ['read_patient_records', 'write_patient_records', 'prescribe_medication', 'schedule_appointments'],
        address: {
          street: 'Jumeirah Street 45',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '22222',
          country: 'UAE'
        },
        hireDate: new Date('2020-01-15')
      },
      {
        username: 'nurse1',
        password: 'nurse123',
        fullName: 'Nurse Aisha Mohammed',
        email: 'aisha.mohammed@hospital.ae',
        phone: '+971507890123',
        dateOfBirth: new Date('1990-08-20'),
        gender: 'female',
        staffRole: 'nurse',
        department: 'Emergency',
        licenseNumber: 'DOH-NUR-2021-005',
        yearsOfExperience: 8,
        hospitalName: 'Dubai Hospital',
        hospitalId: 'DH001',
        hospitalAddress: {
          street: 'Al Khaleej Road',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '11111',
          country: 'UAE'
        },
        workingHours: {
          startTime: '07:00',
          endTime: '19:00',
          workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday']
        },
        permissions: ['read_patient_records', 'write_patient_records'],
        address: {
          street: 'Al Nahda Street 12',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '33333',
          country: 'UAE'
        },
        hireDate: new Date('2021-03-10')
      },
      {
        username: 'admin1',
        password: 'admin123',
        fullName: 'Omar Al-Rashid',
        email: 'omar.rashid@hospital.ae',
        phone: '+971508901234',
        dateOfBirth: new Date('1985-12-03'),
        gender: 'male',
        staffRole: 'admin',
        department: 'Administration',
        yearsOfExperience: 5,
        hospitalName: 'Dubai Hospital',
        hospitalId: 'DH001',
        hospitalAddress: {
          street: 'Al Khaleej Road',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '11111',
          country: 'UAE'
        },
        workingHours: {
          startTime: '08:00',
          endTime: '17:00',
          workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
        },
        permissions: ['schedule_appointments', 'admin_access'],
        address: {
          street: 'Sheikh Zayed Road 78',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '44444',
          country: 'UAE'
        },
        hireDate: new Date('2022-06-01')
      },
      {
        username: 'doctor2',
        password: 'doc123',
        fullName: 'Dr. Priya Sharma',
        email: 'priya.sharma@hospital.ae',
        phone: '+971509012345',
        dateOfBirth: new Date('1980-02-18'),
        gender: 'female',
        staffRole: 'doctor',
        department: 'Internal Medicine',
        specialization: 'Internal Medicine',
        licenseNumber: 'DOH-INT-2019-008',
        yearsOfExperience: 12,
        hospitalName: 'American Hospital Dubai',
        hospitalId: 'AHD001',
        hospitalAddress: {
          street: 'Oud Metha Road',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '55555',
          country: 'UAE'
        },
        workingHours: {
          startTime: '09:00',
          endTime: '17:00',
          workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Saturday']
        },
        permissions: ['read_patient_records', 'write_patient_records', 'prescribe_medication', 'schedule_appointments'],
        address: {
          street: 'Business Bay Boulevard 90',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '66666',
          country: 'UAE'
        },
        hireDate: new Date('2019-09-12')
      }
    ]);

    // Create Regional Officers
    const regionalOfficers = await RegionalOfficer.insertMany([
      {
        username: 'officer1',
        password: 'off123',
        fullName: 'Dr. Khalid Al-Mansoori',
        email: 'khalid.mansoori@doh.ae',
        phone: '+971501122334',
        dateOfBirth: new Date('1970-03-25'),
        gender: 'male',
        officerRank: 'regional_director',
        employeeId: 'RO001',
        department: 'Department of Health - Dubai',
        assignedRegion: 'Northern Emirates',
        assignedDistricts: ['Dubai', 'Sharjah', 'Ajman'],
        assignedStates: ['Dubai', 'Sharjah'],
        jurisdictionLevel: 'regional',
        officeAddress: {
          buildingName: 'Dubai Health Authority Building',
          street: 'Al Khaleej Road',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '11111',
          country: 'UAE'
        },
        officePhone: '+971-4-606-6000',
        responsibilities: ['health_monitoring', 'policy_implementation', 'hospital_oversight', 'emergency_response'],
        clearanceLevel: 'top_secret',
        accessPermissions: ['view_regional_data', 'view_hospital_data', 'view_patient_statistics', 'generate_reports', 'policy_management', 'resource_management', 'emergency_coordination'],
        address: {
          street: 'Palm Jumeirah Residence',
          city: 'Dubai',
          state: 'Dubai',
          zipCode: '77777',
          country: 'UAE'
        },
        yearsOfService: 18,
        previousPostings: [
          { location: 'Abu Dhabi', position: 'District Health Officer', duration: '2010-2015' },
          { location: 'Sharjah', position: 'State Health Officer', duration: '2015-2020' }
        ],
        appointmentDate: new Date('2020-01-01')
      },
      {
        username: 'officer2',
        password: 'off123',
        fullName: 'Dr. Fatima Al-Zahra',
        email: 'fatima.zahra@doh.ae',
        phone: '+971502233445',
        dateOfBirth: new Date('1978-09-14'),
        gender: 'female',
        officerRank: 'district_health_officer',
        employeeId: 'RO002',
        department: 'Department of Health - Abu Dhabi',
        assignedRegion: 'Central Emirates',
        assignedDistricts: ['Abu Dhabi', 'Al Ain'],
        assignedStates: ['Abu Dhabi'],
        jurisdictionLevel: 'state',
        officeAddress: {
          buildingName: 'Abu Dhabi Department of Health',
          street: 'Corniche Road',
          city: 'Abu Dhabi',
          state: 'Abu Dhabi',
          zipCode: '88888',
          country: 'UAE'
        },
        officePhone: '+971-2-449-0000',
        responsibilities: ['health_monitoring', 'disease_surveillance', 'migrant_health_coordination', 'data_analysis'],
        clearanceLevel: 'advanced',
        accessPermissions: ['view_regional_data', 'view_hospital_data', 'view_patient_statistics', 'generate_reports'],
        address: {
          street: 'Al Reem Island Tower 5',
          city: 'Abu Dhabi',
          state: 'Abu Dhabi',
          zipCode: '99999',
          country: 'UAE'
        },
        yearsOfService: 10,
        previousPostings: [
          { location: 'Al Ain', position: 'Health Officer', duration: '2018-2021' }
        ],
        appointmentDate: new Date('2021-07-15')
      }
    ]);

    // Create Medical Records
    const medicalRecords = await MedicalRecord.insertMany([
      {
        patientId: patients[0]._id,
        hospitalStaffId: hospitalStaff[0]._id,
        recordType: 'consultation',
        title: 'Diabetes Follow-up Consultation',
        description: 'Routine diabetes follow-up appointment. Patient shows good compliance with medication regimen.',
        diagnosis: 'Diabetes Type 2 - well controlled',
        treatment: 'Continue current medication regimen with lifestyle modifications',
        medications: [
          { name: 'Metformin', dosage: '500mg', frequency: 'Twice daily', duration: '3 months' }
        ],
        vitals: {
          bloodPressure: '128/82',
          heartRate: 75,
          temperature: 36.8,
          weight: 78.5,
          height: 175
        },
        labResults: [
          { testName: 'HbA1c', result: '6.8%', normalRange: '<7%', unit: '%' },
          { testName: 'Fasting Glucose', result: '125', normalRange: '70-100', unit: 'mg/dL' }
        ],
        visitDate: new Date('2024-01-15'),
        followUpDate: new Date('2024-04-15'),
        severity: 'medium',
        status: 'ongoing'
      },
      {
        patientId: patients[1]._id,
        hospitalStaffId: hospitalStaff[1]._id,
        recordType: 'diagnosis',
        title: 'Emergency Room Visit - Severe Headache',
        description: 'Patient presented with severe headache and nausea. Treated for migraine headache.',
        diagnosis: 'Migraine headache',
        treatment: 'Pain management therapy and rest',
        medications: [
          { name: 'Sumatriptan', dosage: '50mg', frequency: 'As needed', duration: '1 week' }
        ],
        vitals: {
          bloodPressure: '142/90',
          heartRate: 88,
          temperature: 37.2,
          weight: 65.0,
          height: 162
        },
        labResults: [
          { testName: 'Complete Blood Count', result: 'Normal', normalRange: 'Normal', unit: '' }
        ],
        visitDate: new Date('2024-01-22'),
        severity: 'high',
        status: 'resolved'
      },
      {
        patientId: patients[2]._id,
        hospitalStaffId: hospitalStaff[3]._id,
        recordType: 'treatment',
        title: 'Hypertension Management Plan',
        description: 'Blood pressure management consultation with medication adjustment.',
        diagnosis: 'Hypertension - stable, High Cholesterol',
        treatment: 'Medication dosage adjustment and lifestyle counseling',
        medications: [
          { name: 'Amlodipine', dosage: '10mg', frequency: 'Once daily', duration: '3 months' },
          { name: 'Atorvastatin', dosage: '40mg', frequency: 'Once daily', duration: '3 months' }
        ],
        vitals: {
          bloodPressure: '145/95',
          heartRate: 72,
          temperature: 36.5,
          weight: 82.3,
          height: 170
        },
        labResults: [
          { testName: 'Lipid Panel - LDL', result: '145', normalRange: '<100', unit: 'mg/dL' },
          { testName: 'Creatinine', result: '1.1', normalRange: '0.7-1.3', unit: 'mg/dL' }
        ],
        visitDate: new Date('2024-01-30'),
        followUpDate: new Date('2024-05-30'),
        severity: 'medium',
        status: 'ongoing'
      }
    ]);

    // Create Hospital Appointments
    const appointments = await HospitalAppointment.insertMany([
      {
        appointmentId: 'APT_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9),
        patientId: patients[0]._id.toString(),
        patientName: patients[0].fullName,
        patientUhid: patients[0].uhid,
        patientGender: patients[0].gender,
        patientAge: 45,
        patientState: 'Dubai',
        hospitalStaffId: hospitalStaff[0]._id.toString(),
        doctorName: hospitalStaff[0].fullName,
        hospitalId: 'HSP001',
        hospitalName: 'Dubai Hospital',
        appointmentDate: '15/04/2024',
        appointmentTime: '10:00 AM',
        reason: 'Diabetes follow-up appointment',
        consultationFee: 150,
        status: 'approved'
      },
      {
        appointmentId: 'APT_' + (Date.now() + 1) + '_' + Math.random().toString(36).substr(2, 9),
        patientId: patients[1]._id.toString(),
        patientName: patients[1].fullName,
        patientUhid: patients[1].uhid,
        patientGender: patients[1].gender,
        patientAge: 38,
        patientState: 'Dubai',
        hospitalStaffId: hospitalStaff[1]._id.toString(),
        doctorName: hospitalStaff[1].fullName,
        hospitalId: 'HSP001',
        hospitalName: 'Dubai Hospital',
        appointmentDate: '10/02/2024',
        appointmentTime: '2:30 PM',
        reason: 'Annual health screening',
        consultationFee: 200,
        status: 'completed'
      },
      {
        appointmentId: 'APT_' + (Date.now() + 2) + '_' + Math.random().toString(36).substr(2, 9),
        patientId: patients[2]._id.toString(),
        patientName: patients[2].fullName,
        patientUhid: patients[2].uhid,
        patientGender: patients[2].gender,
        patientAge: 52,
        patientState: 'Dubai',
        hospitalStaffId: hospitalStaff[3]._id.toString(),
        doctorName: hospitalStaff[3].fullName,
        hospitalId: 'HSP002',
        hospitalName: 'American Hospital Dubai',
        appointmentDate: '30/05/2024',
        appointmentTime: '11:00 AM',
        reason: 'Blood pressure and cholesterol monitoring',
        consultationFee: 180,
        status: 'approved'
      },
      {
        appointmentId: 'APT_' + (Date.now() + 3) + '_' + Math.random().toString(36).substr(2, 9),
        patientId: patients[3]._id.toString(),
        patientName: patients[3].fullName,
        patientUhid: patients[3].uhid,
        patientGender: patients[3].gender,
        patientAge: 29,
        patientState: 'Dubai',
        hospitalStaffId: hospitalStaff[0]._id.toString(),
        doctorName: hospitalStaff[0].fullName,
        hospitalId: 'HSP001',
        hospitalName: 'Dubai Hospital',
        appointmentDate: '20/03/2024',
        appointmentTime: '9:00 AM',
        reason: 'Asthma management consultation',
        consultationFee: 160,
        status: 'approved'
      }
    ]);

    // Create Health Statistics
    const healthStats = await HealthStatistics.insertMany([
      {
        region: 'Dubai',
        district: 'Deira',
        reportingPeriod: '2024-Q1',
        statistics: {
          totalPopulation: 250000,
          migrantWorkerPopulation: 180000,
          totalPatients: 15420,
          newRegistrations: 1250,
          activeCases: 3420,
          resolvedCases: 11850,
          emergencyCases: 150,
          commonDiseases: [
            { diseaseName: 'Diabetes', caseCount: 2340, severity: 'Moderate' },
            { diseaseName: 'Hypertension', caseCount: 1890, severity: 'Moderate' },
            { diseaseName: 'Respiratory Infections', caseCount: 980, severity: 'Mild' }
          ],
          vaccinationData: [
            { vaccineName: 'COVID-19', administeredCount: 45000, targetPopulation: 50000 },
            { vaccineName: 'Influenza', administeredCount: 12000, targetPopulation: 15000 }
          ],
          hospitalUtilization: [
            { hospitalName: 'Dubai Hospital', bedOccupancy: 85, totalBeds: 100, averageStayDuration: 3.2 },
            { hospitalName: 'American Hospital Dubai', bedOccupancy: 78, totalBeds: 120, averageStayDuration: 2.8 }
          ],
          resourceAllocation: {
            medicalStaff: 450,
            availableDoctors: 120,
            availableNurses: 280,
            medicalSupplies: 'Adequate',
            budgetUtilization: 85
          }
        },
        trends: [
          { metric: 'New Registrations', currentValue: 1250, previousValue: 1100, changePercentage: 13.6, trend: 'increasing' },
          { metric: 'Emergency Cases', currentValue: 150, previousValue: 180, changePercentage: -16.7, trend: 'decreasing' }
        ],
        alerts: [
          { alertType: 'Resource Shortage', severity: 'Medium', description: 'ICU beds at 90% capacity', actionRequired: true },
          { alertType: 'Disease Outbreak', severity: 'Low', description: 'Slight increase in respiratory infections', actionRequired: false }
        ],
        generatedBy: regionalOfficers[0]._id,
        generatedAt: new Date('2024-01-31')
      }
    ]);

    console.log('Sample data created successfully:');
    console.log(`- ${patients.length} patients`);
    console.log(`- ${hospitalStaff.length} hospital staff`);
    console.log(`- ${regionalOfficers.length} regional officers`);
    console.log(`- ${medicalRecords.length} medical records`);
    console.log(`- ${appointments.length} appointments`);
    console.log(`- ${healthStats.length} health statistics reports`);

  } catch (error) {
    console.error('Error populating database:', error);
  } finally {
    await mongoose.connection.close();
    console.log('Database connection closed');
  }
}

populateDatabase();
