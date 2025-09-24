const mongoose = require('mongoose');
const Hospital = require('./src/models/Hospital');
require('dotenv').config();

async function fixHospitalStatus() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('Connected to database');

    // Find all hospitals with lowercase status
    const hospitals = await Hospital.find({ status: 'active' });
    console.log(`Found ${hospitals.length} hospitals with lowercase status`);

    if (hospitals.length > 0) {
      // Update all hospitals to have proper case status
      const result = await Hospital.updateMany(
        { status: { $in: ['active', 'inactive', 'under review', 'suspended', 'closed'] } },
        [
          {
            $set: {
              status: {
                $switch: {
                  branches: [
                    { case: { $eq: ['$status', 'active'] }, then: 'Active' },
                    { case: { $eq: ['$status', 'inactive'] }, then: 'Inactive' },
                    { case: { $eq: ['$status', 'under review'] }, then: 'Under Review' },
                    { case: { $eq: ['$status', 'suspended'] }, then: 'Suspended' },
                    { case: { $eq: ['$status', 'closed'] }, then: 'Closed' }
                  ],
                  default: '$status'
                }
              }
            }
          }
        ]
      );
      
      console.log(`Updated ${result.modifiedCount} hospitals`);
    }

    // Verify the fix
    const activeHospitals = await Hospital.find({ status: 'Active' });
    console.log(`Now have ${activeHospitals.length} hospitals with correct 'Active' status`);

    // Show the hospital list for verification
    const hospitalList = await Hospital.find({ 
      isActive: true, 
      status: 'Active' 
    }).select('hospitalId name location.city location.state status');
    
    console.log('Hospital list now available:');
    hospitalList.forEach(hospital => {
      console.log(`- ${hospital.name} (${hospital.hospitalId}) - ${hospital.location.city}, ${hospital.location.state} - Status: ${hospital.status}`);
    });

  } catch (error) {
    console.error('Error fixing hospital status:', error);
  } finally {
    await mongoose.connection.close();
  }
}

// Run the fix
fixHospitalStatus();