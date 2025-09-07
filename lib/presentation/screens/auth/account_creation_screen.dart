import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import 'patient_registration_screen.dart';
import 'hospital_registration_screen.dart';
import 'doctor_registration_screen.dart';

class AccountCreationScreen extends StatelessWidget {
  const AccountCreationScreen({Key? key}) : super(key: key);

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
                      // App Logo
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
                          Icons.person_add,
                          size: 60,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginLarge),
                      Text(
                        'Create New Account',
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        'Choose your account type to get started',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Account Creation Options
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.radiusExtraLarge),
                      topRight: Radius.circular(AppDimensions.radiusExtraLarge),
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
                          'Select Account Type',
                          style: AppTextStyles.headline3.copyWith(
                            color: AppColors.grey900,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),

                        Text(
                          'Different account types have different registration processes',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),

                        // Patient Registration Card
                        _AccountTypeCard(
                          icon: Icons.person,
                          title: 'Patient Account',
                          subtitle: 'For migrant workers and patients. Immediate access after registration.',
                          badgeText: 'Instant Access',
                          badgeColor: AppColors.success,
                          color: AppColors.primaryGreen,
                          onTap: () => _navigateToRegistration(context, 'patient'),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),

                        // Hospital Registration Card
                        _AccountTypeCard(
                          icon: Icons.local_hospital,
                          title: 'Hospital Account',
                          subtitle: 'For hospital administrators. Requires Regional Officer approval.',
                          badgeText: 'Approval Required',
                          badgeColor: AppColors.primaryOrange,
                          color: AppColors.primaryBlue,
                          onTap: () => _navigateToRegistration(context, 'hospital'),
                        ),
                        const SizedBox(height: AppDimensions.marginMedium),

                        // Doctor Registration Card
                        _AccountTypeCard(
                          icon: Icons.medical_services,
                          title: 'Doctor Account',
                          subtitle: 'For medical professionals. Requires Hospital Administrator approval.',
                          badgeText: 'Hospital Approval',
                          badgeColor: AppColors.primaryOrange,
                          color: AppColors.primaryBlue,
                          onTap: () => _navigateToRegistration(context, 'doctor'),
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),

                        // Back to Login Button
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Back to Login'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.primaryBlue),
                            foregroundColor: AppColors.primaryBlue,
                          ),
                        ),
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

  void _navigateToRegistration(BuildContext context, String accountType) {
    Widget screen;
    switch (accountType) {
      case 'patient':
        screen = const PatientRegistrationScreen();
        break;
      case 'hospital':
        screen = const HospitalRegistrationScreen();
        break;
      case 'doctor':
        screen = const DoctorRegistrationScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color color;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
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
          child: Column(
            children: [
              Row(
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
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppTextStyles.headline6.copyWith(
                                  color: AppColors.grey900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
                ],
              ),
              const SizedBox(height: AppDimensions.marginMedium),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onTap,
                      child: Text('Create Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
