import 'package:flutter/material.dart';
import '../widgets/role_card_widget.dart';
import '../models/user_role_model.dart';
import 'login_screen.dart';
import 'debug_connection_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DebugConnectionScreen(),
                ),
              );
            },
            tooltip: 'Debug Connection',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF81C784), // Light green
              Color(0xFF2E7D32), // Dark green
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 80.0 : 24.0,
              vertical: 32.0,
            ),
            child: Column(
              children: [
                _buildHeader(context, isTablet),
                const SizedBox(height: 40),
                Expanded(child: _buildRoleSelection(context, isTablet)),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.local_hospital,
            size: isTablet ? 80 : 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'DHRMS',
          style: TextStyle(
            fontSize: isTablet ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Digital Health Record Management System',
          style: TextStyle(
            fontSize: isTablet ? 18 : 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Select Your Role',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelection(BuildContext context, bool isTablet) {
    final List<UserRole> roles = [
      UserRole(
        title: 'Patient',
        subtitle: 'Access your health records',
        description:
            'View medical history, book appointments, and track health metrics',
        icon: Icons.person,
        color: const Color(0xFF4CAF50),
        route: '/patient',
      ),
      UserRole(
        title: 'Hospital Staff',
        subtitle: 'Healthcare professionals',
        description: 'Doctors, assistants, and admin staff portal',
        icon: Icons.medical_services,
        color: const Color(0xFF2196F3),
        route: '/hospital',
      ),
      UserRole(
        title: 'Regional Officer',
        subtitle: 'Health department official',
        description: 'Monitor health trends and manage regional healthcare',
        icon: Icons.admin_panel_settings,
        color: const Color(0xFF9C27B0),
        route: '/regional',
      ),
      UserRole(
        title: 'State Health Officer',
        subtitle: 'State health administration',
        description: 'Manage state-wide health initiatives and oversight',
        icon: Icons.account_balance,
        color: const Color(0xFFFF9800),
        route: '/sho',
      ),
      UserRole(
        title: 'WHO Admin',
        subtitle: 'World Health Organization',
        description: 'Administrative oversight and state-wide health analytics',
        icon: Icons.public,
        color: const Color(0xFFFF5722),
        route: '/who',
      ),
    ];

    return Column(
      children: [
        // New Patient Registration Button
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: isTablet ? 30.0 : 24.0),
          child: ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/patient-registration'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 20.0 : 16.0,
                horizontal: 24.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add, size: isTablet ? 28 : 24),
                SizedBox(width: 12),
                Text(
                  'New Patient Registration',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR LOGIN WITH EXISTING ACCOUNT',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
          ],
        ),

        SizedBox(height: isTablet ? 30.0 : 24.0),

        // Role Cards
        Expanded(
          child: ListView.builder(
            itemCount: roles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 16.0),
                child: RoleCardWidget(
                  role: roles[index],
                  isTablet: isTablet,
                  onTap: () => _handleRoleSelection(context, roles[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'For migrant workers in Kerala',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'SIH 2025 Project',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  void _handleRoleSelection(BuildContext context, UserRole role) {
    // Navigate to WHO login for WHO admin role
    if (role.route == '/who') {
      Navigator.pushNamed(context, '/who-login');
    } 
    // Navigate to SHO login for SHO role
    else if (role.route == '/sho') {
      Navigator.pushNamed(context, '/sho-login');
    } 
    // Navigate to hospital role selection for hospital staff
    else if (role.route == '/hospital') {
      Navigator.pushNamed(context, '/hospital-role-selection');
    }
    else {
      // Navigate directly to login screen for all other roles
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
