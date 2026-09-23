import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screening_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/waveform_visualizer.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final VoidCallback onBack;

  const AnalysisDetailScreen({super.key, required this.onBack});

  String _formatTime(double seconds) {
    final int totalSec = seconds.toInt();
    final int m = totalSec ~/ 60;
    final int s = totalSec % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ScreeningSessionProvider>();
    final double audioProgress = (session.audioPosition / session.audioTotalDuration).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.onSurfaceVariant,
                      onPressed: () {
                        session.stopAudioPlayback();
                        onBack();
                      },
                      tooltip: "Back to Results",
                    ),
                    Text(
                      "REPORT #${session.activeSessionId}",
                      style: AppTypography.labelSm.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 12),

                // Audio Playback Section Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Session Audio", style: AppTypography.headlineMd.copyWith(fontSize: 18)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${_formatTime(session.audioPosition)} / ${_formatTime(session.audioTotalDuration)}",
                              style: AppTypography.labelSmBold.copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Interactive Waveform player
                      InteractiveAudioWaveform(
                        currentProgress: audioProgress,
                        onSeek: (progress) {
                          session.seekAudio(progress * session.audioTotalDuration);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Audio Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.skip_previous_rounded),
                            color: AppColors.onSurfaceVariant,
                            onPressed: () => session.seekAudio(0.0),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => session.toggleAudioPlayback(),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                session.isPlayingAudio
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded),
                            color: AppColors.onSurfaceVariant,
                            onPressed: () => session.seekAudio(session.audioTotalDuration),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Analysis Detail",
                  style: AppTypography.displayMetric.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 16),

                // Grid of Findings: Clinical Sentiment & Acoustic Metrics
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 580;

                    final clinicalSentimentCard = Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CLINICAL SENTIMENT",
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 11,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSentimentRow(
                            label: "Vocal Stability",
                            badgeText: session.vocalStability,
                            badgeBg: AppColors.primaryLight.withValues(alpha: 0.6),
                            badgeColor: AppColors.primaryContainer,
                          ),
                          const Divider(color: AppColors.borderSubtle, height: 20),
                          _buildSentimentRow(
                            label: "Tremor Incidence",
                            badgeText: session.tremorIncidence,
                            badgeBg: AppColors.statusRedLight.withValues(alpha: 0.8),
                            badgeColor: AppColors.statusRed,
                          ),
                          const Divider(color: AppColors.borderSubtle, height: 20),
                          _buildSentimentRow(
                            label: "Articulation Rate",
                            badgeText: session.articulationRate,
                            badgeBg: AppColors.surfaceContainer,
                            badgeColor: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    );

                    final acousticMetricsCard = Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ACOUSTIC METRICS",
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 11,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMetricBar(
                            label: "Jitter (local)",
                            valueStr: "${session.jitterValue}%",
                            fillFraction: 0.40,
                          ),
                          const Divider(color: AppColors.borderSubtle, height: 24),
                          _buildMetricBar(
                            label: "Shimmer (local)",
                            valueStr: "${session.shimmerValue}%",
                            fillFraction: 0.65,
                          ),
                        ],
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: clinicalSentimentCard),
                          const SizedBox(width: 16),
                          Expanded(child: acousticMetricsCard),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          clinicalSentimentCard,
                          const SizedBox(height: 16),
                          acousticMetricsCard,
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Model Rationale Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "MODEL RATIONALE",
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        session.modelRationale,
                        style: AppTypography.bodyLg.copyWith(
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60), // Spacing for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSentimentRow({
    required String label,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMdMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            badgeText,
            style: AppTypography.labelSmBold.copyWith(
              color: badgeColor,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBar({
    required String label,
    required String valueStr,
    required double fillFraction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.labelSm),
            Text(valueStr, style: AppTypography.metricSm.copyWith(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fillFraction,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
