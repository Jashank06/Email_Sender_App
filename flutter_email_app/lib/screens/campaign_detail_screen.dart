import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_background.dart';
import '../providers/tracking_provider.dart';

class CampaignDetailScreen extends StatefulWidget {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  TrackingProvider? _trackingProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _trackingProvider = context.read<TrackingProvider>();
        _trackingProvider!.initializeWebSocket();
        _trackingProvider!.loadCampaignDetails(widget.campaignId);
        _trackingProvider!.subscribeToCampaign(widget.campaignId);
      }
    });
  }

  @override
  void dispose() {
    _trackingProvider?.unsubscribeFromCampaign(widget.campaignId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: AnimatedBackground(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
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
              ),
              title: Text(
                'DISPATCH INTEL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              centerTitle: true,
            ),
          ],
          body: Consumer<TrackingProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingDetails) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                );
              }

              if (provider.detailsError != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gpp_maybe_rounded, size: 64, color: Colors.white24),
                      const SizedBox(height: 24),
                      Text(
                        'PROTOCOL FAILURE',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.detailsError!.toUpperCase(),
                        style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w700, letterSpacing: 1.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final details = provider.selectedCampaignDetails;
              if (details == null) {
                return Center(
                  child: Text(
                    'DATA NOT ACQUIRED',
                    style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campaign Info Card
                    _buildInfoCard(details),
                    const SizedBox(height: 32),
                    
                    // Statistics Grid
                    _buildStatsGrid(details),
                    const SizedBox(height: 40),
                    
                    // Events List
                    _buildEventsList(provider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(details) {
    return GlassmorphicCard(
      borderRadius: 24,
      blur: 20,
      opacity: 0.08,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Text(
                'ACTIVE DISPATCH',
                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              details.campaign.subject.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.hub_rounded, color: Colors.white24, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'NODE: ${details.campaign.senderName.toUpperCase()} <${details.campaign.senderEmail.toUpperCase()}>',
                    style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w800, letterSpacing: 1.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatsGrid(details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRANSMISSION METRICS',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 2.0),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildStatCard('PACKETS SENT', '${details.stats.sent}', Icons.sensors_rounded),
            _buildStatCard('NODE ACCESS', '${details.stats.openRate}%', Icons.verified_rounded),
            _buildStatCard('LINK BREACH', '${details.stats.clickRate}%', Icons.ads_click_rounded),
            _buildStatCard('DROPPED', '${details.stats.failed}', Icons.gpp_bad_rounded),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassmorphicCard(
      borderRadius: 20,
      opacity: 0.05,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.3), letterSpacing: 1.0),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(TrackingProvider provider) {
    if (provider.campaignEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REAL-TIME LOG',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white24, letterSpacing: 2.0),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.campaignEvents.length > 10 ? 10 : provider.campaignEvents.length,
          itemBuilder: (context, index) {
            final event = provider.campaignEvents[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text(event.statusIcon, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.recipientEmail.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.statusLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withOpacity(0.2),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (event.openCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        '${event.openCount} ACCESS',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
