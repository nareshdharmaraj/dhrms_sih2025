import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_button.dart';
import 'digital_health_card_screen.dart';
import 'wearables_screen_simple.dart';
import '../services/wearable_service.dart';

class PatientDashboardScreen extends StatefulWidget {
  final String? uhid;
  final Map<String, dynamic>? patientData;
  
  const PatientDashboardScreen({
    super.key, 
    this.uhid,
    this.patientData,
  });

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  String get patientName => widget.patientData?['fullName'] ?? 'Patient User';
  String get patientUhid => widget.uhid ?? widget.patientData?['uhid'] ?? 'UHI000000';
  String get patientBloodGroup => widget.patientData?['bloodGroup'] ?? 'O+';
  String get patientAge => _calculateAge(widget.patientData?['dateOfBirth']);

  String _calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null) return '25';
    try {
      DateTime dob = DateTime.parse(dateOfBirth);
      DateTime now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return '25';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.teal.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 240,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade600,
                          Colors.teal.shade500,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      patientName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'UHID: $patientUhid',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _showLogoutDialog,
                                icon: Icon(Icons.logout, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ),
              
              // Dashboard Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Health Stats Cards
                      _buildHealthStatsSection(),
                      
                      SizedBox(height: 25),
                      
                      // Wearables Section
                      _buildWearablesSection(),
                      
                      SizedBox(height: 25),
                      
                      // Quick Actions
                      _buildQuickActionsSection(),
                      
                      SizedBox(height: 25),
                      
                      // Recent Activity
                      _buildRecentActivitySection(),
                      
                      SizedBox(height: 25),
                      
                      // Health Insights
                      _buildHealthInsightsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                  color: color.withValues(alpha: 0.1),
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

  Widget _buildHealthStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.bloodtype,
                title: 'Blood Type',
                value: patientBloodGroup,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.cake,
                title: 'Age',
                value: '$patientAge years',
                color: Colors.orange.shade600,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.health_and_safety,
                title: 'Status',
                value: 'Healthy',
                color: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWearablesSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.watch,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Wearable Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WearablesScreen(patientId: patientUhid),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size(0, 32),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Connected Devices Status
          FutureBuilder<Map<String, dynamic>>(
            future: WearableService.getPatientDevices(patientUhid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!['success']) {
                return Text(
                  'Unable to load devices',
                  style: TextStyle(color: Colors.red),
                );
              }
              
              final devicesList = snapshot.data!['data']['devices'] as List<dynamic>? ?? [];
              final connectedDevices = devicesList.where((d) => d['connectionStatus'] == 'connected').toList();
              
              return Column(
                children: [
                  // Device Status Summary
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: connectedDevices.isNotEmpty 
                          ? Colors.green[50] 
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: connectedDevices.isNotEmpty 
                            ? Colors.green[200]! 
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          connectedDevices.isNotEmpty 
                              ? Icons.check_circle 
                              : Icons.warning_amber,
                          color: connectedDevices.isNotEmpty 
                              ? Colors.green[600] 
                              : Colors.orange[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          connectedDevices.isNotEmpty
                              ? '${connectedDevices.length} device(s) connected'
                              : 'No devices connected',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: connectedDevices.isNotEmpty 
                                ? Colors.green[700] 
                                : Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (connectedDevices.isNotEmpty) ...[
                    SizedBox(height: 12),
                    // Latest Health Data
                    FutureBuilder<Map<String, dynamic>>(
                      future: WearableService.getLatestData(patientId: patientUhid),
                      builder: (context, dataSnapshot) {
                        if (dataSnapshot.hasData && dataSnapshot.data!['success']) {
                          final data = dataSnapshot.data!['data'];
                          return Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Latest Readings',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    if (data['heartRate'] != null)
                                      _buildMiniStat(
                                        icon: Icons.favorite,
                                        label: 'HR',
                                        value: '${data['heartRate']} bpm',
                                        color: Colors.red,
                                      ),
                                    if (data['oxygenLevel'] != null)
                                      _buildMiniStat(
                                        icon: Icons.opacity,
                                        label: 'SpO2',
                                        value: '${data['oxygenLevel']}%',
                                        color: Colors.cyan,
                                      ),
                                    if (data['steps'] != null)
                                      _buildMiniStat(
                                        icon: Icons.directions_walk,
                                        label: 'Steps',
                                        value: '${data['steps']}',
                                        color: Colors.green,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                  
                  SizedBox(height: 12),
                  
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WearablesScreen(patientId: patientUhid),
                              ),
                            );
                          },
                          icon: Icon(Icons.bluetooth_searching, size: 16),
                          label: Text(
                            'Connect Device',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WearablesScreen(patientId: patientUhid),
                              ),
                            );
                          },
                          icon: Icon(Icons.analytics, size: 16),
                          label: Text(
                            'View Analytics',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildActionCard(
              icon: Icons.health_and_safety,
              title: 'Digital Card',
              subtitle: 'View health card',
              color: Colors.blue.shade600,
              onTap: () {
                if (patientUhid != 'UHI000000') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DigitalHealthCardScreen(uhid: patientUhid),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please register first to get your digital health card')),
                  );
                }
              },
            ),
            _buildActionCard(
              icon: Icons.medical_information,
              title: 'Health Records',
              subtitle: 'View medical history',
              color: Colors.green.shade600,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Health Records feature coming soon')),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.calendar_today,
              title: 'Appointments',
              subtitle: 'Book & manage',
              color: Colors.orange.shade600,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Appointments feature coming soon')),
                );
              },
            ),
            _buildActionCard(
              icon: Icons.medication,
              title: 'Medications',
              subtitle: 'Track medicines',
              color: Colors.purple.shade600,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Medications feature coming soon')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.person_add,
                title: 'Account Created',
                subtitle: 'Welcome to DHRMS',
                time: 'Today',
                color: Colors.green.shade600,
              ),
              if (patientUhid != 'UHI000000') ...[
                Divider(height: 20),
                _buildActivityItem(
                  icon: Icons.card_membership,
                  title: 'Digital Health Card Generated',
                  subtitle: 'UHID: $patientUhid',
                  time: 'Today',
                  color: Colors.blue.shade600,
                ),
              ],
              Divider(height: 20),
              _buildActivityItem(
                icon: Icons.security,
                title: 'Profile Secured',
                subtitle: 'Your data is protected',
                time: 'Today',
                color: Colors.orange.shade600,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.tips_and_updates, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Health Tips',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                '• Drink at least 8 glasses of water daily\n'
                '• Exercise for 30 minutes daily\n'
                '• Get 7-8 hours of sleep\n'
                '• Eat balanced meals with vegetables\n'
                '• Take regular health checkups',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.teal.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
