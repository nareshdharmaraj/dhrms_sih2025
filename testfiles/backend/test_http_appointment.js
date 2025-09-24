// Simple HTTP test for appointment booking
const https = require('https');
const http = require('http');

const appointmentData = {
  patientId: 'TEST-002',
  patientName: 'Test Patient 2',
  doctorId: 'DOC-001',
  doctorName: 'Dr. Test Doctor',
  hospitalId: 'HOSP-001',
  hospitalName: 'Apollo Main Hospital',
  appointmentDate: '22/09/2025',
  appointmentTime: '11:00 AM',
  reason: 'Test booking via HTTP',
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

console.log('🧪 Testing appointment booking via native HTTP...');
console.log('📅 Data:', appointmentData);

const req = http.request(options, (res) => {
  console.log(`📡 Status Code: ${res.statusCode}`);
  console.log(`📡 Headers:`, res.headers);

  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('📄 Response:', data);
    if (res.statusCode === 201) {
      console.log('✅ Appointment booking successful!');
    } else {
      console.log('❌ Appointment booking failed!');
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Request error:', error);
});

req.write(postData);
req.end();