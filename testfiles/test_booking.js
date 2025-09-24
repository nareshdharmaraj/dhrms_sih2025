// Test appointment booking with sample data
const sampleAppointment = {
  patientId: '68c0065c99ba74782396e8e0',  // Use a valid patient ID from your DB
  patientName: 'John Doe Test',
  doctorId: '68c0065c99ba74782396e8ee',    // Use the doctor ID we tested earlier
  doctorName: 'Dr. Test Doctor',
  hospitalId: '68cfb655dbb1cd543710dc26',  // Use valid hospital ID
  hospitalName: 'Apollo Main Hospital',
  appointmentDate: '25/09/2025',
  appointmentTime: '10:00 AM',
  reason: 'General consultation test',
  consultationFee: 500
};

console.log('🧪 Testing Appointment Booking API');
console.log('=' * 50);
console.log('Sample data:', JSON.stringify(sampleAppointment, null, 2));

// Test with curl command format
const curlCommand = `curl -X POST "http://localhost:3000/api/appointments" -H "Content-Type: application/json" -d '${JSON.stringify(sampleAppointment)}'`;
console.log('\nCurl command to test:');
console.log(curlCommand);