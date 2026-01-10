import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/email_provider.dart';
import '../providers/tracking_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_button.dart';

class SendEmailScreen extends StatefulWidget {
  const SendEmailScreen({super.key});

  @override
  State<SendEmailScreen> createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends State<SendEmailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              
              Expanded(
                child: Consumer<EmailProvider>(
                  builder: (context, provider, _) {
                    if (provider.isSending) {
                      return Consumer<TrackingProvider>(
                        builder: (context, trackingProvider, _) {
                          if (trackingProvider.currentProgress != null) {
                            return Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                                physics: const BouncingScrollPhysics(),
                                child: ProgressCard(progress: trackingProvider.currentProgress!),
                              ),
                            );
                          }
                          return _buildSendingView();
                        },
                      );
                    } else if (provider.sendResult != null) {
                      return _buildResultView(provider);
                    } else {
                      return _buildConfirmView(provider);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAMPAIGN DISPATCH',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'PRE-FLIGHT SECURITY REVIEW',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentWhite.withOpacity(0.4),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfirmView(EmailProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'READY FOR DEPLOYMENT',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'VERIFY STATION CONFIGURATION BEFORE RELEASE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentWhite.withOpacity(0.4),
              letterSpacing: 1.0,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 40),
          
          _buildConfigCard(
            icon: Icons.hub_rounded,
            title: 'PROTOCOL',
            value: provider.emailConfig?.provider.toUpperCase() ?? 'NONE',
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildConfigCard(
            icon: Icons.alternate_email_rounded,
            title: 'SOURCE NODE',
            value: provider.emailConfig?.email ?? 'NONE',
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildConfigCard(
            icon: provider.useManualRecipients ? Icons.data_array_rounded : Icons.storage_rounded,
            title: provider.useManualRecipients ? 'TARGET VECTOR' : 'DATABASE SOURCE',
            value: provider.useManualRecipients 
                ? '${provider.recipients.length} TARGETS IDENTIFIED'
                : 'SHEET ID: ${provider.sheetId.length > 20 ? provider.sheetId.substring(0, 15) + '...' : provider.sheetId}',
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildConfigCard(
            icon: Icons.title_rounded,
            title: 'DISPATCH TITLE',
            value: provider.subject.toUpperCase(),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildConfigCard(
            icon: Icons.attachment_rounded,
            title: 'PAYLOAD',
            value: provider.attachments.isEmpty 
                ? 'NO ADDITIONAL PAYLOAD' 
                : '${provider.attachments.length} OBJECTS ATTACHED',
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 48),
          
          AnimatedButton(
            onPressed: () => _handleSend(provider),
            text: 'INITIALIZE DISPATCH',
            icon: Icons.rocket_launch_rounded,
          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
  
  Widget _buildConfigCard({required IconData icon, required String title, required String value}) {
    return GlassmorphicCard(
      borderRadius: 20,
      blur: 15,
      opacity: 0.05,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.accentWhite.withOpacity(0.4),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSendingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2000.ms, color: Colors.white10)
            .scale(duration: 1500.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), curve: Curves.easeInOut),
          
          const SizedBox(height: 40),
          
          const Text(
            'TRANSMITTING...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4.0,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'STATION IS DISPATCHING DATA PACKETS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentWhite.withOpacity(0.4),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultView(EmailProvider provider) {
    final result = provider.sendResult!;
    final successCount = result['successCount'] ?? 0;
    final total = result['totalContacts'] ?? 0;
    final failedCount = result['failedCount'] ?? 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.done_all_rounded,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 32),
          
          Text(
            successCount == total ? 'MISSION COMPLETED' : 'TRANSMISSION REPORT',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 48),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'TOTAL',
                  total.toString(),
                  Icons.sensors_rounded,
                  Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'SUCCESS',
                  successCount.toString(),
                  Icons.verified_rounded,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'FAILED',
                  failedCount.toString(),
                  Icons.gpp_bad_rounded,
                  Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 56),
          
          AnimatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            text: 'RETURN TO STATION',
            icon: Icons.home_rounded,
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassmorphicCard(
      borderRadius: 24,
      blur: 20,
      opacity: 0.04,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: color.withOpacity(0.4),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleSend(EmailProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.email;
    
    if (userId == null) {
      _showSnack('NODE UNAUTHORIZED');
      return;
    }

    final success = await provider.sendBulkEmails(userId);
    
    if (!mounted) return;
    
    if (!success && provider.error != null) {
      _showSnack(provider.error!.toUpperCase());
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 12)),
        backgroundColor: Colors.black.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }
}
