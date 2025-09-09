import 'package:flutter/material.dart';
import '../widgets/role_card_widget.dart';
import '../models/user_role_model.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
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
                Expanded(
                  child: _buildRoleSelection(context, isTablet),
                ),
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
        description: 'View medical history, book appointments, and track health metrics',
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
    ];

    return ListView.builder(
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
    // Navigate directly to login screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
