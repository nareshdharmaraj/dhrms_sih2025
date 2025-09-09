import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        backgroundColor: AppConstants.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // Handle logout
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppConstants.lightGreen,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: AppConstants.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: AppConstants.mediumPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, Patient!',
                                style: TextStyle(
                                  fontSize: AppConstants.titleFont,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'UHI ID: UHI123456789',
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            
            // Quick Actions
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
                    icon: Icons.medical_information,
                    title: 'View Records',
                    subtitle: 'Access your health records',
                    color: AppConstants.primaryGreen,
                    onTap: () {
                      // Navigate to records
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Records feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.calendar_today,
                    title: 'Appointments',
                    subtitle: 'Book & manage appointments',
                    color: AppConstants.primaryBlue,
                    onTap: () {
                      // Navigate to appointments
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appointments feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.medication,
                    title: 'Medications',
                    subtitle: 'Track your medications',
                    color: AppConstants.warningOrange,
                    onTap: () {
                      // Navigate to medications
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Medications feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'Update your information',
                    color: AppConstants.primaryPurple,
                    onTap: () {
                      // Navigate to profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile feature coming soon')),
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
                Navigator.pop(context); // Close dialog
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
