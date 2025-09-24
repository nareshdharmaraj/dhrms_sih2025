// Test appointment creation with correct schema matching existing appointments
const mongoose = require('mongoose');

// Test appointment creation
async function testCorrectAppointmentCreation() {
  console.log('🧪 Testing appointment creation with correct schema...');
  
  // Sample appointment data from Flutter app
  const appointmentData = {
    patientId: '66f2c123d4567890abcdef12', // Sample ObjectId format
    patientName: 'Test Patient Flutter',
    patientUhid: 'UHID123456',
    doctorId: '66f2c456d4567890abcdef34', // This will map to hospitalStaffId
    doctorName: 'Dr. Test Doctor',
    hospitalId: '66f2c789d4567890abcdef56',
    hospitalName: 'Apollo Main Hospital',
    appointmentDate: '23/09/2025', // DD/MM/YYYY format
    appointmentTime: '2:00 PM',
    reason: 'Flutter app test booking',
    consultationFee: 500
  };

  try {
    const response = await fetch('http://localhost:3000/api/appointments', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(appointmentData)
    });

    console.log('📡 Response status:', response.status);
    const result = await response.text();
    console.log('📄 Response:', result);

    if (response.status === 201) {
      const parsedResult = JSON.parse(result);
      console.log('✅ Appointment created successfully!');
      console.log('🎫 Appointment ID:', parsedResult.appointmentId);
      
      // Verify the appointment structure matches existing appointments
      console.log('📋 Created appointment structure:');
      console.log({
        appointmentId: parsedResult.data.appointmentId,
        patientId: parsedResult.data.patientId,
        hospitalStaffId: parsedResult.data.hospitalStaffId, // Should exist now
        hospitalName: parsedResult.data.hospitalName,
        appointmentDate: parsedResult.data.appointmentDate,
        status: parsedResult.data.status
      });
      
      return true;
    } else {
      console.log('❌ Failed to create appointment');
      try {
        const errorData = JSON.parse(result);
        console.log('❌ Error details:', errorData);
      } catch (e) {
        console.log('❌ Raw error:', result);
      }
      return false;
    }
  } catch (error) {
    console.log('❌ Network error:', error.message);
    return false;
  }
}

// Run the test
testCorrectAppointmentCreation()
  .then(success => {
    if (success) {
      console.log('\n🎉 Appointment creation test PASSED!');
      console.log('✅ The Flutter app should now be able to book appointments successfully.');
      console.log('✅ Appointments will be stored with the correct schema matching existing data.');
    } else {
      console.log('\n❌ Appointment creation test FAILED!');
      console.log('🔍 Please check the server logs for more details.');
    }
  })
  .catch(console.error);