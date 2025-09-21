import 'package:flutter/material.dart';
import '../widgets/role_card_widget.dart';
import '../models/user_role_model.dart';
import 'login_screen.dart';

class HospitalRoleSelectionScreen extends StatelessWidget {
  const HospitalRoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Hospital Roles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF64B5F6), // Light blue
              Color(0xFF2196F3), // Blue
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
                Expanded(child: _buildHospitalRoleSelection(context, isTablet)),
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
            Icons.medical_services,
            size: isTablet ? 80 : 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Hospital Staff',
          style: TextStyle(
            fontSize: isTablet ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your hospital role',
          style: TextStyle(
            fontSize: isTablet ? 18 : 14,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHospitalRoleSelection(BuildContext context, bool isTablet) {
    final List<UserRole> hospitalRoles = [
      UserRole(
        title: 'Hospital Admin',
        subtitle: 'Administrative management',
        description: 'Manage hospital operations, staff, and resources',
        icon: Icons.admin_panel_settings,
        color: const Color(0xFF4CAF50),
        route: '/hospital-admin',
      ),
      UserRole(
        title: 'Doctor',
        subtitle: 'Medical professional',
        description: 'Access patient records, manage appointments and treatments',
        icon: Icons.local_hospital,
        color: const Color(0xFF2196F3),
        route: '/doctor',
      ),
      UserRole(
        title: 'Assistant',
        subtitle: 'Medical assistant/Nurse',
        description: 'Support doctors, manage patient care and records',
        icon: Icons.person_add,
        color: const Color(0xFF9C27B0),
        route: '/assistant',
      ),
    ];

    return Column(
      children: [
        // Hospital Registration Option
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: isTablet ? 30.0 : 24.0),
          child: ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/hospital-registration'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2196F3),
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
                Icon(Icons.business, size: isTablet ? 28 : 24),
                const SizedBox(width: 12),
                Text(
                  'Register New Hospital',
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR LOGIN AS EXISTING STAFF',
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

        // Hospital Role Cards
        Expanded(
          child: ListView.builder(
            itemCount: hospitalRoles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 20.0 : 16.0),
                child: RoleCardWidget(
                  role: hospitalRoles[index],
                  isTablet: isTablet,
                  onTap: () => _handleHospitalRoleSelection(context, hospitalRoles[index]),
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
            'Hospital Staff Portal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'DHRMS - SIH 2025',
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

  void _handleHospitalRoleSelection(BuildContext context, UserRole role) {
    switch (role.route) {
      case '/hospital-admin':
        Navigator.pushNamed(context, '/hospital-admin-login');
        break;
      case '/doctor':
        Navigator.pushNamed(context, '/hospital-doctor-login');
        break;
      case '/assistant':
        Navigator.pushNamed(context, '/hospital-assistant-login');
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
    }
  }
}