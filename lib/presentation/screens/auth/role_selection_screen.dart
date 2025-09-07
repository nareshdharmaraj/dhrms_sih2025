import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_styles.dart';
import 'login_screen.dart';
import 'account_creation_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryBlue, AppColors.darkBlue],
            ),
          ),
          child: Column(
            children: [
              // Header
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo Placeholder
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.health_and_safety,
                          size: 60,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginLarge),

                      // App Title
                      Text(
                        'MyHealth',
                        style: AppTextStyles.headline1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),

                      // Subtitle
                      Text(
                        'Digital Health Record Management System',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),

                      // Description
                      Text(
                        'For Migrant Workers in Kerala',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Role Selection Cards
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusLarge * 2),
                      topRight: Radius.circular(AppDimensions.radiusLarge * 2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppDimensions.marginMedium),

                        // Title
                        Text(
                          'Select Your Role',
                          style: AppTextStyles.headline3.copyWith(
                            color: const Color.fromARGB(255, 6, 4, 4),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),

                        Text(
                          'Choose your role to access the appropriate dashboard',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: const Color.fromARGB(255, 2, 2, 2),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),

                        // Role Cards
                        // Normal User Card
                        _RoleCard(
                          icon: Icons.person,
                          title: 'Migrant Worker',
                          subtitle:
                              'Access your health records, monitor vitals, and get medical assistance',
                          color: AppColors.userRole,
                          onTap: () => _navigateToLogin(
                            context,
                            AppConstants.roleNormalUser,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),

                        // Hospital Card
                        _RoleCard(
                          icon: Icons.local_hospital,
                          title: 'Hospital/Medical Staff',
                          subtitle:
                              'Manage patient records, update medical data, and track health status',
                          color: AppColors.hospitalRole,
                          onTap: () => _navigateToLogin(
                            context,
                            AppConstants.roleHospital,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),

                        // Regional Officer Card
                        _RoleCard(
                          icon: Icons.admin_panel_settings,
                          title: 'Regional Health Officer',
                          subtitle:
                              'Monitor regional health data, manage outbreaks, and oversee operations',
                          color: AppColors.regionalOfficerRole,
                          onTap: () => _navigateToLogin(
                            context,
                            AppConstants.roleRegionalOfficer,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),
                        
                        // Create Account Button
                        OutlinedButton.icon(
                          onPressed: () => _navigateToAccountCreation(context),
                          icon: Icon(Icons.person_add, color: AppColors.primaryBlue),
                          label: Text(
                            'Create New Account',
                            style: TextStyle(color: AppColors.primaryBlue),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.primaryBlue),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(userRole: role)),
    );
  }

  void _navigateToAccountCreation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountCreationScreen()),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            color: color.withOpacity(0.05),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                ),
                child: Icon(icon, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: AppDimensions.marginMedium),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline6.copyWith(
                        color: AppColors.grey900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward_ios, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
