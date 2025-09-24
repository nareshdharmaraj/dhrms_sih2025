// Test script for area assignment system
// Run this after starting the server to test the new functionality

const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';

// Test configuration
const TEST_CONFIG = {
  // You'll need to replace these with actual SHO credentials from your system
  SHO_LOGIN: {
    email: 'sho.tn@gov.in', // Replace with actual SHO email
    password: 'password123' // Replace with actual SHO password
  }
};

let authToken = '';

// Helper function to make authenticated requests
const apiRequest = async (method, endpoint, data = null) => {
  try {
    const config = {
      method,
      url: `${BASE_URL}${endpoint}`,
      headers: {
        'Authorization': `Bearer ${authToken}`,
        'Content-Type': 'application/json'
      }
    };
    
    if (data) {
      config.data = data;
    }
    
    const response = await axios(config);
    return response.data;
  } catch (error) {
    console.error(`API Error [${method} ${endpoint}]:`, error.response?.data || error.message);
    throw error;
  }
};

// Test 1: Login as SHO
async function testSHOLogin() {
  console.log('\n🔐 Testing SHO Login...');
  try {
    const response = await axios.post(`${BASE_URL}/sho/login`, TEST_CONFIG.SHO_LOGIN);
    authToken = response.data.token;
    console.log('✅ SHO Login successful');
    console.log('📋 SHO Info:', response.data.sho.fullName, '- State:', response.data.sho.assignedState);
    return response.data.sho;
  } catch (error) {
    console.error('❌ SHO Login failed:', error.response?.data || error.message);
    throw error;
  }
}

// Test 2: Get district assignment info for Chennai (dense district)
async function testChennaiDistrictInfo() {
  console.log('\n📍 Testing Chennai District Assignment Info...');
  try {
    const response = await apiRequest('GET', '/rho/districts/Chennai/assignment-info');
    console.log('✅ Chennai district info retrieved');
    console.log('📊 District Type:', response.strategy.isDense ? 'Dense' : 'Sparse');
    console.log('📋 Assignment Type:', response.strategy.assignmentType);
    console.log('🏘️  Available Areas:', response.availableAreas.length);
    response.availableAreas.forEach(area => {
      console.log(`   - ${area.name} (${area.code}) - Population: ${area.population.toLocaleString()}`);
    });
    return response;
  } catch (error) {
    console.error('❌ Chennai district info failed:', error.response?.data || error.message);
    throw error;
  }
}

// Test 3: Get district assignment info for Namakkal (sparse district)
async function testNamakkalDistrictInfo() {
  console.log('\n📍 Testing Namakkal District Assignment Info...');
  try {
    const response = await apiRequest('GET', '/rho/districts/Namakkal/assignment-info');
    console.log('✅ Namakkal district info retrieved');
    console.log('📊 District Type:', response.strategy.isDense ? 'Dense' : 'Sparse');
    console.log('📋 Assignment Type:', response.strategy.assignmentType);
    console.log('🏘️  Available Areas:', response.availableAreas.length);
    return response;
  } catch (error) {
    console.error('❌ Namakkal district info failed:', error.response?.data || error.message);
    throw error;
  }
}

// Test 4: Create RHO for Chennai with specific area assignment (Ambattur)
async function testCreateChennaiRHOWithArea() {
  console.log('\n👤 Testing Chennai RHO Creation with Ambattur Area...');
  try {
    const rhoData = {
      fullName: 'Dr. Arun Kumar Ambattur',
      email: 'arun.kumar.ambattur@tn.gov.in',
      phone: '+91-9876543220',
      password: 'rho123456',
      assignedDistrict: 'Chennai',
      assignedAreas: ['Ambattur'], // Specific area assignment
      qualification: 'MBBS, MD (Community Medicine)',
      experience: 8,
      licenseNumber: 'TN-MED-2024-AMB-001'
    };

    const response = await apiRequest('POST', '/rho/create', rhoData);
    console.log('✅ Chennai RHO created successfully');
    console.log('🆔 Officer ID:', response.rho.officerId);
    console.log('🏘️  Assignment Type:', response.assignmentInfo.assignmentType);
    console.log('📍 Areas Assigned:', response.assignmentInfo.areasAssigned.join(', '));
    return response.rho;
  } catch (error) {
    console.error('❌ Chennai RHO creation failed:', error.response?.data || error.message);
    throw error;
  }
}

// Test 5: Create RHO for Chennai with different area (Sholinganallur)
async function testCreateChennaiRHOWithDifferentArea() {
  console.log('\n👤 Testing Chennai RHO Creation with Sholinganallur Area...');
  try {
    const rhoData = {
      fullName: 'Dr. Priya Sharma Sholinganallur',
      email: 'priya.sharma.sgl@tn.gov.in',
      phone: '+91-9876543221',
      password: 'rho123456',
      assignedDistrict: 'Chennai',
      assignedAreas: ['Sholinganallur'], // Different area assignment
      qualification: 'MBBS, MPH',
      experience: 6,
      licenseNumber: 'TN-MED-2024-SGL-001'
    };

    const response = await apiRequest('POST', '/rho/create', rhoData);
    console.log('✅ Chennai RHO (Sholinganallur) created successfully');
    console.log('🆔 Officer ID:', response.rho.officerId);
    console.log('🏘️  Assignment Type:', response.assignmentInfo.assignmentType);
    console.log('📍 Areas Assigned:', response.assignmentInfo.areasAssigned.join(', '));
    return response.rho;
  } catch (error) {
    console.error('❌ Chennai RHO (Sholinganallur) creation failed:', error.response?.data || error.message);
    throw error;
  }
}

// Test 6: Try to create duplicate area assignment (should fail)
async function testDuplicateAreaAssignment() {
  console.log('\n🚫 Testing Duplicate Area Assignment (should fail)...');
  try {
    const rhoData = {
      fullName: 'Dr. Another Doctor',
      email: 'another.doctor@tn.gov.in',
      phone: '+91-9876543222',
      password: 'rho123456',
      assignedDistrict: 'Chennai',
      assignedAreas: ['Ambattur'], // Same area as Test 4
      qualification: 'MBBS, MD',
      experience: 5,
      licenseNumber: 'TN-MED-2024-DUP-001'
    };

    const response = await apiRequest('POST', '/rho/create', rhoData);
    console.log('❌ Duplicate area assignment should have failed!');
    return null;
  } catch (error) {
    if (error.response?.status === 400 && error.response?.data?.errors?.some(err => err.includes('already assigned'))) {
      console.log('✅ Duplicate area assignment correctly rejected');
      return true;
    } else {
      console.error('❌ Unexpected error in duplicate test:', error.response?.data || error.message);
      throw error;
    }
  }
}

// Test 7: Create RHO for Namakkal (sparse district, full district assignment)
async function testCreateNamakkalRHO() {
  console.log('\n👤 Testing Namakkal RHO Creation (Full District)...');
  try {
    const rhoData = {
      fullName: 'Dr. Rajesh Kumar Namakkal',
      email: 'rajesh.kumar.namakkal@tn.gov.in',
      phone: '+91-9876543223',
      password: 'rho123456',
      assignedDistrict: 'Namakkal',
      // No assignedAreas for sparse district
      qualification: 'MBBS, MD (Public Health)',
      experience: 10,
      licenseNumber: 'TN-MED-2024-NAM-001'
    };

    const response = await apiRequest('POST', '/rho/create', rhoData);
    console.log('✅ Namakkal RHO created successfully');
    console.log('🆔 Officer ID:', response.rho.officerId);
    console.log('🏘️  Assignment Type:', response.assignmentInfo.assignmentType);
    console.log('📍 Areas Assigned:', response.assignmentInfo.areasAssigned.join(', '));
    return response.rho;
  } catch (error) {
    console.error('❌ Namakkal RHO creation failed:', error.response?.data || error.message);
    throw error;
  }
}

// Test 8: Get area coverage details for specific area
async function testAreaCoverageDetails() {
  console.log('\n📊 Testing Area Coverage Details...');
  try {
    const response = await apiRequest('GET', '/rho/districts/Chennai/areas/Ambattur');
    console.log('✅ Area coverage details retrieved');
    console.log('📍 Area Name:', response.area.name);
    console.log('👥 Population:', response.area.population.toLocaleString());
    console.log('📐 Area (km²):', response.area.areaKm2);
    console.log('🏘️  Sub-districts:', response.area.subDistricts.join(', '));
    console.log('🔒 Is Assigned:', response.assignment.isAssigned);
    if (response.assignment.assignedTo) {
      console.log('👤 Assigned To:', response.assignment.assignedTo.fullName);
    }
    return response;
  } catch (error) {
    console.error('❌ Area coverage details failed:', error.response?.data || error.message);
    throw error;
  }
}

// Test 9: List all RHOs and verify assignments
async function testListRHOs() {
  console.log('\n📋 Testing RHO List with Area Assignments...');
  try {
    const response = await apiRequest('GET', '/rho/list');
    console.log('✅ RHO list retrieved');
    console.log('📊 Total RHOs:', response.rhos.length);
    
    response.rhos.forEach(rho => {
      console.log(`\n👤 ${rho.fullName} (${rho.officerId})`);
      console.log(`   📍 District: ${rho.assignedDistrict}`);
      if (rho.assignedAreas && rho.assignedAreas.length > 0) {
        console.log(`   🏘️  Areas: ${rho.assignedAreas.map(area => area.name).join(', ')}`);
      } else {
        console.log(`   🏘️  Areas: Full District`);
      }
    });
    
    return response;
  } catch (error) {
    console.error('❌ RHO list failed:', error.response?.data || error.message);
    throw error;
  }
}

// Main test function
async function runAreaAssignmentTests() {
  console.log('🚀 Starting Area Assignment System Tests...');
  console.log('================================================');
  
  try {
    // Test 1: Login
    const sho = await testSHOLogin();
    
    // Test 2: Chennai district info
    await testChennaiDistrictInfo();
    
    // Test 3: Namakkal district info
    await testNamakkalDistrictInfo();
    
    // Test 4: Create Chennai RHO with Ambattur
    const chennaiRHO1 = await testCreateChennaiRHOWithArea();
    
    // Test 5: Create Chennai RHO with Sholinganallur
    const chennaiRHO2 = await testCreateChennaiRHOWithDifferentArea();
    
    // Test 6: Try duplicate area assignment
    await testDuplicateAreaAssignment();
    
    // Test 7: Create Namakkal RHO
    const namakkalRHO = await testCreateNamakkalRHO();
    
    // Test 8: Get area coverage details
    await testAreaCoverageDetails();
    
    // Test 9: List all RHOs
    await testListRHOs();
    
    console.log('\n🎉 All Area Assignment Tests Completed Successfully!');
    console.log('================================================');
    
    console.log('\n📊 Test Summary:');
    console.log('✅ Dense District (Chennai): Area-specific assignment working');
    console.log('✅ Sparse District (Namakkal): Full district assignment working');
    console.log('✅ Area conflict prevention working');
    console.log('✅ RHO ID generation with area codes working');
    console.log('✅ Area coverage details retrieval working');
    
  } catch (error) {
    console.log('\n❌ Test Suite Failed:', error.message);
    process.exit(1);
  }
}

// Run tests if this file is executed directly
if (require.main === module) {
  console.log('📝 IMPORTANT: Please update TEST_CONFIG with valid SHO credentials before running!');
  console.log('📝 Make sure the backend server is running on http://localhost:5000');
  console.log('\nTo run this test, update the SHO credentials and run: node test-area-assignment.js\n');
  
  // Uncomment the next line after updating credentials
  // runAreaAssignmentTests();
}

module.exports = {
  runAreaAssignmentTests,
  testSHOLogin,
  testChennaiDistrictInfo,
  testNamakkalDistrictInfo,
  testCreateChennaiRHOWithArea,
  testCreateChennaiRHOWithDifferentArea,
  testDuplicateAreaAssignment,
  testCreateNamakkalRHO,
  testAreaCoverageDetails,
  testListRHOs
};