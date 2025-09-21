const axios = require('axios');

async function testHospitalRegistration() {
    try {
        console.log('🏥 Testing Hospital Registration API...');
        
        const hospitalData = {
            hospitalName: "City General Hospital",
            address: {
                street: "123 Main Street",
                city: "Mumbai",
                state: "Maharashtra",
                district: "Mumbai",
                pincode: "400001"
            },
            contactNumber: "9876543210",
            email: "admin@citygeneral.com",
            registrationNumber: "REG123456",
            licenseId: "LIC789012",
            hospitalType: "Private",
            specialties: ["General Medicine", "Cardiology", "Surgery"],
            totalBeds: 100,
            emergencyServices: true,
            ambulanceServices: true,
            establishedYear: 1995,
            adminDetails: {
                username: "admin001",
                password: "password123",
                adminName: "Dr. Rajesh Kumar",
                adminEmail: "rajesh.kumar@citygeneral.com",
                adminPhone: "9876543211"
            }
        };

        const response = await axios.post('http://localhost:3000/api/hospital/register', hospitalData);
        
        console.log('✅ Hospital Registration Successful!');
        console.log('Hospital ID:', response.data.data.hospital.hospitalId);
        console.log('Admin ID:', response.data.data.admin.adminId);
        console.log('Token:', response.data.data.token);
        
        return response.data.data;
        
    } catch (error) {
        console.error('❌ Hospital Registration Failed:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Message:', error.response.data.message);
            console.error('Errors:', error.response.data.errors);
        } else {
            console.error('Error:', error.message);
        }
        return null;
    }
}

async function testDoctorCreation(token, hospitalId) {
    try {
        console.log('\n👨‍⚕️ Testing Doctor Creation API...');
        
        const doctorData = {
            username: "doctor001",
            password: "password123",
            doctorName: "Dr. Priya Sharma",
            email: "priya.sharma@citygeneral.com",
            contactNumber: "9876543212",
            specialization: "Cardiology",
            licenseNumber: "DOC123456",
            qualification: "MBBS, MD Cardiology",
            experienceYears: 10
        };

        const response = await axios.post('http://localhost:3000/api/hospital-admin/doctors', doctorData, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        console.log('✅ Doctor Creation Successful!');
        console.log('Doctor ID:', response.data.data.doctorId);
        console.log('Doctor Name:', response.data.data.doctorName);
        
        return response.data.data;
        
    } catch (error) {
        console.error('❌ Doctor Creation Failed:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Message:', error.response.data.message);
            console.error('Errors:', error.response.data.errors);
        } else {
            console.error('Error:', error.message);
        }
        return null;
    }
}

async function testAssistantCreation(token, doctorId) {
    try {
        console.log('\n👩‍💼 Testing Assistant Creation API...');
        
        const assistantData = {
            username: "assistant001",
            password: "password123",
            assistantName: "Ms. Anita Desai",
            email: "anita.desai@citygeneral.com",
            contactNumber: "9876543213",
            department: "Cardiology",
            qualification: "BSc Nursing",
            experienceYears: 5,
            assignedDoctor: doctorId
        };

        const response = await axios.post('http://localhost:3000/api/hospital-admin/assistants', assistantData, {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        console.log('✅ Assistant Creation Successful!');
        console.log('Assistant ID:', response.data.data.assistantId);
        console.log('Assistant Name:', response.data.data.assistantName);
        console.log('Assigned Doctor:', response.data.data.assignedDoctor);
        
        return response.data.data;
        
    } catch (error) {
        console.error('❌ Assistant Creation Failed:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Message:', error.response.data.message);
            console.error('Errors:', error.response.data.errors);
        } else {
            console.error('Error:', error.message);
        }
        return null;
    }
}

async function testAdminDashboard(token) {
    try {
        console.log('\n📊 Testing Admin Dashboard API...');
        
        const response = await axios.get('http://localhost:3000/api/hospital-admin/dashboard', {
            headers: {
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
            }
        });
        
        console.log('✅ Dashboard Data Retrieved Successfully!');
        console.log('Hospital:', response.data.data.hospital.hospitalName);
        console.log('Total Doctors:', response.data.data.stats.totalDoctors);
        console.log('Total Assistants:', response.data.data.stats.totalAssistants);
        
        return response.data.data;
        
    } catch (error) {
        console.error('❌ Dashboard Retrieval Failed:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Message:', error.response.data.message);
        } else {
            console.error('Error:', error.message);
        }
        return null;
    }
}

async function runTests() {
    console.log('🧪 Starting Hospital Management System API Tests...\n');
    
    // Step 1: Register Hospital
    const hospitalData = await testHospitalRegistration();
    if (!hospitalData) {
        console.error('❌ Hospital registration failed. Stopping tests.');
        return;
    }
    
    const { token, hospital, admin } = hospitalData;
    
    // Step 2: Create Doctor
    const doctorData = await testDoctorCreation(token, hospital._id);
    if (!doctorData) {
        console.error('❌ Doctor creation failed. Continuing with other tests...');
    }
    
    // Step 3: Create Assistant
    if (doctorData) {
        const assistantData = await testAssistantCreation(token, doctorData._id);
        if (!assistantData) {
            console.error('❌ Assistant creation failed. Continuing with other tests...');
        }
    }
    
    // Step 4: Test Dashboard
    await testAdminDashboard(token);
    
    console.log('\n🎉 Tests Completed!');
    console.log('\n📋 Summary:');
    console.log(`Hospital: ${hospital.hospitalName} (ID: ${hospital.hospitalId})`);
    console.log(`Admin: ${admin.adminName} (ID: ${admin.adminId})`);
    if (doctorData) {
        console.log(`Doctor: ${doctorData.doctorName} (ID: ${doctorData.doctorId})`);
    }
}

// Install axios if not present
try {
    require('axios');
    runTests();
} catch (error) {
    console.log('📦 Installing axios package...');
    const { exec } = require('child_process');
    exec('npm install axios', (error, stdout, stderr) => {
        if (error) {
            console.error('❌ Failed to install axios:', error);
            return;
        }
        console.log('✅ Axios installed successfully');
        runTests();
    });
}