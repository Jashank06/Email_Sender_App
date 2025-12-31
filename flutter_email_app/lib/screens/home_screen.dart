import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import 'email_config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryBlack,
              AppTheme.secondaryBlack,
              AppTheme.primaryBlack,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background orbs
            _buildAnimatedOrb(
              top: -100,
              left: -100,
              color: AppTheme.glowBlue,
              size: 300,
            ),
            _buildAnimatedOrb(
              bottom: -150,
              right: -150,
              color: AppTheme.glowPurple,
              size: 400,
            ),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon/logo
                      _buildAppIcon(),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        'Email Sender',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 40,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [AppTheme.glowBlue, AppTheme.glowPurple],
                            ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Send personalized emails from Google Sheets\nwith Gmail & Outlook support',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Feature cards
                      _buildFeatureCards(),
                      
                      const SizedBox(height: 60),
                      
                      // Get started button
                      _buildGetStartedButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimatedOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3 * _glowController.value),
                  color.withOpacity(0.1 * _glowController.value),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAppIcon() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.glowBlue, AppTheme.glowPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.glowBlue.withOpacity(0.6),
            blurRadius: 40,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: AppTheme.glowPurple.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(10, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Image.asset(
          'assets/App_Logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.email_rounded,
              size: 70,
              color: Colors.white,
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.email_outlined,
        'title': 'Gmail & Outlook',
        'description': 'Both providers supported',
      },
      {
        'icon': Icons.table_chart_outlined,
        'title': 'Google Sheets',
        'description': 'Import contacts easily',
      },
      {
        'icon': Icons.edit_outlined,
        'title': 'Custom Templates',
        'description': 'Personalize your emails',
      },
    ];
    
    return Row(
      children: features.map((feature) {
        final index = features.indexOf(feature);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 1 ? 8 : 0),
            child: GlassmorphicCard(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.glowBlue.withOpacity(0.3),
                          AppTheme.glowPurple.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: AppTheme.accentWhite,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    feature['title'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['description'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: AppTheme.accentWhite.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppTheme.glowBlue, AppTheme.glowPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.glowBlue.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmailConfigScreen(),
              ),
            );
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.primaryBlack,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
