import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import 'doctor_patients_screen.dart';
import 'doctor_prescriptions_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorDashboardScreen({super.key, required this.doctorData});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _DoctorHomeTab(doctorData: widget.doctorData),
      DoctorPatientsScreen(doctorData: widget.doctorData),
      DoctorPrescriptionsScreen(doctorData: widget.doctorData),
      DoctorProfileScreen(doctorData: widget.doctorData),
    ];
  }

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
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Prescriptions',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DoctorHomeTab extends StatelessWidget {
  final Map<String, dynamic> doctorData;

  const _DoctorHomeTab({required this.doctorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text('Dr. ${doctorData['name']?.split(' ').last ?? 'Doctor'}'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
                    'Welcome, ${doctorData['name'] ?? 'Doctor'}',
                    style: AppTextStyles.headline5.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    '${doctorData['specialization'] ?? 'Medical Professional'}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    'Doctor ID: ${doctorData['doctorId'] ?? 'N/A'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Quick Stats
            Text(
              'Today\'s Overview',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Patients Today',
                    '12',
                    Icons.people,
                    AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _buildStatCard(
                    'Total Patients',
                    '${doctorData['patientsCount'] ?? 0}',
                    Icons.group,
                    AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Prescriptions',
                    '8',
                    Icons.receipt_long,
                    AppColors.primaryOrange,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _buildStatCard(
                    'Experience',
                    '${doctorData['experience'] ?? 'N/A'}',
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
              ],
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
                _buildActionCard(
                  'View Patients',
                  Icons.people,
                  AppColors.primaryBlue,
                  () => _navigateToPatients(context),
                ),
                _buildActionCard(
                  'New Prescription',
                  Icons.add_box,
                  AppColors.primaryGreen,
                  () => _navigateToPrescriptions(context),
                ),
                _buildActionCard(
                  'Patient History',
                  Icons.history,
                  AppColors.primaryOrange,
                  () => _navigateToPatients(context),
                ),
                _buildActionCard(
                  'Register Patient',
                  Icons.person_add,
                  AppColors.info,
                  () => _navigateToRegisterPatient(context),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginLarge),

            // Recent Activities
            Text(
              'Recent Activities',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Card(
              child: Column(
                children: [
                  _buildActivityItem(
                    'Prescribed medication for Rajesh Kumar',
                    '2 hours ago',
                    Icons.medication,
                    AppColors.primaryGreen,
                  ),
                  const Divider(),
                  _buildActivityItem(
                    'Updated medical record for Priya Nair',
                    '4 hours ago',
                    Icons.edit_note,
                    AppColors.primaryBlue,
                  ),
                  const Divider(),
                  _buildActivityItem(
                    'Registered new patient: Arun Menon',
                    '1 day ago',
                    Icons.person_add,
                    AppColors.info,
                  ),
                ],
              ),
            ),
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
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              value,
              style: AppTextStyles.headline5.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
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
                  color: color.withValues(alpha: 0.1),
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

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(time),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  void _navigateToPatients(BuildContext context) {
    // Will be implemented with proper navigation
  }

  void _navigateToPrescriptions(BuildContext context) {
    // Will be implemented with proper navigation
  }

  void _navigateToRegisterPatient(BuildContext context) {
    // Will be implemented with proper navigation
  }
}
