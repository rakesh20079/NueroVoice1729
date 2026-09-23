import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AnimatedWaveformVisualizer extends StatefulWidget {
  final bool isRecording;
  final int barCount;

  const AnimatedWaveformVisualizer({
    super.key,
    required this.isRecording,
    this.barCount = 14,
  });

  @override
  State<AnimatedWaveformVisualizer> createState() =>
      _AnimatedWaveformVisualizerState();
}

class _AnimatedWaveformVisualizerState extends State<AnimatedWaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              double height;
              if (widget.isRecording) {
                final double phase = (index / widget.barCount) * math.pi * 2;
                final double wave = math.sin(_controller.value * math.pi * 2 + phase);
                final double factor = 0.3 + 0.7 * wave.abs();
                height = 6.0 + factor * 28.0;
              } else {
                // Resting state subtle bars
                height = 4.0 + (index % 3) * 2.0;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 3.5,
                height: height,
                decoration: BoxDecoration(
                  color: widget.isRecording
                      ? AppColors.primaryContainer
                      : AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class InteractiveAudioWaveform extends StatelessWidget {
  final double currentProgress; // 0.0 to 1.0
  final ValueChanged<double>? onSeek;

  const InteractiveAudioWaveform({
    super.key,
    required this.currentProgress,
    this.onSeek,
  });

  // Predefined normalized audio sample bar heights
  static const List<double> barRatios = [
    0.2, 0.4, 0.7, 0.5, 0.8, 0.9, 0.6, 0.3, 0.7, 0.85,
    0.6, 0.4, 0.75, 0.95, 0.8, 0.5, 0.4, 0.65, 0.7, 0.85,
    0.9, 0.7, 0.5, 0.35, 0.6, 0.8, 0.9, 0.65, 0.4, 0.25,
    0.5, 0.75, 0.85, 0.6, 0.4, 0.7, 0.8, 0.65, 0.35, 0.2,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalBars = barRatios.length;
        final barWidth = (constraints.maxWidth - (totalBars * 2.5)) / totalBars;

        return GestureDetector(
          onTapDown: (details) {
            if (onSeek != null && constraints.maxWidth > 0) {
              final tapX = details.localPosition.dx.clamp(0.0, constraints.maxWidth);
              onSeek!(tapX / constraints.maxWidth);
            }
          },
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Waveform bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(totalBars, (i) {
                    final isPassed = (i / totalBars) <= currentProgress;
                    final height = barRatios[i] * 56.0;

                    return Container(
                      width: math.max(2.0, barWidth),
                      height: height,
                      decoration: BoxDecoration(
                        color: isPassed
                            ? AppColors.primaryContainer
                            : AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    );
                  }),
                ),
                // Playhead indicator needle
                Positioned(
                  left: (constraints.maxWidth - 16) * currentProgress,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
