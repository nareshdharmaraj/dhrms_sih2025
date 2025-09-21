import 'package:flutter/material.dart';
import '../services/configuration_manager.dart';
import '../utils/environment_config.dart';

/// Debug widget to show and test configuration
class ConfigurationDebugWidget extends StatefulWidget {
  const ConfigurationDebugWidget({super.key});

  @override
  State<ConfigurationDebugWidget> createState() => _ConfigurationDebugWidgetState();
}

class _ConfigurationDebugWidgetState extends State<ConfigurationDebugWidget> {
  String _currentUrl = '';
  String _configInfo = '';

  @override
  void initState() {
    super.initState();
    _loadConfigInfo();
  }

  Future<void> _loadConfigInfo() async {
    await EnvironmentConfig.initialize();
    
    final url = EnvironmentConfig.getApiBaseUrl();
    final configInfo = ConfigurationManager.instance.getConfigurationInfo();
    
    setState(() {
      _currentUrl = url;
      _configInfo = configInfo.toString();
    });
    
    debugPrint('🔍 Configuration Debug:');
    debugPrint('   Current URL: $url');
    debugPrint('   Config Info: $configInfo');
  }

  Future<void> _resetConfiguration() async {
    await ConfigurationManager.instance.resetToDefaults();
    await _loadConfigInfo();
  }

  Future<void> _testConnection() async {
    // This would test the connection to the current URL
    debugPrint('🧪 Testing connection to: $_currentUrl');
    // Add actual HTTP test here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Debug'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current API URL:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _currentUrl.contains(':3001') ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentUrl.contains(':3001') ? Colors.red : Colors.green,
                ),
              ),
              child: Text(
                _currentUrl.isEmpty ? 'Loading...' : _currentUrl,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: _currentUrl.contains(':3001') ? Colors.red.shade800 : Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            if (_currentUrl.contains(':3001'))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Wrong Port Detected!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('The app is trying to connect to port 3001, but the server is running on port 3000.'),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _resetConfiguration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset Config'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _testConnection,
                  child: const Text('Test Connection'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loadConfigInfo,
                  child: const Text('Refresh'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            Text(
              'Configuration Details:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _configInfo.isEmpty ? 'Loading configuration...' : _configInfo,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}