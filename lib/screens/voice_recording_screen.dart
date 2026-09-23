import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screening_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/waveform_visualizer.dart';

class VoiceRecordingScreen extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onProceedToAnalysis;

  const VoiceRecordingScreen({
    super.key,
    required this.onCancel,
    required this.onProceedToAnalysis,
  });

  @override
  State<VoiceRecordingScreen> createState() => _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends State<VoiceRecordingScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  final List<_MicParticle> _micParticles = [];
  final math.Random _random = math.Random(1337);

  @override
  void initState() {
    super.initState();
    // Continuous drifting minimal animation matching Home screen background
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // 16 minimal floating scientific nodes inside the mic circle
    for (int i = 0; i < 16; i++) {
      _micParticles.add(
        _MicParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 1.8 + 1.2,
          speed: _random.nextDouble() * 0.35 + 0.15,
          angle: _random.nextDouble() * 2 * math.pi,
          opacity: _random.nextDouble() * 0.4 + 0.2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ScreeningSessionProvider>();
    final isRecording = session.recordingState == RecordingState.recording;
    final isCompleted = session.recordingState == RecordingState.completed;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top navigation indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.onSurfaceVariant,
                    onPressed: widget.onCancel,
                    tooltip: "Cancel",
                  ),
                  Text(
                    "STEP 1 OF 3",
                    style: AppTypography.labelSm.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance back button
                ],
              ),

              const SizedBox(height: 16),

              // Recording Card Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: Column(
                  children: [
                    // Digital Timer
                    Text(
                      _formatTimer(session.recordedSeconds),
                      style: AppTypography.displayMetric.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Large Circular Mic Display (NOT TAPPABLE - recording only triggered via button)
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRecording
                            ? AppColors.primaryContainer.withValues(alpha: 0.06)
                            : AppColors.surfaceContainerLow,
                        border: Border.all(
                          color: isRecording
                              ? AppColors.primaryContainer
                              : AppColors.borderSubtle,
                          width: isRecording ? 2.5 : 1.2,
                        ),
                      ),
                      child: ClipOval(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Minimal Scientific Particle Canvas inside mic circle (like Home screen background)
                            AnimatedBuilder(
                              animation: _particleController,
                              builder: (context, _) {
                                return CustomPaint(
                                  size: const Size(130, 130),
                                  painter: _MicParticlePainter(
                                    particles: _micParticles,
                                    progress: _particleController.value,
                                    isRecording: isRecording,
                                    pulse: _pulseController.value,
                                  ),
                                );
                              },
                            ),

                            // Mic Icon centered over minimal animation
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                final double iconScale = isRecording
                                    ? 1.0 + (_pulseController.value * 0.10)
                                    : 1.0;

                                return Transform.scale(
                                  scale: iconScale,
                                  child: Icon(
                                    isRecording
                                        ? Icons.mic
                                        : (isCompleted
                                            ? Icons.check_rounded
                                            : Icons.mic_none_outlined),
                                    size: 46,
                                    color: isRecording
                                        ? AppColors.primaryContainer
                                        : (isCompleted
                                            ? AppColors.statusGreen
                                            : AppColors.onSurfaceVariant),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Animated Waveform Visualizer
                    AnimatedWaveformVisualizer(
                      isRecording: isRecording,
                      barCount: 22,
                    ),

                    const SizedBox(height: 20),

                    // Instructions & Real-time Progress
                    Column(
                      children: [
                        Text(
                          isRecording
                              ? (session.recordedSeconds < 5
                                  ? "Sustain 'Aaaah...' steadily (${session.recordedSeconds}s · min 5s needed)"
                                  : "Good! Continue holding (${session.recordedSeconds}s / max 10s)")
                              : (isCompleted
                                  ? "Voice sample captured (${session.recordedSeconds}.0s)"
                                  : "Take a deep breath and sustain the vowel sound 'Aaaah...' for 5 to 10 seconds."),
                          style: AppTypography.bodyMd.copyWith(
                            color: isRecording && session.recordedSeconds >= 5
                                ? AppColors.statusGreen
                                : AppColors.onSurface,
                            fontWeight: isRecording ? FontWeight.w600 : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (session.recordingError != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.statusRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.statusRed.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: AppColors.statusRed),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    session.recordingError!,
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.statusRed,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Minimal Model Selector (Choose from 4 pre-trained models)
                    _buildMinimalModelSelector(session),

                    const SizedBox(height: 24),

                    // Action Button (Exclusive trigger for recording)
                    if (!isCompleted)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isRecording) {
                              session.stopRecording();
                            } else {
                              session.startRecording();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRecording
                                ? AppColors.statusRed
                                : AppColors.primaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isRecording ? Icons.stop_rounded : Icons.fiber_manual_record,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRecording ? "Stop recording" : "Start recording",
                                style: AppTypography.bodyMdMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onProceedToAnalysis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Proceed to analysis",
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
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => session.resetRecording(),
                        child: Text(
                          "Retake sample",
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalModelSelector(ScreeningSessionProvider session) {
    final bool isRecording = session.recordingState == RecordingState.recording;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black26, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.memory_rounded,
                size: 13,
                color: Colors.black87,
              ),
              const SizedBox(width: 5),
              Text(
                "Select model",
                style: AppTypography.labelSm.copyWith(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(ScreeningSessionProvider.availableModels.length, (index) {
              final model = ScreeningSessionProvider.availableModels[index];
              final isSelected = session.selectedModelIndex == index;
              return InkWell(
                onTap: isRecording ? null : () => session.setSelectedModelIndex(index),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        model["name"]!,
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}


class _MicParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double angle;
  final double opacity;

  _MicParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.opacity,
  });
}

class _MicParticlePainter extends CustomPainter {
  final List<_MicParticle> particles;
  final double progress;
  final bool isRecording;
  final double pulse;

  _MicParticlePainter({
    required this.particles,
    required this.progress,
    required this.isRecording,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final List<Offset> positions = [];
    final double intensity = isRecording ? 1.5 : 0.8;

    for (final p in particles) {
      final double currentX = (p.x + math.cos(p.angle) * p.speed * progress) % 1.0;
      final double currentY = (p.y + math.sin(p.angle) * p.speed * progress) % 1.0;
      final pos = Offset(currentX * size.width, currentY * size.height);
      positions.add(pos);

      dotPaint.color = AppColors.primaryContainer.withValues(
        alpha: (p.opacity * 0.45 * intensity).clamp(0.0, 1.0),
      );
      canvas.drawCircle(pos, p.radius, dotPaint);
    }

    // Connect close particles with subtle hairline lines (identical to Home background)
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final dist = (positions[i] - positions[j]).distance;
        if (dist < 40) {
          linePaint.color = AppColors.primaryContainer.withValues(
            alpha: ((1.0 - dist / 40) * 0.12 * intensity).clamp(0.0, 1.0),
          );
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MicParticlePainter oldDelegate) => true;
}
