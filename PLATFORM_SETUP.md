# Platform Configuration Guide

## Overview
This app now supports automatic platform detection and configuration for different deployment environments:

- **Web Browser**: Uses `localhost:3000`
- **Android Emulator**: Uses `10.0.2.2:3000`
- **iOS Simulator**: Uses `localhost:3000`
- **Physical Devices**: Uses debug configuration

## Quick Setup

### For Development (Emulator/Web)
1. Start your backend server on port 3000
2. Run the Flutter app normally:
   ```bash
   flutter run
   ```
   The app will automatically detect the platform and use the correct endpoint.

### For Physical Device Testing
1. Update `lib/utils/debug_config.dart`:
   ```dart
   static const bool forcePhysicalDeviceMode = true;
   static const String physicalDeviceIP = 'YOUR_COMPUTER_IP_HERE';
   ```

2. Find your computer's IP address:
   - **Windows**: `ipconfig` (look for IPv4 Address)
   - **macOS/Linux**: `ifconfig` or `ip addr show`

3. Make sure your backend server allows external connections:
   ```javascript
   app.listen(3000, '0.0.0.0', () => {
     console.log('Server running on all interfaces at port 3000');
   });
   ```

4. Connect your phone to the same WiFi network as your computer

5. Run the app on your physical device

## Platform Detection Logic

The app automatically detects:
- `kIsWeb` for web browsers
- `Platform.isAndroid` for Android devices
- `Platform.isIOS` for iOS devices
- Debug configuration override for physical device testing

## Troubleshooting

### Connection Refused Errors
1. Check if backend server is running
2. Verify IP address in debug_config.dart (for physical devices)
3. Ensure phone and computer are on same WiFi network
4. Check firewall settings on your computer

### Emulator Issues
- Android emulator automatically uses `10.0.2.2:3000`
- iOS simulator automatically uses `localhost:3000`
- If still having issues, check if backend server is running on localhost:3000

### Web Issues
- Make sure to start backend with CORS enabled
- Access the web app at `localhost:3000` (frontend) while backend runs on `localhost:3000`
- If ports conflict, modify the backend to run on a different port and update debug_config.dart

## Backend Server Configuration

Ensure your backend server (`backend/src/server.js`) has:
```javascript
// Enable CORS for all origins during development
app.use(cors({
  origin: true,
  credentials: true
}));

// Listen on all interfaces to allow external connections
app.listen(3000, '0.0.0.0', () => {
  console.log('Server running on http://0.0.0.0:3000');
});
```

## Current Configuration

- **Default Emulator**: ✅ Auto-configured (10.0.2.2:3000)
- **Default Web**: ✅ Auto-configured (localhost:3000)
- **Physical Device**: Configure in `debug_config.dart`

The app will now work seamlessly across all platforms with minimal configuration required.