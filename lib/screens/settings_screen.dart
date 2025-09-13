import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config/app_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Backend Configuration Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backend Configuration',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Backend Toggle Switch
                      SwitchListTile(
                        title: const Text('Use Cloud Backend'),
                        subtitle: Text(
                          AppConfig.useCloud
                              ? 'Connected to cloud server'
                              : 'Connected to local server',
                        ),
                        value: AppConfig.useCloud,
                        onChanged: (bool value) {
                          settings.toggleBackend(value);
                        },
                        secondary: Icon(
                          AppConfig.useCloud
                              ? Icons.cloud_done
                              : Icons.computer,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const Divider(),

                      // Current Configuration Display
                      _buildInfoRow('Environment:', AppConfig.environment),
                      _buildInfoRow('Base URL:', AppConfig.baseUrl),
                      _buildInfoRow('API URL:', AppConfig.apiUrl),

                      const SizedBox(height: 16),

                      // Test Connection Button
                      ElevatedButton.icon(
                        onPressed: () => _testConnection(context),
                        icon: const Icon(Icons.network_check),
                        label: const Text('Test Connection'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Debug Information Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Information',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Health Check:', AppConfig.healthCheck),
                      _buildInfoRow('Test Endpoint:', AppConfig.testEndpoint),
                      _buildInfoRow(
                        'Patient Register:',
                        AppConfig.patientsRegister,
                      ),
                      _buildInfoRow(
                        'Wearable Devices:',
                        AppConfig.wearableDevices,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _testConnection(BuildContext context) async {
    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Testing connection...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Here you would make an actual HTTP request to test the connection
      // For now, we'll just show the current configuration
      await Future.delayed(const Duration(seconds: 1));

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Testing ${AppConfig.environment} backend at ${AppConfig.baseUrl}',
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class SettingsProvider extends ChangeNotifier {
  void toggleBackend(bool useCloud) {
    AppConfig.setBackend(cloud: useCloud);
    notifyListeners();
  }
}
