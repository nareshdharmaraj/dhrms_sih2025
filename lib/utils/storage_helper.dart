import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class StorageHelper {
  static const String _deviceIdKey = 'contact_tracing_device_id';
  static const String _uhidKey = 'patient_uhid';
  static const String _userIdKey = 'user_id';

  // Device ID management for contact tracing
  static Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  static Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }

  static Future<String> generateDeviceId() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999);
    final deviceId = 'DHRMS_CT_${timestamp}_$random';
    await saveDeviceId(deviceId);
    return deviceId;
  }

  // UHID management
  static Future<String?> getUHID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_uhidKey);
  }

  static Future<void> saveUHID(String uhid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uhidKey, uhid);
  }

  // User ID management
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Clear all contact tracing data
  static Future<void> clearContactTracingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }

  // Utility methods
  static Future<bool> hasDeviceId() async {
    final deviceId = await getDeviceId();
    return deviceId != null && deviceId.isNotEmpty;
  }

  static Future<bool> hasUHID() async {
    final uhid = await getUHID();
    return uhid != null && uhid.isNotEmpty;
  }
}
