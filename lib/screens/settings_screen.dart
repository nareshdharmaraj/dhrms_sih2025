import 'package:flutter/material.dart';
import '../services/patient_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PatientSettingsService _settingsService = PatientSettingsService();

  // State variables
  bool _notificationsEnabled = true;
  bool _locationEnabled = false;
  bool _biometricEnabled = false;
  bool _healthRemindersEnabled = true;
  bool _emergencyAlertsEnabled = true;

  String _language = 'English';
  String _theme = 'System';

  // Patient ID - In real app, get from authentication service
  final String _patientId = 'PATIENT_001';

  bool _isLoading = true;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      // Initialize the settings service
      await _settingsService.initialize();

      // Load all settings
      await Future.wait([
        _loadNotificationSettings(),
        _loadAppPreferences(),
        _checkBiometricAvailability(),
        _checkLocationPermission(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load settings');
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final settings = await _settingsService.getNotificationSettings(
        _patientId,
      );
      setState(() {
        _notificationsEnabled = settings['pushNotifications'] ?? true;
        _healthRemindersEnabled = settings['medicationReminders'] ?? true;
        _emergencyAlertsEnabled = settings['emergencyAlerts'] ?? true;
      });
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  Future<void> _loadAppPreferences() async {
    try {
      final prefs = await _settingsService.getAppPreferences();
      setState(() {
        _language = prefs['language'] ?? 'English';
        _theme = prefs['theme'] ?? 'System';
      });
    } catch (e) {
      print('Error loading app preferences: $e');
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final available = await _settingsService.isBiometricAvailable();
      final enabled = await _settingsService.isBiometricEnabled();
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
      });
    } catch (e) {
      print('Error checking biometric availability: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      final enabled = await _settingsService.isLocationEnabled();
      setState(() {
        _locationEnabled = enabled;
      });
    } catch (e) {
      print('Error checking location permission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                  () => _showEditProfileDialog(),
                ),
                _buildListTile(
                  'Change Password',
                  'Update your login credentials',
                  Icons.lock,
                  () => _showChangePasswordDialog(),
                ),
                _buildListTile(
                  'Privacy Settings',
                  'Manage your privacy preferences',
                  Icons.privacy_tip,
                  () => _showPrivacySettingsDialog(),
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
                  (value) =>
                      _updateNotificationSetting('pushNotifications', value),
                ),
                _buildSwitchTile(
                  'Health Reminders',
                  'Get medication and appointment reminders',
                  Icons.schedule,
                  _healthRemindersEnabled,
                  (value) =>
                      _updateNotificationSetting('medicationReminders', value),
                ),
                _buildSwitchTile(
                  'Emergency Alerts',
                  'Critical health and safety notifications',
                  Icons.emergency,
                  _emergencyAlertsEnabled,
                  (value) =>
                      _updateNotificationSetting('emergencyAlerts', value),
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
                  _settingsService
                      .getSupportedLanguages()
                      .map((lang) => lang['name']!)
                      .toList(),
                  (value) => _updateLanguage(value!),
                ),
                _buildDropdownTile(
                  'Theme',
                  'Choose app appearance',
                  Icons.palette,
                  _theme,
                  ['Light', 'Dark', 'System'],
                  (value) => _updateTheme(value!),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Security
            _buildSectionCard('Security', Icons.security, Colors.red.shade600, [
              _buildSwitchTile(
                'Biometric Login',
                _biometricAvailable
                    ? 'Use fingerprint or face recognition'
                    : 'Biometric sensor not available',
                Icons.fingerprint,
                _biometricEnabled,
                _biometricAvailable ? (value) => _toggleBiometric(value) : null,
              ),
              _buildSwitchTile(
                'Location Services',
                'Allow location for emergency services',
                Icons.location_on,
                _locationEnabled,
                (value) => _toggleLocation(value),
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
                  'App Information',
                  'Version, build info, and system details',
                  Icons.phone_android,
                  () => _showAppInfoDialog(),
                ),
                _buildListTile(
                  'Help & Support',
                  'Get help and contact support',
                  Icons.help_outline,
                  () => _showHelpSupportDialog(),
                ),
                _buildListTile(
                  'Terms & Conditions',
                  'Read terms of service',
                  Icons.description,
                  () => _showTermsDialog(),
                ),
                _buildListTile(
                  'Privacy Policy',
                  'View our privacy policy',
                  Icons.policy,
                  () => _showPrivacyPolicyDialog(),
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
    ValueChanged<bool>? onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        thumbColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blue.shade600;
          }
          return null;
        }),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade600),
    );
  }

  // ==================== PROFILE MANAGEMENT ====================

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    // Load current profile data
    _settingsService.getPatientProfile(_patientId).then((profile) {
      if (profile != null) {
        nameController.text = profile['fullName'] ?? '';
        emailController.text = profile['email'] ?? '';
        phoneController.text = profile['phone'] ?? '';
        addressController.text = profile['address'] ?? '';
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _updateProfile(
                nameController.text,
                emailController.text,
                phoneController.text,
                addressController.text,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile(
    String name,
    String email,
    String phone,
    String address,
  ) async {
    try {
      final profileData = {
        'fullName': name,
        'email': email,
        'phone': phone,
        'address': address,
      };

      final success = await _settingsService.updatePatientProfile(
        _patientId,
        profileData,
      );
      Navigator.pop(context);

      if (success) {
        _showSuccessSnackBar('Profile updated successfully!');
      } else {
        _showErrorSnackBar('Failed to update profile');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Error updating profile: $e');
    }
  }

  // ==================== PASSWORD MANAGEMENT ====================

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    helperText:
                        'Min 8 chars, uppercase, lowercase, number, special char',
                  ),
                  obscureText: true,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _changePassword(
                currentPasswordController.text,
                newPasswordController.text,
                confirmPasswordController.text,
              ),
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword != confirmPassword) {
      Navigator.pop(context);
      _showErrorSnackBar('New passwords do not match');
      return;
    }

    if (newPassword.length < 8) {
      Navigator.pop(context);
      _showErrorSnackBar('Password must be at least 8 characters long');
      return;
    }

    try {
      final success = await _settingsService.changePassword(
        _patientId,
        currentPassword,
        newPassword,
      );
      Navigator.pop(context);

      if (success) {
        _showSuccessSnackBar('Password changed successfully!');
      } else {
        _showErrorSnackBar(
          'Failed to change password. Check your current password.',
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Error changing password: $e');
    }
  }

  // ==================== PRIVACY SETTINGS ====================

  void _showPrivacySettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Privacy Settings'),
              content: FutureBuilder<Map<String, bool>>(
                future: _settingsService.getPrivacySettings(_patientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final settings = snapshot.data ?? {};

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SwitchListTile(
                          title: const Text('Share with Doctors'),
                          subtitle: const Text(
                            'Allow doctors to access your health data',
                          ),
                          value: settings['shareDataWithDoctors'] ?? true,
                          onChanged: (value) => setState(
                            () => settings['shareDataWithDoctors'] = value,
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Research Participation'),
                          subtitle: const Text(
                            'Share anonymized data for research',
                          ),
                          value: settings['shareDataWithResearchers'] ?? false,
                          onChanged: (value) => setState(
                            () => settings['shareDataWithResearchers'] = value,
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Location Data'),
                          subtitle: const Text(
                            'Share location for emergency services',
                          ),
                          value: settings['shareLocationData'] ?? false,
                          onChanged: (value) => setState(
                            () => settings['shareLocationData'] = value,
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Health Metrics'),
                          subtitle: const Text(
                            'Share vital signs and health metrics',
                          ),
                          value: settings['shareHealthMetrics'] ?? true,
                          onChanged: (value) => setState(
                            () => settings['shareHealthMetrics'] = value,
                          ),
                        ),
                        SwitchListTile(
                          title: const Text('Emergency Access'),
                          subtitle: const Text(
                            'Allow emergency access to critical data',
                          ),
                          value: settings['allowEmergencyAccess'] ?? true,
                          onChanged: (value) => setState(
                            () => settings['allowEmergencyAccess'] = value,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _updatePrivacySettings(),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updatePrivacySettings() async {
    try {
      // Get current settings from the dialog
      final settings = await _settingsService.getPrivacySettings(_patientId);
      final success = await _settingsService.updatePrivacySettings(
        _patientId,
        settings,
      );

      Navigator.pop(context);

      if (success) {
        _showSuccessSnackBar('Privacy settings updated successfully!');
      } else {
        _showErrorSnackBar('Failed to update privacy settings');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Error updating privacy settings: $e');
    }
  }

  // ==================== NOTIFICATION SETTINGS ====================

  Future<void> _updateNotificationSetting(String settingKey, bool value) async {
    try {
      final settings = await _settingsService.getNotificationSettings(
        _patientId,
      );
      settings[settingKey] = value;

      final success = await _settingsService.updateNotificationSettings(
        _patientId,
        settings,
      );

      if (success) {
        setState(() {
          switch (settingKey) {
            case 'pushNotifications':
              _notificationsEnabled = value;
              break;
            case 'medicationReminders':
              _healthRemindersEnabled = value;
              break;
            case 'emergencyAlerts':
              _emergencyAlertsEnabled = value;
              break;
          }
        });
        _showSuccessSnackBar('Notification settings updated!');
      } else {
        _showErrorSnackBar('Failed to update notification settings');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating notification settings: $e');
    }
  }

  // ==================== LANGUAGE & THEME ====================

  Future<void> _updateLanguage(String language) async {
    try {
      final success = await _settingsService.updateLanguage(language);

      if (success) {
        setState(() {
          _language = language;
        });
        _showSuccessSnackBar('Language updated! Restart app to apply changes.');
      } else {
        _showErrorSnackBar('Failed to update language');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating language: $e');
    }
  }

  Future<void> _updateTheme(String theme) async {
    try {
      final success = await _settingsService.updateTheme(theme);

      if (success) {
        setState(() {
          _theme = theme;
        });
        _showSuccessSnackBar('Theme updated!');
      } else {
        _showErrorSnackBar('Failed to update theme');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating theme: $e');
    }
  }

  // ==================== BIOMETRIC AUTHENTICATION ====================

  Future<void> _toggleBiometric(bool value) async {
    try {
      bool success;

      if (value) {
        success = await _settingsService.enableBiometricAuth(_patientId);
        if (success) {
          _showSuccessSnackBar('Biometric authentication enabled!');
        } else {
          _showErrorSnackBar('Failed to enable biometric authentication');
        }
      } else {
        success = await _settingsService.disableBiometricAuth(_patientId);
        if (success) {
          _showSuccessSnackBar('Biometric authentication disabled!');
        } else {
          _showErrorSnackBar('Failed to disable biometric authentication');
        }
      }

      if (success) {
        setState(() {
          _biometricEnabled = value;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error updating biometric settings: $e');
    }
  }

  // ==================== LOCATION SERVICES ====================

  Future<void> _toggleLocation(bool value) async {
    try {
      bool success;

      if (value) {
        success = await _settingsService.enableLocationServices(_patientId);
        if (success) {
          _showSuccessSnackBar('Location services enabled!');
        } else {
          _showErrorSnackBar(
            'Failed to enable location services. Please check app permissions.',
          );
        }
      } else {
        success = await _settingsService.disableLocationServices(_patientId);
        if (success) {
          _showSuccessSnackBar('Location services disabled!');
        } else {
          _showErrorSnackBar('Failed to disable location services');
        }
      }

      if (success) {
        setState(() {
          _locationEnabled = value;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error updating location settings: $e');
    }
  }

  // ==================== APP INFORMATION ====================

  void _showAppInfoDialog() async {
    final appInfo = await _settingsService.getAppInfo();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('App Name', appInfo['appName'] ?? 'DHRMS'),
                _buildInfoRow('Version', appInfo['version'] ?? '1.0.0'),
                _buildInfoRow('Build Number', appInfo['buildNumber'] ?? '1'),
                _buildInfoRow('Platform', appInfo['platform'] ?? 'Unknown'),
                _buildInfoRow('OS Version', appInfo['osVersion'] ?? 'Unknown'),
                _buildInfoRow(
                  'Device Model',
                  appInfo['deviceModel'] ?? 'Unknown',
                ),
                _buildInfoRow(
                  'Manufacturer',
                  appInfo['manufacturer'] ?? 'Unknown',
                ),
                const SizedBox(height: 16),
                const Text(
                  'System Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Package: ${appInfo['packageName'] ?? 'com.example.dhrms'}',
                ),
              ],
            ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ==================== HELP & SUPPORT ====================

  void _showHelpSupportDialog() {
    final supportInfo = _settingsService.getSupportInfo();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Contact Support',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildSupportItem(
                  'Team',
                  supportInfo['teamName']!,
                  Icons.group,
                  null,
                ),
                _buildSupportItem(
                  'Contact Person',
                  supportInfo['contactPerson']!,
                  Icons.person,
                  null,
                ),
                _buildSupportItem(
                  'Phone',
                  supportInfo['phone']!,
                  Icons.phone,
                  () => _settingsService.makeCall(supportInfo['phone']!),
                ),
                _buildSupportItem(
                  'Email',
                  supportInfo['email']!,
                  Icons.email,
                  () =>
                      _settingsService.sendSupportEmail(supportInfo['email']!),
                ),
                _buildSupportItem(
                  'Location',
                  supportInfo['location']!,
                  Icons.location_on,
                  null,
                ),
                _buildSupportItem(
                  'Support Hours',
                  supportInfo['supportHours']!,
                  Icons.schedule,
                  null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupportItem(
    String label,
    String value,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: onTap != null
                          ? Colors.blue.shade600
                          : Colors.black87,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.launch, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  // ==================== LEGAL DOCUMENTS ====================

  void _showTermsDialog() {
    _showScrollableTextDialog(
      'Terms & Conditions',
      _settingsService.getTermsAndConditions(),
    );
  }

  void _showPrivacyPolicyDialog() {
    _showScrollableTextDialog(
      'Privacy Policy',
      _settingsService.getPrivacyPolicy(),
    );
  }

  void _showScrollableTextDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              child: Text(content, style: const TextStyle(fontSize: 12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
