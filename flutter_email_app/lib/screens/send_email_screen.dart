import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/email_provider.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';

class SendEmailScreen extends StatefulWidget {
  const SendEmailScreen({super.key});

  @override
  State<SendEmailScreen> createState() => _SendEmailScreenState();
}

class _SendEmailScreenState extends State<SendEmailScreen> {
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
            _buildBackgroundOrb(top: -100, right: -100, color: AppTheme.glowBlue),
            _buildBackgroundOrb(bottom: -150, left: -150, color: AppTheme.glowPurple),
            
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  
                  Expanded(
                    child: Consumer<EmailProvider>(
                      builder: (context, provider, _) {
                        if (provider.isSending) {
                          return _buildSendingView();
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
          ],
        ),
      ),
    );
  }
  
  Widget _buildBackgroundOrb({double? top, double? bottom, double? left, double? right, required Color color}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
              Colors.transparent,
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.accentWhite),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Send Emails',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConfirmView(EmailProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to Send',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Review your configuration before sending',
            style: Theme.of(context).textTheme.bodyMedium,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          
          _buildConfigCard(
            icon: Icons.email_outlined,
            title: 'Email Provider',
            value: provider.emailConfig?.provider.toUpperCase() ?? 'N/A',
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildConfigCard(
            icon: Icons.account_circle_outlined,
            title: 'Email Account',
            value: provider.emailConfig?.email ?? 'N/A',
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildConfigCard(
            icon: provider.useManualRecipients ? Icons.paste_rounded : Icons.table_chart_outlined,
            title: provider.useManualRecipients ? 'Recipients' : 'Google Sheet',
            value: provider.useManualRecipients 
                ? '${provider.recipients.length} manual entries'
                : 'ID: ${provider.sheetId.length > 20 ? provider.sheetId.substring(0, 20) + '...' : provider.sheetId}',
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildConfigCard(
            icon: Icons.subject_outlined,
            title: 'Subject',
            value: provider.subject,
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),
          
          _buildSendButton(provider),
        ],
      ),
    );
  }
  
  Widget _buildConfigCard({required IconData icon, required String title, required String value}) {
    return GlassmorphicCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.glowBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.glowBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.accentWhite.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSendButton(EmailProvider provider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [AppTheme.successGreen, AppTheme.glowBlue]),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleSend(provider),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Send Emails',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
  
  Widget _buildSendingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppTheme.glowBlue, AppTheme.glowPurple]),
            ),
            child: const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1500.ms)
            .scale(duration: 1000.ms, begin: Offset(0.9, 0.9), end: Offset(1.1, 1.1)),
          
          const SizedBox(height: 32),
          
          Text(
            'Sending Emails...',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Please wait while we send your emails',
            style: Theme.of(context).textTheme.bodyMedium,
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
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: successCount == total
                    ? [AppTheme.successGreen, AppTheme.glowBlue]
                    : [AppTheme.glowBlue, AppTheme.glowPurple],
              ),
            ),
            child: Icon(
              successCount == total ? Icons.check_circle_outline : Icons.info_outline,
              size: 60,
              color: Colors.white,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 32),
          
          Text(
            successCount == total ? 'All Emails Sent!' : 'Emails Sent',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  total.toString(),
                  Icons.email_outlined,
                  AppTheme.glowBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Success',
                  successCount.toString(),
                  Icons.check_circle_outline,
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Failed',
                  failedCount.toString(),
                  Icons.error_outline,
                  AppTheme.errorRed,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildDoneButton(),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassmorphicCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDoneButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [AppTheme.glowBlue, AppTheme.glowPurple]),
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
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Center(
            child: Text(
              'Done',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlack,
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
  
  Future<void> _handleSend(EmailProvider provider) async {
    final success = await provider.sendBulkEmails();
    
    if (!mounted) return;
    
    if (!success && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
