import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../models/email_event_model.dart';
import '../utils/theme.dart';
import 'glassmorphic_card.dart';

class ProgressCard extends StatelessWidget {
  final EmailProgress progress;

  const ProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      borderRadius: 32,
      blur: 30,
      opacity: 0.08,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(
                    Icons.sensors_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DISPATCH ACTIVE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'MISSION IN PROGRESS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Progress Bar & Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${progress.percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${progress.sent} / ${progress.total} NODES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.3),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        color: Colors.white.withOpacity(0.05),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 6,
                        width: (MediaQuery.of(context).size.width - 128) * (progress.percentage / 100),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Statistics Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    label: 'VERIFIED',
                    value: progress.sent.toString(),
                    icon: Icons.verified_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    label: 'FAILED',
                    value: progress.failed.toString(),
                    icon: Icons.gpp_bad_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Time & Meta Data
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _buildMetaRow('ELAPSED TIME', progress.formattedElapsedTime),
                  const SizedBox(height: 12),
                  _buildMetaRow('ESTIMATED REMAINING', progress.formattedEstimatedTime),
                  const SizedBox(height: 12),
                  _buildMetaRow('TRANSMISSION RATE', '${progress.emailsPerMinute.toStringAsFixed(1)} NODES/MIN'),
                ],
              ),
            ),

            if (progress.currentEmail != null) ...[
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'LINKING: ${progress.currentEmail!.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withOpacity(0.15),
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 3.seconds, color: Colors.white.withOpacity(0.03));
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white30),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(0.2),
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.2),
            letterSpacing: 1.0,
          ),
        ),
        Text(
          value.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
