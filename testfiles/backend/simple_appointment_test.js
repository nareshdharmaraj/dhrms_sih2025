// Simple test to create appointment via API
const http = require('http');

const appointmentData = {
  patientId: 'PAT-001',
  patientName: 'Test Patient',
  doctorId: 'DOC-001', 
  doctorName: 'Dr. Test Doctor',
  hospitalId: 'HOSP-001',
  hospitalName: 'Apollo Main Hospital',
  appointmentDate: '22/09/2025',
  appointmentTime: '10:00 AM',
  reason: 'Test consultation',
  consultationFee: 500
};

const data = JSON.stringify(appointmentData);

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/appointments',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

console.log('🧪 Testing appointment creation via HTTP...');
console.log('📅 Data:', appointmentData);

const req = http.request(options, (res) => {
  console.log(`📡 Status: ${res.statusCode}`);
  
  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
  });
  
  res.on('end', () => {
    console.log('📄 Response:', body);
    try {
      const response = JSON.parse(body);
      if (response.success) {
        console.log('✅ Appointment created successfully!');
        console.log('🎫 Appointment ID:', response.appointmentId);
      } else {
        console.log('❌ Failed to create appointment:', response.message);
      }
    } catch (e) {
      console.log('📄 Raw response:', body);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Request error:', error);
});

req.write(data);
req.end();