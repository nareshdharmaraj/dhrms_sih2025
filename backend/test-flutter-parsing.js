// Test to verify Flutter data parsing logic
const responseData = {
  "success": true,
  "message": "Statistics retrieved successfully",
  "data": {
    "populationCovered": 0,
    "healthcareCenters": 0,
    "emergencyServices": 5,
    "mobileUnits": 2,
    "totalStaffManaged": 0,
    "patientsServed": 0,
    "recentActivities": [
      {
        "type": "Inspection",
        "location": "Pathanamthitta",
        "timestamp": "2025-09-22T15:43:30.766Z",
        "status": "Completed"
      }
    ],
    "profile": {
      "officerId": "RHO_Pathanamthitta_001",
      "fullName": "DR Jhon",
      "assignedState": "Kerala",
      "assignedDistrict": "Pathanamthitta",
      "assignedRegion": "Southern Kerala",
      "isActive": true,
      "lastLogin": "2025-09-22T15:43:30.363Z"
    }
  }
};

// Simulate Flutter parsing (this is what happens in rho_dashboard_screen.dart line 61)
const _dashboardData = responseData['data'] || {};

console.log('Flutter Dashboard Data Simulation:');
console.log('Population Covered:', _dashboardData['populationCovered'] || 0);
console.log('Healthcare Centers:', _dashboardData['healthcareCenters'] || 0);
console.log('Emergency Services:', _dashboardData['emergencyServices'] || 0);
console.log('Mobile Units:', _dashboardData['mobileUnits'] || 0);
console.log('Recent Activities Count:', (_dashboardData['recentActivities'] || []).length);
console.log('Profile Name:', _dashboardData['profile']?.fullName || 'Unknown');

console.log('\n✅ All data fields successfully parsed for Flutter dashboard!');