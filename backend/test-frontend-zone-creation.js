const fetch = require('node-fetch');

async function testFrontendZoneCreation() {
  try {
    console.log('🧪 Testing frontend-style zone creation...');
    
    // This matches what the frontend sends
    const requestBody = {
      'zoneName': 'Test Frontend Zone',
      'state': 'Kerala',
      'district': 'Thrissur',
      'areas': [
        {
          'areaName': 'Thrissur',
          'areaCode': 'THRISSUR_001',
          'isDenselyPopulated': true,
        },
        {
          'areaName': 'Mukundapuram',
          'areaCode': 'MUKUNDAPURAM_001',
          'isDenselyPopulated': true,
        }
      ],
      'zoneType': 'urban',
      'priority': 'medium',
      'metadata': {
        'description': 'Zone created for Test Frontend Zone',
        'subDistricts': ['Thrissur', 'Mukundapuram'],
        'basedOnSubDistricts': true,
      },
      'createdBy': {
        'shoId': 'test_sho_id',
        'shoName': 'SHO Name',
      },
    };
    
    console.log('📤 Sending request with body:', JSON.stringify(requestBody, null, 2));
    
    const response = await fetch('http://localhost:3000/api/zone-management/zones', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(requestBody),
    });
    
    console.log('📨 Response status:', response.status);
    const responseData = await response.text();
    console.log('📨 Response body:', responseData);
    
    if (response.ok) {
      console.log('✅ Zone creation successful!');
    } else {
      console.log('❌ Zone creation failed!');
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

testFrontendZoneCreation();