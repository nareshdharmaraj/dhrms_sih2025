import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wearable_device.dart';
import '../models/wearable_data.dart';
import '../utils/app_constants.dart';

class WearableService {
  // Use dynamic base URL from AppConstants
  static String get baseUrl => AppConstants.apiBaseUrl;

  // Device Management
  static Future<Map<String, dynamic>> registerDevice({
    required String patientId,
    required String deviceName,
    required WearableDeviceType deviceType,
    required String manufacturer,
    required String model,
    required String macAddress,
    required String bluetoothId,
    String? firmwareVersion,
    List<WearableCapability>? capabilities,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wearables/devices/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'patientId': patientId,
          'deviceName': deviceName,
          'deviceType': deviceType.value,
          'manufacturer': manufacturer,
          'model': model,
          'macAddress': macAddress,
          'bluetoothId': bluetoothId,
          'firmwareVersion': firmwareVersion,
          'capabilities': capabilities?.map((cap) => cap.value).toList() ?? [],
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'device': WearableDevice.fromJson(data['data']['device']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to register device',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getPatientDevices(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wearables/devices/patient/$patientId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final devices = (data['data']['devices'] as List)
            .map((deviceJson) => WearableDevice.fromJson(deviceJson))
            .toList();

        return {
          'success': true,
          'devices': devices,
          'count': data['data']['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch devices',
          'devices': <WearableDevice>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'devices': <WearableDevice>[],
      };
    }
  }

  static Future<Map<String, dynamic>> updateDeviceStatus({
    required String deviceId,
    WearableConnectionStatus? connectionStatus,
    int? batteryLevel,
    bool? isConnected,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (connectionStatus != null) body['connectionStatus'] = connectionStatus.value;
      if (batteryLevel != null) body['batteryLevel'] = batteryLevel;
      if (isConnected != null) body['isConnected'] = isConnected;

      final response = await http.put(
        Uri.parse('$baseUrl/wearables/devices/$deviceId/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'device': WearableDevice.fromJson(data['data']['device']),
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update device status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteDevice(String deviceId, {bool deleteData = false}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/wearables/devices/$deviceId?deleteData=$deleteData'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete device',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Data Management
  static Future<Map<String, dynamic>> storeWearableData(List<Map<String, dynamic>> dataPoints) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wearables/data/store'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'data': dataPoints,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'stored': data['data']['stored'],
          'criticalAlerts': data['data']['criticalAlerts'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to store wearable data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getLatestData({
    required String patientId,
    WearableDataType? dataType,
    int limit = 10,
  }) async {
    try {
      String url = '$baseUrl/wearables/data/latest/$patientId?limit=$limit';
      if (dataType != null) {
        url += '&dataType=${dataType.value}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final readings = (data['data']['readings'] as List)
            .map((readingJson) => WearableData.fromJson(readingJson))
            .toList();

        return {
          'success': true,
          'readings': readings,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch latest data',
          'readings': <WearableData>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'readings': <WearableData>[],
      };
    }
  }

  static Future<Map<String, dynamic>> getHourlyData({
    required String patientId,
    required WearableDataType dataType,
    DateTime? startDate,
    DateTime? endDate,
    String timezone = 'UTC',
  }) async {
    try {
      String url = '$baseUrl/wearables/data/hourly/$patientId?dataType=${dataType.value}&timezone=$timezone';
      
      if (startDate != null) {
        url += '&startDate=${startDate.toIso8601String()}';
      }
      if (endDate != null) {
        url += '&endDate=${endDate.toIso8601String()}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'dataType': data['data']['dataType'],
          'period': data['data']['period'],
          'hourlyReadings': data['data']['hourlyReadings'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch hourly data',
          'hourlyReadings': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'hourlyReadings': [],
      };
    }
  }

  static Future<Map<String, dynamic>> getAlerts({
    required String patientId,
    WearableAlertLevel? alertLevel,
    int limit = 50,
  }) async {
    try {
      String url = '$baseUrl/wearables/alerts/$patientId?limit=$limit';
      if (alertLevel != null && alertLevel != WearableAlertLevel.none) {
        url += '&alertLevel=${alertLevel.value}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final alerts = (data['data']['alerts'] as List)
            .map((alertJson) => WearableData.fromJson(alertJson))
            .toList();

        return {
          'success': true,
          'alerts': alerts,
          'count': data['data']['count'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch alerts',
          'alerts': <WearableData>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'alerts': <WearableData>[],
      };
    }
  }

  static Future<Map<String, dynamic>> getHealthDashboard(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wearables/dashboard/$patientId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final connectedDevices = (data['data']['connectedDevices'] as List)
            .map((deviceJson) => WearableDevice.fromJson(deviceJson))
            .toList();

        final latestReadings = <WearableDataType, WearableData>{};
        final latestReadingsData = data['data']['latestReadings'] as Map<String, dynamic>;
        
        for (final entry in latestReadingsData.entries) {
          final dataType = WearableDataType.fromString(entry.key);
          final reading = WearableData.fromJson(entry.value);
          latestReadings[dataType] = reading;
        }

        final recentAlerts = (data['data']['recentAlerts'] as List)
            .map((alertJson) => WearableData.fromJson(alertJson))
            .toList();

        return {
          'success': true,
          'connectedDevices': connectedDevices,
          'latestReadings': latestReadings,
          'recentAlerts': recentAlerts,
          'todayActivity': data['data']['todayActivity'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch health dashboard',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Utility Methods
  static Map<String, dynamic> createDataPoint({
    required String patientId,
    required String deviceId,
    required WearableDataType dataType,
    required double value,
    double? secondaryValue,
    required String unit,
    int quality = 100,
    Map<String, dynamic>? metadata,
    WearableDataSource source = WearableDataSource.realTime,
  }) {
    return {
      'patientId': patientId,
      'deviceId': deviceId,
      'dataType': dataType.value,
      'timestamp': DateTime.now().toIso8601String(),
      'value': value,
      'secondaryValue': secondaryValue,
      'unit': unit,
      'quality': quality,
      'metadata': metadata ?? {},
      'source': source.value,
    };
  }

  static bool isValueInNormalRange(WearableDataType dataType, double value, {double? secondaryValue}) {
    switch (dataType) {
      case WearableDataType.heartRate:
        return value >= 60 && value <= 100;
      case WearableDataType.bloodPressure:
        return value >= 90 && value <= 140 && 
               (secondaryValue == null || (secondaryValue >= 60 && secondaryValue <= 90));
      case WearableDataType.oxygenSaturation:
        return value >= 95 && value <= 100;
      case WearableDataType.temperature:
        return value >= 36.1 && value <= 37.2;
      default:
        return true; // For other types, assume normal for now
    }
  }
}
