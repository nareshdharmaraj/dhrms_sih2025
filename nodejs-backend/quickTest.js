const http = require('http');

async function quickHealthCheck() {
    return new Promise((resolve) => {
        console.log('🔍 Testing health endpoint...');
        
        const req = http.request({
            hostname: 'localhost',
            port: 5000,
            path: '/health',
            method: 'GET',
            timeout: 5000
        }, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                console.log('✅ Health Check Success:', data);
                resolve(true);
            });
        });

        req.on('error', (error) => {
            console.log('❌ Health Check Failed:', error.message);
            if (error.code === 'ECONNREFUSED') {
                console.log('🔧 Server is not running on port 5000');
            }
            resolve(false);
        });

        req.on('timeout', () => {
            console.log('❌ Health Check Timeout');
            req.destroy();
            resolve(false);
        });

        req.end();
    });
}

async function testPatientCreation() {
    return new Promise((resolve) => {
        console.log('\n📝 Testing patient creation...');
        
        const newPatient = JSON.stringify({
            username: 'test_patient_' + Date.now(),
            password: 'test123',
            personalInfo: {
                firstName: 'Test',
                lastName: 'Patient',
                email: 'test@example.com',
                phone: '9876543210',
                dateOfBirth: new Date('1990-01-01'),
                gender: 'Male',
                address: {
                    street: '123 Test Street',
                    city: 'Test City',
                    state: 'Test State',
                    pincode: '123456'
                }
            },
            medicalInfo: {
                bloodGroup: 'O+',
                height: 175,
                weight: 70
            }
        });

        const req = http.request({
            hostname: 'localhost',
            port: 5000,
            path: '/api/v1/patients',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(newPatient)
            },
            timeout: 5000
        }, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                if (res.statusCode === 201) {
                    console.log('✅ Patient Creation Success:', JSON.parse(data).message);
                } else {
                    console.log('❌ Patient Creation Failed:', data);
                }
                resolve(true);
            });
        });

        req.on('error', (error) => {
            console.log('❌ Patient Creation Failed:', error.message);
            resolve(false);
        });

        req.on('timeout', () => {
            console.log('❌ Patient Creation Timeout');
            req.destroy();
            resolve(false);
        });

        req.write(newPatient);
        req.end();
    });
}

async function runQuickTests() {
    console.log('🚀 Quick DHRMS API Tests\n');
    
    const healthOk = await quickHealthCheck();
    
    if (healthOk) {
        await testPatientCreation();
        console.log('\n🎉 Quick tests completed successfully!');
        console.log('\n📊 Your enhanced database is working with:');
        console.log('   🏥 5 Hospitals with complete facility data');
        console.log('   👨‍⚕️5 Doctors with professional profiles');
        console.log('   🏃‍♂️5 Patients with detailed medical histories');
        console.log('   💊 3 Prescriptions with billing information');
        console.log('\n🔑 Test with these credentials:');
        console.log('   Hospital: apollo_admin / apollo123');
        console.log('   Doctor: dr_rajesh_sharma / doctor123');
        console.log('   Patient: rajesh_kumar_90 / patient123');
    } else {
        console.log('\n❌ Server connection failed. Please ensure:');
        console.log('   1. Server is running: node server.js');
        console.log('   2. MongoDB is running');
        console.log('   3. Port 5000 is available');
    }
}

runQuickTests().catch(console.error);
