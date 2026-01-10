import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_button.dart';
import '../widgets/page_transition.dart';
import 'email_config_screen.dart';
import 'campaigns_screen.dart';
import 'profile_screen.dart';
import 'send_email_screen.dart';
import 'auth_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/tracking_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _cardController;
  late List<Animation<double>> _cardAnimations;
  
  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _cardAnimations = List.generate(
      10,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardController,
          curve: Interval(
            (index * 0.1).clamp(0.0, 1.0),
            (0.6 + (index * 0.1)).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
    
    _cardController.forward();
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _cardController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Sync userId to TrackingProvider whenever it changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<TrackingProvider>().setUserId(auth.currentUser?.email);
        });

        if (!auth.isAuthenticated) {
          return const AuthScreen();
        }

        return Scaffold(
          body: AnimatedBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => context.read<TrackingProvider>().loadCampaigns(),
                color: AppTheme.accentPurple,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: const Text(
                        'EMAIL SENDER PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 2.0,
                        ),
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  child: const ProfileScreen(),
                                  type: PageTransitionType.slideUp,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    // Main Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            
                            // Top Section: Info & Logo
                            Row(
                              children: [
                                // Hero Logo with animation
                                Transform.scale(
                                  scale: 0.7,
                                  child: _buildAnimatedLogo(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'WELCOME BACK',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                          color: AppTheme.accentWhite.withOpacity(0.4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        auth.currentUser?.name?.toUpperCase() ?? 'USER',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.accentWhite,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // Quick Actions Grid
                            _buildQuickActions(context),
                            
                            const SizedBox(height: 40),
                            
                            // Stats Section Header
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4, bottom: 20),
                                child: Row(
                                  children: [
                                    const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PERFORMANCE',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                        color: AppTheme.accentWhite.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Stats Cards
                            Consumer<TrackingProvider>(
                              builder: (context, tracking, _) {
                                final stats = tracking.userStats;
                                return _buildStatsCards(stats);
                              },
                            ),
                            
                            const SizedBox(height: 50),
                            
                            // Feature Cards section
                            _buildFeatureCards(),
                            
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Hero(
            tag: 'app_logo',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: Colors.black,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 20,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Stack(
                  children: [
                    Center(
                      child: Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/App_Logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.email_rounded,
                              size: 60,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(UserStats stats) {
    return AnimatedBuilder(
      animation: _cardAnimations[0],
      builder: (context, child) {
        return Opacity(
          opacity: _cardAnimations[0].value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _cardAnimations[0].value)),
            child: Row(
              children: [
                Expanded(child: _buildStatCard(stats.totalCampaigns.toString(), 'CAMPAIGNS', Icons.campaign_rounded, Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(stats.totalEmailsSent.toString(), 'SENT', Icons.send_rounded, Colors.white70)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('${stats.averageSuccessRate.toStringAsFixed(1)}%', 'SUCCESS', Icons.check_circle_rounded, Colors.white60)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return GlassmorphicCard(
      blur: 20,
      opacity: 0.05,
      borderRadius: 24,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppTheme.accentWhite.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'title': 'SEND EMAIL',
        'icon': Icons.send_rounded,
        'gradient': AppTheme.primaryGradient,
        'route': const SendEmailScreen(),
      },
      {
        'title': 'CONFIGURE',
        'icon': Icons.settings_rounded,
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF444444), Colors.black],
        ),
        'route': const EmailConfigScreen(),
      },
      {
        'title': 'CAMPAIGNS',
        'icon': Icons.analytics_rounded,
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF888888), Color(0xFF333333)],
        ),
        'route': const CampaignsScreen(),
      },
      {
        'title': 'PROFILE',
        'icon': Icons.person_rounded,
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFB0B0B0)],
        ),
        'route': const ProfileScreen(),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final aspectRatio = constraints.maxWidth > 600 ? 1.0 : 1.25;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _cardAnimations[index + 1],
              builder: (context, child) {
                return Opacity(
                  opacity: _cardAnimations[index + 1].value,
                  child: Transform.translate(
                    offset: Offset(0, 40 * (1 - _cardAnimations[index + 1].value)),
                    child: _buildQuickActionCard(
                      context,
                      actions[index]['title'] as String,
                      actions[index]['icon'] as IconData,
                      actions[index]['gradient'] as LinearGradient,
                      actions[index]['route'] as Widget,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    LinearGradient gradient,
    Widget route,
  ) {
    bool isWhite = gradient.colors.first == Colors.white || gradient.colors.first == AppTheme.accentWhite;
    
    return GlassmorphicCard(
      onTap: () {
        Navigator.push(
          context,
          CustomPageTransition(child: route),
        );
      },
      borderRadius: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: isWhite ? Colors.black : Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: AppTheme.accentWhite,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.bolt_rounded,
        'title': 'PREMIUM PERFORMANCE',
        'description': 'Proprietary delivery algorithms.',
        'color': Colors.white,
      },
      {
        'icon': Icons.security_rounded,
        'title': 'ENTERPRISE SECURITY',
        'description': 'Military-grade data encryption.',
        'color': Colors.white70,
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'SMART ANALYTICS',
        'description': 'Real-time tracking and insights.',
        'color': Colors.white60,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Text(
            'STATION CAPABILITIES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              color: AppTheme.accentWhite.withOpacity(0.6),
            ),
          ),
        ),
        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return AnimatedBuilder(
            animation: _cardAnimations[index + 5],
            builder: (context, child) {
              return Opacity(
                opacity: _cardAnimations[index + 5].value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - _cardAnimations[index + 5].value)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassmorphicCard(
                      blur: 30,
                      opacity: 0.04,
                      borderRadius: 24,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Icon(
                              feature['icon'] as IconData,
                              color: feature['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feature['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  feature['description'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.accentWhite.withOpacity(0.4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withOpacity(0.2),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }
}
