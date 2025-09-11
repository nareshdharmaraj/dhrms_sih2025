const mongoose = require('mongoose');
const Patient = require('../src/models/Patient');

async function updatePatientsWithUHID() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('Connected to MongoDB');

    // Get all patients without UHID
    const patientsWithoutUHID = await Patient.find({
      $or: [
        { uhid: { $exists: false } },
        { uhid: null },
        { uhid: '' }
      ]
    });

    console.log(`Found ${patientsWithoutUHID.length} patients without UHID`);

    for (const patient of patientsWithoutUHID) {
      // Generate UHID
      if (patient.firstName && patient.lastName && patient.aadhaarNumber) {
        const nameCode = (patient.firstName.substring(0, 2) + patient.lastName.substring(0, 2)).toUpperCase();
        const aadhaarCode = patient.aadhaarNumber.substring(8, 12);
        const uhid = nameCode + aadhaarCode;

        // Generate QR code data
        const qrCodeData = JSON.stringify({
          uhid: uhid,
          type: 'DHRMS_PATIENT_CARD',
          timestamp: new Date().toISOString()
        });

        // Update patient
        await Patient.findByIdAndUpdate(patient._id, {
          uhid: uhid,
          'digitalCard.cardNumber': uhid,
          'digitalCard.qrCode': qrCodeData,
          'digitalCard.issueDate': new Date(),
          'digitalCard.isActive': true
        });

        console.log(`Updated patient ${patient.fullName} with UHID: ${uhid}`);
      } else {
        console.log(`Skipping patient ${patient._id} - missing required fields`);
      }
    }

    console.log('UHID update completed');

  } catch (error) {
    console.error('Error updating patients with UHID:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

// Add sample patient for testing registration
async function addSamplePatient() {
  try {
    await mongoose.connect('mongodb://localhost:27017/myhealth', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('Connected to MongoDB for sample patient');

    const samplePatient = new Patient({
      firstName: 'John',
      lastName: 'Doe',
      aadhaarNumber: '123456789012',
      phone: '9876543210',
      email: 'john.doe@example.com',
      dateOfBirth: new Date('1990-01-15'),
      gender: 'male',
      bloodGroup: 'O+',
      address: {
        street: '123 Sample Street',
        city: 'Kochi',
        state: 'Kerala',
        zipCode: '682001',
        country: 'India'
      },
      emergencyContact: {
        name: 'Jane Doe',
        phone: '9876543211',
        relationship: 'Spouse'
      },
      homeState: 'Kerala',
      medicalHistory: [
        {
          condition: 'Hypertension',
          diagnosedDate: new Date('2020-05-10'),
          notes: 'Under medication'
        }
      ],
      allergies: ['Penicillin'],
      currentMedications: [
        {
          name: 'Amlodipine',
          dosage: '5mg',
          frequency: 'Once daily'
        }
      ]
    });

    await samplePatient.save();
    console.log(`Sample patient created with UHID: ${samplePatient.uhid}`);

  } catch (error) {
    console.error('Error creating sample patient:', error);
  } finally {
    await mongoose.disconnect();
  }
}

// Run the functions
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.includes('--sample')) {
    addSamplePatient();
  } else {
    updatePatientsWithUHID();
  }
}

module.exports = { updatePatientsWithUHID, addSamplePatient };
