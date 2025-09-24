// Comprehensive appointment booking test
console.log('🧪 COMPREHENSIVE APPOINTMENT BOOKING TEST');
console.log('='.repeat(50));

// Test 1: Check if server is running
async function testServerHealth() {
  console.log('\n1️⃣ Testing server health...');
  try {
    const response = await fetch('http://localhost:3000/health');
    if (response.ok) {
      console.log('✅ Server is running');
      return true;
    } else {
      console.log('❌ Server responded with error:', response.status);
      return false;
    }
  } catch (error) {
    console.log('❌ Server is not running:', error.message);
    return false;
  }
}

// Test 2: Check existing appointments
async function testExistingAppointments() {
  console.log('\n2️⃣ Checking existing appointments...');
  try {
    const response = await fetch('http://localhost:3000/api/appointments');
    if (response.ok) {
      const data = await response.json();
      console.log(`✅ Found ${data.length} existing appointments`);
      if (data.length > 0) {
        console.log('📋 First appointment sample:', {
          _id: data[0]._id,
          patientId: data[0].patientId,
          doctorId: data[0].doctorId || data[0].hospitalStaffId,
          hospitalName: data[0].hospitalName,
          status: data[0].status
        });
      }
      return true;
    } else {
      console.log('❌ Failed to fetch appointments:', response.status);
      return false;
    }
  } catch (error) {
    console.log('❌ Error fetching appointments:', error.message);
    return false;
  }
}

// Test 3: Create new appointment
async function testAppointmentCreation() {
  console.log('\n3️⃣ Testing appointment creation...');
  
  const appointmentData = {
    patientId: 'PAT-TEST-001',
    patientName: 'Test Patient Flutter',
    doctorId: 'DOC-001',
    doctorName: 'Dr. Test Doctor',
    hospitalId: 'HOSP-001',
    hospitalName: 'Apollo Main Hospital',
    appointmentDate: '23/09/2025',
    appointmentTime: '2:00 PM',
    reason: 'Flutter app test booking',
    consultationFee: 500
  };

  console.log('📅 Appointment data:', appointmentData);

  try {
    const response = await fetch('http://localhost:3000/api/appointments', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(appointmentData)
    });

    console.log('📡 Response status:', response.status);
    const responseData = await response.text();
    console.log('📄 Response body:', responseData);

    if (response.status === 201) {
      const result = JSON.parse(responseData);
      console.log('✅ Appointment created successfully!');
      console.log('🎫 Appointment ID:', result.appointmentId);
      return { success: true, appointmentId: result.appointmentId };
    } else {
      console.log('❌ Failed to create appointment');
      try {
        const errorData = JSON.parse(responseData);
        console.log('❌ Error details:', errorData);
      } catch (e) {
        console.log('❌ Raw error:', responseData);
      }
      return { success: false, error: responseData };
    }
  } catch (error) {
    console.log('❌ Network error:', error.message);
    return { success: false, error: error.message };
  }
}

// Test 4: Verify appointment was stored
async function testAppointmentStorage(appointmentId) {
  console.log('\n4️⃣ Verifying appointment storage...');
  
  try {
    const response = await fetch('http://localhost:3000/api/appointments');
    if (response.ok) {
      const appointments = await response.json();
      const newAppointment = appointments.find(apt => 
        apt.appointmentId === appointmentId || 
        apt.patientName === 'Test Patient Flutter'
      );
      
      if (newAppointment) {
        console.log('✅ Appointment found in database!');
        console.log('📋 Stored appointment:', {
          appointmentId: newAppointment.appointmentId,
          patientName: newAppointment.patientName,
          doctorName: newAppointment.doctorName,
          hospitalName: newAppointment.hospitalName,
          appointmentDate: newAppointment.appointmentDate,
          appointmentTime: newAppointment.appointmentTime,
          status: newAppointment.status
        });
        return true;
      } else {
        console.log('❌ Appointment not found in database');
        return false;
      }
    } else {
      console.log('❌ Failed to fetch appointments for verification');
      return false;
    }
  } catch (error) {
    console.log('❌ Error verifying appointment storage:', error.message);
    return false;
  }
}

// Run all tests
async function runComprehensiveTest() {
  console.log('🚀 Starting comprehensive appointment booking test...\n');

  // Test 1: Server Health
  const serverOk = await testServerHealth();
  if (!serverOk) {
    console.log('\n❌ CRITICAL: Server is not running. Please start the server first.');
    return;
  }

  // Test 2: Existing Appointments
  await testExistingAppointments();

  // Test 3: Create Appointment
  const creationResult = await testAppointmentCreation();
  if (!creationResult.success) {
    console.log('\n❌ CRITICAL: Appointment creation failed.');
    console.log('🔍 This is the main issue that needs to be fixed.');
    return;
  }

  // Test 4: Verify Storage
  const storageOk = await testAppointmentStorage(creationResult.appointmentId);
  
  // Final Summary
  console.log('\n' + '='.repeat(50));
  console.log('📊 COMPREHENSIVE TEST SUMMARY');
  console.log('='.repeat(50));
  console.log('✅ Server Health:', serverOk ? 'PASS' : 'FAIL');
  console.log('✅ Appointment Creation:', creationResult.success ? 'PASS' : 'FAIL');
  console.log('✅ Database Storage:', storageOk ? 'PASS' : 'FAIL');
  
  if (serverOk && creationResult.success && storageOk) {
    console.log('\n🎉 ALL TESTS PASSED! Appointment booking is working correctly.');
    console.log('🔄 You can now test the Flutter app - it should work properly.');
  } else {
    console.log('\n❌ Some tests failed. The appointment booking system needs fixing.');
  }
}

// Start the test
runComprehensiveTest().catch(console.error);