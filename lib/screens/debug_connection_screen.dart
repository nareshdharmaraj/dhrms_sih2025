import 'package:flutter/material.dart';
import '../utils/connection_test_service.dart';
import '../utils/app_constants.dart';
import '../utils/debug_config.dart';

class DebugConnectionScreen extends StatefulWidget {
  const DebugConnectionScreen({super.key});

  @override
  State<DebugConnectionScreen> createState() => _DebugConnectionScreenState();
}

class _DebugConnectionScreenState extends State<DebugConnectionScreen> {
  Map<String, dynamic>? testResults;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-run tests when screen opens
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      isLoading = true;
      testResults = null;
    });

    final results = await ConnectionTestService.runAllTests();

    setState(() {
      testResults = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connection Debug'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _runTests,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfigSection(),
            SizedBox(height: 20),
            _buildTestSection(),
            SizedBox(height: 20),
            _buildActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildConfigRow('API Base URL', AppConstants.apiBaseUrl),
            _buildConfigRow('Physical Device Mode', DebugConfig.forcePhysicalDeviceMode.toString()),
            _buildConfigRow('Physical Device IP', DebugConfig.physicalDeviceIP),
            _buildConfigRow('Server Port', DebugConfig.serverPort.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Tests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (isLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Testing connections...'),
                  ],
                ),
              )
            else if (testResults != null)
              _buildTestResults()
            else
              Text('No test results yet'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    if (testResults == null) return Container();

    return Column(
      children: [
        _buildTestResultItem('Overall', testResults!['overall']),
        Divider(),
        _buildTestResultItem('Basic Connection', testResults!['basic']),
        _buildTestResultItem('Login Endpoint', testResults!['login']),
        _buildTestResultItem('Registration Endpoint', testResults!['registration']),
      ],
    );
  }

  Widget _buildTestResultItem(String title, Map<String, dynamic> result) {
    final isSuccess = result['success'] == true;
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green : Colors.red,
        ),
        title: Text(title),
        subtitle: Text(result['message'] ?? 'No message'),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result['endpoint'] != null)
                  SelectableText(
                    'Endpoint: ${result['endpoint']}',
                    style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                if (result['statusCode'] != null)
                  Text(
                    'Status Code: ${result['statusCode']}',
                    style: TextStyle(fontSize: 12),
                  ),
                if (result['latency'] != null)
                  Text(
                    'Latency: ${result['latency']}',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                if (result['error'] != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Error Details:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    result['error'],
                    style: TextStyle(fontSize: 11, color: Colors.red, fontFamily: 'monospace'),
                  ),
                ],
                if (result['troubleshooting'] != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Troubleshooting Steps:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  Text(
                    result['troubleshooting'],
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Retest'),
                  onPressed: _runTests,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.settings),
                  label: Text('Config Guide'),
                  onPressed: _showConfigGuide,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.bug_report),
                  label: Text('Debug Info'),
                  onPressed: _showDebugInfo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configuration Guide'),
        content: SingleChildScrollView(
          child: Text('''
For Physical Device Testing:

1. Open lib/utils/debug_config.dart
2. Set forcePhysicalDeviceMode = true
3. Update physicalDeviceIP to your computer's IP
4. Ensure your backend server is running
5. Connect phone to same WiFi as computer

Common IP Commands:
• Windows: ipconfig
• Mac/Linux: ifconfig

Current Settings:
• Physical Mode: ${DebugConfig.forcePhysicalDeviceMode}
• Device IP: ${DebugConfig.physicalDeviceIP}
• API URL: ${AppConstants.apiBaseUrl}
          '''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Debug Information'),
        content: SingleChildScrollView(
          child: SelectableText('''
Platform: ${Theme.of(context).platform}
API Base URL: ${AppConstants.apiBaseUrl}
Physical Device Mode: ${DebugConfig.forcePhysicalDeviceMode}
Physical Device IP: ${DebugConfig.physicalDeviceIP}
Server Port: ${DebugConfig.serverPort}

Test Results:
${testResults != null ? testResults.toString() : 'No test results'}
          '''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}