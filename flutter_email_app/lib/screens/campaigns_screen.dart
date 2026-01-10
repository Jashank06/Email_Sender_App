import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/tracking_provider.dart';
import '../providers/email_provider.dart';
import '../models/campaign_model.dart';
import '../utils/theme.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_button.dart';
import 'send_email_screen.dart';
import 'campaign_detail_screen.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().loadCampaigns();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: AnimatedBackground(
        child: Column(
          children: [
            // Custom App Bar
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const Text(
                      'CAMPAIGNS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        onPressed: () {
                          context.read<TrackingProvider>().loadCampaigns();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: Consumer<TrackingProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingCampaigns) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (provider.campaignsError != null) {
                    return Center(
                      child: GlassmorphicCard(
                        borderRadius: 24,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.white),
                              const SizedBox(height: 20),
                              const Text(
                                'ERROR LOADING DATA',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                provider.campaignsError!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.accentWhite.withOpacity(0.4),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              AnimatedButton(
                                onPressed: () => provider.loadCampaigns(),
                                text: 'RETRY',
                                icon: Icons.refresh_rounded,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (provider.campaigns.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 24),
                          const Text(
                            'NO CAMPAIGNS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white30,
                              letterSpacing: 3.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'SEND YOUR FIRST EMAIL STATION DISPATCH',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => provider.loadCampaigns(),
                    color: Colors.white,
                    backgroundColor: Colors.black,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: provider.campaigns.length,
                      itemBuilder: (context, index) {
                        final campaign = provider.campaigns[index];
                        return _CampaignCard(campaign: campaign);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const _CampaignCard({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassmorphicCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailScreen(campaignId: campaign.id),
            ),
          );
        },
        borderRadius: 24,
        blur: 20,
        opacity: 0.05,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campaign.subject.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.alternate_email_rounded, size: 14, color: Colors.white.withOpacity(0.4)),
                            const SizedBox(width: 6),
                            Text(
                              campaign.senderEmail,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.accentWhite.withOpacity(0.4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(status: campaign.status),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StatItem(label: 'SENT', value: '${campaign.sentCount}', total: campaign.totalEmails.toString(), icon: Icons.send_rounded)),
                        Container(height: 30, width: 1, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(width: 16),
                        Expanded(child: _StatItem(label: 'OPENS', value: '${campaign.openedCount}', percentage: '${campaign.openRate}%', icon: Icons.visibility_rounded)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _StatItem(label: 'CLICKS', value: '${campaign.clickedCount}', percentage: '${campaign.clickRate}%', icon: Icons.touch_app_rounded)),
                        Container(height: 30, width: 1, color: Colors.white.withOpacity(0.1)),
                        const SizedBox(width: 16),
                        Expanded(child: _StatItem(label: 'FAILED', value: '${campaign.failedCount}', labelColor: campaign.failedCount > 0 ? Colors.white60 : null, icon: Icons.error_outline_rounded)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 14, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy · HH:mm').format(campaign.createdAt).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentWhite.withOpacity(0.2),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.1), size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white;
    String label = status.toUpperCase();

    switch (status) {
      case 'completed':
        color = Colors.white;
        label = 'COMPLETED';
        break;
      case 'sending':
        color = Colors.white.withOpacity(0.7);
        label = 'SENDING';
        break;
      case 'failed':
        color = Colors.white.withOpacity(0.5);
        label = 'FAILED';
        break;
      default:
        color = Colors.white.withOpacity(0.3);
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? total;
  final String? percentage;
  final Color? labelColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.total,
    this.percentage,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.white.withOpacity(0.3)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: labelColor ?? AppTheme.accentWhite.withOpacity(0.3),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            if (total != null) ...[
              const SizedBox(width: 4),
              Text(
                '/ $total',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white30,
                ),
              ),
            ],
            if (percentage != null) ...[
              const SizedBox(width: 6),
              Text(
                percentage!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white30,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
