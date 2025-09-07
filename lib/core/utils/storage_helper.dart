import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Get SharedPreferences instance
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Authentication token methods
  static Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    final prefs = await _instance;
    await prefs.remove('auth_token');
  }

  // Refresh token methods
  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await _instance;
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await _instance;
    return prefs.getString('refresh_token');
  }

  static Future<void> removeRefreshToken() async {
    final prefs = await _instance;
    await prefs.remove('refresh_token');
  }

  // User data methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _instance;
    final userDataJson = jsonEncode(userData);
    await prefs.setString('user_data', userDataJson);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _instance;
    final userDataJson = prefs.getString('user_data');
    if (userDataJson != null) {
      return jsonDecode(userDataJson) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> removeUserData() async {
    final prefs = await _instance;
    await prefs.remove('user_data');
  }

  // User role methods
  static Future<void> saveUserRole(String role) async {
    final prefs = await _instance;
    await prefs.setString('user_role', role);
  }

  static Future<String?> getUserRole() async {
    final prefs = await _instance;
    return prefs.getString('user_role');
  }

  static Future<void> removeUserRole() async {
    final prefs = await _instance;
    await prefs.remove('user_role');
  }

  // User ID methods
  static Future<void> saveUserId(String userId) async {
    final prefs = await _instance;
    await prefs.setString('user_id', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await _instance;
    return prefs.getString('user_id');
  }

  static Future<void> removeUserId() async {
    final prefs = await _instance;
    await prefs.remove('user_id');
  }

  // Login status methods
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _instance;
    await prefs.setBool('is_logged_in', isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    return prefs.getBool('is_logged_in') ?? false;
  }

  // App settings methods
  static Future<void> saveThemeMode(String themeMode) async {
    final prefs = await _instance;
    await prefs.setString('theme_mode', themeMode);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await _instance;
    return prefs.getString('theme_mode');
  }

  static Future<void> saveLanguage(String language) async {
    final prefs = await _instance;
    await prefs.setString('language', language);
  }

  static Future<String?> getLanguage() async {
    final prefs = await _instance;
    return prefs.getString('language');
  }

  // Health data methods
  static Future<void> saveHealthRecords(List<Map<String, dynamic>> records) async {
    final prefs = await _instance;
    final recordsJson = jsonEncode(records);
    await prefs.setString('health_records', recordsJson);
  }

  static Future<List<Map<String, dynamic>>?> getHealthRecords() async {
    final prefs = await _instance;
    final recordsJson = prefs.getString('health_records');
    if (recordsJson != null) {
      final recordsList = jsonDecode(recordsJson) as List;
      return recordsList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  static Future<void> removeHealthRecords() async {
    final prefs = await _instance;
    await prefs.remove('health_records');
  }

  // Vitals data methods
  static Future<void> saveVitalsData(Map<String, dynamic> vitalsData) async {
    final prefs = await _instance;
    final vitalsJson = jsonEncode(vitalsData);
    await prefs.setString('vitals_data', vitalsJson);
  }

  static Future<Map<String, dynamic>?> getVitalsData() async {
    final prefs = await _instance;
    final vitalsJson = prefs.getString('vitals_data');
    if (vitalsJson != null) {
      return jsonDecode(vitalsJson) as Map<String, dynamic>;
    }
    return null;
  }

  // Emergency contacts methods
  static Future<void> saveEmergencyContacts(List<Map<String, dynamic>> contacts) async {
    final prefs = await _instance;
    final contactsJson = jsonEncode(contacts);
    await prefs.setString('emergency_contacts', contactsJson);
  }

  static Future<List<Map<String, dynamic>>?> getEmergencyContacts() async {
    final prefs = await _instance;
    final contactsJson = prefs.getString('emergency_contacts');
    if (contactsJson != null) {
      final contactsList = jsonDecode(contactsJson) as List;
      return contactsList.cast<Map<String, dynamic>>();
    }
    return null;
  }

  // AI chat session methods
  static Future<void> saveCurrentAISession(String sessionId) async {
    final prefs = await _instance;
    await prefs.setString('current_ai_session', sessionId);
  }

  static Future<String?> getCurrentAISession() async {
    final prefs = await _instance;
    return prefs.getString('current_ai_session');
  }

  static Future<void> removeCurrentAISession() async {
    final prefs = await _instance;
    await prefs.remove('current_ai_session');
  }

  // Notifications settings
  static Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    final prefs = await _instance;
    final settingsJson = jsonEncode(settings);
    await prefs.setString('notification_settings', settingsJson);
  }

  static Future<Map<String, bool>?> getNotificationSettings() async {
    final prefs = await _instance;
    final settingsJson = prefs.getString('notification_settings');
    if (settingsJson != null) {
      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      return settingsMap.map((key, value) => MapEntry(key, value as bool));
    }
    return null;
  }

  // Privacy settings
  static Future<void> savePrivacySettings(Map<String, bool> settings) async {
    final prefs = await _instance;
    final settingsJson = jsonEncode(settings);
    await prefs.setString('privacy_settings', settingsJson);
  }

  static Future<Map<String, bool>?> getPrivacySettings() async {
    final prefs = await _instance;
    final settingsJson = prefs.getString('privacy_settings');
    if (settingsJson != null) {
      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      return settingsMap.map((key, value) => MapEntry(key, value as bool));
    }
    return null;
  }

  // Location data
  static Future<void> saveLastKnownLocation(double latitude, double longitude) async {
    final prefs = await _instance;
    await prefs.setDouble('last_latitude', latitude);
    await prefs.setDouble('last_longitude', longitude);
    await prefs.setInt('location_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<Map<String, double>?> getLastKnownLocation() async {
    final prefs = await _instance;
    final latitude = prefs.getDouble('last_latitude');
    final longitude = prefs.getDouble('last_longitude');
    
    if (latitude != null && longitude != null) {
      return {
        'latitude': latitude,
        'longitude': longitude,
      };
    }
    return null;
  }

  // Device information
  static Future<void> saveDeviceInfo(Map<String, String> deviceInfo) async {
    final prefs = await _instance;
    final deviceInfoJson = jsonEncode(deviceInfo);
    await prefs.setString('device_info', deviceInfoJson);
  }

  static Future<Map<String, String>?> getDeviceInfo() async {
    final prefs = await _instance;
    final deviceInfoJson = prefs.getString('device_info');
    if (deviceInfoJson != null) {
      final deviceInfoMap = jsonDecode(deviceInfoJson) as Map<String, dynamic>;
      return deviceInfoMap.map((key, value) => MapEntry(key, value.toString()));
    }
    return null;
  }

  // Clear all data (for logout)
  static Future<void> clearAllData() async {
    final prefs = await _instance;
    await prefs.clear();
  }

  // Clear only auth data (for logout but keep app settings)
  static Future<void> clearAuthData() async {
    final prefs = await _instance;
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    await prefs.setBool('is_logged_in', false);
  }

  // Backup and restore data
  static Future<Map<String, dynamic>> exportData() async {
    final prefs = await _instance;
    return prefs.getKeys().fold<Map<String, dynamic>>({}, (map, key) {
      final value = prefs.get(key);
      if (value != null) {
        map[key] = value;
      }
      return map;
    });
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    final prefs = await _instance;
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      }
    }
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key);
  }

  // Get all keys
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _instance;
    return prefs.getKeys();
  }
}
