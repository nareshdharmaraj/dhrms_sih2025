const { AreaAssignmentService } = require('./src/services/areaAssignmentService');

// Test zone extraction for different districts
async function testZoneExtraction() {
    console.log('🧪 Testing Zone Extraction Logic...\n');

    const testDistricts = ['Chennai', 'Salem', 'Madurai', 'Tiruchirappalli'];

    for (const district of testDistricts) {
        try {
            console.log(`📍 Testing district: ${district}`);
            const assignmentInfo = AreaAssignmentService.getDistrictAssignmentInfoWithRealData(district);
            
            console.log(`   Type: ${assignmentInfo.type}`);
            console.log(`   Areas count: ${assignmentInfo.areas.length}`);
            
            // Extract zones from area names
            const zones = new Set();
            const areaNames = [];
            
            for (const area of assignmentInfo.areas) {
                areaNames.push(area.name);
                if (area.name.includes('Zone ')) {
                    const zoneMatch = area.name.match(/Zone (\d+)/);
                    if (zoneMatch) {
                        zones.add(`Zone ${zoneMatch[1]}`);
                    }
                } else {
                    zones.add('All Areas');
                }
            }
            
            console.log(`   Area names: ${areaNames.join(', ')}`);
            console.log(`   Extracted zones: ${Array.from(zones).sort().join(', ')}`);
            console.log('   ---');
            
        } catch (error) {
            console.error(`   ❌ Error for ${district}: ${error.message}`);
        }
    }
}

testZoneExtraction();