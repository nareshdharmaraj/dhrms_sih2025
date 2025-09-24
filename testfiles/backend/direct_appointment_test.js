// Simple direct appointment creation test
const http = require('http');

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

const postData = JSON.stringify(appointmentData);

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/appointments',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('🧪 DIRECT APPOINTMENT CREATION TEST');
console.log('='.repeat(40));
console.log('📅 Appointment data:', appointmentData);
console.log('🌐 Request URL: http://localhost:3000/api/appointments');

const req = http.request(options, (res) => {
  console.log(`📡 Status: ${res.statusCode}`);
  console.log(`📋 Headers:`, res.headers);

  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
  });

  res.on('end', () => {
    console.log('📄 Response body:', body);
    
    if (res.statusCode === 201) {
      try {
        const result = JSON.parse(body);
        console.log('✅ SUCCESS! Appointment created');
        console.log('🎫 Appointment ID:', result.appointmentId);
      } catch (e) {
        console.log('✅ SUCCESS! Response:', body);
      }
    } else {
      console.log('❌ FAILED! Status:', res.statusCode);
      console.log('❌ Error details:', body);
    }
  });
});

req.on('error', (e) => {
  console.log('❌ Request error:', e.message);
});

req.write(postData);
req.end();