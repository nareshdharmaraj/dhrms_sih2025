const Patient = require('../models/Patient');
const HospitalStaff = require('../models/HospitalStaff');
const RegionalOfficer = require('../models/RegionalOfficer');

/**
 * Generate a unique UHI (Universal Health Identity) ID
 * Format: {First4LettersOfName}{Last4DigitsOfAadhaar} = exactly 8 characters
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
    
    // Get exactly first 4 letters of name (pad with 'X' if less than 4 characters)
    const first4Letters = cleanFirstName.length >= 4 
      ? cleanFirstName.substring(0, 4) 
      : cleanFirstName.padEnd(4, 'X');
    
    // Get last 4 digits of Aadhaar
    const last4Digits = aadhaarNumber.slice(-4);
    
    // Base UHI format: exactly 8 characters (4 letters + 4 digits)
    let baseUHI = `${first4Letters}${last4Digits}`;

    // Check for uniqueness across all models
    let uhiId = baseUHI;
    let suffix = 1;
    let isUnique = false;

    while (!isUnique) {
      const currentUHI = suffix === 1 ? uhiId : `${first4Letters}${(parseInt(last4Digits) + suffix).toString().padStart(4, '0')}`;
      
      // Check across all three models (using correct field names)
      const [patientExists, staffExists, officerExists] = await Promise.all([
        Patient.findOne({ uhid: currentUHI }), // Patient model uses 'uhid'
        HospitalStaff.findOne({ uhi: currentUHI }), // Staff model uses 'uhi'
        RegionalOfficer.findOne({ uhi: currentUHI }) // Officer model uses 'uhi'
      ]);

      if (!patientExists && !staffExists && !officerExists) {
        uhiId = currentUHI;
        isUnique = true;
      } else {
        suffix++;
        // If we exceed reasonable suffix range, try different approach
        if (suffix > 999) {
          // Change one letter in the name part for uniqueness
          const nameVariations = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
          const randomIndex = Math.floor(Math.random() * nameVariations.length);
          const modifiedName = first4Letters.substring(0, 3) + nameVariations[randomIndex];
          uhiId = `${modifiedName}${last4Digits}`;
          
          // Check this variation
          const [variantPatientExists, variantStaffExists, variantOfficerExists] = await Promise.all([
            Patient.findOne({ uhid: uhiId }), // Patient model uses 'uhid'
            HospitalStaff.findOne({ uhi: uhiId }), // Staff model uses 'uhi'
            RegionalOfficer.findOne({ uhi: uhiId }) // Officer model uses 'uhi'
          ]);

          if (!variantPatientExists && !variantStaffExists && !variantOfficerExists) {
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

  // UHI should be exactly 8 characters: 4 letters + 4 digits
  return /^[A-Z]{4}\d{4}$/.test(uhi);
}

/**
 * Check if UHI exists in any of the user collections
 * @param {string} uhi - UHI to check
 * @returns {Object} - Result with exists status and details
 */
async function checkUHIExists(uhi) {
  try {
    const [patient, staff, officer] = await Promise.all([
      Patient.findOne({ uhid: uhi }), // Patient model uses 'uhid'
      HospitalStaff.findOne({ uhi }), // Staff model uses 'uhi'
      RegionalOfficer.findOne({ uhi }) // Officer model uses 'uhi'
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
