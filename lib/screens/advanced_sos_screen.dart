import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';

class AdvancedSOSScreen extends StatefulWidget {
  const AdvancedSOSScreen({super.key});

  @override
  State<AdvancedSOSScreen> createState() => _AdvancedSOSScreenState();
}

class _AdvancedSOSScreenState extends State<AdvancedSOSScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countdownAnimation;
  late Animation<double> _fadeAnimation;

  bool _isSOSActive = false;
  bool _isCountingDown = false;
  int _countdown = 10;
  Timer? _countdownTimer;
  
  final List<SOSAction> _sosActions = [
    SOSAction(
      title: 'Emergency Call',
      description: 'Call 108 (Ambulance)',
      icon: Icons.local_hospital,
      color: Colors.red,
      isCompleted: false,
    ),
    SOSAction(
      title: 'Location Sharing',
      description: 'Share live location',
      icon: Icons.location_on,
      color: Colors.blue,
      isCompleted: false,
    ),
    SOSAction(
      title: 'Contact Notification',
      description: 'Alert emergency contacts',
      icon: Icons.contacts,
      color: Colors.green,
      isCompleted: false,
    ),
    SOSAction(
      title: 'Medical Info',
      description: 'Send medical details',
      icon: Icons.medical_information,
      color: Colors.orange,
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _countdownController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _countdownAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.linear),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    _fadeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isSOSActive
                ? [Colors.red.shade800, Colors.red.shade600, Colors.red.shade400]
                : [Colors.red.shade50, Colors.white, Colors.orange.shade50],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _isSOSActive ? _buildSOSActiveView() : _buildSOSInactiveView(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSOSInactiveView() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInstructionsCard(),
                const SizedBox(height: 30),
                _buildSOSButton(),
                const SizedBox(height: 30),
                _buildQuickActionsCard(),
                const SizedBox(height: 30),
                _buildLocationStatusCard(),
                const SizedBox(height: 30),
                _buildSOSSettingsCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSOSActiveView() {
    return Container(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            title: const Text('Emergency SOS Active'),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isCountingDown) _buildCountdownView() else _buildExecutingView(),
                  const SizedBox(height: 50),
                  _buildCancelButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
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
                Colors.red.shade700,
                Colors.red.shade600,
                Colors.orange.shade500,
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.red.shade700.withOpacity(0.9),
                      Colors.red.shade600.withOpacity(0.8),
                      Colors.orange.shade500.withOpacity(0.9),
                    ],
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sos, color: Colors.white, size: 40),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Emergency SOS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Quick emergency assistance',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
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
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'How to Use Emergency SOS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep('1', 'Press and hold the SOS button', 'Long press for 3 seconds to activate'),
          _buildInstructionStep('2', '10-second countdown begins', 'You can cancel during this time'),
          _buildInstructionStep('3', 'Emergency services contacted', 'Automatic call to 108'),
          _buildInstructionStep('4', 'Location and contacts notified', 'Live location shared with emergency contacts'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onLongPressStart: (_) => _startSOS(),
      onLongPressEnd: (_) => _cancelSOS(),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade700,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sos, color: Colors.white, size: 48),
                      SizedBox(height: 8),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hold to activate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Emergency Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Call 108',
                  Icons.local_hospital,
                  Colors.red,
                  () => _makeEmergencyCall('108'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Share Location',
                  Icons.location_on,
                  Colors.blue,
                  () => _shareLocation(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Call Police',
                  Icons.local_police,
                  Colors.indigo,
                  () => _makeEmergencyCall('100'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Contacts',
                  Icons.contacts,
                  Colors.green,
                  () => _showEmergencyContacts(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
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

  Widget _buildLocationStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'GPS enabled - Location will be shared during emergencies',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green.shade600),
        ],
      ),
    );
  }

  Widget _buildSOSSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SOS Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.timer, color: Colors.blue),
            title: const Text('Countdown Duration'),
            subtitle: const Text('10 seconds'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCountdownSettings(),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.contacts, color: Colors.green),
            title: const Text('Emergency Contacts'),
            subtitle: const Text('3 contacts configured'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEmergencyContacts(),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.medical_information, color: Colors.red),
            title: const Text('Medical Information'),
            subtitle: const Text('Update medical details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMedicalInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownView() {
    return Column(
      children: [
        const Text(
          'Emergency SOS Activating',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: _countdownAnimation,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value: _countdownAnimation.value,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                },
              ),
            ),
            Text(
              _countdown.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Emergency services will be contacted',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const Text(
          'Tap cancel to stop',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildExecutingView() {
    return Column(
      children: [
        const Text(
          'Emergency SOS Active',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: _sosActions.map((action) => _buildSOSActionItem(action)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSOSActionItem(SOSAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: action.isCompleted ? Colors.green : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(action.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  action.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (action.isCompleted)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _cancelEmergency,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red.shade600,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'CANCEL EMERGENCY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _startSOS() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isSOSActive = true;
      _isCountingDown = true;
      _countdown = 10;
    });
    
    _countdownController.forward();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });
      
      HapticFeedback.lightImpact();
      
      if (_countdown <= 0) {
        timer.cancel();
        _executeEmergency();
      }
    });
  }

  void _cancelSOS() {
    if (_isCountingDown) {
      _cancelEmergency();
    }
  }

  void _cancelEmergency() {
    _countdownTimer?.cancel();
    _countdownController.reset();
    
    setState(() {
      _isSOSActive = false;
      _isCountingDown = false;
      _countdown = 10;
      for (var action in _sosActions) {
        action.isCompleted = false;
      }
    });
    
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency SOS cancelled'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _executeEmergency() {
    setState(() {
      _isCountingDown = false;
    });
    
    // Simulate executing emergency actions
    _simulateEmergencyActions();
  }

  void _simulateEmergencyActions() async {
    for (int i = 0; i < _sosActions.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _sosActions[i].isCompleted = true;
      });
      HapticFeedback.lightImpact();
    }
    
    // Show completion
    await Future.delayed(const Duration(seconds: 2));
    _showEmergencyCompleted();
  }

  void _showEmergencyCompleted() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 30),
            const SizedBox(width: 10),
            const Text('Emergency Alert Sent'),
          ],
        ),
        content: const Text(
          'Emergency services have been contacted and your emergency contacts have been notified with your location.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelEmergency();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _makeEmergencyCall(String number) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $number...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareLocation() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location shared with emergency contacts'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showEmergencyContacts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening emergency contacts...'),
      ),
    );
  }

  void _showCountdownSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Countdown Duration'),
        content: const Text('Set the countdown duration before emergency services are contacted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMedicalInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening medical information...'),
      ),
    );
  }
}

class SOSAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  bool isCompleted;

  SOSAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isCompleted = false,
  });
}