import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = false;
  bool _biometricEnabled = false;
  bool _autoSync = true;
  String _language = 'English';
  String _theme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account Settings
            _buildSectionCard(
              'Account Settings',
              Icons.person,
              Colors.blue.shade600,
              [
                _buildListTile(
                  'Edit Profile',
                  'Update your personal information',
                  Icons.edit,
                  () => _showComingSoon('Edit Profile'),
                ),
                _buildListTile(
                  'Change Password',
                  'Update your login credentials',
                  Icons.lock,
                  () => _showComingSoon('Change Password'),
                ),
                _buildListTile(
                  'Privacy Settings',
                  'Manage your privacy preferences',
                  Icons.privacy_tip,
                  () => _showComingSoon('Privacy Settings'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Notifications
            _buildSectionCard(
              'Notifications',
              Icons.notifications,
              Colors.orange.shade600,
              [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive health alerts and reminders',
                  Icons.notifications_active,
                  _notificationsEnabled,
                  (value) => setState(() => _notificationsEnabled = value),
                ),
                _buildSwitchTile(
                  'Health Reminders',
                  'Get medication and appointment reminders',
                  Icons.schedule,
                  _autoSync,
                  (value) => setState(() => _autoSync = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // App Preferences
            _buildSectionCard(
              'App Preferences',
              Icons.settings,
              Colors.green.shade600,
              [
                _buildDropdownTile(
                  'Language',
                  'Select your preferred language',
                  Icons.language,
                  _language,
                  ['English', 'Hindi', 'Malayalam', 'Tamil'],
                  (value) => setState(() => _language = value!),
                ),
                _buildDropdownTile(
                  'Theme',
                  'Choose app appearance',
                  Icons.palette,
                  _theme,
                  ['Light', 'Dark', 'System'],
                  (value) => setState(() => _theme = value!),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Security
            _buildSectionCard('Security', Icons.security, Colors.red.shade600, [
              _buildSwitchTile(
                'Biometric Login',
                'Use fingerprint or face recognition',
                Icons.fingerprint,
                _biometricEnabled,
                (value) => setState(() => _biometricEnabled = value),
              ),
              _buildSwitchTile(
                'Location Services',
                'Allow location for emergency services',
                Icons.location_on,
                _locationEnabled,
                (value) => setState(() => _locationEnabled = value),
              ),
            ]),

            const SizedBox(height: 20),

            // App Information
            _buildSectionCard(
              'App Information',
              Icons.info,
              Colors.purple.shade600,
              [
                _buildListTile(
                  'About DHRMS',
                  'Learn about the Digital Health Record System',
                  Icons.info_outline,
                  () => _showAboutDialog(),
                ),
                _buildListTile(
                  'Help & Support',
                  'Get help and contact support',
                  Icons.help_outline,
                  () => _showComingSoon('Help & Support'),
                ),
                _buildListTile(
                  'Terms & Conditions',
                  'Read terms of service',
                  Icons.description,
                  () => _showComingSoon('Terms & Conditions'),
                ),
                _buildListTile(
                  'Privacy Policy',
                  'View our privacy policy',
                  Icons.policy,
                  () => _showComingSoon('Privacy Policy'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Logout Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue.shade600;
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((String option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About DHRMS'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Health Record Management System',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Version: 1.0.0'),
              SizedBox(height: 5),
              Text(
                'A comprehensive health management system for migrant workers in Kerala.',
              ),
              SizedBox(height: 10),
              Text('Developed for the Government of Kerala'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
