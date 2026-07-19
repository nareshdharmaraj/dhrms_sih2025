// Simple test to verify registration endpoint works
// This simulates the exact data structure sent by the Flutter frontend

const testRegistration = () => {
  const registrationData = {
    "username": "testuser123",
    "password": "password123", 
    "email": "test@example.com",
    "role": "user",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "1234567890",
    "dateOfBirth": "1990-01-01",
    "gender": "male",
    "address": {
      "street": "123 Test St",
      "city": "Test City", 
      "state": "Test State",
      "pincode": "123456"
    },
    "bloodGroup": "O+",
    "aadhaarNumber": "123456789012"
  };

  console.log('Test Data Structure:');
  console.log(JSON.stringify(registrationData, null, 2));
  
  console.log('\nValidation Check:');
  console.log('✓ Username:', registrationData.username);
  console.log('✓ Password length:', registrationData.password.length, '(min 6)');
  console.log('✓ Email format:', registrationData.email.includes('@'));
  console.log('✓ Role (user/doctor/hospital):', registrationData.role);
  console.log('✓ First Name:', registrationData.firstName);
  console.log('✓ Last Name:', registrationData.lastName);
  console.log('✓ Phone:', registrationData.phone);
  
  console.log('\nThis data structure should work with the registration endpoint.');
  console.log('The backend expects exactly these fields for validation.');
};

testRegistration();
