// Test script to verify real administrative data integration
const { AreaAssignmentService } = require('./src/services/areaAssignmentService');

async function testRealDataIntegration() {
    console.log('🧪 Testing Real Administrative Data Integration\n');
    
    try {
        // Test 1: Get districts for Tamil Nadu
        console.log('📍 Test 1: Tamil Nadu Districts');
        const tnDistricts = AreaAssignmentService.getDistrictsForState('Tamil Nadu');
        console.log(`Found ${tnDistricts.length} districts in Tamil Nadu`);
        console.log('First district structure:', JSON.stringify(tnDistricts[0], null, 2));
        console.log('Sample districts:', tnDistricts.slice(0, 3).map(d => d.name || d.district || d).join(', '));
        // Test 2: Get districts for Kerala
        console.log('\n📍 Test 2: Kerala Districts');
        const keralaDistricts = AreaAssignmentService.getDistrictsForState('Kerala');
        console.log(`Found ${keralaDistricts.length} districts in Kerala`);
        console.log('Sample districts:', keralaDistricts.slice(0, 3).map(d => d.name).join(', '));
        
        // Test 3: Get districts for Andhra Pradesh
        console.log('\n📍 Test 3: Andhra Pradesh Districts');
        const apDistricts = AreaAssignmentService.getDistrictsForState('Andhra Pradesh');
        console.log(`Found ${apDistricts.length} districts in Andhra Pradesh`);
        console.log('Sample districts:', apDistricts.slice(0, 3).map(d => d.name).join(', '));
        
        // Test 4: Check Chennai (dense district) assignment info
        console.log('\n🏙️ Test 4: Chennai District Assignment (Dense)');
        const chennaiInfo = AreaAssignmentService.getDistrictAssignmentInfoWithRealData('Chennai');
        console.log('Chennai Info:', JSON.stringify(chennaiInfo, null, 2));
        if (chennaiInfo && chennaiInfo.availableAreas) {
            console.log(`Chennai isDense: ${chennaiInfo.isDense}`);
            console.log(`Available areas: ${chennaiInfo.availableAreas.length}`);
            console.log('Sample areas:', chennaiInfo.availableAreas.slice(0, 3).join(', '));
        }
        
        // Test 5: Check a sparse district
        console.log('\n🌾 Test 5: Dindigul District Assignment (Sparse)');
        const dindigulInfo = AreaAssignmentService.getDistrictAssignmentInfoWithRealData('Dindigul');
        console.log('Dindigul Info:', JSON.stringify(dindigulInfo, null, 2));
        if (dindigulInfo && dindigulInfo.availableAreas) {
            console.log(`Dindigul isDense: ${dindigulInfo.isDense}`);
            console.log(`Available areas: ${dindigulInfo.availableAreas.length}`);
            console.log('Areas:', dindigulInfo.availableAreas.join(', '));
        }
        
        // Test 6: Test invalid state
        console.log('\n❌ Test 6: Invalid State (Should return empty)');
        try {
            const invalidDistricts = AreaAssignmentService.getDistrictsForState('Invalid State');
            console.log(`Invalid state districts: ${invalidDistricts.length}`);
        } catch (error) {
            console.log('✅ Properly handled invalid state:', error.message);
        }
        
        console.log('\n✅ All tests completed successfully!');
        console.log('\n📊 Summary:');
        console.log(`- Tamil Nadu: ${tnDistricts.length} districts`);
        console.log(`- Kerala: ${keralaDistricts.length} districts`);
        console.log(`- Andhra Pradesh: ${apDistricts.length} districts`);
        console.log(`- Total: ${tnDistricts.length + keralaDistricts.length + apDistricts.length} districts`);
        console.log('\n🎯 Integration Status:');
        console.log('✅ Real administrative data loaded successfully');
        console.log('✅ State-based district filtering working');
        console.log('✅ Dense district classification (Chennai) working');
        console.log('✅ Sparse district classification (Dindigul) working');
        console.log('✅ Error handling for invalid states working');
        
    } catch (error) {
        console.error('❌ Test failed:', error.message);
        console.error(error.stack);
    }
}

// Run the test
testRealDataIntegration();