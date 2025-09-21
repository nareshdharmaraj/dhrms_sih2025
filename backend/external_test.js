const axios = require('axios');

async function testExternalIP() {
    try {
        console.log('Testing server on external IP...');
        const response = await axios.get('http://10.123.62.47:3000/health');
        console.log('✅ Server accessible on external IP:', response.data);
        
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
        
        const regResponse = await axios.post('http://10.123.62.47:3000/api/hospital/register', hospitalData);
        console.log('✅ Hospital registered successfully!');
        console.log('Hospital ID:', regResponse.data.data.hospital.hospitalId);
        console.log('Admin ID:', regResponse.data.data.admin.adminId);
        console.log('Token received:', regResponse.data.data.token ? 'Yes' : 'No');
        
        return regResponse.data.data;
        
    } catch (error) {
        console.error('❌ Error occurred:');
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Response:', error.response.data);
        } else {
            console.error('Error message:', error.message);
        }
    }
}

testExternalIP();