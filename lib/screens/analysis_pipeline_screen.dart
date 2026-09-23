import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screening_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AnalysisPipelineScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onComplete;

  const AnalysisPipelineScreen({
    super.key,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  State<AnalysisPipelineScreen> createState() => _AnalysisPipelineScreenState();
}

class _AnalysisPipelineScreenState extends State<AnalysisPipelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<ScreeningSessionProvider>();
      session.startPipelineAnalysis(onComplete: () {
        if (mounted) {
          // Automatic transition directly to results
          widget.onComplete();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ScreeningSessionProvider>();
    final int percent = (session.pipelineProgress * 100).toInt();
    final bool isDone = session.pipelineStage == PipelineStage.complete;
    final String modelName = session.selectedModelDisplayName;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Cancel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      session.cancelPipeline();
                      widget.onCancel();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back, size: 18, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text("Cancel Analysis", style: AppTypography.labelSm),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "PROCESSING",
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text("Analyzing Voice Sample", style: AppTypography.headlineLg),
              const SizedBox(height: 4),
              Text(
                "Streaming acoustic data to FastAPI backend with $modelName inference.",
                style: AppTypography.bodyMd,
              ),

              const SizedBox(height: 20),

              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: session.pipelineProgress,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryContainer,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 44,
                    child: Text(
                      "$percent%",
                      style: AppTypography.labelSmBold.copyWith(
                        color: AppColors.primaryContainer,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Real-Time Execution Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "REAL-TIME EXECUTION STATUS",
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 11,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          modelName,
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 11,
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Stage 1
                    _buildCheckItem(
                      title: "Audio Captured & Validated",
                      subtitle: "${session.recordedSeconds >= 5 ? session.recordedSeconds : 10}.0s sustained vowel · 16 kHz mono",
                      isFinished: session.pipelineProgress >= 0.20,
                      isInProgress: session.pipelineProgress < 0.20,
                    ),
                    _buildConnectorLine(),

                    // Stage 2
                    _buildCheckItem(
                      title: "Silence Trimming & YIN Pitch Tracking",
                      subtitle: "Trimming top 25dB & extracting fundamental frequencies",
                      isFinished: session.pipelineProgress >= 0.50,
                      isInProgress: session.pipelineProgress >= 0.20 && session.pipelineProgress < 0.50,
                    ),
                    _buildConnectorLine(),

                    // Stage 3
                    _buildCheckItem(
                      title: "Feature Extraction (MFCC & Dysphonia)",
                      subtitle: "13 MFCC coefficients, Jitter, Shimmer, & HNR via Praat",
                      isFinished: session.pipelineProgress >= 0.75,
                      isInProgress: session.pipelineProgress >= 0.50 && session.pipelineProgress < 0.75,
                    ),
                    _buildConnectorLine(),

                    // Stage 4
                    _buildCheckItem(
                      title: "Neural Model Inference",
                      subtitle: session.pipelineProgress >= 0.92
                          ? "Inference completed via $modelName"
                          : "Evaluating 8 scaled biomarkers through $modelName...",
                      isFinished: session.pipelineProgress >= 0.92,
                      isInProgress: session.pipelineProgress >= 0.75 && session.pipelineProgress < 0.92,
                    ),
                    _buildConnectorLine(),

                    // Stage 5
                    _buildCheckItem(
                      title: "Result Aggregation & Risk Scoring",
                      subtitle: isDone
                          ? "Screening verified · Opening results..."
                          : "Calibrating probability confidence intervals",
                      isFinished: isDone,
                      isInProgress: session.pipelineProgress >= 0.92 && !isDone,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Abort Button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    session.cancelPipeline();
                    widget.onCancel();
                  },
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.statusRed),
                  label: Text(
                    "Abort Analysis",
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.statusRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem({
    required String title,
    required String subtitle,
    required bool isFinished,
    required bool isInProgress,
    bool isLast = false,
  }) {
    Color iconColor;
    IconData icon;

    if (isFinished) {
      iconColor = AppColors.statusGreen;
      icon = Icons.check_circle_rounded;
    } else if (isInProgress) {
      iconColor = AppColors.primaryContainer;
      icon = Icons.radio_button_checked_rounded;
    } else {
      iconColor = AppColors.borderSubtle;
      icon = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMdMedium.copyWith(
                  color: isFinished || isInProgress
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                  fontWeight: isFinished || isInProgress ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.labelSm.copyWith(
                  color: isInProgress
                      ? AppColors.primaryContainer
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine() {
    return Container(
      margin: const EdgeInsets.only(left: 9),
      width: 2,
      height: 18,
      color: AppColors.borderSubtle,
    );
  }
}
