// Test Hospital System API Endpoints
const axios = require('axios');

const API_BASE = 'http://localhost:5000/api';

// Test Data
const testHospital = {
  hospitalName: "Test General Hospital",
  address: {
    street: "123 Main Street",
    city: "Mumbai",
    state: "Maharashtra",
    district: "Mumbai",
    pincode: "400001"
  },
  contactNumber: "9876543210",
  email: "test@hospital.com",
  registrationNumber: "REG123456",
  licenseId: "LIC789012",
  hospitalType: "Private",
  specialties: ["General Medicine", "Cardiology", "Orthopedics"],
  totalBeds: 100,
  emergencyServices: true,
  ambulanceServices: true,
  website: "https://testgeneralhospital.com",
  establishedYear: 2020,
  adminDetails: {
    username: "admin_test",
    password: "admin123",
    adminName: "Test Admin",
    adminEmail: "admin@hospital.com",
    adminPhone: "9876543211"
  }
};

const testDoctor = {
  doctorName: "Dr. John Smith",
  username: "dr_john",
  password: "doctor123",
  email: "john@hospital.com",
  contactNumber: "9876543212",
  specialization: "Cardiology",
  qualifications: ["MBBS", "MD Cardiology"],
  department: "Cardiology",
  dutySchedule: {
    Monday: { startTime: "09:00", endTime: "17:00", isAvailable: true },
    Tuesday: { startTime: "09:00", endTime: "17:00", isAvailable: true },
    Wednesday: { startTime: "09:00", endTime: "17:00", isAvailable: true },
    Thursday: { startTime: "09:00", endTime: "17:00", isAvailable: true },
    Friday: { startTime: "09:00", endTime: "17:00", isAvailable: true }
  },
  emergencyContact: {
    name: "Jane Smith",
    phone: "9876543213",
    relationship: "Spouse"
  }
};

const testAssistant = {
  assistantName: "Mary Johnson",
  username: "mary_assistant",
  password: "assistant123",
  email: "mary@hospital.com",
  contactNumber: "9876543214",
  designation: "Medical Assistant",
  department: "Cardiology",
  dutySchedule: {
    Monday: { startTime: "08:00", endTime: "16:00", isAvailable: true },
    Tuesday: { startTime: "08:00", endTime: "16:00", isAvailable: true },
    Wednesday: { startTime: "08:00", endTime: "16:00", isAvailable: true },
    Thursday: { startTime: "08:00", endTime: "16:00", isAvailable: true },
    Friday: { startTime: "08:00", endTime: "16:00", isAvailable: true }
  },
  emergencyContact: {
    name: "Robert Johnson",
    phone: "9876543215",
    relationship: "Husband"
  }
};

let hospitalId = '';
let adminToken = '';
let doctorToken = '';
let assistantToken = '';
let doctorId = '';

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function testHospitalRegistration() {
  console.log('\n=== Testing Hospital Registration ===');
  try {
    const response = await axios.post(`${API_BASE}/hospital/register`, testHospital);
    console.log('✓ Hospital registration successful');
    console.log('Hospital ID:', response.data.data.hospital.hospitalId);
    console.log('Admin ID:', response.data.data.admin.adminId);
    hospitalId = response.data.data.hospital.hospitalId;
    return true;
  } catch (error) {
    console.log('✗ Hospital registration failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testGetHospitals() {
  console.log('\n=== Testing Get All Hospitals ===');
  try {
    const response = await axios.get(`${API_BASE}/hospital/list`);
    console.log('✓ Get hospitals successful');
    console.log('Found hospitals:', response.data.count);
    return true;
  } catch (error) {
    console.log('✗ Get hospitals failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testAdminLogin() {
  console.log('\n=== Testing Admin Login ===');
  try {
    const response = await axios.post(`${API_BASE}/hospital-admin/login`, {
      hospitalId: hospitalId,
      username: testHospital.adminDetails.username,
      password: testHospital.adminDetails.password
    });
    console.log('✓ Admin login successful');
    console.log('Admin Token received');
    adminToken = response.data.data.token;
    return true;
  } catch (error) {
    console.log('✗ Admin login failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testAdminDashboard() {
  console.log('\n=== Testing Admin Dashboard ===');
  try {
    const response = await axios.get(`${API_BASE}/hospital-admin/dashboard`, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✓ Admin dashboard access successful');
    console.log('Dashboard data received');
    return true;
  } catch (error) {
    console.log('✗ Admin dashboard failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testCreateDoctor() {
  console.log('\n=== Testing Doctor Creation ===');
  try {
    const response = await axios.post(`${API_BASE}/hospital-admin/doctors`, testDoctor, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✓ Doctor creation successful');
    console.log('Doctor ID:', response.data.data.doctorId);
    doctorId = response.data.data.doctorId;
    return true;
  } catch (error) {
    console.log('✗ Doctor creation failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testDoctorLogin() {
  console.log('\n=== Testing Doctor Login ===');
  try {
    const response = await axios.post(`${API_BASE}/hospital-doctor/login`, {
      hospitalId: hospitalId,
      username: testDoctor.username,
      password: testDoctor.password
    });
    console.log('✓ Doctor login successful');
    console.log('Doctor Token received');
    doctorToken = response.data.data.token;
    return true;
  } catch (error) {
    console.log('✗ Doctor login failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testCreateAssistant() {
  console.log('\n=== Testing Assistant Creation ===');
  try {
    // Assign assistant to the doctor we created
    testAssistant.assignedDoctorId = doctorId;
    
    const response = await axios.post(`${API_BASE}/hospital-admin/assistants`, testAssistant, {
      headers: { Authorization: `Bearer ${adminToken}` }
    });
    console.log('✓ Assistant creation successful');
    console.log('Assistant ID:', response.data.data.assistantId);
    return true;
  } catch (error) {
    console.log('✗ Assistant creation failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testAssistantLogin() {
  console.log('\n=== Testing Assistant Login ===');
  try {
    const response = await axios.post(`${API_BASE}/hospital-assistant/login`, {
      hospitalId: hospitalId,
      username: testAssistant.username,
      password: testAssistant.password
    });
    console.log('✓ Assistant login successful');
    console.log('Assistant Token received');
    assistantToken = response.data.data.token;
    return true;
  } catch (error) {
    console.log('✗ Assistant login failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testDoctorDashboard() {
  console.log('\n=== Testing Doctor Dashboard ===');
  try {
    const response = await axios.get(`${API_BASE}/hospital-doctor/dashboard`, {
      headers: { Authorization: `Bearer ${doctorToken}` }
    });
    console.log('✓ Doctor dashboard access successful');
    console.log('Assigned assistants:', response.data.data.summary.assignedAssistants);
    return true;
  } catch (error) {
    console.log('✗ Doctor dashboard failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function testAssistantDashboard() {
  console.log('\n=== Testing Assistant Dashboard ===');
  try {
    const response = await axios.get(`${API_BASE}/hospital-assistant/dashboard`, {
      headers: { Authorization: `Bearer ${assistantToken}` }
    });
    console.log('✓ Assistant dashboard access successful');
    console.log('Assigned doctor:', response.data.data.summary.assignedDoctor?.doctorName || 'None');
    return true;
  } catch (error) {
    console.log('✗ Assistant dashboard failed:', error.response?.data?.message || error.message);
    return false;
  }
}

async function runTests() {
  console.log('🏥 Hospital Management System API Tests');
  console.log('=========================================');
  
  let passed = 0;
  let total = 0;
  
  const tests = [
    testHospitalRegistration,
    testGetHospitals,
    testAdminLogin,
    testAdminDashboard,
    testCreateDoctor,
    testDoctorLogin,
    testCreateAssistant,
    testAssistantLogin,
    testDoctorDashboard,
    testAssistantDashboard
  ];
  
  for (const test of tests) {
    total++;
    const result = await test();
    if (result) passed++;
    await sleep(500); // Small delay between tests
  }
  
  console.log('\n=========================================');
  console.log(`📊 Test Results: ${passed}/${total} tests passed`);
  
  if (passed === total) {
    console.log('🎉 All tests passed! Hospital system is working correctly.');
  } else {
    console.log('❌ Some tests failed. Please check the errors above.');
  }
}

// Handle errors gracefully
process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error.message);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Run tests if this is the main module
if (require.main === module) {
  runTests().catch(error => {
    console.error('Test suite failed:', error.message);
    process.exit(1);
  });
}

module.exports = {
  runTests,
  testHospital,
  testDoctor,
  testAssistant
};