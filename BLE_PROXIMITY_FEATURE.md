# BLE Proximity Alert Feature

## Overview
A comprehensive Bluetooth Low Energy (BLE) based contact tracing and proximity alert system integrated into the DHRMS patient dashboard.

## Features

### 🔵 BLE Contact Tracing Service
- **Automatic Device Detection**: Scans for nearby BLE devices every 5 seconds
- **Proximity Broadcasting**: Broadcasts anonymized device ID for contact tracing
- **Distance Estimation**: Uses RSSI values to calculate approximate distance
- **Privacy-First**: Daily rotating anonymized IDs for privacy protection

### 📡 Infected IDs Management  
- **Backend Integration**: Fetches infected device IDs from server
- **Smart Caching**: Local storage with 1-hour cache expiry
- **Real-time Updates**: Periodic background updates every 5 minutes
- **Offline Support**: Works with cached data when offline

### 🚨 Smart Notifications
- **Local Notifications**: Immediate proximity alerts with vibration and sound
- **Firebase Cloud Messaging**: Remote notifications and updates
- **Risk Level Assessment**: High/Medium/Low risk categorization
- **Alert Cooldown**: 15-minute cooldown to prevent alert spam

### 🎛️ User Interface
- **Real-time Status**: Live service status and scanning indicator
- **Statistics Dashboard**: Infected count, detected devices, recent alerts
- **Alert History**: Chronological list of all proximity alerts
- **Control Panel**: Start/stop tracing with settings access

## Technical Architecture

### Core Components
1. **BLEContactTracingService** - Main service coordinator
2. **InfectedIDsManager** - Backend integration for infected IDs
3. **BLENotificationService** - Notification management
4. **BLEUtils** - Utility functions for distance calculation
5. **ProximityAlertScreen** - User interface

### Dependencies Added
```yaml
flutter_reactive_ble: ^5.3.1      # BLE scanning and broadcasting
firebase_messaging: ^14.7.10       # Push notifications
flutter_local_notifications: ^16.3.2  # Local notifications
crypto: ^3.0.3                     # Hash generation for privacy
```

### Key Features

#### Privacy & Security
- **Anonymized IDs**: SHA256-based daily rotating identifiers
- **No Personal Data**: Only anonymized device IDs are transmitted
- **Local Processing**: Distance calculations done locally
- **Secure Communication**: HTTPS for all backend communications

#### Performance Optimization  
- **Background Processing**: Continues scanning when app is backgrounded
- **Battery Optimization**: Efficient scanning intervals and low-power BLE
- **Memory Management**: Automatic cleanup of old data
- **Error Handling**: Robust error handling and recovery

#### Health Guidelines Compliance
- **CDC Guidelines**: 6-foot proximity detection for 15+ minute exposure
- **Risk Assessment**: Multi-level risk categorization
- **Contact Duration**: Tracks exposure duration for better risk assessment
- **Alert Timing**: Smart alerting to prevent user fatigue

## Integration Points

### Patient Dashboard
- **Services Tab**: Proximity button in services grid
- **Navigation**: Direct access to proximity alert screen
- **Status Integration**: Dashboard shows active/inactive status

### Permissions Required
- **Bluetooth**: BLE scanning and advertising
- **Location**: Required for BLE on Android
- **Notifications**: Local and push notifications
- **Background**: Background processing capabilities

## Usage Flow

1. **Initialization**: User opens proximity screen from patient dashboard
2. **Permission Check**: App requests necessary permissions
3. **Service Start**: User taps "Start Tracing" button
4. **Background Operation**: Service runs continuously in background
5. **Alert Delivery**: Immediate alerts when infected devices detected
6. **Data Sync**: Periodic updates of infected IDs from backend

## Configuration

### Backend API Endpoints
- `GET /api/infected-ids` - Fetch current infected device IDs
- `POST /api/report-infection` - Report new infection
- `GET /health` - Service health check

### Customizable Parameters
- **Proximity Threshold**: RSSI -60 dBm (~2 meters)
- **Alert Cooldown**: 15 minutes between alerts for same device
- **Update Interval**: 5 minutes for infected IDs refresh
- **Cache Expiry**: 1 hour for infected IDs cache
- **Scan Frequency**: Every 5 seconds for device discovery

## Privacy Considerations

### Data Minimization
- Only stores anonymized device IDs
- No location data collected or stored
- Automatic data expiry and cleanup

### User Control  
- **Opt-in System**: Users must explicitly enable contact tracing
- **Transparent Operations**: Clear status indicators and explanations
- **Data Control**: Users can clear history and disable at any time

## Future Enhancements

### Planned Features
- **Exposure Scoring**: Advanced risk calculation algorithms
- **Health Authority Integration**: Direct integration with health departments
- **Advanced Analytics**: Exposure patterns and trends
- **Multi-disease Support**: Support for different infectious diseases
- **Wearable Integration**: Smartwatch and fitness tracker support

### Technical Improvements
- **Mesh Network**: Peer-to-peer contact sharing
- **Advanced Encryption**: Enhanced privacy with advanced crypto
- **AI Risk Assessment**: Machine learning for better risk prediction
- **Cross-platform Sync**: Multi-device contact tracing

## Development Notes

### Testing
- **Permission Testing**: Test on different Android/iOS versions
- **Background Testing**: Verify background operation
- **Notification Testing**: Test all notification scenarios
- **Integration Testing**: Test with backend APIs

### Deployment
- **Gradual Rollout**: Phased deployment to test scalability
- **Monitoring**: Backend monitoring for infected IDs API
- **User Feedback**: Collect user experience feedback
- **Performance Metrics**: Monitor battery usage and performance

## Support

For technical support or questions about the BLE proximity feature:
- Check the in-app help section
- Contact the DHRMS support team
- Review the troubleshooting guide in the app

---

**Note**: This feature requires Android 6.0+ or iOS 10.0+ for full BLE functionality. Backend API endpoints need to be implemented according to the specified interface.
