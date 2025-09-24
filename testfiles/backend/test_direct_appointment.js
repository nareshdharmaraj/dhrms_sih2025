const mongoose = require('mongoose');

// Connect to MongoDB
mongoose.connect('mongodb+srv://nareshdharmaraj:KYMvhOaQjSNJvLLJ@cluster0.8xhvo.mongodb.net/myhealth?retryWrites=true&w=majority&appName=Cluster0');

// Define a simple appointment schema (matching our updated model)
const appointmentSchema = new mongoose.Schema({
  appointmentId: { type: String, required: true, unique: true },
  patientId: { type: String, required: true },
  patientName: { type: String, required: true },
  patientUhid: { type: String, required: true },
  doctorId: { type: String, required: true },
  doctorName: { type: String, required: true },
  hospitalId: { type: String, required: true },
  hospitalName: { type: String, required: true },
  appointmentDate: { type: String, required: true },
  appointmentTime: { type: String, required: true },
  reason: { type: String, required: true },
  consultationFee: { type: Number, required: true },
  status: { type: String, default: 'pending' }
});

const Appointment = mongoose.model('HospitalAppointment', appointmentSchema);

async function testDirectAppointment() {
  try {
    console.log('📅 Testing direct appointment creation...');
    
    const appointmentData = {
      appointmentId: `APT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      patientId: 'TEST-001',
      patientName: 'Test Patient',
      patientUhid: 'TEST-001',
      doctorId: 'DOC-001',
      doctorName: 'Dr. Test Doctor',
      hospitalId: 'HOSP-001',
      hospitalName: 'Apollo Main Hospital',
      appointmentDate: '2025-09-22',
      appointmentTime: '10:00 AM',
      reason: 'Test booking',
      consultationFee: 500,
      status: 'pending'
    };

    const appointment = new Appointment(appointmentData);
    const savedAppointment = await appointment.save();
    
    console.log('✅ Appointment created successfully!');
    console.log('📄 Appointment ID:', savedAppointment.appointmentId);
    console.log('📄 Full appointment:', savedAppointment);
    
    // Check if it exists in the database
    const foundAppointment = await Appointment.findOne({ appointmentId: savedAppointment.appointmentId });
    console.log('🔍 Found in database:', foundAppointment ? 'Yes' : 'No');
    
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Error creating appointment:', error.message);
    console.error('Full error:', error);
    process.exit(1);
  }
}

testDirectAppointment();