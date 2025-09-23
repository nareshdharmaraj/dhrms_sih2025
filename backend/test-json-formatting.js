// Test to verify proper JSON formatting for RHO data
const mockRHOData = {
  _id: "68cff9005548d04547ecbff2",
  officerId: "RHO_Pathanamthitta_001",
  assignedDistrict: "Pathanamthitta",
  districtCode: "PAT",
  assignedAreas: [
    {
      name: "Full District",
      code: "PAT",
      type: "full-district",
      population: 0,
      areaKm2: 0
    }
  ],
  coverage: {
    subDistricts: [],
    blocks: [],
    villages: [],
    primaryHealthCenters: [],
    communityHealthCenters: [],
    hospitals: [],
    population: 0,
    areaKm2: 0,
    ruralPopulation: 0,
    urbanPopulation: 0
  },
  officeAddress: {
    buildingName: null,
    street: null,
    city: "Pathanamthitta",
    state: "Kerala",
    zipCode: ""
  }
};

// Simulate the data transformation
function formatRHOData(rhoObj) {
  // Format assignedAreas
  rhoObj.assignedAreas = (rhoObj.assignedAreas || []).map(area => ({
    name: String(area.name || ''),
    code: String(area.code || ''),
    type: String(area.type || 'area'),
    population: Number(area.population || 0),
    areaKm2: Number(area.areaKm2 || 0),
    healthFacilities: {
      primaryHealthCenters: Math.floor((Number(area.population) || 0) / 20000) || 1,
      communityHealthCenters: Math.floor((Number(area.population) || 0) / 80000) || 1,
      hospitals: Math.floor((Number(area.population) || 0) / 100000) || 1
    },
    coveragePercentage: Math.min(100, ((Number(area.population) || 0) / 50000) * 100) || 85
  }));

  // Format coverage
  rhoObj.coverage = {
    districts: [rhoObj.assignedDistrict].filter(Boolean),
    subDistricts: Array.isArray(rhoObj.coverage?.subDistricts) ? rhoObj.coverage.subDistricts : [],
    blocks: Array.isArray(rhoObj.coverage?.blocks) ? rhoObj.coverage.blocks : [],
    villages: Array.isArray(rhoObj.coverage?.villages) ? rhoObj.coverage.villages : [],
    primaryHealthCenters: Array.isArray(rhoObj.coverage?.primaryHealthCenters) ? rhoObj.coverage.primaryHealthCenters : [],
    communityHealthCenters: Array.isArray(rhoObj.coverage?.communityHealthCenters) ? rhoObj.coverage.communityHealthCenters : [],
    hospitals: Array.isArray(rhoObj.coverage?.hospitals) ? rhoObj.coverage.hospitals : [],
    populationCovered: rhoObj.coverage?.population || 0,
    hospitalsCovered: Array.isArray(rhoObj.coverage?.hospitals) ? rhoObj.coverage.hospitals.length : 0,
    primaryDistrict: rhoObj.coverage?.primaryDistrict || rhoObj.assignedDistrict || '',
    population: rhoObj.coverage?.population || 0,
    areaKm2: rhoObj.coverage?.areaKm2 || 0,
    ruralPopulation: rhoObj.coverage?.ruralPopulation || 0,
    urbanPopulation: rhoObj.coverage?.urbanPopulation || 0
  };

  // Format office address
  if (rhoObj.officeAddress) {
    const addressParts = [
      rhoObj.officeAddress.buildingName,
      rhoObj.officeAddress.street
    ].filter(Boolean);
    
    rhoObj.officeAddress = {
      address: addressParts.length > 0 ? addressParts.join(', ') : '',
      city: rhoObj.officeAddress.city || '',
      state: rhoObj.officeAddress.state || '',
      pincode: rhoObj.officeAddress.zipCode || ''
    };
  } else {
    rhoObj.officeAddress = {
      address: '',
      city: '',
      state: '',
      pincode: ''
    };
  }

  return rhoObj;
}

// Test the transformation
const formattedData = formatRHOData(JSON.parse(JSON.stringify(mockRHOData)));

// Test JSON serialization
try {
  const jsonString = JSON.stringify(formattedData, null, 2);
  console.log('✅ JSON serialization successful!');
  console.log('Formatted Data:');
  console.log(jsonString);
  
  // Test parsing back
  const parsedBack = JSON.parse(jsonString);
  console.log('✅ JSON parsing successful!');
  console.log('assignedAreas type:', typeof parsedBack.assignedAreas);
  console.log('assignedAreas length:', parsedBack.assignedAreas.length);
  console.log('coverage.districts:', parsedBack.coverage.districts);
  
} catch (error) {
  console.error('❌ JSON error:', error.message);
}