import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../services/configuration_manager.dart';

/// Environment-based configuration service with dynamic runtime switching
/// Combines build-time environment variables with runtime configuration management
class EnvironmentConfig {
  // Build-time environment variables (fallbacks)
  static const String _buildTimeApiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  
  static const String _buildTimeCloudUrl = String.fromEnvironment(
    'CLOUD_API_URL', 
    defaultValue: 'https://dhrms-sih2025.onrender.com/api',
  );
  
  static const bool _buildTimeUseCloud = bool.fromEnvironment(
    'USE_CLOUD_SERVER',
    defaultValue: false,
  );
  
  static const String _buildTimePhysicalIp = String.fromEnvironment(
    'PHYSICAL_DEVICE_IP',
    defaultValue: '172.2.4.104',
  );
  
  static const int _buildTimeServerPort = int.fromEnvironment(
    'SERVER_PORT',
    defaultValue: 3000,
  );

  /// Get the current API base URL - now uses ConfigurationManager for dynamic switching
  static String getApiBaseUrl() {
    // Priority 1: Use build-time override if specified
    if (_buildTimeApiUrl.isNotEmpty) {
      debugPrint('🔍 Using build-time API URL: $_buildTimeApiUrl');
      return _buildTimeApiUrl;
    }
    
    // Priority 2: Use runtime configuration manager
    final runtimeUrl = ConfigurationManager.instance.getCurrentApiUrl();
    debugPrint('🔍 Using runtime API URL: $runtimeUrl');
    return runtimeUrl;
  }
  
  // Getters for compatibility and configuration display
  static bool get useCloudServer => ConfigurationManager.instance.currentMode == ApiConfigMode.cloud;
  static String get cloudApiUrl => ConfigurationManager.instance.cloudUrl;
  static String get physicalDeviceIP => ConfigurationManager.instance.physicalDeviceIp;
  static int get serverPort => ConfigurationManager.instance.serverPort;
  static ApiConfigMode get currentMode => ConfigurationManager.instance.currentMode;
  
  /// Initialize the configuration system
  static Future<void> initialize() async {
    await ConfigurationManager.instance.initialize();
    
    // TEMPORARY FIX: Force reset if using wrong port 3001
    final currentUrl = ConfigurationManager.instance.getCurrentApiUrl();
    if (currentUrl.contains(':3001')) {
      debugPrint('🔧 Detected old port 3001, resetting configuration...');
      await ConfigurationManager.instance.resetToDefaults();
    }
    
    // Apply build-time overrides if they exist
    if (_buildTimeUseCloud) {
      await ConfigurationManager.instance.switchMode(ApiConfigMode.cloud);
    }
    
    if (_buildTimeCloudUrl != 'https://your-app-name.onrender.com/api') {
      await ConfigurationManager.instance.updateCloudUrl(_buildTimeCloudUrl);
    }
    
    if (_buildTimePhysicalIp != '172.2.4.104') {
      await ConfigurationManager.instance.updatePhysicalDeviceIp(_buildTimePhysicalIp);
    }
    
    if (_buildTimeServerPort != 3000) {
      await ConfigurationManager.instance.updateServerPort(_buildTimeServerPort);
    }
    
    debugPrint('🚀 EnvironmentConfig initialized with mode: ${ConfigurationManager.instance.currentMode.displayName}');
    debugPrint('🔍 Final API URL: ${getApiBaseUrl()}');
  }
  
  /// Get current environment information for debugging
  static Map<String, dynamic> getEnvironmentInfo() {
    final configInfo = ConfigurationManager.instance.getConfigurationInfo();
    
    return {
      ...configInfo,
      'buildTimeOverrides': {
        'apiBaseUrl': _buildTimeApiUrl,
        'useCloudServer': _buildTimeUseCloud,
        'cloudApiUrl': _buildTimeCloudUrl,
        'physicalDeviceIP': _buildTimePhysicalIp,
        'serverPort': _buildTimeServerPort,
      },
      'platform': _getPlatformName(),
      'isWeb': kIsWeb,
      'isDebugMode': kDebugMode,
      'isProfileMode': kProfileMode,
      'isReleaseMode': kReleaseMode,
    };
  }
  
  static String _getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
  
  /// Instructions for configuring environment variables
  static const String configurationInstructions = '''
Environment Configuration Guide:

1. BUILD-TIME CONFIGURATION (Recommended):
   flutter run --dart-define=API_BASE_URL=http://your-ip:3000/api
   flutter run --dart-define=USE_CLOUD_SERVER=true
   flutter run --dart-define=CLOUD_API_URL=https://your-app.onrender.com/api

2. FOR DEVELOPMENT:
   Create a launch configuration in your IDE with dart-define parameters

3. FOR PRODUCTION:
   Set environment variables in your CI/CD pipeline or build scripts

4. AVAILABLE ENVIRONMENT VARIABLES:
   - API_BASE_URL: Direct API URL override
   - USE_CLOUD_SERVER: true/false for cloud vs local
   - CLOUD_API_URL: Your cloud deployment URL
   - PHYSICAL_DEVICE_IP: IP address for physical device testing
   - SERVER_PORT: Backend server port (default: 3000)

5. EXAMPLES:
   # Local development with physical device
   flutter run --dart-define=PHYSICAL_DEVICE_IP=192.168.1.100
   
   # Cloud development
   flutter run --dart-define=USE_CLOUD_SERVER=true --dart-define=CLOUD_API_URL=https://myapp.onrender.com/api
   
   # Direct URL override
   flutter run --dart-define=API_BASE_URL=https://api.myapp.com/v1
  ''';
}