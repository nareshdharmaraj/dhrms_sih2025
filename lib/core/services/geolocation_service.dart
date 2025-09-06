import 'dart:math';

class GeolocationService {
  // Mock current location (Kochi, Kerala)
  static const double _currentLatitude = 9.9312;
  static const double _currentLongitude = 76.2673;

  // Mock nearby hospitals data
  static final List<Map<String, dynamic>> _nearbyHospitals = [
    {
      'id': 'KGH001',
      'name': 'Kochi General Hospital',
      'type': 'Multi-specialty',
      'latitude': 9.9312,
      'longitude': 76.2673,
      'address': '123 Medical College Road, Kochi, Kerala 682020',
      'phone': '+91 484 2345678',
      'distance': 0.0,
      'availableBeds': 45,
      'totalBeds': 500,
      'emergencyServices': true,
      'rating': 4.5,
      'specialties': ['Cardiology', 'Neurology', 'Emergency', 'ICU'],
      'waitTime': '15 mins',
      'hasAmbulance': true,
    },
    {
      'id': 'AMRH002',
      'name': 'Amrita Institute of Medical Sciences',
      'type': 'Super Specialty',
      'latitude': 9.9030,
      'longitude': 76.2950,
      'address': 'AIMS Ponekkara, Kochi, Kerala 682041',
      'phone': '+91 484 2851234',
      'distance': 2.1,
      'availableBeds': 23,
      'totalBeds': 1400,
      'emergencyServices': true,
      'rating': 4.8,
      'specialties': ['Cardiology', 'Oncology', 'Neurosurgery', 'Transplant'],
      'waitTime': '20 mins',
      'hasAmbulance': true,
    },
    {
      'id': 'LKMD003',
      'name': 'Lakeshore Hospital',
      'type': 'Multi-specialty',
      'latitude': 9.9442,
      'longitude': 76.2828,
      'address': 'NH Bypass, Maradu, Kochi, Kerala 682304',
      'phone': '+91 484 2701234',
      'distance': 3.2,
      'availableBeds': 18,
      'totalBeds': 300,
      'emergencyServices': true,
      'rating': 4.3,
      'specialties': ['Emergency', 'Surgery', 'Pediatrics', 'Orthopedics'],
      'waitTime': '25 mins',
      'hasAmbulance': true,
    },
    {
      'id': 'RJHS004',
      'name': 'Rajagiri Hospital',
      'type': 'Multi-specialty',
      'latitude': 9.9495,
      'longitude': 76.3250,
      'address': 'Chunangamveli, Aluva, Kochi, Kerala 683112',
      'phone': '+91 484 2351234',
      'distance': 4.8,
      'availableBeds': 12,
      'totalBeds': 400,
      'emergencyServices': true,
      'rating': 4.4,
      'specialties': ['Cardiology', 'Neurology', 'Gastroenterology', 'ICU'],
      'waitTime': '30 mins',
      'hasAmbulance': true,
    },
    {
      'id': 'SMHS005',
      'name': 'Sunrise Hospital',
      'type': 'General',
      'latitude': 9.8850,
      'longitude': 76.2520,
      'address': 'Kakkanad, Kochi, Kerala 682030',
      'phone': '+91 484 2401234',
      'distance': 5.5,
      'availableBeds': 8,
      'totalBeds': 150,
      'emergencyServices': true,
      'rating': 4.0,
      'specialties': ['General Medicine', 'Emergency', 'Pediatrics'],
      'waitTime': '35 mins',
      'hasAmbulance': false,
    },
    {
      'id': 'MEGH006',
      'name': 'Medical Trust Hospital',
      'type': 'Multi-specialty',
      'latitude': 9.9750,
      'longitude': 76.2899,
      'address': 'M.G Road, Kochi, Kerala 682016',
      'phone': '+91 484 2661234',
      'distance': 6.2,
      'availableBeds': 15,
      'totalBeds': 250,
      'emergencyServices': true,
      'rating': 4.2,
      'specialties': ['Surgery', 'Medicine', 'Emergency', 'Maternity'],
      'waitTime': '40 mins',
      'hasAmbulance': true,
    },
  ];

  // Mock infected persons proximity data
  static final List<Map<String, dynamic>> _proximityAlerts = [
    {
      'id': 'PA001',
      'type': 'COVID-19',
      'severity': 'High',
      'distance': 0.5,
      'location': 'Ernakulam Market Area',
      'reportedTime': '2024-01-20 14:30',
      'affectedCount': 3,
      'precautions': [
        'Wear N95 mask',
        'Maintain 6 feet distance',
        'Use hand sanitizer frequently',
        'Avoid crowded areas',
      ],
    },
    {
      'id': 'PA002',
      'type': 'Dengue',
      'severity': 'Medium',
      'distance': 1.2,
      'location': 'Marine Drive',
      'reportedTime': '2024-01-19 16:45',
      'affectedCount': 2,
      'precautions': [
        'Use mosquito repellent',
        'Avoid stagnant water areas',
        'Wear full sleeves clothing',
        'Seek medical help if fever persists',
      ],
    },
    {
      'id': 'PA003',
      'type': 'Flu Outbreak',
      'severity': 'Low',
      'distance': 2.8,
      'location': 'Fort Kochi',
      'reportedTime': '2024-01-18 10:20',
      'affectedCount': 5,
      'precautions': [
        'Wear surgical mask',
        'Wash hands frequently',
        'Avoid close contact',
        'Get flu vaccination',
      ],
    },
  ];

  // Get current location
  static Map<String, double> getCurrentLocation() {
    return {'latitude': _currentLatitude, 'longitude': _currentLongitude};
  }

  // Calculate distance between two points using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get nearby hospitals sorted by distance
  static List<Map<String, dynamic>> getNearbyHospitals({
    double? maxDistance,
    String? specialty,
    bool? emergencyOnly,
    bool? availableBedsOnly,
  }) {
    List<Map<String, dynamic>> hospitals = List.from(_nearbyHospitals);

    // Apply filters
    if (maxDistance != null) {
      hospitals = hospitals.where((h) => h['distance'] <= maxDistance).toList();
    }

    if (specialty != null) {
      hospitals = hospitals.where((h) {
        List<String> specialties = List<String>.from(h['specialties']);
        return specialties.any(
          (s) => s.toLowerCase().contains(specialty.toLowerCase()),
        );
      }).toList();
    }

    if (emergencyOnly == true) {
      hospitals = hospitals
          .where((h) => h['emergencyServices'] == true)
          .toList();
    }

    if (availableBedsOnly == true) {
      hospitals = hospitals.where((h) => h['availableBeds'] > 0).toList();
    }

    // Sort by distance
    hospitals.sort((a, b) => a['distance'].compareTo(b['distance']));

    return hospitals;
  }

  // Get specific hospital by ID
  static Map<String, dynamic>? getHospitalById(String id) {
    try {
      return _nearbyHospitals.firstWhere((h) => h['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get proximity alerts
  static List<Map<String, dynamic>> getProximityAlerts({
    double? maxDistance,
    String? diseaseType,
    String? severity,
  }) {
    List<Map<String, dynamic>> alerts = List.from(_proximityAlerts);

    // Apply filters
    if (maxDistance != null) {
      alerts = alerts.where((a) => a['distance'] <= maxDistance).toList();
    }

    if (diseaseType != null) {
      alerts = alerts
          .where(
            (a) => a['type'].toLowerCase().contains(diseaseType.toLowerCase()),
          )
          .toList();
    }

    if (severity != null) {
      alerts = alerts
          .where((a) => a['severity'].toLowerCase() == severity.toLowerCase())
          .toList();
    }

    // Sort by distance (closest first)
    alerts.sort((a, b) => a['distance'].compareTo(b['distance']));

    return alerts;
  }

  // Get high-risk proximity alerts (within 2km)
  static List<Map<String, dynamic>> getHighRiskAlerts() {
    return getProximityAlerts(
      maxDistance: 2.0,
    ).where((alert) => alert['severity'] == 'High').toList();
  }

  // Get emergency hospitals (24/7 emergency services)
  static List<Map<String, dynamic>> getEmergencyHospitals() {
    return getNearbyHospitals(emergencyOnly: true, maxDistance: 10.0);
  }

  // Get hospitals with available beds
  static List<Map<String, dynamic>> getHospitalsWithBeds() {
    return getNearbyHospitals(availableBedsOnly: true);
  }

  // Search hospitals by name or specialty
  static List<Map<String, dynamic>> searchHospitals(String query) {
    if (query.isEmpty) return _nearbyHospitals;

    return _nearbyHospitals.where((hospital) {
      final name = hospital['name'].toLowerCase();
      final type = hospital['type'].toLowerCase();
      final specialties = hospital['specialties'].join(' ').toLowerCase();
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) ||
          type.contains(searchQuery) ||
          specialties.contains(searchQuery);
    }).toList();
  }

  // Get route to hospital (mock implementation)
  static Map<String, dynamic> getRouteToHospital(String hospitalId) {
    final hospital = getHospitalById(hospitalId);
    if (hospital == null) return {};

    return {
      'distance': hospital['distance'],
      'estimatedTime': '${(hospital['distance'] * 3).round()} mins',
      'route': 'Take NH-66, then turn right at Medical College Junction',
      'traffic': 'Moderate',
      'alternativeRoutes': 2,
      'coordinates': [
        {'lat': _currentLatitude, 'lng': _currentLongitude},
        {'lat': hospital['latitude'], 'lng': hospital['longitude']},
      ],
    };
  }

  // Book ambulance (mock implementation)
  static Map<String, dynamic> bookAmbulance(
    String hospitalId,
    String emergencyType,
  ) {
    final hospital = getHospitalById(hospitalId);
    if (hospital == null || !hospital['hasAmbulance']) {
      return {
        'success': false,
        'message': 'Ambulance service not available at this hospital',
      };
    }

    return {
      'success': true,
      'bookingId': 'AMB${DateTime.now().millisecondsSinceEpoch}',
      'estimatedArrival': '${(hospital['distance'] * 2 + 5).round()} mins',
      'ambulanceNumber': 'KL-07-AB-${(1000 + Random().nextInt(9000))}',
      'driverName': 'Ravi Kumar',
      'driverPhone': '+91 98765 43210',
      'hospitalName': hospital['name'],
      'message': 'Ambulance dispatched successfully',
    };
  }

  // Report infected person location (mock implementation)
  static bool reportInfectedLocation(
    String diseaseType,
    String location,
    int count,
  ) {
    // In a real app, this would send data to a server
    return true;
  }

  // Get health statistics for area
  static Map<String, dynamic> getAreaHealthStats() {
    return {
      'totalHospitals': _nearbyHospitals.length,
      'emergencyHospitals': _nearbyHospitals
          .where((h) => h['emergencyServices'])
          .length,
      'availableBeds': _nearbyHospitals.fold(
        0,
        (sum, h) => sum + (h['availableBeds'] as int),
      ),
      'totalBeds': _nearbyHospitals.fold(
        0,
        (sum, h) => sum + (h['totalBeds'] as int),
      ),
      'activeAlerts': _proximityAlerts.length,
      'highRiskAlerts': _proximityAlerts
          .where((a) => a['severity'] == 'High')
          .length,
      'averageRating':
          _nearbyHospitals.fold(0.0, (sum, h) => sum + h['rating']) /
          _nearbyHospitals.length,
      'coverageRadius': '10 km',
    };
  }

  // Get real-time bed availability (mock implementation)
  static Future<Map<String, dynamic>> getRealTimeBedAvailability(
    String hospitalId,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final hospital = getHospitalById(hospitalId);
    if (hospital == null) return {};

    return {
      'hospitalId': hospitalId,
      'hospitalName': hospital['name'],
      'lastUpdated': DateTime.now().toIso8601String(),
      'bedTypes': {
        'general': {
          'available': Random().nextInt(20),
          'total': 100,
          'price': '₹1,500/day',
        },
        'icu': {
          'available': Random().nextInt(5),
          'total': 20,
          'price': '₹5,000/day',
        },
        'emergency': {
          'available': Random().nextInt(10),
          'total': 30,
          'price': '₹3,000/day',
        },
        'private': {
          'available': Random().nextInt(15),
          'total': 50,
          'price': '₹8,000/day',
        },
      },
      'waitingList': Random().nextInt(5),
      'averageWaitTime': '${Random().nextInt(60)} minutes',
    };
  }

  // Emergency contact numbers
  static Map<String, String> getEmergencyContacts() {
    return {
      'ambulance': '108',
      'police': '100',
      'fire': '101',
      'healthHelpline': '104',
      'nationalEmergency': '112',
      'covidHelpline': '1075',
      'womenHelpline': '1091',
      'childHelpline': '1098',
    };
  }
}
