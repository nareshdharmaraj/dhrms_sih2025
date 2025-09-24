const http = require('http');

const data = JSON.stringify({
  "patientId": "NARE523407",
  "patientName": "NARESHD NARESHD",
  "doctorId": "H001QWER",
  "doctorName": "qwerty",
  "hospitalId": "HOSP-001",
  "hospitalName": "Apollo Main Hospital",
  "appointmentDate": "25/9/2025",
  "appointmentTime": "02:00 PM",
  "reason": "heart attack",
  "consultationFee": 100
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/appointments',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data)
  }
};

console.log('🧪 Testing appointment booking API...');
console.log('📋 Request data:', JSON.parse(data));

const req = http.request(options, (res) => {
  console.log(`📡 Status Code: ${res.statusCode}`);
  console.log(`📋 Headers:`, res.headers);

  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
  });

  res.on('end', () => {
    console.log('📦 Response Body:');
    try {
      const response = JSON.parse(body);
      console.log(JSON.stringify(response, null, 2));
      
      if (res.statusCode === 201) {
        console.log('✅ Appointment booking successful!');
        console.log(`🎫 Appointment ID: ${response.appointmentId}`);
      } else {
        console.log('❌ Appointment booking failed');
        console.log(`💥 Error: ${response.message}`);
      }
    } catch (e) {
      console.log('Raw response:', body);
    }
  });
});

req.on('error', (error) => {
  console.error('💥 Request error:', error);
});

req.write(data);
req.end();