#!/usr/bin/env node

/**
 * Quick Test Script for Login Fix
 * Tests the hospital doctor login endpoint to verify validation bypass works
 * 
 * Run with: node test_login_fix.js
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

async function testDoctorLogin() {
  console.log('🧪 Testing Hospital Doctor Login Fix...\n');
  
  try {
    // Test with any doctor credentials (this will likely fail due to invalid creds)
    // but should NOT fail due to validation errors
    const response = await axios.post(`${BASE_URL}/hospital-doctor/login`, {
      username: 'test_doctor',
      password: 'test123',
      hospitalId: 'H001'
    });
    
    console.log('✅ Login successful:', response.data);
    
  } catch (error) {
    if (error.response) {
      const { status, data } = error.response;
      
      // Expected error: Invalid credentials (401)
      // NOT expected: ValidationError (500)
      if (status === 401 && data.message === 'Invalid credentials') {
        console.log('✅ Login validation fix working correctly!');
        console.log('   Expected 401 error received:', data.message);
        console.log('   No ValidationError means the fix is successful!\n');
      } else if (status === 500 && data.message?.includes('validation failed')) {
        console.log('❌ Validation error still occurring:');
        console.log('   Status:', status);
        console.log('   Error:', data.message);
        console.log('   The fix may need adjustment.\n');
      } else {
        console.log('ℹ️  Other error (may be expected):');
        console.log('   Status:', status);
        console.log('   Message:', data.message);
      }
    } else {
      console.log('❌ Network error:', error.message);
    }
  }
}

async function testHospitalList() {
  console.log('🏥 Testing Hospital List endpoint...\n');
  
  try {
    const response = await axios.get(`${BASE_URL}/hospital/list`);
    console.log('✅ Hospital list retrieved successfully');
    console.log('   Count:', response.data.count);
    console.log('   Hospitals available for testing\n');
  } catch (error) {
    console.log('❌ Hospital list error:', error.response?.data || error.message);
  }
}

async function runTests() {
  console.log('='.repeat(60));
  console.log('  HOSPITAL DOCTOR LOGIN VALIDATION FIX TEST');
  console.log('='.repeat(60));
  
  await testHospitalList();
  await testDoctorLogin();
  
  console.log('='.repeat(60));
  console.log('Test completed. Check the results above.');
  console.log('='.repeat(60));
}

// Run the test
runTests().catch(console.error);
