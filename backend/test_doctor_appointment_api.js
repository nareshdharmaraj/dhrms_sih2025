const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test data - replace with actual doctor ID from your database
const TEST_DOCTOR_ID = '64f7a1b23e4d5c6789abc123'; // Replace with actual doctor ID

async function testDoctorAppointmentAPIs() {
    console.log('🧪 Testing Doctor Appointment APIs...\n');

    try {
        // Test 1: Get appointment statistics
        console.log('1️⃣ Testing statistics endpoint...');
        try {
            const statsResponse = await axios.get(`${BASE_URL}/doctor-appointments/stats/${TEST_DOCTOR_ID}`);
            console.log('✅ Statistics Response:', statsResponse.data);
        } catch (error) {
            console.log('❌ Statistics Error:', error.response?.data || error.message);
        }
        console.log();

        // Test 2: Get requests (pending appointments)
        console.log('2️⃣ Testing requests endpoint...');
        try {
            const requestsResponse = await axios.get(`${BASE_URL}/doctor-appointments/${TEST_DOCTOR_ID}/requests`);
            console.log('✅ Requests Response:', requestsResponse.data);
        } catch (error) {
            console.log('❌ Requests Error:', error.response?.data || error.message);
        }
        console.log();

        // Test 3: Get current appointments (approved)
        console.log('3️⃣ Testing current appointments endpoint...');
        try {
            const currentResponse = await axios.get(`${BASE_URL}/doctor-appointments/${TEST_DOCTOR_ID}/current`);
            console.log('✅ Current Appointments Response:', currentResponse.data);
        } catch (error) {
            console.log('❌ Current Appointments Error:', error.response?.data || error.message);
        }
        console.log();

        // Test 4: Get rejected appointments
        console.log('4️⃣ Testing rejected appointments endpoint...');
        try {
            const rejectedResponse = await axios.get(`${BASE_URL}/doctor-appointments/${TEST_DOCTOR_ID}/rejected`);
            console.log('✅ Rejected Appointments Response:', rejectedResponse.data);
        } catch (error) {
            console.log('❌ Rejected Appointments Error:', error.response?.data || error.message);
        }
        console.log();

        // Test 5: Test server health
        console.log('5️⃣ Testing server health...');
        try {
            const healthResponse = await axios.get('http://localhost:3000/health');
            console.log('✅ Server Health:', healthResponse.data);
        } catch (error) {
            console.log('❌ Health Check Error:', error.response?.data || error.message);
        }

        console.log('\n🏁 API Testing Complete!');
        console.log('\n📋 Next Steps:');
        console.log('1. Replace TEST_DOCTOR_ID with actual doctor ID from database');
        console.log('2. Create some test appointment data if needed');
        console.log('3. Test approve/reject endpoints with actual appointment IDs');
        console.log('4. Integrate the new Enhanced Doctor Screen in Flutter app');

    } catch (error) {
        console.error('❌ Overall Test Error:', error.message);
    }
}

// Also test with different doctor IDs
async function testWithMultipleDoctorIds() {
    console.log('\n🔍 Testing with common doctor ID patterns...\n');
    
    // Common test patterns
    const testIds = [
        'DOC001',
        'DOC_001',  
        'doctor1',
        'doctor_001',
        '507f1f77bcf86cd799439011', // Valid ObjectId format
        'test_doctor_id'
    ];

    for (const doctorId of testIds) {
        console.log(`🧪 Testing with Doctor ID: ${doctorId}`);
        try {
            const response = await axios.get(`${BASE_URL}/doctor-appointments/stats/${doctorId}`);
            console.log(`✅ Success for ${doctorId}:`, response.data.data);
        } catch (error) {
            console.log(`❌ Failed for ${doctorId}:`, error.response?.data?.message || error.message);
        }
        console.log();
    }
}

// Run the tests
testDoctorAppointmentAPIs()
    .then(() => testWithMultipleDoctorIds())
    .catch(error => {
        console.error('❌ Test suite failed:', error.message);
    });