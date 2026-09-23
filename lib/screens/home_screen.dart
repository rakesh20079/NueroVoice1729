import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/particle_canvas.dart';
import 'benchmark_report_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onStartScreening;

  const HomeScreen({
    super.key,
    required this.onStartScreening,
  });

  void _openBenchmarkReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BenchmarkReportScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScientificParticleCanvas(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1729 Labs Sovereign Minimal Header Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "1729 LABS",
                        style: AppTypography.labelSmBold.copyWith(
                          letterSpacing: 1.4,
                          fontSize: 10.5,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Hero Clinical Screening Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Scientific minimal icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          size: 28,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Parkinson's voice screening",
                        style: AppTypography.displayMetric,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Clinical-grade voice biomarker analysis powered by hybrid quantum machine learning.",
                        style: AppTypography.bodyLg,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),
                      ElevatedButton(
                        onPressed: onStartScreening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.12),
                          foregroundColor: AppColors.primaryContainer,
                          elevation: 0,
                          side: BorderSide(
                            color: AppColors.primaryContainer.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Start screening",
                              style: AppTypography.bodyLg.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: AppColors.primaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Benchmark & Training Report Card
                InkWell(
                  onTap: () => _openBenchmarkReport(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.borderSubtle,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            size: 22,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Benchmark & Training Report",
                                style: AppTypography.bodyMdMedium.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "V1 vs V2 metrics, 5-fold cross-val & PennyLane VQC",
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 11.5,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.primaryContainer,
                        ),
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
  }
}
