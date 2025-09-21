import 'package:flutter/material.dart';
import '../models/sho.dart';
import '../utils/colors.dart';
import '../widgets/sho_buttons.dart';
import 'regional_health_officer_screen.dart';

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
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
      // Simulate API call for dashboard data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _dashboardData = {
          'totalRHOs': 15,
          'activeRHOs': 12,
          'totalRegions': 8,
          'totalStaff': 245,
          'pendingApprovals': 3,
          'recentActivity': [
            {'action': 'New RHO registered', 'time': '2 hours ago'},
            {'action': 'Staff limit updated', 'time': '5 hours ago'},
            {'action': 'Region coverage expanded', 'time': '1 day ago'},
          ],
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
    }
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
        return const RegionalHealthOfficerScreen();
      case 2:
        return _buildAnalyticsTab();
      case 3:
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
                  'Overseeing ${_dashboardData['totalRegions']} regions',
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
              value: '${_dashboardData['totalRHOs']}',
              icon: Icons.people,
              color: AppColors.primary,
              index: 0,
            ),
            ShoStatCard(
              title: 'Active RHOs',
              value: '${_dashboardData['activeRHOs']}',
              icon: Icons.check_circle,
              color: AppColors.success,
              index: 1,
            ),
            ShoStatCard(
              title: 'Total Staff',
              value: '${_dashboardData['totalStaff']}',
              icon: Icons.group,
              color: AppColors.info,
              index: 2,
            ),
            ShoStatCard(
              title: 'Pending Approvals',
              value: '${_dashboardData['pendingApprovals']}',
              icon: Icons.pending,
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
                  title: 'View Analytics',
                  subtitle: 'Performance metrics',
                  icon: Icons.analytics,
                  color: AppColors.info,
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
          ...(_dashboardData['recentActivity'] as List).asMap().entries.map(
            (entry) {
              final index = entry.key;
              final activity = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShoActivityCard(
                  action: activity['action'],
                  time: activity['time'],
                  index: index,
                ),
              );
            },
          ),
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
}
