// Script to test the unassigned zones API endpoint
const mongoose = require('mongoose');
require('dotenv').config();

async function testUnassignedZonesAPI() {
  try {
    // First make sure we have a connection to test against
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB');

    // Simulate the API call by calling the controller directly
    const ZoneManagementController = require('./src/controllers/zoneManagementController');
    
    // Mock request and response objects
    const req = {
      params: {
        state: 'Kerala',
        district: 'Ernakulam'
      }
    };

    const res = {
      status: function(code) {
        this.statusCode = code;
        return this;
      },
      json: function(data) {
        console.log(`📡 API Response (${this.statusCode}):`);
        console.log(JSON.stringify(data, null, 2));
        return this;
      }
    };

    console.log('\n🔍 TESTING UNASSIGNED ZONES API');
    console.log('==========================================');
    console.log(`📞 Calling: GET /api/zone-management/zones/${req.params.state}/${req.params.district}/unassigned`);
    
    await ZoneManagementController.getUnassignedZones(req, res);

  } catch (error) {
    console.error('❌ Error testing API:', error);
  } finally {
    await mongoose.disconnect();
    console.log('\n✅ Disconnected from MongoDB');
  }
}

testUnassignedZonesAPI();