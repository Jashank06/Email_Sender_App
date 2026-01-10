import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final bool showParticles;
  
  const AnimatedBackground({
    super.key,
    required this.child,
    this.colors = const [
      AppTheme.primaryBlack,
      AppTheme.secondaryBlack,
    ],
    this.showParticles = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    if (widget.showParticles) {
      _initParticles();
    }
  }

  void _initParticles() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 4 + 1,
        speedX: (random.nextDouble() - 0.5) * 0.0005,
        speedY: random.nextDouble() * 0.0005 + 0.0002,
        opacity: random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated Gradient Background
        AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlack,
                    AppTheme.secondaryBlack,
                    Color.lerp(
                      AppTheme.primaryBlack,
                      Colors.white.withOpacity(0.05),
                      _gradientController.value,
                    )!,
                  ],
                  stops: [
                    0.0,
                    0.6 + _gradientController.value * 0.2,
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),
        
        // Floating Particles
        if (widget.showParticles)
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: _particles,
                  animationValue: _particleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
        
        // Glowing Orbs (Monochrome)
        Positioned(
          top: -150,
          right: -100,
          child: AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.08 * _gradientController.value),
                      Colors.white.withOpacity(0.02 * _gradientController.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        Positioned(
          bottom: -200,
          left: -150,
          child: AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.05 * (1 - _gradientController.value)),
                      Colors.white.withOpacity(0.01 * (1 - _gradientController.value)),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Content
        widget.child,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speedX;
  final double speedY;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.opacity,
  });

  void update() {
    x += speedX;
    y += speedY;

    if (x > 1) x = 0;
    if (x < 0) x = 1;
    if (y > 1) y = -0.1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size);

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
