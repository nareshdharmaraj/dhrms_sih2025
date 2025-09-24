#!/usr/bin/env node

const http = require('http');

// Test WHO login and comprehensive analytics
async function testWhoAnalytics() {
    console.log('🧪 Testing WHO Comprehensive Analytics...\n');

    try {
        // Step 1: Login as WHO admin
        console.log('📋 Step 1: Login as WHO Admin');
        const loginData = JSON.stringify({
            adminId: 'WHO_ADMIN_001',
            password: 'WhoAdmi@2024'
        });

        const loginOptions = {
            hostname: 'localhost',
            port: 3000,
            path: '/api/who/login',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(loginData)
            }
        };

        const loginResponse = await new Promise((resolve, reject) => {
            const req = http.request(loginOptions, (res) => {
                let data = '';
                res.on('data', (chunk) => data += chunk);
                res.on('end', () => {
                    try {
                        resolve({ status: res.statusCode, data: JSON.parse(data) });
                    } catch (e) {
                        reject(e);
                    }
                });
            });
            req.on('error', reject);
            req.write(loginData);
            req.end();
        });

        console.log(`Login Status: ${loginResponse.status}`);
        
        if (loginResponse.status !== 200 || !loginResponse.data.success) {
            console.log('❌ WHO Login failed:', loginResponse.data.message);
            return;
        }

        const authToken = loginResponse.data.token;
        console.log('✅ WHO Login successful\n');

        // Step 2: Test comprehensive analytics endpoint
        console.log('📋 Step 2: Test Comprehensive Analytics Endpoint');
        
        const analyticsOptions = {
            hostname: 'localhost',
            port: 3000,
            path: '/api/who/analytics/comprehensive',
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            }
        };

        const analyticsResponse = await new Promise((resolve, reject) => {
            const req = http.request(analyticsOptions, (res) => {
                let data = '';
                res.on('data', (chunk) => data += chunk);
                res.on('end', () => {
                    try {
                        resolve({ status: res.statusCode, data: JSON.parse(data) });
                    } catch (e) {
                        reject(e);
                    }
                });
            });
            req.on('error', reject);
            req.end();
        });

        console.log(`Analytics Status: ${analyticsResponse.status}`);
        
        if (analyticsResponse.status !== 200 || !analyticsResponse.data.success) {
            console.log('❌ Comprehensive Analytics failed:', analyticsResponse.data.message);
            return;
        }

        console.log('✅ Comprehensive Analytics successful\n');

        // Step 3: Display analytics summary
        const analytics = analyticsResponse.data.analytics;
        console.log('📊 ANALYTICS SUMMARY:');
        console.log('=' .repeat(50));
        
        if (analytics.hierarchy && analytics.hierarchy.totals) {
            const totals = analytics.hierarchy.totals;
            console.log(`👥 Total SHOs: ${totals.totalSHOs || 'N/A'}`);
            console.log(`🏥 Total RHOs: ${totals.totalRHOs || 'N/A'}`);
            console.log(`🏢 Total Hospitals: ${totals.totalHospitals || 'N/A'}`);
            console.log(`⚕️  Total Doctors: ${totals.totalDoctors || 'N/A'}`);
            console.log(`👨‍⚕️ Total Assistants: ${totals.totalAssistants || 'N/A'}`);
        }

        if (analytics.hierarchy && analytics.hierarchy.stateBreakdown) {
            console.log(`\n📍 States with Data: ${analytics.hierarchy.stateBreakdown.length}`);
            analytics.hierarchy.stateBreakdown.slice(0, 3).forEach(state => {
                console.log(`   ${state.state}: ${state.hospitals} hospitals, ${state.doctors} doctors`);
            });
        }

        if (analytics.performance) {
            console.log(`\n📈 Performance Metrics:`);
            console.log(`   Hospital Efficiency: ${analytics.performance.averageHospitalEfficiency?.toFixed(1) || 'N/A'}%`);
            console.log(`   Staff Satisfaction: ${analytics.performance.averageStaffSatisfaction?.toFixed(1) || 'N/A'}%`);
            console.log(`   Coverage: ${analytics.performance.totalCoverage || 'N/A'}%`);
        }

        console.log('\n🎉 All tests passed successfully!');
        console.log('✅ WHO Comprehensive Analytics is working correctly.');

    } catch (error) {
        console.error('❌ Test failed with error:', error.message);
    }
}

// Run the test
testWhoAnalytics();
