const mongoose = require('mongoose');
const Patient = require('./src/models/Patient');
const HospitalStaff = require('./src/models/HospitalStaff');
const RegionalOfficer = require('./src/models/RegionalOfficer');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/myhealth', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(async () => {
  console.log('✅ Connected to MongoDB for setup');
  
  // Clear existing data
  await Patient.deleteMany({});
  await HospitalStaff.deleteMany({});
  await RegionalOfficer.deleteMany({});
  console.log('🗑️ Cleared existing data');
  
  // Create Patients
  const patients = [
    {
      username: 'patient1',
      password: 'pass123',
      fullName: 'Ravi Kumar',
      email: 'ravi.kumar@email.com',
      phone: '+919876543210',
      dateOfBirth: new Date('1990-05-15'),
      gender: 'male',
      bloodGroup: 'B+',
      address: {
        street: '123 MG Road',
        city: 'Kochi',
        state: 'Kerala',
        zipCode: '682001',
        country: 'India'
      },
      emergencyContact: {
        name: 'Priya Kumar',
        relationship: 'Wife',
        phone: '+919876543211'
      },
      medicalHistory: [
        {
          condition: 'Hypertension',
          diagnosedDate: new Date('2020-01-15'),
          notes: 'Controlled with medication'
        }
      ],
      allergies: ['Penicillin', 'Shellfish'],
      currentMedications: [
        {
          name: 'Amlodipine',
          dosage: '5mg',
          frequency: 'Once daily'
        }
      ],
      workLocation: 'Kochi Industrial Area',
      employerName: 'Tech Solutions Pvt Ltd',
      workPermitNumber: 'WP2024001',
      homeState: 'Tamil Nadu'
    },
    {
      username: 'patient2',
      password: 'pass456',
      fullName: 'Lakshmi Nair',
      email: 'lakshmi.nair@email.com',
      phone: '+919876543212',
      dateOfBirth: new Date('1985-08-22'),
      gender: 'female',
      bloodGroup: 'A+',
      address: {
        street: '456 Marine Drive',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695001',
        country: 'India'
      },
      emergencyContact: {
        name: 'Suresh Nair',
        relationship: 'Husband',
        phone: '+919876543213'
      },
      medicalHistory: [
        {
          condition: 'Diabetes Type 2',
          diagnosedDate: new Date('2019-03-10'),
          notes: 'Well controlled with diet and medication'
        }
      ],
      allergies: ['Aspirin'],
      currentMedications: [
        {
          name: 'Metformin',
          dosage: '500mg',
          frequency: 'Twice daily'
        }
      ],
      workLocation: 'IT Park Technopark',
      employerName: 'Global IT Services',
      workPermitNumber: 'WP2024002',
      homeState: 'Karnataka'
    },
    {
      username: 'patient3',
      password: 'pass789',
      fullName: 'Mohammed Ali',
      email: 'mohammed.ali@email.com',
      phone: '+919876543214',
      dateOfBirth: new Date('1992-12-03'),
      gender: 'male',
      bloodGroup: 'O+',
      address: {
        street: '789 Calicut Road',
        city: 'Kozhikode',
        state: 'Kerala',
        zipCode: '673001',
        country: 'India'
      },
      emergencyContact: {
        name: 'Fatima Ali',
        relationship: 'Mother',
        phone: '+919876543215'
      },
      medicalHistory: [],
      allergies: [],
      currentMedications: [],
      workLocation: 'Kozhikode Port',
      employerName: 'Maritime Logistics Ltd',
      workPermitNumber: 'WP2024003',
      homeState: 'West Bengal'
    }
  ];
  
  // Create Hospital Staff
  const hospitalStaff = [
    {
      username: 'doctor1',
      password: 'doc123',
      fullName: 'Dr. Priya Menon',
      email: 'priya.menon@hospital.com',
      phone: '+919876543220',
      dateOfBirth: new Date('1980-04-10'),
      gender: 'female',
      staffRole: 'doctor',
      department: 'General Medicine',
      specialization: 'Internal Medicine',
      licenseNumber: 'KMC2020001',
      yearsOfExperience: 15,
      hospitalName: 'Kerala Government Medical College',
      hospitalId: 'KGMC001',
      hospitalAddress: {
        street: 'Medical College Road',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695011',
        country: 'India'
      },
      workingHours: {
        startTime: '09:00',
        endTime: '17:00',
        workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
      },
      permissions: ['read_patient_records', 'write_patient_records', 'prescribe_medication', 'schedule_appointments'],
      address: {
        street: '12 Doctors Colony',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695012',
        country: 'India'
      },
      hireDate: new Date('2010-06-01')
    },
    {
      username: 'nurse1',
      password: 'nurse123',
      fullName: 'Sister Mary Joseph',
      email: 'mary.joseph@hospital.com',
      phone: '+919876543221',
      dateOfBirth: new Date('1985-07-20'),
      gender: 'female',
      staffRole: 'nurse',
      department: 'Emergency',
      licenseNumber: 'KNC2018001',
      yearsOfExperience: 10,
      hospitalName: 'Kerala Government Medical College',
      hospitalId: 'KGMC001',
      hospitalAddress: {
        street: 'Medical College Road',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695011',
        country: 'India'
      },
      workingHours: {
        startTime: '08:00',
        endTime: '16:00',
        workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
      },
      permissions: ['read_patient_records', 'write_patient_records', 'schedule_appointments'],
      address: {
        street: '34 Nurses Quarters',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695012',
        country: 'India'
      },
      hireDate: new Date('2015-03-15')
    },
    {
      username: 'admin1',
      password: 'admin123',
      fullName: 'Rajesh Kumar',
      email: 'rajesh.kumar@hospital.com',
      phone: '+919876543222',
      dateOfBirth: new Date('1975-11-30'),
      gender: 'male',
      staffRole: 'admin',
      department: 'Administration',
      yearsOfExperience: 20,
      hospitalName: 'Kerala Government Medical College',
      hospitalId: 'KGMC001',
      hospitalAddress: {
        street: 'Medical College Road',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695011',
        country: 'India'
      },
      workingHours: {
        startTime: '09:00',
        endTime: '18:00',
        workingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
      },
      permissions: ['read_patient_records', 'schedule_appointments', 'view_reports', 'admin_access'],
      address: {
        street: '67 Staff Quarters',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695012',
        country: 'India'
      },
      hireDate: new Date('2005-01-10')
    }
  ];
  
  // Create Regional Officers
  const regionalOfficers = [
    {
      username: 'officer1',
      password: 'officer123',
      fullName: 'Dr. Sunil Kumar IAS',
      email: 'sunil.kumar@kerala.gov.in',
      phone: '+919876543230',
      dateOfBirth: new Date('1970-02-15'),
      gender: 'male',
      officerRank: 'district_health_officer',
      employeeId: 'DHO2020001',
      department: 'Health Department',
      assignedRegion: 'South Kerala',
      assignedDistricts: ['Thiruvananthapuram', 'Kollam', 'Pathanamthitta'],
      assignedStates: ['Kerala'],
      jurisdictionLevel: 'district',
      officeAddress: {
        buildingName: 'District Collectorate',
        street: 'Collectorate Road',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695033',
        country: 'India'
      },
      officePhone: '+914712734567',
      responsibilities: ['health_monitoring', 'disease_surveillance', 'hospital_oversight', 'migrant_health_coordination'],
      clearanceLevel: 'advanced',
      accessPermissions: ['view_regional_data', 'view_hospital_data', 'view_patient_statistics', 'generate_reports'],
      address: {
        street: '89 Officers Colony',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695034',
        country: 'India'
      },
      yearsOfService: 25,
      previousPostings: [
        {
          location: 'Kottayam',
          position: 'Assistant Health Officer',
          duration: '2000-2005'
        },
        {
          location: 'Alappuzha',
          position: 'Health Officer',
          duration: '2005-2015'
        }
      ],
      appointmentDate: new Date('2020-04-01')
    },
    {
      username: 'officer2',
      password: 'officer456',
      fullName: 'Dr. Meera Nair',
      email: 'meera.nair@kerala.gov.in',
      phone: '+919876543231',
      dateOfBirth: new Date('1975-09-08'),
      gender: 'female',
      officerRank: 'state_health_officer',
      employeeId: 'SHO2018001',
      department: 'Health Department',
      assignedRegion: 'Kerala State',
      assignedDistricts: ['All Kerala Districts'],
      assignedStates: ['Kerala'],
      jurisdictionLevel: 'state',
      officeAddress: {
        buildingName: 'State Health Directorate',
        street: 'Government Secretariat',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695001',
        country: 'India'
      },
      officePhone: '+914712518888',
      responsibilities: ['policy_implementation', 'resource_allocation', 'emergency_response', 'data_analysis'],
      clearanceLevel: 'top_secret',
      accessPermissions: ['view_regional_data', 'view_hospital_data', 'view_patient_statistics', 'generate_reports', 'policy_management', 'resource_management'],
      address: {
        street: '45 State Officers Residence',
        city: 'Thiruvananthapuram',
        state: 'Kerala',
        zipCode: '695035',
        country: 'India'
      },
      yearsOfService: 22,
      previousPostings: [
        {
          location: 'Thrissur',
          position: 'District Health Officer',
          duration: '2010-2018'
        }
      ],
      appointmentDate: new Date('2018-07-01')
    }
  ];
  
  try {
    // Insert all data
    await Patient.insertMany(patients);
    console.log(`✅ Created ${patients.length} patients`);
    
    await HospitalStaff.insertMany(hospitalStaff);
    console.log(`✅ Created ${hospitalStaff.length} hospital staff members`);
    
    await RegionalOfficer.insertMany(regionalOfficers);
    console.log(`✅ Created ${regionalOfficers.length} regional officers`);
    
    // Display summary
    console.log('\n📊 Database Summary:');
    console.log(`   Patients: ${await Patient.countDocuments()}`);
    console.log(`   Hospital Staff: ${await HospitalStaff.countDocuments()}`);
    console.log(`   Regional Officers: ${await RegionalOfficer.countDocuments()}`);
    
    console.log('\n🔑 Sample Login Credentials:');
    console.log('   PATIENTS:');
    console.log('   - Username: patient1, Password: pass123 (Ravi Kumar)');
    console.log('   - Username: patient2, Password: pass456 (Lakshmi Nair)');
    console.log('   - Username: patient3, Password: pass789 (Mohammed Ali)');
    
    console.log('\n   HOSPITAL STAFF:');
    console.log('   - Username: doctor1, Password: doc123 (Dr. Priya Menon - Doctor)');
    console.log('   - Username: nurse1, Password: nurse123 (Sister Mary Joseph - Nurse)');
    console.log('   - Username: admin1, Password: admin123 (Rajesh Kumar - Admin)');
    
    console.log('\n   REGIONAL OFFICERS:');
    console.log('   - Username: officer1, Password: officer123 (Dr. Sunil Kumar - District Health Officer)');
    console.log('   - Username: officer2, Password: officer456 (Dr. Meera Nair - State Health Officer)');
    
  } catch (error) {
    console.error('❌ Error creating data:', error);
  }
  
  mongoose.connection.close();
  console.log('\n✅ Database setup completed successfully!');
})
.catch((error) => {
  console.error('❌ MongoDB connection error:', error);
  process.exit(1);
});
