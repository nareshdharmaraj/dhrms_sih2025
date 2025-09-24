const http = require('http');

// Test function to check if API endpoints are working
async function testPatientAppointmentsAPI() {
  console.log('🧪 Testing Patient Appointments API...\n');
  
  const baseUrl = 'http://localhost:3000';
  const patientId = 'NARE523407';
  
  // Test 1: Get patient appointments
  try {
    console.log('📋 Test 1: Fetching patient appointments...');
    const response1 = await fetch(`${baseUrl}/api/patient-appointments/${patientId}`);
    const data1 = await response1.json();
    
    if (data1.success) {
      console.log('✅ SUCCESS: Patient appointments endpoint working');
      console.log(`   Found ${data1.count} appointments`);
      if (data1.data && data1.data.length > 0) {
        console.log(`   Sample appointment: ${data1.data[0].appointmentId}`);
      }
    } else {
      console.log('❌ FAILED: Patient appointments endpoint not working');
    }
  } catch (error) {
    console.log('❌ ERROR: Patient appointments endpoint not accessible');
    console.log('   Make sure the server is running with the new routes loaded');
  }
  
  // Test 2: Get patient appointments with filters
  try {
    console.log('\n🔍 Test 2: Testing filters...');
    const response2 = await fetch(`${baseUrl}/api/patient-appointments/${patientId}?status=pending`);
    const data2 = await response2.json();
    
    if (data2.success) {
      console.log('✅ SUCCESS: Filtering by status works');
      console.log(`   Found ${data2.count} pending appointments`);
    }
  } catch (error) {
    console.log('❌ ERROR: Filtering not working');
  }
  
  // Test 3: Get patient statistics
  try {
    console.log('\n📊 Test 3: Testing statistics...');
    const response3 = await fetch(`${baseUrl}/api/patient-appointments/stats/${patientId}`);
    const data3 = await response3.json();
    
    if (data3.success) {
      console.log('✅ SUCCESS: Statistics endpoint working');
      console.log('   Stats:', JSON.stringify(data3.data, null, 2));
    }
  } catch (error) {
    console.log('❌ ERROR: Statistics endpoint not working');
  }
  
  console.log('\n📝 Manual Test Commands:');
  console.log(`\n1. Get all appointments:`);
  console.log(`   curl -X GET "${baseUrl}/api/patient-appointments/${patientId}"`);
  
  console.log(`\n2. Filter by doctor name:`);
  console.log(`   curl -X GET "${baseUrl}/api/patient-appointments/${patientId}?doctorName=qwerty"`);
  
  console.log(`\n3. Filter by status:`);
  console.log(`   curl -X GET "${baseUrl}/api/patient-appointments/${patientId}?status=pending"`);
  
  console.log(`\n4. Get statistics:`);
  console.log(`   curl -X GET "${baseUrl}/api/patient-appointments/stats/${patientId}"`);
  
  console.log('\n⚠️  Note: If tests fail, restart the backend server to load new routes:');
  console.log('   cd backend && npm start');
}

// Check if fetch is available (Node.js 18+)
if (typeof fetch === 'undefined') {
  console.log('⚠️  fetch not available. Using manual test commands instead...\n');
  
  const baseUrl = 'http://localhost:3000';
  const patientId = 'NARE523407';
  
  console.log('📝 Manual Test Commands:');
  console.log(`\n1. Get all appointments:`);
  console.log(`   Invoke-WebRequest -Uri "${baseUrl}/api/patient-appointments/${patientId}" -Method GET | Select-Object -ExpandProperty Content`);
  
  console.log(`\n2. Filter by doctor name:`);
  console.log(`   Invoke-WebRequest -Uri "${baseUrl}/api/patient-appointments/${patientId}?doctorName=qwerty" -Method GET | Select-Object -ExpandProperty Content`);
  
  console.log(`\n3. Filter by status:`);
  console.log(`   Invoke-WebRequest -Uri "${baseUrl}/api/patient-appointments/${patientId}?status=pending" -Method GET | Select-Object -ExpandProperty Content`);
  
  console.log(`\n4. Get statistics:`);
  console.log(`   Invoke-WebRequest -Uri "${baseUrl}/api/patient-appointments/stats/${patientId}" -Method GET | Select-Object -ExpandProperty Content`);
  
} else {
  testPatientAppointmentsAPI();
}