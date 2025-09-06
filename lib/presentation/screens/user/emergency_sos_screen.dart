import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  bool _isEmergencyActive = false;
  int _countdown = 0;

  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Emergency Services',
      phone: '108',
      type: 'Ambulance',
      icon: Icons.local_hospital,
      isPrimary: true,
    ),
    EmergencyContact(
      name: 'Police Emergency',
      phone: '100',
      type: 'Police',
      icon: Icons.local_police,
      isPrimary: true,
    ),
    EmergencyContact(
      name: 'Fire Emergency',
      phone: '101',
      type: 'Fire Department',
      icon: Icons.local_fire_department,
      isPrimary: true,
    ),
    EmergencyContact(
      name: 'Priya Kumar',
      phone: '+91 9876543211',
      type: 'Emergency Contact',
      icon: Icons.person,
      isPrimary: false,
    ),
    EmergencyContact(
      name: 'Dr. Sarah Joseph',
      phone: '+91 9876543212',
      type: 'Family Doctor',
      icon: Icons.medical_services,
      isPrimary: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startEmergency() {
    setState(() {
      _isEmergencyActive = true;
      _countdown = 10;
    });

    _pulseController.repeat(reverse: true);
    _fadeController.repeat(reverse: true);

    // Start countdown
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0 && _isEmergencyActive) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else if (_countdown == 0 && _isEmergencyActive) {
        _executeEmergencyCall();
      }
    });
  }

  void _cancelEmergency() {
    setState(() {
      _isEmergencyActive = false;
      _countdown = 0;
    });

    _pulseController.stop();
    _fadeController.stop();
    _pulseController.reset();
    _fadeController.reset();
  }

  void _executeEmergencyCall() {
    _cancelEmergency();
    // In real app, this would initiate emergency call and location sharing
    _showEmergencyDialog();
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.phone_in_talk,
          color: AppColors.success,
          size: 40,
        ),
        title: const Text('Emergency Alert Sent'),
        content: const Text(
          'Emergency services have been notified and your location has been shared with emergency contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isEmergencyActive ? AppColors.error : AppColors.grey100,
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showEmergencySettings(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            children: [
              if (!_isEmergencyActive) ...[
                _buildInstructionsCard(),
                const SizedBox(height: AppDimensions.marginLarge),
                _buildEmergencyButton(),
                const SizedBox(height: AppDimensions.marginLarge),
                _buildQuickDialSection(),
              ] else ...[
                _buildEmergencyActiveView(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 24),
                const SizedBox(width: AppDimensions.marginSmall),
                Text(
                  'How to use Emergency SOS',
                  style: AppTextStyles.headline6.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            _buildInstructionItem(
              '1. Press and hold the SOS button',
              'Long press will start a 10-second countdown',
            ),
            _buildInstructionItem(
              '2. Countdown begins',
              'You have 10 seconds to cancel if pressed accidentally',
            ),
            _buildInstructionItem(
              '3. Emergency contacts notified',
              'Your location and medical info will be shared automatically',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Center(
      child: GestureDetector(
        onLongPress: _startEmergency,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sos, color: AppColors.white, size: 60),
                      SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hold to activate',
                        style: TextStyle(color: AppColors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmergencyActiveView() {
    return Expanded(
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Emergency SOS Active',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginLarge),

                Text(
                  'Calling emergency services in',
                  style: AppTextStyles.headline6.copyWith(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginMedium),

                Text(
                  '$_countdown',
                  style: AppTextStyles.headline1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginLarge),

                Text(
                  'Your location is being shared with emergency contacts',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginExtraLarge),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cancelEmergency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                      ),
                    ),
                    child: Text(
                      'CANCEL EMERGENCY',
                      style: AppTextStyles.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickDialSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Dial',
            style: AppTextStyles.headline6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.marginMedium),

          Expanded(
            child: ListView.builder(
              itemCount: _emergencyContacts.length,
              itemBuilder: (context, index) {
                return _buildEmergencyContactCard(_emergencyContacts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: contact.isPrimary
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Icon(
            contact.icon,
            color: contact.isPrimary ? AppColors.error : AppColors.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          contact.name,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.type,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            ),
            Text(
              contact.phone,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone, color: AppColors.success),
          onPressed: () => _makeEmergencyCall(contact),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _makeEmergencyCall(EmergencyContact contact) {
    // In real app, this would initiate phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${contact.name} at ${contact.phone}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showEmergencySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLarge),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Settings',
                style: AppTextStyles.headline6.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.marginLarge),

              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Add Emergency Contact'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Add emergency contact functionality
                },
              ),

              ListTile(
                leading: const Icon(Icons.medical_information),
                title: const Text('Medical Information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Edit medical information
                },
              ),

              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location Sharing'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: Toggle location sharing
                  },
                ),
              ),

              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Countdown Duration'),
                subtitle: const Text('10 seconds'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Adjust countdown duration
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String type;
  final IconData icon;
  final bool isPrimary;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.type,
    required this.icon,
    required this.isPrimary,
  });
}
