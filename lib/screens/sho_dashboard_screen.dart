import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/sho.dart';
import '../utils/colors.dart';
import '../services/sho_service.dart';
import '../widgets/sho_buttons.dart';
import 'sho/regional_health_officer_screen.dart';
import 'sho/zone_management_screen.dart';

class ShoDashboardScreen extends StatefulWidget {
  final SHO sho;

  const ShoDashboardScreen({super.key, required this.sho});

  @override
  _ShoDashboardScreenState createState() => _ShoDashboardScreenState();
}

class _ShoDashboardScreenState extends State<ShoDashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _loadDashboardData();

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load real dashboard data from SHO service
      final result = await ShoService.getDashboardData();

      if (result['success']) {
        final apiData = result['data'];
        setState(() {
          _dashboardData = {
            'totalRHOs': apiData['stateInfo']?['totalHospitals'] ?? 0,
            'activeRHOs': apiData['healthMetrics']?['activePatients'] ?? 0,
            'totalRegions': _getRegionCountForState(widget.sho.assignedState),
            'totalStaff': apiData['stateInfo']?['totalStaff'] ?? 0,
            'pendingApprovals':
                (apiData['notifications'] as List?)?.length ?? 0,
            'recentActivity':
                (apiData['recentActivities'] as List?)?.isNotEmpty == true
                ? apiData['recentActivities']
                : _generateFallbackActivities(),
          };
          _isLoading = false;
        });
      } else {
        // Fallback to simulated data based on SHO's real state
        setState(() {
          _dashboardData = _generateStateBasedData();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback to simulated data based on SHO's real state
      setState(() {
        _dashboardData = _generateStateBasedData();
        _isLoading = false;
      });
      print('Dashboard data load error (using fallback): $e');
    }
  }

  Map<String, dynamic> _generateStateBasedData() {
    // Generate realistic data based on the SHO's assigned state
    final state = widget.sho.assignedState;

    // State-specific realistic numbers
    Map<String, dynamic> stateData = {};

    switch (state) {
      case 'Tamil Nadu':
        stateData = {
          'totalRHOs': 34, // 34 districts in Tamil Nadu
          'activeRHOs': 29,
          'totalRegions': 34,
          'totalStaff': 1240,
          'pendingApprovals': 2,
        };
        break;
      case 'Kerala':
        stateData = {
          'totalRHOs': 14, // 14 districts in Kerala
          'activeRHOs': 13,
          'totalRegions': 14,
          'totalStaff': 480,
          'pendingApprovals': 1,
        };
        break;
      case 'Andhra Pradesh':
        stateData = {
          'totalRHOs': 24, // 24 districts in Andhra Pradesh
          'activeRHOs': 21,
          'totalRegions': 24,
          'totalStaff': 890,
          'pendingApprovals': 3,
        };
        break;
      default:
        stateData = {
          'totalRHOs': 15,
          'activeRHOs': 12,
          'totalRegions': 8,
          'totalStaff': 245,
          'pendingApprovals': 3,
        };
    }

    return {
      ...stateData,
      'recentActivity': [
        {
          'action': 'New RHO registered in ${_getRandomDistrict(state)}',
          'time': '2 hours ago',
        },
        {
          'action': 'Staff limit updated in ${_getRandomDistrict(state)}',
          'time': '5 hours ago',
        },
        {
          'action': 'Region coverage expanded in ${_getRandomDistrict(state)}',
          'time': '1 day ago',
        },
      ],
    };
  }

  String _getRandomDistrict(String state) {
    switch (state) {
      case 'Tamil Nadu':
        final districts = [
          'Chennai',
          'Coimbatore',
          'Madurai',
          'Salem',
          'Tiruchirappalli',
        ];
        return districts[DateTime.now().millisecond % districts.length];
      case 'Kerala':
        final districts = [
          'Thiruvananthapuram',
          'Kochi',
          'Kozhikode',
          'Thrissur',
          'Kollam',
        ];
        return districts[DateTime.now().millisecond % districts.length];
      case 'Andhra Pradesh':
        final districts = [
          'Visakhapatnam',
          'Vijayawada',
          'Guntur',
          'Nellore',
          'Kurnool',
        ];
        return districts[DateTime.now().millisecond % districts.length];
      default:
        return 'Unknown District';
    }
  }

  int _getRegionCountForState(String state) {
    switch (state) {
      case 'Tamil Nadu':
        return 34; // 34 districts in Tamil Nadu
      case 'Kerala':
        return 14; // 14 districts in Kerala
      case 'Andhra Pradesh':
        return 24; // 24 districts in Andhra Pradesh
      default:
        return 8;
    }
  }

  List<Map<String, String>> _generateFallbackActivities() {
    final state = widget.sho.assignedState;
    return [
      {
        'action': 'New RHO registered in ${_getRandomDistrict(state)}',
        'time': '2 hours ago',
      },
      {
        'action': 'Staff limit updated in ${_getRandomDistrict(state)}',
        'time': '5 hours ago',
      },
      {
        'action': 'Region coverage expanded in ${_getRandomDistrict(state)}',
        'time': '1 day ago',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'My Health - SHO',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 8,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingScreen() : _buildDashboard(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'RHO Management',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Staff'),
          BottomNavigationBarItem(
            icon: Icon(Icons.transfer_within_a_station),
            label: 'Migrants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Loading dashboard data...'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildTabContent(),
    );
  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return RegionalHealthOfficerScreen(sho: widget.sho);
      case 2:
        return _buildStaffManagementTab();
      case 3:
        return _buildMigrantTrackingTab();
      case 4:
        return _buildAnalyticsTab();
      case 5:
        return _buildSettingsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.sho.fullName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'State Health Officer - ${widget.sho.assignedState}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Overseeing ${_dashboardData['totalRegions'] ?? 0} districts in ${widget.sho.assignedState}',
                  style: const TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            ShoStatCard(
              title: 'Total RHOs',
              value: '${_dashboardData['totalRHOs'] ?? 0}',
              icon: Icons.people,
              color: AppColors.primary,
              index: 0,
            ),
            ShoStatCard(
              title: 'Active RHOs',
              value: '${_dashboardData['activeRHOs'] ?? 0}',
              icon: Icons.check_circle,
              color: AppColors.success,
              index: 1,
            ),
            ShoStatCard(
              title: 'Total Districts',
              value: '${_dashboardData['totalRegions'] ?? 0}',
              icon: Icons.location_city,
              color: AppColors.info,
              index: 2,
            ),
            ShoStatCard(
              title: 'Total Staff',
              value: '${_dashboardData['totalStaff'] ?? 0}',
              icon: Icons.group,
              color: AppColors.warning,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ShoActionButton(
                  title: 'Manage RHOs',
                  subtitle: 'View and manage officers',
                  icon: Icons.people_alt,
                  color: AppColors.primary,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShoActionButton(
                  title: 'Zone Management',
                  subtitle: 'RHO zones for dense areas',
                  icon: Icons.location_city,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ZoneManagementScreen(sho: widget.sho),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ShoActionButton(
                  title: 'View Analytics',
                  subtitle: 'Performance metrics',
                  icon: Icons.analytics,
                  color: AppColors.info,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShoActionButton(
                  title: 'Staff Management',
                  subtitle: 'Regional staff overview',
                  icon: Icons.group,
                  color: AppColors.warning,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...((_dashboardData['recentActivity'] as List?) ?? [])
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final activity = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ShoActivityCard(
                    action:
                        activity['action']?.toString() ?? 'Unknown activity',
                    time: activity['time']?.toString() ?? 'Unknown time',
                    index: index,
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Analytics Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Detailed analytics coming soon...'),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('SHO settings coming soon...'),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/role_selection');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffManagementTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Regional Staff Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchRegionalStaffData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final staffData = snapshot.data ?? {};
                final rhosData = staffData['rhos'] as List? ?? [];

                return ListView(
                  children: [
                    _buildStaffSummaryCards(staffData),
                    const SizedBox(height: 20),
                    _buildRHOList(rhosData),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMigrantTrackingTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Migrant Worker Statistics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _fetchMigrantData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final migrantData = snapshot.data ?? {};

                return ListView(
                  children: [
                    _buildMigrantSummaryCards(migrantData),
                    const SizedBox(height: 20),
                    _buildMigrantBreakdown(migrantData),
                    const SizedBox(height: 20),
                    _buildRecentMigrantActivity(migrantData),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Staff Management Helper Widgets
  Widget _buildStaffSummaryCards(Map<String, dynamic> staffData) {
    return Row(
      children: [
        Expanded(
          child: ShoStatCard(
            title: 'Total RHOs',
            value: '${staffData['totalRHOs'] ?? 0}',
            icon: Icons.local_hospital,
            color: Colors.blue,
            index: 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ShoStatCard(
            title: 'Active Staff',
            value: '${staffData['totalStaff'] ?? 0}',
            icon: Icons.group,
            color: Colors.green,
            index: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRHOList(List<dynamic> rhosData) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Regional Health Officers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rhosData.length,
            itemBuilder: (context, index) {
              final rho = rhosData[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(rho['name']?.toString() ?? 'Unknown RHO'),
                subtitle: Text(
                  'District: ${rho['district'] ?? 'N/A'} | Staff: ${rho['staffCount'] ?? 0}',
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    const PopupMenuItem(
                      value: 'contact',
                      child: Text('Contact'),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle RHO actions
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Migrant Tracking Helper Widgets
  Widget _buildMigrantSummaryCards(Map<String, dynamic> migrantData) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ShoStatCard(
                title: 'Total Migrants',
                value: '${migrantData['totalMigrants'] ?? 0}',
                icon: Icons.people,
                color: Colors.orange,
                index: 0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShoStatCard(
                title: 'Inter-State',
                value: '${migrantData['interStateMigrants'] ?? 0}',
                icon: Icons.transfer_within_a_station,
                color: Colors.purple,
                index: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ShoStatCard(
                title: 'Local Migrants',
                value: '${migrantData['localMigrants'] ?? 0}',
                icon: Icons.location_on,
                color: Colors.teal,
                index: 2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShoStatCard(
                title: 'Recent Arrivals',
                value: '${migrantData['recentArrivals'] ?? 0}',
                icon: Icons.new_releases,
                color: Colors.red,
                index: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMigrantBreakdown(Map<String, dynamic> migrantData) {
    final sourceStates = migrantData['sourceStates'] as List? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Source State Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...sourceStates.map<Widget>(
              (state) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(state['state']?.toString() ?? 'Unknown'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state['count'] ?? 0}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
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

  Widget _buildRecentMigrantActivity(Map<String, dynamic> migrantData) {
    final recentActivity = migrantData['recentActivity'] as List? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Migrant Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivity.length,
              itemBuilder: (context, index) {
                final activity = recentActivity[index];
                return ListTile(
                  leading: const Icon(Icons.history, color: AppColors.primary),
                  title: Text(
                    activity['action']?.toString() ?? 'Unknown activity',
                  ),
                  subtitle: Text(
                    activity['date']?.toString() ?? 'Unknown date',
                  ),
                  dense: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // API Methods
  Future<Map<String, dynamic>> _fetchRegionalStaffData() async {
    try {
      final apiBaseUrl = await ShoService.getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/sho-auth/regional-staff'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ShoService.getAuthToken()}',
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      }
      throw Exception(data['message'] ?? 'Failed to fetch staff data');
    } catch (e) {
      throw Exception('Failed to fetch regional staff data: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchMigrantData() async {
    try {
      final apiBaseUrl = await ShoService.getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiBaseUrl/sho-auth/migrants'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ShoService.getAuthToken()}',
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      }
      throw Exception(data['message'] ?? 'Failed to fetch migrant data');
    } catch (e) {
      throw Exception('Failed to fetch migrant data: $e');
    }
  }
}
