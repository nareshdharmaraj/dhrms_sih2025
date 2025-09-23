const axios = require('axios');

async function testAppointmentBooking() {
  try {
    const appointmentData = {
      patientId: 'TEST-001',
      patientName: 'Test Patient',
      doctorId: 'DOC-001',
      doctorName: 'Dr. Test Doctor',
      hospitalId: 'HOSP-001',
      hospitalName: 'Apollo Main Hospital',
      appointmentDate: '22/09/2025',
      appointmentTime: '10:00 AM',
      reason: 'Test booking',
      consultationFee: 500
    };

    console.log('🧪 Testing appointment booking...');
    console.log('📅 Data:', appointmentData);

    const response = await axios.post('http://localhost:3000/api/appointments', appointmentData, {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    console.log('✅ Success! Status:', response.status);
    console.log('📄 Response:', response.data);

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.response) {
      console.error('📄 Response data:', error.response.data);
      console.error('📄 Response status:', error.response.status);
    }
  }
}

testAppointmentBooking();