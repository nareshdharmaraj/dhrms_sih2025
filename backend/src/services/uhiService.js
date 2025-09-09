const Patient = require('../models/Patient');
const HospitalStaff = require('../models/HospitalStaff');
const RegionalOfficer = require('../models/RegionalOfficer');

/**
 * Generate a unique UHI (Universal Health Identity) ID
 * Format: {FirstName}{Last4DigitsOfAadhaar} + optional suffix for uniqueness
 * @param {string} firstName - First name of the user
 * @param {string} aadhaarNumber - 12-digit Aadhaar number
 * @param {string} role - User role (patient, hospital_staff, regional_officer)
 * @returns {string} - Unique UHI ID
 */
async function generateUHI(firstName, aadhaarNumber, role = 'patient') {
  try {
    // Validate inputs
    if (!firstName || !aadhaarNumber) {
      throw new Error('First name and Aadhaar number are required');
    }

    if (!/^\d{12}$/.test(aadhaarNumber)) {
      throw new Error('Aadhaar number must be exactly 12 digits');
    }

    // Clean and format first name (remove spaces, special chars, convert to uppercase)
    const cleanFirstName = firstName.replace(/[^a-zA-Z]/g, '').toUpperCase();
    
    // Get last 4 digits of Aadhaar
    const last4Digits = aadhaarNumber.slice(-4);
    
    // Base UHI format
    let baseUHI = `${cleanFirstName}${last4Digits}`;
    
    // Ensure minimum length
    if (baseUHI.length < 6) {
      baseUHI = baseUHI.padEnd(6, '0');
    }

    // Check for uniqueness across all models
    let uhiId = baseUHI;
    let suffix = 0;
    let isUnique = false;

    while (!isUnique) {
      const currentUHI = suffix === 0 ? uhiId : `${baseUHI}${suffix}`;
      
      // Check across all three models
      const [patientExists, staffExists, officerExists] = await Promise.all([
        Patient.findOne({ uhi: currentUHI }),
        HospitalStaff.findOne({ uhi: currentUHI }),
        RegionalOfficer.findOne({ uhi: currentUHI })
      ]);

      if (!patientExists && !staffExists && !officerExists) {
        uhiId = currentUHI;
        isUnique = true;
      } else {
        suffix++;
        // Add additional elements for uniqueness
        if (suffix > 99) {
          // After 99 attempts, add random elements
          const randomSuffix = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
          uhiId = `${baseUHI}${randomSuffix}`;
          
          // Check this random combination
          const [randomPatientExists, randomStaffExists, randomOfficerExists] = await Promise.all([
            Patient.findOne({ uhi: uhiId }),
            HospitalStaff.findOne({ uhi: uhiId }),
            RegionalOfficer.findOne({ uhi: uhiId })
          ]);

          if (!randomPatientExists && !randomStaffExists && !randomOfficerExists) {
            isUnique = true;
          }
        }
      }
    }

    return uhiId;
  } catch (error) {
    console.error('Error generating UHI:', error);
    throw new Error('Failed to generate unique UHI');
  }
}

/**
 * Validate UHI format
 * @param {string} uhi - UHI to validate
 * @returns {boolean} - Whether UHI is valid
 */
function validateUHI(uhi) {
  if (!uhi || typeof uhi !== 'string') {
    return false;
  }

  // UHI should be alphanumeric and at least 6 characters
  return /^[A-Z0-9]{6,}$/.test(uhi);
}

/**
 * Check if UHI exists in any of the user collections
 * @param {string} uhi - UHI to check
 * @returns {Object} - Result with exists status and details
 */
async function checkUHIExists(uhi) {
  try {
    const [patient, staff, officer] = await Promise.all([
      Patient.findOne({ uhi }),
      HospitalStaff.findOne({ uhi }),
      RegionalOfficer.findOne({ uhi })
    ]);

    if (patient) {
      return {
        exists: true,
        role: 'patient',
        user: patient
      };
    }

    if (staff) {
      return {
        exists: true,
        role: 'hospital_staff',
        user: staff
      };
    }

    if (officer) {
      return {
        exists: true,
        role: 'regional_officer',
        user: officer
      };
    }

    return {
      exists: false,
      role: null,
      user: null
    };
  } catch (error) {
    console.error('Error checking UHI existence:', error);
    throw new Error('Failed to check UHI existence');
  }
}

/**
 * Generate UHI with additional context for better uniqueness
 * @param {Object} userData - User data containing firstName, aadhaarNumber, and optional context
 * @returns {string} - Unique UHI ID
 */
async function generateUHIWithContext(userData) {
  const { firstName, aadhaarNumber, dateOfBirth, role } = userData;
  
  try {
    let baseUHI = await generateUHI(firstName, aadhaarNumber, role);
    
    // If still having conflicts, add birth year as additional context
    if (dateOfBirth) {
      const birthYear = new Date(dateOfBirth).getFullYear().toString().slice(-2);
      const contextUHI = `${baseUHI}${birthYear}`;
      
      const exists = await checkUHIExists(contextUHI);
      if (!exists.exists) {
        return contextUHI;
      }
    }
    
    return baseUHI;
  } catch (error) {
    console.error('Error generating UHI with context:', error);
    throw error;
  }
}

module.exports = {
  generateUHI,
  validateUHI,
  checkUHIExists,
  generateUHIWithContext
};
