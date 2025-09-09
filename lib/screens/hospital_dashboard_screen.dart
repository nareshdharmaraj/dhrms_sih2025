import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  State<HospitalDashboardScreen> createState() => _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Dashboard'),
        backgroundColor: AppConstants.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppConstants.lightBlue,
                      child: Icon(
                        Icons.local_hospital,
                        size: 30,
                        color: AppConstants.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: AppConstants.mediumPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Hospital Staff!',
                            style: TextStyle(
                              fontSize: AppConstants.titleFont,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Staff ID: HSP001',
                            style: TextStyle(
                              fontSize: AppConstants.mediumFont,
                              color: AppConstants.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: AppConstants.titleFont,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryText,
              ),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.mediumPadding,
                mainAxisSpacing: AppConstants.mediumPadding,
                children: [
                  _buildActionCard(
                    icon: Icons.people,
                    title: 'Patient Records',
                    subtitle: 'Manage patient data',
                    color: AppConstants.primaryBlue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Patient Records feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.add_box,
                    title: 'Add Record',
                    subtitle: 'Create new health record',
                    color: AppConstants.successGreen,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Record feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.analytics,
                    title: 'Reports',
                    subtitle: 'View analytics & reports',
                    color: AppConstants.warningOrange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reports feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'Hospital configuration',
                    color: AppConstants.mediumGrey,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.mediumPadding),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppConstants.mediumFont,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppConstants.smallFont,
                  color: AppConstants.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
            CustomButton(
              text: 'Logout',
              backgroundColor: AppConstants.errorRed,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
