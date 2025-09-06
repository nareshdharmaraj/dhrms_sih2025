import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _biometricEnabled = false;
  bool _emergencyAlertsEnabled = true;
  bool _healthRemindersEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System Default';

  final List<String> _languages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Bengali',
    'Marathi',
    'Gujarati',
    'Kannada',
    'Malayalam',
    'Punjabi',
  ];

  final List<String> _themes = [
    'System Default',
    'Light',
    'Dark',
    'High Contrast',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headline3.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.grey100,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildSectionHeader('Account & Privacy'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profile Settings',
            subtitle: 'Manage your personal information',
            onTap: () => _showFeatureDialog('Profile Settings'),
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'Control your data and privacy',
            onTap: () => _showFeatureDialog('Privacy & Security'),
          ),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face unlock',
            value: _biometricEnabled,
            onChanged: (value) => setState(() => _biometricEnabled = value),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSectionHeader('Notifications & Alerts'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive app notifications',
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildSwitchTile(
            icon: Icons.emergency,
            title: 'Emergency Alerts',
            subtitle: 'Critical health emergency notifications',
            value: _emergencyAlertsEnabled,
            onChanged: (value) =>
                setState(() => _emergencyAlertsEnabled = value),
          ),
          _buildSwitchTile(
            icon: Icons.schedule,
            title: 'Health Reminders',
            subtitle: 'Medication and appointment reminders',
            value: _healthRemindersEnabled,
            onChanged: (value) =>
                setState(() => _healthRemindersEnabled = value),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSectionHeader('App Preferences'),
          _buildDropdownTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            items: _languages,
            selectedItem: _selectedLanguage,
            onChanged: (value) => setState(() => _selectedLanguage = value!),
          ),
          _buildDropdownTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _selectedTheme,
            items: _themes,
            selectedItem: _selectedTheme,
            onChanged: (value) => setState(() => _selectedTheme = value!),
          ),
          _buildSwitchTile(
            icon: Icons.location_on_outlined,
            title: 'Location Services',
            subtitle: 'Enable for nearby hospitals and alerts',
            value: _locationEnabled,
            onChanged: (value) => setState(() => _locationEnabled = value),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSectionHeader('Health Data'),
          _buildSettingsTile(
            icon: Icons.cloud_sync_outlined,
            title: 'Data Sync',
            subtitle: 'Manage cloud synchronization',
            onTap: () => _showFeatureDialog('Data Sync'),
          ),
          _buildSettingsTile(
            icon: Icons.download_outlined,
            title: 'Export Health Data',
            subtitle: 'Download your health records',
            onTap: () => _showFeatureDialog('Export Health Data'),
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () => _showClearCacheDialog(),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          _buildSectionHeader('Support & Information'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => _showFeatureDialog('Help & Support'),
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About MyHealth',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(),
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Legal information',
            onTap: () => _showFeatureDialog('Terms & Conditions'),
          ),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Log out of your account',
            onTap: () => _showSignOutDialog(),
            textColor: AppColors.error,
          ),

          const SizedBox(height: AppDimensions.paddingExtraLarge),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.paddingMedium,
        top: AppDimensions.paddingSmall,
      ),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (textColor ?? AppColors.primaryBlue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: textColor ?? AppColors.primaryBlue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: textColor ?? AppColors.grey900,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.grey600),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        tileColor: AppColors.white,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryBlue,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        tileColor: AppColors.white,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> items,
    required String selectedItem,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 24),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.grey900,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        trailing: DropdownButton<String>(
          value: selectedItem,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          underline: Container(),
          icon: Icon(Icons.expand_more, color: AppColors.grey600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        tileColor: AppColors.white,
      ),
    );
  }

  void _showFeatureDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text(
          '$feature functionality will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all cached data and free up storage space. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About MyHealth'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MyHealth - Digital Health Record Management System'),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
            Text('Build: 2024.01.001'),
            SizedBox(height: 16),
            Text('Developed for Smart India Hackathon 2024'),
            Text('© 2024 MyHealth Team'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate back to role selection screen
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
