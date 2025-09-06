import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class RegionalDashboardScreen extends StatefulWidget {
  const RegionalDashboardScreen({super.key});

  @override
  State<RegionalDashboardScreen> createState() =>
      _RegionalDashboardScreenState();
}

class _RegionalDashboardScreenState extends State<RegionalDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _RegionalHomeTab(),
    const _AnalyticsTab(),
    const _AlertsTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.regionalOfficerRole,
        unselectedItemColor: AppColors.grey500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _RegionalHomeTab extends StatelessWidget {
  const _RegionalHomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Regional Dashboard'),
        backgroundColor: AppColors.regionalOfficerRole,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.regionalOfficerRole,
                    Colors.orange.shade800,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, K. R. Nair',
                    style: AppTextStyles.headline5.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    'Regional Health Officer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(
                        'Ernakulam District',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Key Metrics
            Text(
              'Regional Health Metrics',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Workers',
                    value: '15,247',
                    icon: Icons.people,
                    color: AppColors.primaryBlue,
                    trend: '+2.5%',
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _MetricCard(
                    title: 'Active Cases',
                    value: '342',
                    icon: Icons.local_hospital,
                    color: AppColors.primaryOrange,
                    trend: '-1.2%',
                    isPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Critical Alerts',
                    value: '23',
                    icon: Icons.warning,
                    color: AppColors.error,
                    trend: '+5',
                    isPositive: false,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _MetricCard(
                    title: 'Hospitals',
                    value: '47',
                    icon: Icons.business,
                    color: AppColors.primaryGreen,
                    trend: 'Active',
                    isPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Disease Outbreak Alert
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dengue Outbreak Alert',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        Text(
                          '15 new cases reported in Kochi area',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Quick Actions
            Text(
              'Administrative Actions',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.marginMedium,
              mainAxisSpacing: AppDimensions.marginMedium,
              childAspectRatio: 1.2,
              children: [
                _QuickActionCard(
                  icon: Icons.map,
                  title: 'Disease Heatmap',
                  color: AppColors.error,
                  onTap: () {},
                ),
                _QuickActionCard(
                  icon: Icons.analytics,
                  title: 'Health Reports',
                  color: AppColors.primaryBlue,
                  onTap: () {},
                ),
                _QuickActionCard(
                  icon: Icons.notifications_active,
                  title: 'Send Alerts',
                  color: AppColors.primaryOrange,
                  onTap: () {},
                ),
                _QuickActionCard(
                  icon: Icons.inventory,
                  title: 'Resource Allocation',
                  color: AppColors.primaryGreen,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Recent Activities
            Text(
              'Recent System Activities',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            _ActivityCard(
              time: '2 hours ago',
              activity: 'New outbreak alert triggered',
              location: 'Kochi Industrial Area',
              type: 'Disease Alert',
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            _ActivityCard(
              time: '5 hours ago',
              activity: 'Health screening completed',
              location: 'Construction Site Zone A',
              type: 'Health Check',
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            _ActivityCard(
              time: 'Yesterday',
              activity: 'Resource allocation updated',
              location: 'Ernakulam District Hospitals',
              type: 'Admin Update',
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Analytics'),
        backgroundColor: AppColors.regionalOfficerRole,
        foregroundColor: AppColors.white,
      ),
      body: const Center(child: Text('Analytics Tab - Under Development')),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Alerts'),
        backgroundColor: AppColors.regionalOfficerRole,
        foregroundColor: AppColors.white,
      ),
      body: const Center(child: Text('Alerts Tab - Under Development')),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.regionalOfficerRole,
        foregroundColor: AppColors.white,
      ),
      body: const Center(child: Text('Profile Tab - Under Development')),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSmall,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Text(
                  value,
                  style: AppTextStyles.headline5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppDimensions.marginSmall),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String time;
  final String activity;
  final String location;
  final String type;
  final Color color;

  const _ActivityCard({
    required this.time,
    required this.activity,
    required this.location,
    required this.type,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Icon(Icons.notifications_active, color: color, size: 20),
            ),
            const SizedBox(width: AppDimensions.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        activity,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        time,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    location,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  Text(
                    type,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}
