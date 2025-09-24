const axios = require('axios');

async function testPrescriptionAPIWithRealData() {
    try {
        console.log('\n🌐 TESTING PRESCRIPTION API WITH REAL FRONTEND DATA');
        console.log('=' .repeat(70));
        
        // This is the exact data from the frontend request
        const realRequestData = {
            "appointmentId": "68d29fdc8cd6da1fca2c18d0",
            "doctorId": "68cfb6f6fd481e8dcf67744c",
            "patientId": "NARE523407",
            "hospitalId": "HOSP-001",
            "patientName": "NARESHD NARESHD",
            "patientUHID": "NARE523407",
            "doctorName": "Dr. A John Smith",
            "doctorIdentifier": "DOC-001",
            "hospitalName": "Apollo Main Hospital",
            "hospitalAddress": "",
            "hospitalContact": {
                "phone": "",
                "email": ""
            },
            "appointmentNumber": "APT-TEST-001", // Adding the missing field
            "diseaseName": "malarial disease",
            "diseaseType": "communicable",
            "expectedRecoveryDays": 7,
            "medicines": [
                {
                    "type": "tablet",
                    "name": "dolo",
                    "power": "650",
                    "countPerDose": 1,
                    "timing": [
                        "morning",
                        "night"
                    ],
                    "beforeAfterFood": "after",
                    "duration": 7,
                    "totalCount": 14
                },
                {
                    "type": "injection",
                    "name": "anti malarial",
                    "dosageDetails": "5 ml",
                    "frequency": "1",
                    "additionalNotes": "saves from spreading"
                }
            ],
            "nextVisitDate": "2025-09-30T00:00:00.000",
            "nextVisitMandatory": true,
            "isConfirmed": true
        };
        
        // Test with the no-auth endpoint first
        console.log('\n🔵 TEST 1: NO-AUTH API ENDPOINT');
        console.log('=' .repeat(50));
        
        try {
            const noAuthResponse = await axios.post('http://localhost:3000/api/test/prescriptions', realRequestData, {
                headers: {
                    'Content-Type': 'application/json'
                }
            });
            
            console.log('✅ No-auth API call successful!');
            console.log('📋 Response status:', noAuthResponse.status);
            console.log('📋 Response data:', JSON.stringify(noAuthResponse.data, null, 2));
            
        } catch (noAuthError) {
            console.error('❌ No-auth API call failed:');
            console.error('📋 Status:', noAuthError.response?.status);
            console.error('📋 Data:', noAuthError.response?.data);
            console.error('📋 Message:', noAuthError.message);
        }
        
        // Test with the regular auth endpoint
        console.log('\n🔵 TEST 2: AUTH API ENDPOINT');
        console.log('=' .repeat(50));
        
        const authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N0b3JJZCI6IkRPQy0wMDEiLCJob3NwaXRhbElkIjoiSE9TUC0wMDEiLCJyb2xlIjoiaG9zcGl0YWxfZG9jdG9yIiwiaWF0IjoxNzU4NjUxMzkzLCJleHAiOjE3NTg3Mzc3OTN9.twxLom9wqSbDM5KYO7FOxQxpYBMITAxsap7Wg4sAQFE';
        
        try {
            const authResponse = await axios.post('http://localhost:3000/api/prescriptions', realRequestData, {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${authToken}`
                }
            });
            
            console.log('✅ Auth API call successful!');
            console.log('📋 Response status:', authResponse.status);
            console.log('📋 Response data:', JSON.stringify(authResponse.data, null, 2));
            
        } catch (authError) {
            console.error('❌ Auth API call failed:');
            console.error('📋 Status:', authError.response?.status);
            console.error('📋 Data:', authError.response?.data);
            console.error('📋 Message:', authError.message);
        }
        
    } catch (error) {
        console.error('\n❌ Test setup failed:', error);
    }
}

testPrescriptionAPIWithRealData();