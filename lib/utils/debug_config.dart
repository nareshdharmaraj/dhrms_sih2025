/// Debug configuration for development and testing
/// 
/// This file helps developers easily switch between different
/// deployment environments without modifying core files.
library;

class DebugConfig {
  // Environment Configuration
  // Set to true to use cloud server, false for local development
  static const bool useCloudServer = false;
  
  // Render server configuration (for cloud testing)
  static const String cloudServerUrl = 'https://your-app-name.onrender.com/api';
  // Replace 'your-app-name' with your actual Render service name
  // Example: 'https://myhealth-backend.onrender.com/api'
  
  // Local development configuration
  // Set this to true when testing on physical device
  // Set to false for emulator/web testing
  static const bool forcePhysicalDeviceMode = true;
  
  // Alternative: Set this to your computer's IP address for physical device testing
  static const String physicalDeviceIP = '172.2.4.104';
  // Alternative IPs from your network:
  // Ethernet: '172.2.4.104' (recommended if phone is on same network)
  // Hotspot: '192.168.137.1' (if using mobile hotspot from this computer)
  
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
    📱 PHYSICAL DEVICE SETUP (Current Mode):
    
    1. Make sure your phone and computer are on the same WiFi network
    
    2. Find your computer's IP address:
       - Windows: Open cmd → type "ipconfig" → look for IPv4 Address
       - Mac: System Preferences → Network → Advanced → TCP/IP
       - Linux: Open terminal → type "ifconfig" or "ip addr"
    
    3. Update physicalDeviceIP below with your computer's IP address
    
    4. Start your backend server locally:
       - cd backend
       - npm run dev
    
    5. Test connection using the debug screen (🐛 icon) in the app
    
    🌐 RENDER CLOUD MODE (Alternative):
    
    1. Set useCloudServer = true
    2. Update cloudServerUrl with your Render service name
    3. Note: First request after sleep takes 30-60 seconds
    
    ⚡ QUICK TIPS FOR PHYSICAL DEVICE:
    - Use debug screen to test connection before using main features
    - If connection fails, verify IP address and WiFi network
    - Make sure Windows Firewall allows Node.js connections
    - Backend server must be running on your computer
  ''';
}