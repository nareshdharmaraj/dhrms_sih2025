# Geolocation Features - MyHealth DHRMS

## Overview
The MyHealth app now includes comprehensive geolocation services for enhanced healthcare accessibility and safety. These features help users find nearby medical facilities and stay informed about health risks in their area.

## Key Features

### 1. Nearby Hospitals Screen
**Location**: `lib/screens/nearby_hospitals_screen.dart`

**Features**:
- **Hospital Discovery**: Find hospitals within customizable radius (1-20km)
- **Advanced Filtering**: Filter by emergency services, available beds, ratings
- **Real-time Information**: 
  - Bed availability status
  - Wait times
  - Hospital ratings and reviews
  - Contact information
- **Multiple View Modes**:
  - List view with detailed information
  - Map view (placeholder for future integration)
  - Statistics overview
- **Interactive Features**:
  - Get directions to hospital
  - Call hospital directly
  - Book ambulance services
  - View hospital specialties

**Quick Actions**:
- Emergency ambulance booking
- Route planning with traffic information
- Hospital comparison

### 2. Proximity Alerts Screen
**Location**: `lib/screens/proximity_alerts_screen.dart`

**Features**:
- **Health Alert Monitoring**: Track infectious disease outbreaks in your area
- **Risk Assessment**: High, medium, and low severity classifications
- **Customizable Radius**: Set alert radius from 1-20km
- **Disease Tracking**: Monitor COVID-19, Dengue, Flu, and other outbreaks
- **Safety Guidelines**: Specific precautions for each health alert
- **Notification Settings**: Enable/disable push notifications
- **Emergency Contacts**: Quick access to health helplines

**Alert Types**:
- High Risk: Immediate health threats requiring urgent precautions
- Medium Risk: Moderate health concerns with recommended safety measures
- Low Risk: General health advisories and preventive guidelines

### 3. Geolocation Service
**Location**: `lib/core/services/geolocation_service.dart`

**Core Functions**:
- **Location Services**: GPS-based positioning (mock implementation)
- **Distance Calculation**: Haversine formula for accurate distance measurement
- **Hospital Database**: Comprehensive hospital information with real-time data
- **Alert Management**: Proximity-based health alert system
- **Emergency Services**: Ambulance booking and emergency contacts

**Data Management**:
- Hospital search and filtering
- Real-time bed availability
- Route calculation
- Health statistics aggregation
- Emergency contact directory

## Integration Points

### User Dashboard Integration
The geolocation features are integrated into the normal user dashboard through:

1. **Quick Actions Grid**:
   - "Nearby Hospitals" button for immediate hospital discovery
   - "Health Alerts" button for proximity-based health warnings

2. **Navigation**:
   - Seamless navigation between geolocation screens
   - Back navigation to main dashboard

### Hospital Role Integration
Future integration planned with hospital management systems for:
- Real-time bed availability updates
- Direct booking confirmations
- Ambulance dispatch coordination

## Technical Implementation

### Mock Data Structure
The service currently uses comprehensive mock data including:

**Hospital Data**:
- 6 hospitals in Kochi, Kerala area
- Complete contact information
- Specialty departments
- Bed availability status
- Emergency service capability
- Ambulance services
- Rating and review data

**Alert Data**:
- COVID-19 high-risk alerts
- Dengue medium-risk warnings
- Flu outbreak low-risk notifications
- Affected area mapping
- Precautionary guidelines

### Distance Calculation
Uses the Haversine formula for precise distance calculations:
```dart
double distance = GeolocationService.calculateDistance(
  userLat, userLng, hospitalLat, hospitalLng
);
```

### Real-time Features (Mock)
- Bed availability updates
- Ambulance booking confirmations
- Route optimization
- Traffic condition simulation

## User Experience Features

### Search and Discovery
- **Text Search**: Find hospitals by name, type, or specialty
- **Filter Options**: Multiple filter criteria for precise results
- **Sort Options**: Distance, rating, availability-based sorting

### Emergency Features
- **SOS Integration**: Quick access from emergency screens
- **Ambulance Booking**: Direct booking with ETA and tracking
- **Emergency Contacts**: One-tap access to emergency numbers

### Health Safety
- **Alert Notifications**: Proactive health risk notifications
- **Safety Guidelines**: Disease-specific precautionary measures
- **Community Reporting**: User-generated health alert reporting

## Future Enhancements

### Planned Features
1. **Real GPS Integration**: Replace mock location with actual GPS services
2. **Live Map Integration**: Google Maps or similar mapping service
3. **Real-time Data**: API integration with hospital management systems
4. **Push Notifications**: Real-time alert notifications
5. **Offline Mode**: Cached data for offline hospital discovery
6. **Advanced Analytics**: Health trend analysis and reporting

### Scalability Considerations
- **Data Caching**: Implement efficient data caching strategies
- **Performance Optimization**: Lazy loading and pagination
- **Multi-language Support**: Localization for different regions
- **Accessibility**: Enhanced accessibility features for all users

## Usage Instructions

### For Normal Users
1. **Finding Hospitals**:
   - Tap "Nearby Hospitals" on dashboard
   - Use search and filters to find specific hospitals
   - View hospital details and get directions
   - Book ambulance if needed

2. **Monitoring Health Alerts**:
   - Tap "Health Alerts" on dashboard
   - Review active alerts in your area
   - Adjust alert radius in settings
   - Report new health concerns

### For Hospital Staff
- Integration with hospital dashboard for bed management
- Ambulance dispatch coordination
- Patient admission workflow

## Security and Privacy

### Data Protection
- Location data is handled securely
- Personal health information is encrypted
- User consent for location services
- Anonymized reporting for health alerts

### Privacy Features
- Optional location sharing
- Configurable privacy settings
- Secure data transmission
- GDPR compliance ready

## Support and Documentation

### Emergency Contacts
- Ambulance: 108
- Police: 100
- Fire: 101
- Health Helpline: 104
- National Emergency: 112

### Technical Support
- Error handling with user-friendly messages
- Comprehensive logging for debugging
- Fallback mechanisms for service failures
- User feedback integration

This geolocation feature set transforms the MyHealth app into a comprehensive healthcare navigation and safety platform, ensuring users can quickly access medical services and stay informed about health risks in their community.
