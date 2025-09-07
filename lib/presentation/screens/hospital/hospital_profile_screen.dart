import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class HospitalProfileScreen extends StatefulWidget {
  const HospitalProfileScreen({super.key});

  @override
  State<HospitalProfileScreen> createState() => _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends State<HospitalProfileScreen> {
  bool _emergencyServicesEnabled = true;
  bool _bedBookingEnabled = true;
  bool _locationServicesEnabled = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System Default';

  final List<String> _languages = [
    'English',
    'Hindi',
    'Malayalam',
    'Tamil',
    'Telugu',
  ];

  final List<String> _themes = [
    'System Default',
    'Light',
    'Dark',
    'High Contrast',
  ];

  // Mock hospital data
  final Map<String, dynamic> _hospitalData = {
    'name': 'Kochi General Hospital',
    'id': 'KGH001',
    'type': 'Multi-specialty Hospital',
    'established': '1985',
    'beds': '500',
    'departments': [
      'General Medicine',
      'ICU',
      'Emergency',
      'Pediatrics',
      'Cardiology',
      'Orthopedics',
      'Surgery',
      'Maternity',
    ],
    'address': '123 Medical College Road, Kochi, Kerala 682020',
    'phone': '+91 484 2345678',
    'email': 'info@kochigeneral.in',
    'website': 'www.kochigeneral.in',
    'license': 'KL-HOS-2024-001',
    'accreditation': 'NABH Accredited',
    'latitude': 9.9312,
    'longitude': 76.2673,
    'services': [
      'Emergency Services 24/7',
      'ICU & Critical Care',
      'Surgical Services',
      'Diagnostic Imaging',
      'Laboratory Services',
      'Pharmacy',
      'Blood Bank',
      'Ambulance Services',
    ],
    'staff': {
      'doctors': 85,
      'nurses': 180,
      'technicians': 65,
      'administrative': 45,
    },
    'ratings': {
      'overall': 4.5,
      'cleanliness': 4.3,
      'staff': 4.6,
      'facilities': 4.4,
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text(
          'Hospital Profile',
          style: AppTextStyles.headline6.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.hospitalRole,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.white),
            onPressed: () => _editHospitalProfile(),
          ),
          IconButton(
            icon: Icon(Icons.share, color: AppColors.white),
            onPressed: () => _shareHospitalProfile(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Header Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.hospitalRole, AppColors.darkGreen],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.local_hospital,
                            color: AppColors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _hospitalData['name'],
                                style: AppTextStyles.headline5.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_hospitalData['type']} • Est. ${_hospitalData['established']}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(
                                height: AppDimensions.paddingSmall,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_hospitalData['ratings']['overall']}/5',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppDimensions.paddingMedium,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _hospitalData['accreditation'],
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Beds',
                    _hospitalData['beds'],
                    Icons.bed,
                    AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'Departments',
                    _hospitalData['departments'].length.toString(),
                    Icons.domain,
                    AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Staff',
                    '${_hospitalData['staff']['doctors'] + _hospitalData['staff']['nurses'] + _hospitalData['staff']['technicians'] + _hospitalData['staff']['administrative']}',
                    Icons.people,
                    AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: _buildStatCard(
                    'Doctors',
                    _hospitalData['staff']['doctors'].toString(),
                    Icons.medical_services,
                    AppColors.hospitalRole,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Hospital Information
            _buildSectionHeader('Hospital Information'),
            _buildInfoCard([
              _buildInfoRow('Hospital ID', _hospitalData['id']),
              _buildInfoRow('License Number', _hospitalData['license']),
              _buildInfoRow('Phone', _hospitalData['phone']),
              _buildInfoRow('Email', _hospitalData['email']),
              _buildInfoRow('Website', _hospitalData['website']),
            ]),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Location & Services
            _buildSectionHeader('Location & Services'),
            _buildLocationCard(),

            const SizedBox(height: AppDimensions.paddingMedium),

            _buildServicesCard(),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Settings
            _buildSectionHeader('Settings & Preferences'),
            _buildSettingsCard(),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Staff Distribution
            _buildSectionHeader('Staff Distribution'),
            _buildStaffCard(),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Hospital Analytics
            _buildSectionHeader('Performance Ratings'),
            _buildRatingsCard(),

            const SizedBox(height: AppDimensions.paddingLarge),

            // Action Buttons
            _buildActionButtons(),

            const SizedBox(height: AppDimensions.paddingExtraLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              value,
              style: AppTextStyles.headline5.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.hospitalRole,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.hospitalRole,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                Text(
                  'Hospital Address',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Text(
              _hospitalData['address'],
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey700),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openMapLocation(),
                  icon: Icon(Icons.map, size: 16),
                  label: Text('View on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hospitalRole,
                    foregroundColor: AppColors.white,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSmall),
                OutlinedButton.icon(
                  onPressed: () => _shareLocation(),
                  icon: Icon(Icons.share_location, size: 16),
                  label: Text('Share Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.hospitalRole,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Services',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hospitalData['services'].map<Widget>((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.hospitalRole.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.hospitalRole.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    service,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.hospitalRole,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            _buildSwitchRow(
              'Emergency Services',
              'Enable 24/7 emergency services',
              _emergencyServicesEnabled,
              (value) => setState(() => _emergencyServicesEnabled = value),
              Icons.emergency,
            ),
            _buildSwitchRow(
              'Bed Booking',
              'Allow online bed booking requests',
              _bedBookingEnabled,
              (value) => setState(() => _bedBookingEnabled = value),
              Icons.bed,
            ),
            _buildSwitchRow(
              'Location Services',
              'Share location for nearby patients',
              _locationServicesEnabled,
              (value) => setState(() => _locationServicesEnabled = value),
              Icons.location_on,
            ),
            _buildSwitchRow(
              'Notifications',
              'Receive system notifications',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
              Icons.notifications,
            ),
            const Divider(),
            _buildDropdownRow(
              'Language',
              _selectedLanguage,
              _languages,
              (value) => setState(() => _selectedLanguage = value!),
              Icons.language,
            ),
            _buildDropdownRow(
              'Theme',
              _selectedTheme,
              _themes,
              (value) => setState(() => _selectedTheme = value!),
              Icons.palette,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.hospitalRole.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.hospitalRole, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey900,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.hospitalRole,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.hospitalRole.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.hospitalRole, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: options.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            underline: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            _buildStaffRow(
              'Doctors',
              _hospitalData['staff']['doctors'],
              Icons.medical_services,
              AppColors.hospitalRole,
            ),
            _buildStaffRow(
              'Nurses',
              _hospitalData['staff']['nurses'],
              Icons.healing,
              AppColors.primaryGreen,
            ),
            _buildStaffRow(
              'Technicians',
              _hospitalData['staff']['technicians'],
              Icons.engineering,
              AppColors.primaryOrange,
            ),
            _buildStaffRow(
              'Administrative',
              _hospitalData['staff']['administrative'],
              Icons.admin_panel_settings,
              AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffRow(String title, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            _buildRatingRow(
              'Overall Rating',
              _hospitalData['ratings']['overall'],
              AppColors.hospitalRole,
            ),
            _buildRatingRow(
              'Cleanliness',
              _hospitalData['ratings']['cleanliness'],
              AppColors.success,
            ),
            _buildRatingRow(
              'Staff Behavior',
              _hospitalData['ratings']['staff'],
              AppColors.primaryBlue,
            ),
            _buildRatingRow(
              'Facilities',
              _hospitalData['ratings']['facilities'],
              AppColors.primaryOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String title, double rating, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color: index < rating ? Colors.amber : AppColors.grey300,
              );
            }),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            rating.toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _viewAnalytics(),
                icon: Icon(Icons.analytics),
                label: Text('View Analytics'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hospitalRole,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _manageServices(),
                icon: Icon(Icons.settings),
                label: Text('Manage Services'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportData(),
                icon: Icon(Icons.download),
                label: Text('Export Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.hospitalRole,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _contactSupport(),
                icon: Icon(Icons.support_agent),
                label: Text('Support'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.hospitalRole,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _editHospitalProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Text(
          'Hospital profile editing functionality will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareHospitalProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hospital profile shared successfully')),
    );
  }

  void _openMapLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Open Map'),
        content: Text(
          'Opening map with hospital location:\nLat: ${_hospitalData['latitude']}\nLong: ${_hospitalData['longitude']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareLocation() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Hospital location shared')));
  }

  void _viewAnalytics() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Analytics dashboard opened')));
  }

  void _manageServices() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Services'),
        content: Text(
          'Service management functionality will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Exporting hospital data...')));
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support Contact Information:'),
            SizedBox(height: 8),
            Text('Email: support@myhealth.in'),
            Text('Phone: +91 1800 123 4567'),
            Text('Hours: 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
