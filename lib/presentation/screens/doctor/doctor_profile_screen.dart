import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfileScreen({super.key, required this.doctorData});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _qualificationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.doctorData['name'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.doctorData['phone'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.doctorData['email'] ?? '',
    );
    _qualificationController = TextEditingController(
      text: widget.doctorData['qualification'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryBlue.withValues(
                        alpha: 0.1,
                      ),
                      child: Text(
                        widget.doctorData['name']
                                ?.toString()
                                .substring(0, 2)
                                .toUpperCase() ??
                            'DR',
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    Text(
                      widget.doctorData['name']?.toString() ?? 'Doctor Name',
                      style: AppTextStyles.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.doctorData['specialization']?.toString() ??
                          'Specialization',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Active',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Professional Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Professional Information',
                      style: AppTextStyles.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    _buildProfileField(
                      'Doctor ID',
                      widget.doctorData['doctorId']?.toString() ?? 'N/A',
                      Icons.badge,
                      isEditable: false,
                    ),
                    _buildProfileField(
                      'Specialization',
                      widget.doctorData['specialization']?.toString() ?? 'N/A',
                      Icons.medical_services,
                      isEditable: false,
                    ),
                    _buildProfileField(
                      'Department',
                      widget.doctorData['department']?.toString() ?? 'N/A',
                      Icons.business,
                      isEditable: false,
                    ),
                    _buildProfileField(
                      'Experience',
                      widget.doctorData['experience']?.toString() ?? 'N/A',
                      Icons.work_history,
                      isEditable: false,
                    ),
                    _buildEditableField(
                      'Qualification',
                      _qualificationController,
                      Icons.school,
                    ),
                    _buildProfileField(
                      'Consultation Fee',
                      '₹${widget.doctorData['consultationFee']?.toString() ?? '0'}',
                      Icons.currency_rupee,
                      isEditable: false,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Contact Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: AppTextStyles.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    _buildEditableField(
                      'Full Name',
                      _nameController,
                      Icons.person,
                    ),
                    _buildEditableField(
                      'Phone Number',
                      _phoneController,
                      Icons.phone,
                    ),
                    _buildEditableField(
                      'Email Address',
                      _emailController,
                      Icons.email,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: AppTextStyles.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Total Patients',
                            widget.doctorData['patientsCount']?.toString() ??
                                '0',
                            Icons.people,
                            AppColors.primaryBlue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Join Date',
                            _formatJoinDate(widget.doctorData['joinDate']),
                            Icons.calendar_today,
                            AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Schedule Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Schedule',
                      style: AppTextStyles.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    if (widget.doctorData['schedule'] != null) ...[
                      ...((widget.doctorData['schedule']
                              as Map<String, dynamic>)
                          .entries
                          .map(
                            (entry) => _buildScheduleItem(
                              entry.key.toString(),
                              entry.value.toString(),
                            ),
                          )),
                    ] else
                      const Text('No schedule information available'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Settings Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: AppTextStyles.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: AppColors.primaryBlue,
                      ),
                      title: const Text('Notifications'),
                      subtitle: const Text(
                        'Manage your notification preferences',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.lock,
                        color: AppColors.primaryBlue,
                      ),
                      title: const Text('Change Password'),
                      subtitle: const Text('Update your account password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePasswordDialog(),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.help,
                        color: AppColors.primaryBlue,
                      ),
                      title: const Text('Help & Support'),
                      subtitle: const Text('Get help with using the app'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text('Logout'),
                      subtitle: const Text('Sign out of your account'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showLogoutDialog(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    String value,
    IconData icon, {
    bool isEditable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.grey600, size: 20),
          const SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.grey600, size: 20),
          const SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (_isEditing)
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  )
                else
                  Text(
                    controller.text.isEmpty ? 'Not specified' : controller.text,
                    style: AppTextStyles.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day.substring(0, 1).toUpperCase() + day.substring(1),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(time, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  String _formatJoinDate(dynamic joinDate) {
    if (joinDate == null) return 'N/A';
    try {
      final date = DateTime.parse(joinDate.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return joinDate.toString();
    }
  }

  void _saveProfile() {
    // Save profile changes
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to hospital dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
