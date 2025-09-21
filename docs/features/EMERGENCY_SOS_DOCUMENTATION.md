# Emergency SOS Dialing Feature

## Overview
The Emergency SOS feature has been implemented to automatically dial the emergency contact number stored in the user's account after a countdown, without requiring user confirmation.

## How It Works

### 1. Emergency Contact Detection
- The system looks for emergency contact numbers in the patient data
- Checks multiple possible fields: `emergencyContact.phone`, `emergencyContacts[0].phone`
- Falls back to default ambulance number (108) if no emergency contact is found

### 2. SOS Activation Process
1. User presses and holds the SOS button for 3 seconds
2. 10-second countdown begins with visual feedback
3. User can cancel during countdown by tapping "CANCEL EMERGENCY"
4. After countdown expires, automatic dialing occurs

### 3. Automatic Dialing
- Uses `url_launcher` package to open device dialer
- Calls `tel:` scheme with the emergency contact number
- On mobile: Opens dialer and initiates call automatically
- On web: Opens tel: link (browser dependent)

## Implementation Details

### Files Created/Modified:
1. **lib/utils/emergency_dialer.dart** (NEW)
   - Handles platform-specific dialing using URL launcher
   - Provides error handling for failed dial attempts

2. **lib/screens/advanced_sos_screen.dart** (MODIFIED)
   - Updated to accept patient data containing emergency contact
   - Modified countdown process to dial automatically after timeout
   - Updated UI to show user's emergency number instead of generic 108

3. **lib/screens/patient_dashboard_screen.dart** (MODIFIED)
   - Updated SOS button to pass patient data to SOS screen

4. **pubspec.yaml** (MODIFIED)
   - Added `url_launcher: ^6.2.2` dependency

### Key Features:
- **No Confirmation Required**: After countdown, dialing happens automatically
- **Emergency Contact Priority**: Uses user's emergency contact, not fixed numbers
- **Fallback Safety**: Falls back to 108 (ambulance) if no emergency contact found
- **Visual Feedback**: Clear countdown with cancel option
- **Error Handling**: Shows user-friendly error messages if dialing fails

## Usage Example

```dart
// Patient data with emergency contact
Map<String, dynamic> patientData = {
  'fullName': 'John Doe',
  'uhid': 'UHID123',
  'emergencyContact': {
    'name': 'Jane Doe',
    'relationship': 'Spouse',
    'phone': '9876543210',
  },
};

// Navigate to SOS screen with patient data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AdvancedSOSScreen(patientData: patientData),
  ),
);
```

## Testing

### To Test Emergency Dialing:
1. Ensure you have a patient with emergency contact data
2. Navigate to Emergency SOS from the dashboard
3. Press and hold the SOS button
4. Wait for the 10-second countdown to complete
5. Verify that the dialer opens with the correct emergency number

### Test Cases:
- ✅ Emergency contact exists: Should dial the emergency contact number
- ✅ No emergency contact: Should dial 108 (ambulance)
- ✅ Countdown cancellation: Should stop the process when cancelled
- ✅ Manual dial buttons: Should work independently from countdown
- ✅ Error handling: Should show error message if dialing fails

## Security & Privacy
- No phone numbers are stored or transmitted externally
- Uses only local patient data already available in the app
- Follows platform-specific dialing permissions and guidelines

## Platform Support
- **Android**: Full support with automatic call initiation
- **iOS**: Full support with automatic call initiation  
- **Web**: Limited support (browser dependent, may require user confirmation)

## Dependencies
- `url_launcher: ^6.2.2` - For cross-platform URL/phone number launching
- No additional permissions required for basic tel: scheme usage