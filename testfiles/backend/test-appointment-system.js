const { spawn } = require('child_process');
const path = require('path');

console.log('🧪 Starting appointment system test...\n');

// Start the backend server
const backend = spawn('node', ['src/server.js'], {
  cwd: path.join(__dirname),
  stdio: 'inherit'
});

console.log('✅ Backend server started for testing');
console.log('📋 Test the following endpoints:');
console.log('');
console.log('🏥 Hospitals:');
console.log('   GET /api/hospital/list');
console.log('');
console.log('👨‍⚕️ Doctors:');
console.log('   GET /api/appointments/hospitals/{hospitalId}/doctors');
console.log('');
console.log('📅 Appointments:');
console.log('   POST /api/appointments - Create appointment');
console.log('   GET /api/appointments/doctor/{doctorId} - Get doctor appointments');
console.log('   GET /api/appointments/patient/{patientId} - Get patient appointments');
console.log('   PUT /api/appointments/{appointmentId}/status - Update status');
console.log('   GET /api/appointments/{appointmentId} - Get specific appointment');
console.log('');
console.log('🔗 Test URLs:');
console.log('   http://localhost:3000/health - Health check');
console.log('   http://localhost:3000/api/hospital/list - Hospital list');
console.log('');
console.log('⏹️  Press Ctrl+C to stop the server');

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n🛑 Stopping test server...');
  backend.kill();
  process.exit(0);
});

backend.on('close', (code) => {
  console.log(`Backend server exited with code ${code}`);
});