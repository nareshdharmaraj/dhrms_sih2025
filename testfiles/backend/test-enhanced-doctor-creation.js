const axios = require('axios');

// Test configuration
const BASE_URL = 'http://localhost:3000/api'; // Update with your server URL
const TEST_HOSPITAL_ID = 'H001';
const TEST_ADMIN_USERNAME = 'admin';
const TEST_ADMIN_PASSWORD = 'admin123';

let authToken = '';

// Test data for enhanced doctor creation
const testDoctorData = {
  doctorId: `DR${Date.now().toString().substring(7)}`,
  name: 'Dr. Sarah Johnson',
  gender: 'Female',
  dateOfBirth: '1985-05-15',
  specializations: ['Cardiology', 'Internal Medicine'],
  department: 'Cardiology',
  contactNumber: '9876543210',
  email: `sarah.johnson.${Date.now()}@hospital.com`,
  qualification: 'MD Cardiology',
  experienceYears: 8,
  availableTimings: '9:00 AM - 12:00 PM',
  consultationFee: 1500,
  password: 'doctor123'
};

// Helper function to make authenticated requests
const makeRequest = async (method, endpoint, data = null) => {
  try {
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: authToken ? { 'Authorization': `Bearer ${authToken}` } : {},
    };
    
    if (data) {
      config.data = data;
    }
    
    const response = await axios(config);
    return response.data;
  } catch (error) {
    console.error(`Error in ${method} ${endpoint}:`, error.response?.data || error.message);
    throw error;
  }
};

// Test 1: Admin Login
const testAdminLogin = async () => {
  console.log('\n=== Testing Admin Login ===');
  try {
    const loginData = {
      hospitalId: TEST_HOSPITAL_ID,
      username: TEST_ADMIN_USERNAME,
      password: TEST_ADMIN_PASSWORD
    };
    
    const response = await makeRequest('POST', '/hospital-admin/login', loginData);
    
    if (response.success) {
      authToken = response.data.token;
      console.log('✅ Admin login successful');
      console.log('Admin Name:', response.data.admin.adminName);
      console.log('Hospital:', response.data.admin.hospitalName);
      return true;
    } else {
      console.log('❌ Admin login failed:', response.message);
      return false;
    }
  } catch (error) {
    console.log('❌ Admin login error:', error.response?.data?.message || error.message);
    return false;
  }
};

// Test 2: Create Doctor with Enhanced Fields
const testCreateDoctor = async () => {
  console.log('\n=== Testing Enhanced Doctor Creation ===');
  try {
    console.log('Sending doctor data:', JSON.stringify(testDoctorData, null, 2));
    
    const response = await makeRequest('POST', '/hospital-admin/doctors', testDoctorData);
    
    if (response.success) {
      console.log('✅ Doctor created successfully');
      console.log('Doctor ID:', response.data.doctorId);
      console.log('Name:', response.data.name);
      console.log('Specializations:', response.data.specializations);
      console.log('Experience:', response.data.experienceYears, 'years');
      console.log('Consultation Fee:', '₹' + response.data.consultationFee);
      console.log('Available Timings:', response.data.availableTimings);
      
      // Store doctor ID for further tests
      testDoctorData.createdDoctorId = response.data.doctorId;
      return response.data;
    } else {
      console.log('❌ Doctor creation failed:', response.message);
      return null;
    }
  } catch (error) {
    console.log('❌ Doctor creation error:', error.response?.data?.message || error.message);
    if (error.response?.data?.errors) {
      console.log('Validation errors:', error.response.data.errors);
    }
    return null;
  }
};

// Test 3: Retrieve All Doctors
const testGetAllDoctors = async () => {
  console.log('\n=== Testing Get All Doctors ===');
  try {
    const response = await makeRequest('GET', '/hospital-admin/doctors');
    
    if (response.success) {
      console.log('✅ Retrieved doctors successfully');
      console.log('Total doctors:', response.data.length);
      
      // Find our newly created doctor
      const createdDoctor = response.data.find(d => d.doctorId === testDoctorData.createdDoctorId);
      if (createdDoctor) {
        console.log('✅ Found our created doctor in the list');
        console.log('Stored data verification:');
        console.log('- Name:', createdDoctor.name || createdDoctor.doctorName);
        console.log('- Gender:', createdDoctor.gender);
        console.log('- Specializations:', createdDoctor.specializations);
        console.log('- Experience:', createdDoctor.experienceYears);
        console.log('- Consultation Fee:', createdDoctor.consultationFee);
        console.log('- Available Timings:', createdDoctor.availableTimings);
        return createdDoctor;
      } else {
        console.log('❌ Created doctor not found in the list');
        return null;
      }
    } else {
      console.log('❌ Failed to retrieve doctors:', response.message);
      return null;
    }
  } catch (error) {
    console.log('❌ Get doctors error:', error.response?.data?.message || error.message);
    return null;
  }
};

// Test 4: Validate Field Storage
const validateFieldStorage = (doctorData) => {
  console.log('\n=== Validating Field Storage ===');
  
  const checks = [
    { field: 'name', expected: testDoctorData.name, actual: doctorData.name || doctorData.doctorName },
    { field: 'gender', expected: testDoctorData.gender, actual: doctorData.gender },
    { field: 'specializations', expected: JSON.stringify(testDoctorData.specializations), actual: JSON.stringify(doctorData.specializations) },
    { field: 'experienceYears', expected: testDoctorData.experienceYears, actual: doctorData.experienceYears },
    { field: 'consultationFee', expected: testDoctorData.consultationFee, actual: doctorData.consultationFee },
    { field: 'availableTimings', expected: testDoctorData.availableTimings, actual: doctorData.availableTimings },
    { field: 'email', expected: testDoctorData.email, actual: doctorData.email },
    { field: 'contactNumber', expected: testDoctorData.contactNumber, actual: doctorData.contactNumber },
    { field: 'qualification', expected: testDoctorData.qualification, actual: doctorData.qualification }
  ];
  
  let allValid = true;
  
  for (const check of checks) {
    if (check.expected === check.actual) {
      console.log(`✅ ${check.field}: ${check.actual}`);
    } else {
      console.log(`❌ ${check.field}: Expected "${check.expected}", got "${check.actual}"`);
      allValid = false;
    }
  }
  
  if (allValid) {
    console.log('\n🎉 All fields stored and retrieved correctly!');
  } else {
    console.log('\n⚠️ Some fields were not stored or retrieved correctly.');
  }
  
  return allValid;
};

// Test 5: Test Backwards Compatibility
const testBackwardsCompatibility = async () => {
  console.log('\n=== Testing Backwards Compatibility ===');
  try {
    const legacyDoctorData = {
      doctorName: 'Dr. Legacy Test',
      username: `legacy${Date.now()}`,
      password: 'legacy123',
      email: `legacy.${Date.now()}@hospital.com`,
      contactNumber: '9876543211',
      specialization: 'General Medicine',
      department: 'General Medicine'
    };
    
    console.log('Testing with legacy field structure...');
    const response = await makeRequest('POST', '/hospital-admin/doctors', legacyDoctorData);
    
    if (response.success) {
      console.log('✅ Backwards compatibility maintained');
      console.log('Legacy doctor created:', response.data.doctorId);
      return true;
    } else {
      console.log('❌ Backwards compatibility failed:', response.message);
      return false;
    }
  } catch (error) {
    console.log('❌ Backwards compatibility error:', error.response?.data?.message || error.message);
    return false;
  }
};

// Main test runner
const runAllTests = async () => {
  console.log('🧪 Starting Enhanced Doctor Creation Backend Tests');
  console.log('=' * 60);
  
  try {
    // Test 1: Login
    const loginSuccess = await testAdminLogin();
    if (!loginSuccess) {
      console.log('\n❌ Cannot proceed without authentication. Please check admin credentials.');
      return;
    }
    
    // Test 2: Create Enhanced Doctor
    const createdDoctor = await testCreateDoctor();
    if (!createdDoctor) {
      console.log('\n❌ Doctor creation failed. Cannot proceed with further tests.');
      return;
    }
    
    // Test 3: Retrieve and Verify
    const retrievedDoctor = await testGetAllDoctors();
    if (!retrievedDoctor) {
      console.log('\n❌ Could not retrieve created doctor.');
      return;
    }
    
    // Test 4: Validate Field Storage
    const fieldsValid = validateFieldStorage(retrievedDoctor);
    
    // Test 5: Backwards Compatibility
    const compatibilityOk = await testBackwardsCompatibility();
    
    // Final Summary
    console.log('\n' + '=' * 60);
    console.log('🏁 TEST SUMMARY');
    console.log('=' * 60);
    console.log('✅ Admin Authentication:', loginSuccess ? 'PASS' : 'FAIL');
    console.log('✅ Enhanced Doctor Creation:', createdDoctor ? 'PASS' : 'FAIL');
    console.log('✅ Doctor Retrieval:', retrievedDoctor ? 'PASS' : 'FAIL');
    console.log('✅ Field Storage Validation:', fieldsValid ? 'PASS' : 'FAIL');
    console.log('✅ Backwards Compatibility:', compatibilityOk ? 'PASS' : 'FAIL');
    
    const allTestsPassed = loginSuccess && createdDoctor && retrievedDoctor && fieldsValid && compatibilityOk;
    
    if (allTestsPassed) {
      console.log('\n🎉 ALL TESTS PASSED! Enhanced doctor creation backend is working correctly.');
    } else {
      console.log('\n⚠️ Some tests failed. Please check the backend implementation.');
    }
    
  } catch (error) {
    console.error('\n💥 Test runner error:', error.message);
  }
};

// Run tests if this file is executed directly
if (require.main === module) {
  runAllTests();
}

module.exports = {
  runAllTests,
  testAdminLogin,
  testCreateDoctor,
  testGetAllDoctors,
  validateFieldStorage,
  testBackwardsCompatibility
};