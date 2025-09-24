import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _logoController;
  late AnimationController _heartbeatController;
  late AnimationController _glowController;
  late AnimationController _shineController;
  late AnimationController _fadeOutController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _logoFadeIn;
  late Animation<double> _logoScale;
  late Animation<double> _heartbeatScale;
  late Animation<double> _glowAnimation;
  late Animation<double> _shinePosition;
  late Animation<double> _fadeOut;

  // Loading Progress
  double _loadingProgress = 0.0;
  late Timer _loadingTimer;

  // Particle System
  final List<Particle> _particles = [];
  late Timer _particleTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoading();
    _initializeParticles();

    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeAnimations() {
    // Logo Animation Controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Heartbeat Animation Controller
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Glow Animation Controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Shine Animation Controller
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade Out Animation Controller
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Particle Animation Controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Logo Animations
    _logoFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Heartbeat Animation
    _heartbeatScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _heartbeatController, curve: Curves.easeInOut),
    );

    // Glow Animation
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Shine Animation
    _shinePosition = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Fade Out Animation
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
    );

    // Start Animations
    _logoController.forward();

    // Start repeating animations with delays
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _heartbeatController.repeat(reverse: true);
        _glowController.repeat(reverse: true);
        _particleController.repeat();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _startShineAnimation();
      }
    });
  }

  void _startShineAnimation() {
    _shineController.repeat();
  }

  void _initializeParticles() {
    final random = math.Random();

    // Create initial particles
    for (int i = 0; i < 20; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.5 + 0.1,
          opacity: random.nextDouble() * 0.6 + 0.2,
        ),
      );
    }

    // Timer to update particles
    _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          for (var particle in _particles) {
            particle.update();
          }
        });
      }
    });
  }

  void _startLoading() {
    const totalDuration = Duration(milliseconds: 4000); // 4 seconds total
    const updateInterval = Duration(milliseconds: 50); // Update every 50ms
    final totalSteps =
        totalDuration.inMilliseconds / updateInterval.inMilliseconds;
    final increment = 100.0 / totalSteps;

    _loadingTimer = Timer.periodic(updateInterval, (timer) {
      if (mounted) {
        setState(() {
          _loadingProgress += increment;

          // Ensure we don't exceed 100%
          if (_loadingProgress >= 100.0) {
            _loadingProgress = 100.0;
            timer.cancel();

            // Start exit transition after a brief pause
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _exitSplash();
              }
            });
          }
        });
      }
    });
  }

  void _exitSplash() {
    _fadeOutController.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.nextScreen,
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _heartbeatController.dispose();
    _glowController.dispose();
    _shineController.dispose();
    _fadeOutController.dispose();
    _particleController.dispose();
    _loadingTimer.cancel();
    _particleTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _heartbeatController,
          _glowController,
          _shineController,
          _fadeOutController,
          _particleController,
        ]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOut.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF000000),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Particle System
                  _buildParticleSystem(screenSize),

                  // Main Content
                  SafeArea(
                    child: Column(
                      children: [
                        // Logo Section
                        Expanded(
                          flex: 3,
                          child: Center(child: _buildLogoSection()),
                        ),

                        // App Name Section
                        Expanded(
                          flex: 2,
                          child: Center(child: _buildAppNameSection()),
                        ),

                        // Progress Section
                        Expanded(flex: 2, child: _buildProgressSection()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticleSystem(Size screenSize) {
    return CustomPaint(size: screenSize, painter: ParticlePainter(_particles));
  }

  Widget _buildLogoSection() {
    return Transform.scale(
      scale: _logoScale.value,
      child: Opacity(
        opacity: _logoFadeIn.value,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 5 * _glowAnimation.value,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1 * _glowAnimation.value),
                blurRadius: 40 * _glowAnimation.value,
                spreadRadius: 10 * _glowAnimation.value,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SvgPicture.asset(
              'assets/applogo.svg',
              fit: BoxFit.cover,
              placeholderBuilder: (context) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppNameSection() {
    return Transform.scale(
      scale: _heartbeatScale.value,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2 * _glowAnimation.value),
              blurRadius: 30 * _glowAnimation.value,
              spreadRadius: 10 * _glowAnimation.value,
            ),
          ],
        ),
        child: ClipRect(
          child: Stack(
            children: [
              // Main Text
              Text(
                'My Health',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10),
                    Shadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),

              // Shine Effect
              Positioned.fill(
                child: ClipRect(
                  child: Transform.translate(
                    offset: Offset(_shinePosition.value * 200, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
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

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Progress Text
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Loading... ${_loadingProgress.toInt()}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 1,
                shadows: [
                  Shadow(color: Colors.blue.withOpacity(0.5), blurRadius: 5),
                ],
              ),
            ),
          ),

          // Progress Bar Container
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  // Progress Bar
                  FractionallySizedBox(
                    widthFactor: _loadingProgress / 100.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                            Colors.cyan.shade400,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Glow Effect on Progress Bar
                  if (_loadingProgress > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Particle Class
class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  void update() {
    y -= speed * 0.01;
    if (y < 0) {
      y = 1.0;
      x = math.Random().nextDouble();
    }
  }
}

// Custom Painter for Particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = Colors.white.withOpacity(particle.opacity * 0.6);

      final center = Offset(particle.x * size.width, particle.y * size.height);

      // Draw particle with glow effect
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);
      canvas.drawCircle(center, particle.size, paint);

      // Draw core
      paint.maskFilter = null;
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(center, particle.size * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
