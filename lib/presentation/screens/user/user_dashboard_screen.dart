import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import '../../../screens/nearby_hospitals_screen.dart';
import '../../../screens/proximity_alerts_screen.dart' as NewProximityAlerts;
import 'user_health_records_screen.dart';
import 'emergency_sos_screen.dart';
import 'telemedicine_screen.dart';
import 'vitals_monitoring_screen.dart';
import 'qr_scanner_screen.dart';
import 'ai_health_bot_screen.dart';
import 'insurance_screen.dart';
import 'gamification_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const _HealthTab(),
    const _ServicesTab(),
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
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey500,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Health'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('MyHealth Dashboard'),
        backgroundColor: AppColors.primaryBlue,
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
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.darkBlue],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Rajesh Kumar',
                    style: AppTextStyles.headline5.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    'Health ID: RAJESH2345',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(
                        'Health Status: Good',
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

            // Quick Actions
            Text(
              'Quick Actions',
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
                  icon: Icons.emergency,
                  title: 'Emergency SOS',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EmergencySosScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.local_hospital,
                  title: 'Nearby Hospitals',
                  color: AppColors.primaryBlue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NearbyHospitalsScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.warning,
                  title: 'Health Alerts',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const NewProximityAlerts.ProximityAlertsScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionCard(
                  icon: Icons.qr_code_scanner,
                  title: 'QR Scanner',
                  color: AppColors.primaryGreen,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const QrScannerScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Recent Health Records
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Health Records',
                  style: AppTextStyles.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UserHealthRecordsScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            _HealthRecordCard(
              date: 'Today, 10:30 AM',
              type: 'Checkup',
              doctor: 'Dr. Sarah Joseph',
              hospital: 'Kochi General Hospital',
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            _HealthRecordCard(
              date: 'Yesterday, 2:15 PM',
              type: 'Blood Test',
              doctor: 'Lab Technician',
              hospital: 'Health Lab Kochi',
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthTab extends StatelessWidget {
  const _HealthTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Health Overview'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Score Card
            Card(
              elevation: AppDimensions.elevationMedium,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.darkGreen],
                  ),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Health Score',
                      style: AppTextStyles.headline6.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    Text(
                      '85',
                      style: AppTextStyles.headline2.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Good Health',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Vital Signs
            Text(
              'Recent Vitals',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _VitalCard(
                    icon: Icons.favorite,
                    title: 'Heart Rate',
                    value: '72',
                    unit: 'bpm',
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _VitalCard(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    value: '98.6',
                    unit: '°F',
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _VitalCard(
                    icon: Icons.monitor_weight,
                    title: 'Blood Pressure',
                    value: '120/80',
                    unit: 'mmHg',
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _VitalCard(
                    icon: Icons.air,
                    title: 'Oxygen',
                    value: '98',
                    unit: '%',
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Health Goals
            Text(
              'Health Goals',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    _HealthGoalItem(
                      title: 'Daily Steps',
                      current: 8500,
                      target: 10000,
                      icon: Icons.directions_walk,
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    _HealthGoalItem(
                      title: 'Water Intake',
                      current: 6,
                      target: 8,
                      icon: Icons.local_drink,
                      unit: 'glasses',
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    _HealthGoalItem(
                      title: 'Sleep Hours',
                      current: 7,
                      target: 8,
                      icon: Icons.bedtime,
                      unit: 'hours',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Health Services'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Services
            Text(
              'Emergency Services',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _ServiceCard(
                    icon: Icons.emergency,
                    title: 'Emergency SOS',
                    subtitle: 'Quick emergency help',
                    color: AppColors.error,
                    onTap: () => _navigateToService(context, 'emergency_sos'),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _ServiceCard(
                    icon: Icons.local_hospital,
                    title: 'Find Hospital',
                    subtitle: 'Nearest hospitals',
                    color: AppColors.primaryBlue,
                    onTap: () => _navigateToService(context, 'find_hospital'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Medical Services
            Text(
              'Medical Services',
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
              childAspectRatio: 1.1,
              children: [
                _ServiceCard(
                  icon: Icons.video_call,
                  title: 'Telemedicine',
                  subtitle: 'Online consultation',
                  color: AppColors.primaryGreen,
                  onTap: () => _navigateToService(context, 'telemedicine'),
                ),
                _ServiceCard(
                  icon: Icons.monitor_heart,
                  title: 'Vitals Monitor',
                  subtitle: 'Track health vitals',
                  color: AppColors.primaryOrange,
                  onTap: () => _navigateToService(context, 'vitals'),
                ),
                _ServiceCard(
                  icon: Icons.qr_code_scanner,
                  title: 'QR Scanner',
                  subtitle: 'Scan health codes',
                  color: AppColors.primaryGreen,
                  onTap: () => _navigateToService(context, 'qr_scanner'),
                ),
                _ServiceCard(
                  icon: Icons.smart_toy,
                  title: 'AI Health Bot',
                  subtitle: 'Health assistant',
                  color: AppColors.primaryBlue,
                  onTap: () => _navigateToService(context, 'ai_bot'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Additional Services
            Text(
              'Additional Services',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            _ServiceListTile(
              icon: Icons.security,
              title: 'Insurance Services',
              subtitle: 'Manage health insurance',
              color: AppColors.success,
              onTap: () => _navigateToService(context, 'insurance'),
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            _ServiceListTile(
              icon: Icons.radar,
              title: 'Proximity Alerts',
              subtitle: 'Disease outbreak alerts',
              color: AppColors.warning,
              onTap: () => _navigateToService(context, 'proximity_alerts'),
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            _ServiceListTile(
              icon: Icons.gamepad,
              title: 'Health Gamification',
              subtitle: 'Earn rewards for healthy habits',
              color: AppColors.primaryGreen,
              onTap: () => _navigateToService(context, 'gamification'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToService(BuildContext context, String service) {
    switch (service) {
      case 'emergency_sos':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmergencySosScreen()),
        );
        break;
      case 'telemedicine':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TelemedicineScreen()),
        );
        break;
      case 'vitals':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VitalsMonitoringScreen(),
          ),
        );
        break;
      case 'qr_scanner':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QrScannerScreen()),
        );
        break;
      case 'ai_bot':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIHealthBotScreen()),
        );
        break;
      case 'insurance':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InsuranceScreen()),
        );
        break;
      case 'proximity_alerts':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const NewProximityAlerts.ProximityAlertsScreen(),
          ),
        );
        break;
      case 'gamification':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GamificationScreen()),
        );
        break;
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 'find_hospital':
        // Navigate to hospital finder
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NearbyHospitalsScreen(),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$service service coming soon')));
    }
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    Text(
                      'Rajesh Kumar',
                      style: AppTextStyles.headline5.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Health ID: RAJESH2345',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMedium,
                        vertical: AppDimensions.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                      ),
                      child: Text(
                        'Verified Account',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Profile Information
            _ProfileSection(
              title: 'Personal Information',
              items: [
                _ProfileItem('Age', '32 years'),
                _ProfileItem('Gender', 'Male'),
                _ProfileItem('Blood Group', 'B+'),
                _ProfileItem('Phone', '+91 9876543210'),
                _ProfileItem('Email', 'rajesh.kumar@email.com'),
                _ProfileItem('Address', 'Kochi, Kerala, India'),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // Emergency Contacts
            _ProfileSection(
              title: 'Emergency Contacts',
              items: [
                _ProfileItem(
                  'Primary Contact',
                  'Priya Kumar (Wife)\n+91 9876543211',
                ),
                _ProfileItem(
                  'Secondary Contact',
                  'Dr. Sarah Joseph\n+91 9876543212',
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // Medical Information
            _ProfileSection(
              title: 'Medical Information',
              items: [
                _ProfileItem('Allergies', 'Penicillin, Peanuts'),
                _ProfileItem('Chronic Conditions', 'Hypertension'),
                _ProfileItem('Current Medications', 'Lisinopril 10mg daily'),
                _ProfileItem('Last Checkup', '2 days ago'),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text('Download Health Summary'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                    ),
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

class _HealthRecordCard extends StatelessWidget {
  final String date;
  final String type;
  final String doctor;
  final String hospital;

  const _HealthRecordCard({
    required this.date,
    required this.type,
    required this.doctor,
    required this.hospital,
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
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: const Icon(
                Icons.medical_information,
                color: AppColors.primaryBlue,
                size: 20,
              ),
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
                        type,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        date,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    doctor,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  Text(
                    hospital,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
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

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final Color color;

  const _VitalCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
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
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTextStyles.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthGoalItem extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final IconData icon;
  final String unit;

  const _HealthGoalItem({
    required this.title,
    required this.current,
    required this.target,
    required this.icon,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / target;
    final unitText = unit.isNotEmpty ? ' $unit' : '';

    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue),
        const SizedBox(width: AppDimensions.marginMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$current/$target$unitText',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.marginSmall),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppColors.success : AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ServiceListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
        onTap: onTap,
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            ...items,
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
