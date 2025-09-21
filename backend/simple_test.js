const axios = require('axios');

async function simpleTest() {
    try {
        console.log('Testing server connection...');
        const healthCheck = await axios.get('http://localhost:3000/health');
        console.log('✅ Server is running:', healthCheck.data);
        
        console.log('\nTesting hospital registration...');
        const hospitalData = {
            hospitalName: "Test Hospital",
            address: {
                street: "123 Test Street",
                city: "Mumbai",
                state: "Maharashtra", 
                district: "Mumbai",
                pincode: "400001"
            },
            contactNumber: "9876543210",
            email: "test@hospital.com",
            registrationNumber: "REG001",
            licenseId: "LIC001",
            hospitalType: "Private",
            specialties: ["General Medicine"],
            totalBeds: 50,
            emergencyServices: true,
            ambulanceServices: false,
            establishedYear: 2020,
            adminDetails: {
                username: "testadmin",
                password: "test123",
                adminName: "Test Admin",
                adminEmail: "admin@hospital.com", 
                adminPhone: "9876543211"
            }
        };
        
        const response = await axios.post('http://localhost:3000/api/hospital/register', hospitalData);
        console.log('✅ Hospital registered successfully!');
        console.log('Response:', JSON.stringify(response.data, null, 2));
        
    } catch (error) {
        console.error('❌ Error occurred:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Response:', error.response.data);
        } else if (error.request) {
            console.error('No response received:', error.request);
        } else {
            console.error('Error setting up request:', error.message);
        }
        console.error('Full error:', error);
    }
}

simpleTest();