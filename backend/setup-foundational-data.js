const StateHealthOfficer = require('./src/models/StateHealthOfficer');
const Zone = require('./src/models/Zone');

const setupFoundationalData = async () => {
  try {
    console.log('🚀 Setting up foundational data for testing...\n');

    // 1. Create WHO Admin first (required for SHO creation)
    console.log('1. 🌍 Creating WHO Admin...');
    const WhoAdmin = require('./src/models/WhoAdmin');
    
    let whoAdmin = await WhoAdmin.findOne({ username: 'admin' });
    if (!whoAdmin) {
      whoAdmin = new WhoAdmin({
        adminId: 'WHO_ADMIN_001',
        username: 'admin',
        fullName: 'WHO System Administrator',
        email: 'admin@who.dhrms.gov.in',
        phone: '+91-11-2301-4000',
        password: 'admin123', // Will be hashed
        designation: 'Regional Director',
        region: 'South-East Asia',
        accessLevel: 'Global',
        permissions: {
          canManageStateOfficers: true,
          canManageRegionalOfficers: true,
          canManageHospitals: true,
          canManageUsers: true,
          canViewSystemStats: true,
          canGenerateReports: true,
          canExportData: true,
          canManageSettings: true
        },
        isActive: true
      });
      await whoAdmin.save();
      console.log('✅ WHO Admin created:', whoAdmin.fullName);
    } else {
      console.log('✅ WHO Admin already exists:', whoAdmin.fullName);
    }

    // 2. Create Kerala SHO
    console.log('\n2. 👤 Creating Kerala SHO...');
    
    // Check if Kerala SHO already exists
    let keralaSHO = await StateHealthOfficer.findOne({ 
      assignedState: 'Kerala',
      officerId: 'SHO_KL_001' 
    });

    if (!keralaSHO) {
      keralaSHO = new StateHealthOfficer({
        officerId: 'SHO_KL_001',
        fullName: 'Dr. Priya Kerala',
        email: 'sho.kerala@dhrms.gov.in',
        phone: '+91-9876543210',
        password: 'admin123', // Will be hashed by middleware
        assignedState: 'Kerala',
        isActive: true,
        createdBy: whoAdmin._id
      });

      await keralaSHO.save();
      console.log('✅ Kerala SHO created:', keralaSHO.fullName, keralaSHO.officerId);
    } else {
      console.log('✅ Kerala SHO already exists:', keralaSHO.fullName, keralaSHO.officerId);
    }

    // 2. Create Ernakulam zones
    console.log('\n2. 🏢 Creating Ernakulam zones...');
    
    const ernakulamZones = [
      {
        zoneId: 'ERN-NORTH-001',
        zoneName: 'Ernakulam North Zone',
        state: 'Kerala',
        district: 'Ernakulam',
        areas: [
          {
            areaName: 'Kothamangalam',
            areaCode: 'KOTH-001',
            population: 145000,
            areaKm2: 125.5,
            isDenselyPopulated: true
          },
          {
            areaName: 'Thrikkakara',
            areaCode: 'THRIK-001', 
            population: 135000,
            areaKm2: 45.2,
            isDenselyPopulated: true
          }
        ],
        zoneType: 'urban',
        priority: 'high',
        createdBy: {
          shoId: keralaSHO._id.toString(),
          shoName: keralaSHO.fullName
        },
        metadata: {
          description: 'Northern zone of Ernakulam district covering Kothamangalam and Thrikkakara areas',
          subDistricts: ['Kothamangalam', 'Thrikkakara']
        }
      },
      {
        zoneId: 'ERN-SOUTH-001',
        zoneName: 'Ernakulam South Zone',
        state: 'Kerala',
        district: 'Ernakulam',
        areas: [
          {
            areaName: 'Paravur',
            areaCode: 'PARA-001',
            population: 125000,
            areaKm2: 78.3,
            isDenselyPopulated: true
          },
          {
            areaName: 'Aluva',
            areaCode: 'ALUVA-001',
            population: 165000,
            areaKm2: 52.8,
            isDenselyPopulated: true
          }
        ],
        zoneType: 'urban',
        priority: 'high',
        createdBy: {
          shoId: keralaSHO._id.toString(),
          shoName: keralaSHO.fullName
        },
        metadata: {
          description: 'Southern zone of Ernakulam district covering Paravur and Aluva areas',
          subDistricts: ['Paravur', 'Aluva']
        }
      }
    ];

    for (const zoneData of ernakulamZones) {
      // Check if zone already exists
      let existingZone = await Zone.findOne({ zoneId: zoneData.zoneId });
      
      if (!existingZone) {
        const newZone = new Zone(zoneData);
        await newZone.save();
        console.log(`✅ Created zone: ${zoneData.zoneName} (${zoneData.zoneId})`);
        console.log(`   Areas: ${zoneData.areas.map(a => a.areaName).join(', ')}`);
      } else {
        console.log(`✅ Zone already exists: ${zoneData.zoneName} (${zoneData.zoneId})`);
      }
    }

    // 3. Verify setup
    console.log('\n3. ✅ Verification:');
    const totalSHOs = await StateHealthOfficer.countDocuments({ assignedState: 'Kerala' });
    const totalZones = await Zone.countDocuments({ state: 'Kerala', district: 'Ernakulam' });
    const unassignedZones = await Zone.findUnassigned('Kerala', 'Ernakulam');
    
    console.log(`- Kerala SHOs: ${totalSHOs}`);
    console.log(`- Ernakulam zones: ${totalZones}`);
    console.log(`- Unassigned zones: ${unassignedZones.length}`);
    
    if (unassignedZones.length > 0) {
      console.log('Unassigned zones:');
      unassignedZones.forEach(zone => {
        console.log(`  - ${zone.zoneName}: ${zone.areas.map(a => a.areaName).join(', ')}`);
      });
    }

    console.log('\n🎉 Foundational data setup completed!');
    console.log('\nYou can now test:');
    console.log('1. Login as SHO with: officerId="SHOS001", password="admin123"');
    console.log('2. Create RHOs for Ernakulam district');
    console.log('3. Assign RHOs to zones');

  } catch (error) {
    console.error('❌ Setup error:', error);
  }
};

// Connect to MongoDB and run setup
const mongoose = require('mongoose');
mongoose.connect('mongodb://localhost:27017/dhrms_sih2025', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('📡 Connected to MongoDB');
  return setupFoundationalData();
}).then(() => {
  console.log('✅ Setup completed');
  process.exit(0);
}).catch(error => {
  console.error('❌ Error:', error);
  process.exit(1);
});