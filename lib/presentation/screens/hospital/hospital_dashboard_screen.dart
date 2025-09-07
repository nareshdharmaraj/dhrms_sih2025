import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import '../../../screens/patient_registration_screen.dart';
import '../../../screens/doctor_management_screen.dart';
import 'bed_management_screen.dart';
import 'patient_management_screen.dart';
import 'hospital_profile_screen.dart';
import '../doctor/doctor_login_screen.dart';

class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  State<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HospitalHomeTab(),
    const _PatientsTab(),
    const _RecordsTab(),
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
        selectedItemColor: AppColors.hospitalRole,
        unselectedItemColor: AppColors.grey500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            label: 'Records',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HospitalHomeTab extends StatelessWidget {
  const _HospitalHomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('Hospital Dashboard'),
        backgroundColor: AppColors.hospitalRole,
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
                  colors: [AppColors.hospitalRole, AppColors.darkGreen],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Dr. Sarah Joseph',
                    style: AppTextStyles.headline5.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    'Kochi General Hospital',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  Row(
                    children: [
                      Icon(
                        Icons.local_hospital,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(
                        'General Medicine Department',
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

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Patients',
                    value: '247',
                    icon: Icons.people,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _StatCard(
                    title: 'Today\'s Visits',
                    value: '23',
                    icon: Icons.today,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Critical Cases',
                    value: '5',
                    icon: Icons.warning,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: AppDimensions.marginMedium),
                Expanded(
                  child: _StatCard(
                    title: 'Pending Records',
                    value: '12',
                    icon: Icons.pending_actions,
                    color: AppColors.warning,
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
              crossAxisCount: 3,
              crossAxisSpacing: AppDimensions.marginMedium,
              mainAxisSpacing: AppDimensions.marginMedium,
              childAspectRatio: 0.9,
              children: [
                _QuickActionCard(
                  icon: Icons.person_add,
                  title: 'Register Patient',
                  color: AppColors.primaryBlue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatientRegistrationScreen(),
                    ),
                  ),
                ),
                _QuickActionCard(
                  icon: Icons.bed,
                  title: 'Bed Management',
                  color: AppColors.hospitalRole,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BedManagementScreen(),
                    ),
                  ),
                ),
                _QuickActionCard(
                  icon: Icons.people_alt,
                  title: 'Manage Doctors',
                  color: AppColors.primaryGreen,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorManagementScreen(),
                    ),
                  ),
                ),
                _QuickActionCard(
                  icon: Icons.login,
                  title: 'Doctor Login',
                  color: AppColors.primaryBlue,
                  onTap: () => _navigateToDoctorLogin(context),
                ),
                _QuickActionCard(
                  icon: Icons.analytics,
                  title: 'Hospital Analytics',
                  color: AppColors.primaryOrange,
                  onTap: () => _showAnalytics(),
                ),
                _QuickActionCard(
                  icon: Icons.medical_services,
                  title: 'Emergency',
                  color: AppColors.error,
                  onTap: () => _showEmergencyActions(context),
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

            _ActivityCard(
              time: '10:30 AM',
              activity: 'Health checkup completed',
              patient: 'Rajesh Kumar (RAJESH2345)',
              type: 'Checkup',
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            _ActivityCard(
              time: '9:45 AM',
              activity: 'Blood test results updated',
              patient: 'Priya Sharma (PRIYA6789)',
              type: 'Lab Report',
            ),
          ],
        ),
      ),
    );
  }

  void _showAnalytics() {
    // Show hospital analytics
    // This would display comprehensive hospital statistics and reports
  }

  void _navigateToDoctorLogin(BuildContext context) {
    // Mock hospital doctors data
    final List<Map<String, dynamic>> hospitalDoctors = [
      {
        'doctorId': 'DOC001',
        'name': 'Dr. Rajesh Kumar',
        'specialization': 'Cardiology',
        'email': 'rajesh.kumar@hospital.com',
        'phone': '+91 9876543210',
        'experience': '15 years',
        'qualification': 'MD Cardiology',
        'schedule': 'Mon-Fri 9:00 AM - 5:00 PM',
        'patients': 45,
        'status': 'Active',
        'joinDate': '2020-01-15',
      },
      {
        'doctorId': 'DOC002',
        'name': 'Dr. Priya Sharma',
        'specialization': 'Pediatrics',
        'email': 'priya.sharma@hospital.com',
        'phone': '+91 9876543211',
        'experience': '10 years',
        'qualification': 'MD Pediatrics',
        'schedule': 'Mon-Sat 8:00 AM - 4:00 PM',
        'patients': 38,
        'status': 'Active',
        'joinDate': '2021-03-20',
      },
      {
        'doctorId': 'DOC003',
        'name': 'Dr. Amit Patel',
        'specialization': 'Orthopedics',
        'email': 'amit.patel@hospital.com',
        'phone': '+91 9876543212',
        'experience': '12 years',
        'qualification': 'MS Orthopedics',
        'schedule': 'Tue-Sat 10:00 AM - 6:00 PM',
        'patients': 32,
        'status': 'Active',
        'joinDate': '2020-08-10',
      },
      {
        'doctorId': 'DOC004',
        'name': 'Dr. Neha Singh',
        'specialization': 'Dermatology',
        'email': 'neha.singh@hospital.com',
        'phone': '+91 9876543213',
        'experience': '8 years',
        'qualification': 'MD Dermatology',
        'schedule': 'Mon-Fri 11:00 AM - 7:00 PM',
        'patients': 29,
        'status': 'Active',
        'joinDate': '2022-01-05',
      },
      {
        'doctorId': 'DOC005',
        'name': 'Dr. Suresh Menon',
        'specialization': 'General Medicine',
        'email': 'suresh.menon@hospital.com',
        'phone': '+91 9876543214',
        'experience': '20 years',
        'qualification': 'MBBS, MD Internal Medicine',
        'schedule': 'Mon-Sat 7:00 AM - 3:00 PM',
        'patients': 52,
        'status': 'Active',
        'joinDate': '2018-05-15',
      },
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DoctorLoginScreen(hospitalDoctors: hospitalDoctors),
      ),
    );
  }

  void _showEmergencyActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Emergency Actions',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.marginLarge),
            ListTile(
              leading: const Icon(Icons.local_hospital, color: AppColors.error),
              title: const Text('Emergency Room Status'),
              subtitle: const Text('View current ER capacity and patients'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to ER status
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.error),
              title: const Text('Emergency Contacts'),
              subtitle: const Text('Quick access to emergency numbers'),
              onTap: () {
                Navigator.pop(context);
                // Show emergency contacts
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: AppColors.warning),
              title: const Text('Hospital Alert System'),
              subtitle: const Text('Send hospital-wide alerts'),
              onTap: () {
                Navigator.pop(context);
                // Open alert system
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientsTab extends StatelessWidget {
  const _PatientsTab();

  @override
  Widget build(BuildContext context) {
    return const PatientManagementScreen();
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Records'),
        backgroundColor: AppColors.hospitalRole,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _RecordStatCard(
                    title: 'Total Records',
                    value: '2,847',
                    icon: Icons.folder,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: _RecordStatCard(
                    title: 'Today\'s Records',
                    value: '23',
                    icon: Icons.today,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Row(
              children: [
                Expanded(
                  child: _RecordStatCard(
                    title: 'Pending',
                    value: '12',
                    icon: Icons.pending,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: _RecordStatCard(
                    title: 'Digital Records',
                    value: '98%',
                    icon: Icons.cloud_done,
                    color: AppColors.hospitalRole,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingLarge),

            // Recent Records
            Text(
              'Recent Health Records',
              style: AppTextStyles.headline6.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildRecordCard(index);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(context),
        backgroundColor: AppColors.hospitalRole,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildRecordCard(int index) {
    final records = [
      {
        'id': 'HR${2024001 + index}',
        'patientName': 'John Doe',
        'patientId': 'P12345',
        'type': 'Blood Test',
        'date': '2024-01-20',
        'doctor': 'Dr. Sarah Joseph',
        'status': 'Completed',
      },
      {
        'id': 'HR${2024001 + index}',
        'patientName': 'Baby Sarah',
        'patientId': 'P67890',
        'type': 'Vaccination',
        'date': '2024-01-19',
        'doctor': 'Dr. Priya Nair',
        'status': 'Completed',
      },
      {
        'id': 'HR${2024001 + index}',
        'patientName': 'Amit Patel',
        'patientId': 'P98765',
        'type': 'ECG Report',
        'date': '2024-01-18',
        'doctor': 'Dr. Rajesh Kumar',
        'status': 'Pending',
      },
      {
        'id': 'HR${2024001 + index}',
        'patientName': 'Sunita Devi',
        'patientId': 'P54321',
        'type': 'X-Ray',
        'date': '2024-01-17',
        'doctor': 'Dr. Emergency Team',
        'status': 'In Progress',
      },
      {
        'id': 'HR${2024001 + index}',
        'patientName': 'Rajesh Kumar',
        'patientId': 'P11111',
        'type': 'CT Scan',
        'date': '2024-01-16',
        'doctor': 'Dr. Radiology',
        'status': 'Completed',
      },
    ];

    final record = records[index];
    final statusColor = record['status'] == 'Completed'
        ? AppColors.success
        : record['status'] == 'Pending'
        ? AppColors.warning
        : AppColors.info;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.hospitalRole.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_shared,
                    color: AppColors.hospitalRole,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              record['id']!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              record['status']!,
                              style: AppTextStyles.caption.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${record['patientName']} (${record['patientId']})',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  size: 16,
                  color: AppColors.grey600,
                ),
                const SizedBox(width: 4),
                Text(
                  record['type']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: AppColors.grey600),
                const SizedBox(width: 4),
                Text(
                  record['date']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppColors.grey600),
                const SizedBox(width: 4),
                Text(
                  record['doctor']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: Text('View Details')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Record'),
        content: const Text(
          'Add new health record functionality will be available in a future update.',
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
}

class _RecordStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _RecordStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
                  style: AppTextStyles.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const HospitalProfileScreen();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
                  style: AppTextStyles.headline4.copyWith(
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
  final String patient;
  final String type;

  const _ActivityCard({
    required this.time,
    required this.activity,
    required this.patient,
    required this.type,
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
                color: AppColors.hospitalRole.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: const Icon(
                Icons.medical_information,
                color: AppColors.hospitalRole,
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
                    patient,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                  Text(
                    type,
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
