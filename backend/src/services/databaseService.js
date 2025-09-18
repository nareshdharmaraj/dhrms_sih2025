const Patient = require('../models/Patient');
const HospitalStaff = require('../models/HospitalStaff');
const RegionalOfficer = require('../models/RegionalOfficer');

class DatabaseService {
  // Universal login method - checks all three collections
  async validateUserCredentials(username, password) {
    try {
      // Check in Patients collection
      let user = await Patient.findOne({ username: username });
      if (user && user.password === password) {
        // Create a safe patient data object with default values for missing fields
        const patientData = {
          // Use actual values or defaults
          uhid: user.uhid || username,
          firstName: user.firstName || (user.fullName ? user.fullName.split(' ')[0] : 'Patient'),
          lastName: user.lastName || (user.fullName ? user.fullName.split(' ').slice(1).join(' ') : 'User'),
          fullName: user.fullName || `${user.firstName || 'Patient'} ${user.lastName || 'User'}`,
          email: user.email || '',
          phone: user.phone || '',
          aadhaarNumber: user.aadhaarNumber || '',
          // Provide default values for critical health fields
          dateOfBirth: user.dateOfBirth || '1990-01-01',
          gender: user.gender || 'not specified',
          bloodGroup: user.bloodGroup || 'O+',
          address: user.address || { 
            street: 'Not provided', 
            city: 'Not provided', 
            state: 'Not provided', 
            country: 'India', 
            postalCode: '' 
          },
          emergencyContact: user.emergencyContact || { name: 'Not provided', phone: 'Not provided', relation: 'Not provided' },
          medicalHistory: user.medicalHistory || [],
          allergies: user.allergies || [],
          currentMedications: user.currentMedications || [],
          homeState: user.homeState || 'Not provided',
          isMigrant: user.isMigrant || false,
          migrantDetails: user.migrantDetails || null,
          digitalCard: user.digitalCard || null,
          photo: user.photo || null,
          isActive: user.isActive !== undefined ? user.isActive : true,
          registrationDate: user.registrationDate || new Date()
        };
        
        console.log(`Enhanced patient data for ${username}: `, patientData);
        
        return {
          success: true,
          message: 'Login successful',
          userType: 'patient',
          user: {
            id: user._id,
            username: user.username,
            email: user.email,
            fullName: user.fullName,
            phone: user.phone,
            role: 'patient'
          },
          // Include enhanced patient data with defaults for frontend dashboard
          patientData: patientData
        };
      }

      // Check in Hospital Staff collection
      user = await HospitalStaff.findOne({ username: username });
      if (user && user.password === password) {
        return {
          success: true,
          message: 'Login successful',
          userType: 'hospital_staff',
          user: {
            id: user._id,
            username: user.username,
            email: user.email,
            fullName: user.fullName,
            phone: user.phone,
            staffRole: user.staffRole,
            department: user.department,
            hospitalName: user.hospitalName,
            role: 'hospital_staff'
          }
        };
      }

      // Check in Regional Officers collection
      user = await RegionalOfficer.findOne({ username: username });
      if (user && user.password === password) {
        return {
          success: true,
          message: 'Login successful',
          userType: 'regional_officer',
          user: {
            id: user._id,
            username: user.username,
            email: user.email,
            fullName: user.fullName,
            phone: user.phone,
            officerRank: user.officerRank,
            assignedRegion: user.assignedRegion,
            role: 'regional_officer'
          }
        };
      }

      return { success: false, message: 'Invalid username or password' };
    } catch (error) {
      console.error('Error validating credentials:', error);
      throw error;
    }
  }

  // Patient specific methods
  async createPatient(patientData) {
    try {
      const newPatient = new Patient(patientData);
      const savedPatient = await newPatient.save();
      return {
        success: true,
        message: 'Patient created successfully',
        patient: savedPatient
      };
    } catch (error) {
      if (error.code === 11000) {
        return { success: false, message: 'Username or email already exists' };
      }
      console.error('Error creating patient:', error);
      throw error;
    }
  }

  async getAllPatients() {
    try {
      const patients = await Patient.find({ isActive: true }).select('-password');
      return patients;
    } catch (error) {
      console.error('Error getting all patients:', error);
      throw error;
    }
  }

  async getPatientById(id) {
    try {
      const patient = await Patient.findById(id).select('-password');
      return patient;
    } catch (error) {
      console.error('Error getting patient by ID:', error);
      throw error;
    }
  }

  // Hospital Staff specific methods
  async createHospitalStaff(staffData) {
    try {
      const newStaff = new HospitalStaff(staffData);
      const savedStaff = await newStaff.save();
      return {
        success: true,
        message: 'Hospital staff created successfully',
        staff: savedStaff
      };
    } catch (error) {
      if (error.code === 11000) {
        return { success: false, message: 'Username or email already exists' };
      }
      console.error('Error creating hospital staff:', error);
      throw error;
    }
  }

  async getAllHospitalStaff() {
    try {
      const staff = await HospitalStaff.find({ isActive: true }).select('-password');
      return staff;
    } catch (error) {
      console.error('Error getting all hospital staff:', error);
      throw error;
    }
  }

  async getHospitalStaffById(id) {
    try {
      const staff = await HospitalStaff.findById(id).select('-password');
      return staff;
    } catch (error) {
      console.error('Error getting hospital staff by ID:', error);
      throw error;
    }
  }

  // Regional Officer specific methods
  async createRegionalOfficer(officerData) {
    try {
      const newOfficer = new RegionalOfficer(officerData);
      const savedOfficer = await newOfficer.save();
      return {
        success: true,
        message: 'Regional officer created successfully',
        officer: savedOfficer
      };
    } catch (error) {
      if (error.code === 11000) {
        return { success: false, message: 'Username or email already exists' };
      }
      console.error('Error creating regional officer:', error);
      throw error;
    }
  }

  async getAllRegionalOfficers() {
    try {
      const officers = await RegionalOfficer.find({ isActive: true }).select('-password');
      return officers;
    } catch (error) {
      console.error('Error getting all regional officers:', error);
      throw error;
    }
  }

  async getRegionalOfficerById(id) {
    try {
      const officer = await RegionalOfficer.findById(id).select('-password');
      return officer;
    } catch (error) {
      console.error('Error getting regional officer by ID:', error);
      throw error;
    }
  }

  // Search methods
  async searchUserByUsername(username) {
    try {
      // Search across all collections
      const patient = await Patient.findOne({ username: username }).select('-password');
      if (patient) {
        return { ...patient.toObject(), userType: 'patient' };
      }

      const staff = await HospitalStaff.findOne({ username: username }).select('-password');
      if (staff) {
        return { ...staff.toObject(), userType: 'hospital_staff' };
      }

      const officer = await RegionalOfficer.findOne({ username: username }).select('-password');
      if (officer) {
        return { ...officer.toObject(), userType: 'regional_officer' };
      }

      return null;
    } catch (error) {
      console.error('Error searching user by username:', error);
      throw error;
    }
  }

  // Statistics methods
  async getDatabaseStats() {
    try {
      const patientCount = await Patient.countDocuments({ isActive: true });
      const staffCount = await HospitalStaff.countDocuments({ isActive: true });
      const officerCount = await RegionalOfficer.countDocuments({ isActive: true });

      return {
        patients: patientCount,
        hospitalStaff: staffCount,
        regionalOfficers: officerCount,
        total: patientCount + staffCount + officerCount
      };
    } catch (error) {
      console.error('Error getting database stats:', error);
      throw error;
    }
  }
}

module.exports = new DatabaseService();
