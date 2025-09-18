import 'package:flutter/material.dart';
import '../services/configuration_manager.dart';
import '../utils/app_constants.dart';
import '../utils/connection_test_service.dart';

class ApiConfigurationScreen extends StatefulWidget {
  const ApiConfigurationScreen({super.key});

  @override
  State<ApiConfigurationScreen> createState() => _ApiConfigurationScreenState();
}

class _ApiConfigurationScreenState extends State<ApiConfigurationScreen> {
  late ApiConfigMode _selectedMode;
  final _cloudUrlController = TextEditingController();
  final _physicalIpController = TextEditingController();
  final _portController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _testResults;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfiguration();
  }

  void _loadCurrentConfiguration() {
    final config = ConfigurationManager.instance;
    setState(() {
      _selectedMode = config.currentMode;
      _cloudUrlController.text = config.cloudUrl;
      _physicalIpController.text = config.physicalDeviceIp;
      _portController.text = config.serverPort.toString();
    });
  }

  @override
  void dispose() {
    _cloudUrlController.dispose();
    _physicalIpController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Configuration'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testConnection,
            tooltip: 'Test Connection',
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentStatusCard(),
            const SizedBox(height: 20),
            _buildModeSelector(),
            const SizedBox(height: 20),
            _buildConfigurationInputs(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            if (_testResults != null) ...[
              const SizedBox(height: 20),
              _buildTestResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    final currentUrl = ConfigurationManager.instance.getCurrentApiUrl();
    
    return Card(
      color: AppConstants.lightGreen,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_ethernet, color: AppConstants.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Current Configuration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow('Mode', _selectedMode.displayName),
            _buildStatusRow('API URL', currentUrl),
            _buildStatusRow('Status', _isOnline() ? 'Online' : 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔧 Select Configuration Mode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            ...ApiConfigMode.values.map((mode) => _buildModeOption(mode)),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(ApiConfigMode mode) {
    final isSelected = _selectedMode == mode;
    String description;
    IconData icon;
    
    switch (mode) {
      case ApiConfigMode.cloud:
        description = 'Use cloud server (Render, Heroku, etc.)';
        icon = Icons.cloud;
        break;
      case ApiConfigMode.physicalDevice:
        description = 'Connect to local server via IP address';
        icon = Icons.phone_android;
        break;
      case ApiConfigMode.local:
        description = 'Local development (emulator/simulator)';
        icon = Icons.computer;
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppConstants.primaryGreen : AppConstants.lightGrey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? AppConstants.lightGreen : null,
      ),
      child: RadioListTile<ApiConfigMode>(
        value: mode,
        groupValue: _selectedMode,
        onChanged: (ApiConfigMode? value) {
          if (value != null) {
            setState(() {
              _selectedMode = value;
            });
          }
        },
        title: Row(
          children: [
            Icon(icon, color: AppConstants.primaryGreen),
            const SizedBox(width: 8),
            Text(
              mode.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Text(description),
        activeColor: AppConstants.primaryGreen,
      ),
    );
  }

  Widget _buildConfigurationInputs() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚙️ Configuration Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cloud URL input
            TextFormField(
              controller: _cloudUrlController,
              decoration: InputDecoration(
                labelText: 'Cloud Server URL',
                hintText: 'https://dhrms-sih2025.onrender.com/api',
                prefixIcon: const Icon(Icons.cloud_queue),
                border: const OutlineInputBorder(),
                enabled: _selectedMode == ApiConfigMode.cloud,
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            
            // Physical device IP input
            TextFormField(
              controller: _physicalIpController,
              decoration: InputDecoration(
                labelText: 'Physical Device IP',
                hintText: '192.168.1.100',
                prefixIcon: const Icon(Icons.router),
                border: const OutlineInputBorder(),
                enabled: _selectedMode == ApiConfigMode.physicalDevice,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Port input
            TextFormField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'Server Port',
                hintText: '3000',
                prefixIcon: const Icon(Icons.settings_ethernet),
                border: const OutlineInputBorder(),
                enabled: _selectedMode != ApiConfigMode.cloud,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _applyConfiguration,
            icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_isLoading ? 'Applying...' : 'Apply Configuration'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _testConnection,
            icon: const Icon(Icons.wifi_find),
            label: const Text('Test Connection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestResults() {
    final success = _testResults?['success'] ?? false;
    
    return Card(
      color: success ? AppConstants.lightGreen : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Connection Test Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: success ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _testResults?['message'] ?? 'No test results available',
              style: const TextStyle(fontSize: 14),
            ),
            if (_testResults?['url'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'URL: ${_testResults!['url']}',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isOnline() {
    return _testResults?['success'] ?? false;
  }

  Future<void> _applyConfiguration() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final config = ConfigurationManager.instance;
      
      // Update configuration based on selected mode
      await config.switchMode(_selectedMode);
      
      if (_selectedMode == ApiConfigMode.cloud) {
        await config.updateCloudUrl(_cloudUrlController.text.trim());
      } else if (_selectedMode == ApiConfigMode.physicalDevice) {
        await config.updatePhysicalDeviceIp(_physicalIpController.text.trim());
        await config.updateServerPort(int.tryParse(_portController.text) ?? 3000);
      } else {
        await config.updateServerPort(int.tryParse(_portController.text) ?? 3000);
      }

      // Test the new configuration
      await _testConnection();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Configuration applied successfully!'),
            backgroundColor: AppConstants.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error applying configuration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await ConnectionTestService.runAllTests();
      setState(() {
        _testResults = results;
      });
    } catch (e) {
      setState(() {
        _testResults = {
          'success': false,
          'message': 'Connection test failed: $e',
          'url': ConfigurationManager.instance.getCurrentApiUrl(),
        };
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('This will reset all configuration settings to default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ConfigurationManager.instance.resetToDefaults();
      _loadCurrentConfiguration();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔄 Configuration reset to defaults'),
            backgroundColor: AppConstants.primaryBlue,
          ),
        );
      }
    }
  }
}