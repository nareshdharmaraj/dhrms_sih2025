import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Enumeration for different API configuration modes
enum ApiConfigMode {
  cloud('Cloud Server'),
  local('Local Development'),
  physicalDevice('Physical Device');

  const ApiConfigMode(this.displayName);
  final String displayName;
}

/// Dynamic configuration manager that allows runtime switching between different API configurations
class ConfigurationManager {
  static ConfigurationManager? _instance;
  static ConfigurationManager get instance => _instance ??= ConfigurationManager._();
  
  ConfigurationManager._();
  
  // Storage keys
  static const String _modeKey = 'api_config_mode';
  static const String _cloudUrlKey = 'cloud_api_url';
  static const String _physicalDeviceIpKey = 'physical_device_ip';
  static const String _serverPortKey = 'server_port';
  static const String _lastSwitchedKey = 'last_switched_timestamp';
  
  // Default values
  static const String _defaultCloudUrl = 'https://dhrms-sih2025.onrender.com/api';
  static const String _defaultPhysicalDeviceIp = '172.2.4.104';
  static const int _defaultServerPort = 3000;
  static const int _defaultLocalServerPort = 3000;
  
  // Current configuration
  ApiConfigMode _currentMode = ApiConfigMode.local;
  String _cloudUrl = _defaultCloudUrl;
  String _physicalDeviceIp = _defaultPhysicalDeviceIp;
  int _serverPort = _defaultServerPort;
  
  // Getters
  ApiConfigMode get currentMode => _currentMode;
  String get cloudUrl => _cloudUrl;
  String get physicalDeviceIp => _physicalDeviceIp;
  int get serverPort => _serverPort;
  
  /// Initialize the configuration manager by loading saved preferences
  Future<void> initialize() async {
    await _loadConfiguration();
  }
  
  /// Get the current API base URL based on the selected mode
  String getCurrentApiUrl() {
    switch (_currentMode) {
      case ApiConfigMode.cloud:
        return _cloudUrl;
      case ApiConfigMode.physicalDevice:
        return 'http://$_physicalDeviceIp:$_serverPort/api';
      case ApiConfigMode.local:
        return _getLocalUrl();
    }
  }
  
  /// Get platform-specific local URL
  String _getLocalUrl() {
    final localPort = _defaultLocalServerPort; // Use debug port for local development
    if (kIsWeb) {
      return 'http://localhost:$localPort/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:$localPort/api'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:$localPort/api'; // iOS simulator
    } else {
      // Desktop platforms
      return 'http://localhost:$localPort/api';
    }
  }
  
  /// Switch to a different configuration mode
  Future<void> switchMode(ApiConfigMode newMode) async {
    if (_currentMode != newMode) {
      _currentMode = newMode;
      await _saveConfiguration();
      
      // Log the switch for debugging
      debugPrint('🔄 API Configuration switched to: ${newMode.displayName}');
      debugPrint('📡 New API URL: ${getCurrentApiUrl()}');
    }
  }
  
  /// Update cloud server URL
  Future<void> updateCloudUrl(String newUrl) async {
    if (_cloudUrl != newUrl) {
      _cloudUrl = newUrl;
      await _saveConfiguration();
      debugPrint('☁️ Cloud URL updated to: $newUrl');
    }
  }
  
  /// Update physical device IP
  Future<void> updatePhysicalDeviceIp(String newIp) async {
    if (_physicalDeviceIp != newIp) {
      _physicalDeviceIp = newIp;
      await _saveConfiguration();
      debugPrint('📱 Physical device IP updated to: $newIp');
    }
  }
  
  /// Update server port
  Future<void> updateServerPort(int newPort) async {
    if (_serverPort != newPort) {
      _serverPort = newPort;
      await _saveConfiguration();
      debugPrint('🔌 Server port updated to: $newPort');
    }
  }
  
  /// Get detailed configuration information for debugging
  Map<String, dynamic> getConfigurationInfo() {
    return {
      'currentMode': _currentMode.displayName,
      'currentApiUrl': getCurrentApiUrl(),
      'cloudUrl': _cloudUrl,
      'physicalDeviceIp': _physicalDeviceIp,
      'serverPort': _serverPort,
      'platform': _getPlatformName(),
      'isWeb': kIsWeb,
      'lastSwitched': DateTime.now().toIso8601String(),
    };
  }
  
  /// Reset to default configuration
  Future<void> resetToDefaults() async {
    _currentMode = ApiConfigMode.local;
    _cloudUrl = _defaultCloudUrl;
    _physicalDeviceIp = _defaultPhysicalDeviceIp;
    _serverPort = _defaultServerPort;
    await _saveConfiguration();
    debugPrint('🔄 Configuration reset to defaults');
  }
  
  /// Load configuration from shared preferences
  Future<void> _loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load mode
      final modeIndex = prefs.getInt(_modeKey) ?? ApiConfigMode.local.index;
      _currentMode = ApiConfigMode.values[modeIndex];
      
      // Load URLs and settings
      _cloudUrl = prefs.getString(_cloudUrlKey) ?? _defaultCloudUrl;
      _physicalDeviceIp = prefs.getString(_physicalDeviceIpKey) ?? _defaultPhysicalDeviceIp;
      _serverPort = prefs.getInt(_serverPortKey) ?? _defaultServerPort;
      
      debugPrint('✅ Configuration loaded: ${_currentMode.displayName}');
    } catch (e) {
      debugPrint('⚠️ Error loading configuration: $e');
      // Use defaults if loading fails
    }
  }
  
  /// Save configuration to shared preferences
  Future<void> _saveConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt(_modeKey, _currentMode.index);
      await prefs.setString(_cloudUrlKey, _cloudUrl);
      await prefs.setString(_physicalDeviceIpKey, _physicalDeviceIp);
      await prefs.setInt(_serverPortKey, _serverPort);
      await prefs.setString(_lastSwitchedKey, DateTime.now().toIso8601String());
      
      debugPrint('💾 Configuration saved successfully');
    } catch (e) {
      debugPrint('⚠️ Error saving configuration: $e');
    }
  }
  
  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
  
  /// Get available modes with their current URLs for display
  List<Map<String, String>> getAvailableModes() {
    return ApiConfigMode.values.map((mode) {
      String url;
      switch (mode) {
        case ApiConfigMode.cloud:
          url = _cloudUrl;
          break;
        case ApiConfigMode.physicalDevice:
          url = 'http://$_physicalDeviceIp:$_serverPort/api';
          break;
        case ApiConfigMode.local:
          url = _getLocalUrl();
          break;
      }
      
      return {
        'mode': mode.displayName,
        'url': url,
        'isActive': (mode == _currentMode).toString(),
      };
    }).toList();
  }
}