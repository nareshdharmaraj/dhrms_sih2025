import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/configuration_manager.dart';
import '../utils/environment_config.dart';

/// Debug configuration switcher widget for easy API mode switching during development
class ConfigurationSwitcher extends StatefulWidget {
  final Widget child;
  
  const ConfigurationSwitcher({
    super.key,
    required this.child,
  });

  @override
  State<ConfigurationSwitcher> createState() => _ConfigurationSwitcherState();
}

class _ConfigurationSwitcherState extends State<ConfigurationSwitcher> {
  bool _showDebugPanel = false;
  
  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        
        // Debug panel toggle button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 10,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.orange.withOpacity(0.8),
            onPressed: () {
              setState(() {
                _showDebugPanel = !_showDebugPanel;
              });
            },
            child: Icon(
              _showDebugPanel ? Icons.close : Icons.settings,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        
        // Debug panel
        if (_showDebugPanel)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            right: 10,
            child: _buildDebugPanel(),
          ),
      ],
    );
  }
  
  Widget _buildDebugPanel() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bug_report, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Debug Configuration',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCurrentConfig(),
                SizedBox(height: 12),
                _buildModeSelector(),
                SizedBox(height: 12),
                _buildQuickActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCurrentConfig() {
    final config = EnvironmentConfig.getEnvironmentInfo();
    final currentUrl = EnvironmentConfig.getApiBaseUrl();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Configuration',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfigRow('Mode', EnvironmentConfig.currentMode.displayName),
              _buildConfigRow('API URL', currentUrl),
              _buildConfigRow('Platform', config['platform']),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Switch Mode',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        ...ApiConfigMode.values.map((mode) {
          final isActive = mode == EnvironmentConfig.currentMode;
          return Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isActive ? null : () => _switchMode(mode),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.orange.withOpacity(0.3) : Colors.grey[700],
                    borderRadius: BorderRadius.circular(6),
                    border: isActive ? Border.all(color: Colors.orange, width: 1) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isActive ? Colors.orange : Colors.grey[400],
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        mode.displayName,
                        style: TextStyle(
                          color: isActive ? Colors.orange : Colors.white,
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Refresh',
                Icons.refresh,
                () => _refreshConfig(),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                'Reset',
                Icons.restore,
                () => _resetConfig(),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _switchMode(ApiConfigMode mode) async {
    try {
      await ConfigurationManager.instance.switchMode(mode);
      setState(() {});
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to ${mode.displayName}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to switch mode: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  Future<void> _refreshConfig() async {
    try {
      await ConfigurationManager.instance.initialize();
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configuration refreshed'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  Future<void> _resetConfig() async {
    try {
      await ConfigurationManager.instance.resetToDefaults();
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Configuration reset to defaults'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reset: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

/// Extension to easily wrap any widget with configuration switcher
extension ConfigurationSwitcherExtension on Widget {
  Widget withConfigurationSwitcher() {
    return ConfigurationSwitcher(child: this);
  }
}