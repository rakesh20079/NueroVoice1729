import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screening_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ScreeningResultScreen extends StatefulWidget {
  final VoidCallback onViewDetail;
  final VoidCallback onRetake;

  const ScreeningResultScreen({
    super.key,
    required this.onViewDetail,
    required this.onRetake,
  });

  @override
  State<ScreeningResultScreen> createState() => _ScreeningResultScreenState();
}

class _ScreeningResultScreenState extends State<ScreeningResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _confidenceAnim;

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final session = context.read<ScreeningSessionProvider>();
    _confidenceAnim = Tween<double>(begin: 0.0, end: session.confidenceScore).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOutCubic),
    );

    _counterController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = context.read<ScreeningSessionProvider>();
    if (_confidenceAnim.value != session.confidenceScore) {
      _confidenceAnim = Tween<double>(begin: 0.0, end: session.confidenceScore).animate(
        CurvedAnimation(parent: _counterController, curve: Curves.easeOutCubic),
      );
      _counterController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ScreeningSessionProvider>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.onSurfaceVariant,
                    onPressed: widget.onRetake,
                    tooltip: "Start New",
                  ),
                  Text(
                    "STEP 3 OF 3",
                    style: AppTypography.labelSm.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {
                      _counterController.reset();
                      _counterController.forward();
                    },
                    tooltip: "Replay",
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Hero Result Metric Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // Result Header Status
                    () {
                      Color riskColor;
                      final rLower = session.riskCategory.toLowerCase();
                      if (rLower.contains("high")) {
                        riskColor = AppColors.statusRed;
                      } else if (rLower.contains("mod")) {
                        riskColor = AppColors.statusAmber;
                      } else {
                        riskColor = AppColors.statusGreen;
                      }
                      return Text(
                        session.riskCategory,
                        style: AppTypography.displayMetric.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }(),
                    const SizedBox(height: 8),
                    // Animated Confidence Score
                    AnimatedBuilder(
                      animation: _confidenceAnim,
                      builder: (context, _) {
                        return Text(
                          "${_confidenceAnim.value.toStringAsFixed(1)}% confidence",
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Divider(color: AppColors.borderSubtle, height: 1),
              const SizedBox(height: 24),

              // Info Cards Bento (Grid / Flex)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 500;

                  final modelCard = Container(
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
                          children: [
                            const Icon(
                              Icons.memory,
                              size: 18,
                              color: AppColors.outline,
                            ),
                            const SizedBox(width: 8),
                            Text("Model used", style: AppTypography.headlineMd.copyWith(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primaryContainer.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            session.modelUsed,
                            style: AppTypography.labelSmBold.copyWith(
                              color: AppColors.primaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  final featuresCard = Container(
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
                          children: [
                            const Icon(
                              Icons.insights_rounded,
                              size: 18,
                              color: AppColors.outline,
                            ),
                            const SizedBox(width: 8),
                            Text("Key influencing features", style: AppTypography.headlineMd.copyWith(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            _buildFeatureMetricRow("1.", "Jitter (local)", "${session.jitterValue.toStringAsFixed(2)}%"),
                            const Divider(color: AppColors.borderSubtle, height: 16),
                            _buildFeatureMetricRow("2.", "Shimmer (apq3)", "${session.shimmerValue.toStringAsFixed(2)}%"),
                            const Divider(color: AppColors.borderSubtle, height: 16),
                            _buildFeatureMetricRow("3.", "Harmonic-to-Noise", "${session.selectedHistoryItem?.hnr?.toStringAsFixed(1) ?? "22.5"} dB"),
                          ],
                        ),
                      ],
                    ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: modelCard),
                        const SizedBox(width: 16),
                        Expanded(child: featuresCard),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        modelCard,
                        const SizedBox(height: 16),
                        featuresCard,
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 36),

              // Action Button
              ElevatedButton(
                onPressed: widget.onViewDetail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Detailed Explanation",
                      style: AppTypography.bodyMdMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onRetake,
                child: Text(
                  "Perform another screening",
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureMetricRow(String num, String name, String value) {
    return Row(
      children: [
        Text(
          num,
          style: AppTypography.bodyMdMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            style: AppTypography.bodyMdMedium,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMdMedium.copyWith(
            color: AppColors.primaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
