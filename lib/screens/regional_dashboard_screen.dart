import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';

class RegionalDashboardScreen extends StatefulWidget {
  const RegionalDashboardScreen({super.key});

  @override
  State<RegionalDashboardScreen> createState() => _RegionalDashboardScreenState();
}

class _RegionalDashboardScreenState extends State<RegionalDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regional Officer Dashboard'),
        backgroundColor: AppConstants.primaryPurple,
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
                      backgroundColor: AppConstants.lightPurple,
                      child: Icon(
                        Icons.account_balance,
                        size: 30,
                        color: AppConstants.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: AppConstants.mediumPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Regional Officer!',
                            style: TextStyle(
                              fontSize: AppConstants.titleFont,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Officer ID: RO001',
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
              'Administrative Tools',
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
                    icon: Icons.dashboard,
                    title: 'Overview',
                    subtitle: 'Regional health overview',
                    color: AppConstants.primaryPurple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Overview feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.domain,
                    title: 'Hospitals',
                    subtitle: 'Manage hospitals',
                    color: AppConstants.primaryBlue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hospitals feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.bar_chart,
                    title: 'Analytics',
                    subtitle: 'Health statistics',
                    color: AppConstants.warningOrange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Analytics feature coming soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.security,
                    title: 'Compliance',
                    subtitle: 'Regulatory oversight',
                    color: AppConstants.errorRed,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Compliance feature coming soon')),
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
