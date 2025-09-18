/// Debug configuration for development and testing
/// 
/// This file helps developers easily switch between different
/// deployment environments without modifying core files.
library;

class DebugConfig {
  // Environment Configuration
  // Set to true to use cloud server, false for local development
  static const bool useCloudServer = false;
  
  // Cloud server configuration
  static const String cloudServerUrl = 'https://your-cloud-api.herokuapp.com/api';
  // Example cloud URLs:
  // Heroku: 'https://your-app-name.herokuapp.com/api'
  // Railway: 'https://your-app-name.railway.app/api'
  // Render: 'https://your-app-name.onrender.com/api'
  // Custom domain: 'https://api.yourapp.com/api'
  
  // Local development configuration
  // Set this to true when testing on physical device
  // Set to false for emulator/web testing
  static const bool forcePhysicalDeviceMode = true;
  
  // Alternative: Set this to your computer's IP address for physical device testing
  static const String physicalDeviceIP = '10.123.62.47';
  
  // Server port (usually 3000)
  static const int serverPort = 3000;
  
  // Helper method to get the appropriate base URL
  static String getDebugBaseUrl() {
    // Priority 1: Use cloud server if enabled
    if (useCloudServer) {
      return cloudServerUrl;
    }
    
    // Priority 2: Use physical device mode for local development
    if (forcePhysicalDeviceMode) {
      return 'http://$physicalDeviceIP:$serverPort/api';
    }
    
    // Priority 3: Use default platform detection
    return ''; // Use default platform detection
  }
  
  // Instructions for developers
  static const String instructions = '''
    HOW TO USE THIS DEBUG CONFIG:
    
    🌐 CLOUD SERVER MODE:
    1. Set useCloudServer = true
    2. Update cloudServerUrl with your deployed API URL
    3. Examples:
       - Heroku: https://your-app-name.herokuapp.com/api
       - Railway: https://your-app-name.railway.app/api
       - Render: https://your-app-name.onrender.com/api
       - Custom: https://api.yourapp.com/api
    
    🏠 LOCAL DEVELOPMENT MODE:
    1. Set useCloudServer = false
    
    For Physical Device Testing:
       - Set forcePhysicalDeviceMode = true
       - Update physicalDeviceIP to your computer's IP address
       - Make sure your backend server is running on that IP
    
    For Emulator Testing:
       - Set forcePhysicalDeviceMode = false
       - App will automatically use 10.0.2.2 for Android emulator
    
    For Web Testing:
       - Set forcePhysicalDeviceMode = false
       - App will automatically use localhost for web
    
    For iOS Simulator:
       - Set forcePhysicalDeviceMode = false
       - App will automatically use localhost for iOS simulator
       
    📝 COMMON CLOUD PROVIDERS:
    - Heroku: Free tier available, easy deployment
    - Railway: Modern platform, good for Node.js
    - Render: Free tier, automatic deploys from git
    - Vercel: Great for full-stack apps
    - DigitalOcean App Platform: Scalable option
  ''';
}