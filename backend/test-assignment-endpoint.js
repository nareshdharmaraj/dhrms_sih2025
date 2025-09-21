const http = require('http');
const querystring = require('querystring');

// Test the assignment info endpoint
async function testAssignmentEndpoint() {
    try {
        // First login as SHO to get token
        const loginData = {
            usernameOrEmail: 'sho.tn@health.gov.in',
            password: 'Password123'
        };

        const loginResponse = await makeRequest('POST', '/auth/login', loginData);
        console.log('🔍 Login response:', loginResponse);

        if (!loginResponse.success) {
            console.error('❌ Login failed:', loginResponse.message);
            return;
        }

        const token = loginResponse.data.token;
        console.log('✅ Login successful, token received');

        // Test districts endpoint
        const districtsResponse = await makeRequest('GET', '/rho/districts', null, token);
        console.log('🔍 Districts response:', JSON.stringify(districtsResponse, null, 2));

        if (districtsResponse.success && districtsResponse.data.availableDistricts) {
            const districts = districtsResponse.data.availableDistricts;
            console.log(`✅ Found ${districts.length} districts`);
            
            // Test assignment info for first district
            if (districts.length > 0) {
                const testDistrict = districts[0].name;
                console.log(`🔍 Testing assignment info for: ${testDistrict}`);
                
                const assignmentResponse = await makeRequest('GET', `/rho/districts/${testDistrict}/assignment-info`, null, token);
                console.log('🔍 Assignment info response:', JSON.stringify(assignmentResponse, null, 2));
                
                if (assignmentResponse.success) {
                    console.log('✅ Assignment info endpoint working correctly');
                    console.log(`📊 District: ${assignmentResponse.district}`);
                    console.log(`📊 Type: ${assignmentResponse.type}`);
                    console.log(`📊 Requires area selection: ${assignmentResponse.requiresAreaSelection}`);
                    console.log(`📊 Available areas: ${assignmentResponse.availableAreas?.length || 0}`);
                    console.log(`📊 Subdistricts: ${assignmentResponse.subdistricts?.length || 0}`);
                } else {
                    console.error('❌ Assignment info failed:', assignmentResponse.message);
                }
            }
        } else {
            console.error('❌ Districts endpoint failed:', districtsResponse.message);
        }

    } catch (error) {
        console.error('❌ Test error:', error.message);
    }
}

function makeRequest(method, path, data, token = null) {
    return new Promise((resolve, reject) => {
        const postData = data ? JSON.stringify(data) : null;
        
        const options = {
            hostname: 'localhost',
            port: 3000,
            path: `/api${path}`,
            method: method,
            headers: {
                'Content-Type': 'application/json',
                ...(token && { 'Authorization': `Bearer ${token}` })
            }
        };

        const req = http.request(options, (res) => {
            let body = '';
            
            res.on('data', (chunk) => {
                body += chunk;
            });
            
            res.on('end', () => {
                try {
                    const jsonResponse = JSON.parse(body);
                    resolve(jsonResponse);
                } catch (e) {
                    resolve({ success: false, message: 'Invalid JSON response', body });
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        if (postData) {
            req.write(postData);
        }
        
        req.end();
    });
}

// Run the test
testAssignmentEndpoint();