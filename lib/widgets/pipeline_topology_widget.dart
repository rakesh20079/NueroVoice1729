import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PipelineTopologyWidget extends StatefulWidget {
  final bool isProcessing;

  const PipelineTopologyWidget({
    super.key,
    this.isProcessing = true,
  });

  @override
  State<PipelineTopologyWidget> createState() => _PipelineTopologyWidgetState();
}

class _PipelineTopologyWidgetState extends State<PipelineTopologyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            "ARCHITECTURE TOPOLOGY",
            style: AppTypography.labelSm.copyWith(
              fontSize: 11,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 320,
              child: Column(
                children: [
                  // Root: Feature Extraction
                  _buildNodeBox(
                    icon: Icons.graphic_eq,
                    label: "Feature Extraction",
                    borderColor: AppColors.borderSubtle,
                    iconColor: AppColors.onSurface,
                  ),

                  // Vertical Line
                  _buildAnimatedVerticalLine(height: 24),

                  // Horizontal Splitter Bar
                  _buildHorizontalSplitter(width: 240),

                  // Dual Branches: Quantum & Classical
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Branch: Quantum
                      _buildBranchCard(
                        title: "Quantum Processing",
                        icon: Icons.memory,
                        accentColor: AppColors.primary,
                        pulseColor: AppColors.primaryContainer,
                        isQuantum: true,
                      ),
                      // Right Branch: Classical
                      _buildBranchCard(
                        title: "Classical Processing",
                        icon: Icons.analytics_outlined,
                        accentColor: AppColors.secondary,
                        pulseColor: AppColors.secondaryAccent,
                        isQuantum: false,
                      ),
                    ],
                  ),

                  // Converging lines
                  const SizedBox(height: 12),
                  _buildHorizontalSplitter(width: 240, isRejoin: true),
                  _buildAnimatedVerticalLine(height: 24, isFaded: true),

                  // Aggregation Node
                  _buildNodeBox(
                    icon: Icons.merge_type,
                    label: "Ensemble Inference",
                    borderColor: AppColors.borderSubtle,
                    iconColor: AppColors.onSurfaceVariant,
                    isDashed: true,
                    isFaded: !widget.isProcessing,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeBox({
    required IconData icon,
    required String label,
    required Color borderColor,
    required Color iconColor,
    bool isDashed = false,
    bool isFaded = false,
  }) {
    return Opacity(
      opacity: isFaded ? 0.6 : 1.0,
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodyMdMedium.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Color pulseColor,
    required bool isQuantum,
  }) {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Column(
              children: [
                Icon(icon, size: 22, color: accentColor),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AppTypography.labelSmBold.copyWith(
                    color: accentColor,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  final scale = 0.8 + 0.4 * _animController.value;
                  final opacity = (1.0 - _animController.value).clamp(0.2, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: pulseColor.withValues(alpha: opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                "Processing",
                style: AppTypography.labelSm.copyWith(
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedVerticalLine({required double height, bool isFaded = false}) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return SizedBox(
          height: height,
          width: 2,
          child: CustomPaint(
            painter: _DottedLinePainter(
              progress: _animController.value,
              isVertical: true,
              color: isFaded ? AppColors.outlineVariant : AppColors.primaryContainer,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalSplitter({required double width, bool isRejoin = false}) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return SizedBox(
          width: width,
          height: 12,
          child: CustomPaint(
            painter: _SplitterLinePainter(
              progress: _animController.value,
              color: isRejoin ? AppColors.outlineVariant : AppColors.primaryContainer,
            ),
          ),
        );
      },
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final double progress;
  final bool isVertical;
  final Color color;

  _DottedLinePainter({
    required this.progress,
    required this.isVertical,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    if (isVertical) {
      double startY = (progress * 8) % 8;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(size.width / 2, startY),
          Offset(size.width / 2, (startY + 4).clamp(0.0, size.height)),
          paint,
        );
        startY += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) => true;
}

class _SplitterLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SplitterLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final double midX = size.width / 2;
    // Top connection to center
    canvas.drawLine(Offset(midX, 0), Offset(midX, size.height / 2), paint);
    // Horizontal cross
    canvas.drawLine(Offset(10, size.height / 2), Offset(size.width - 10, size.height / 2), paint);
    // Left & Right droppers
    canvas.drawLine(Offset(10, size.height / 2), Offset(10, size.height), paint);
    canvas.drawLine(Offset(size.width - 10, size.height / 2), Offset(size.width - 10, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _SplitterLinePainter oldDelegate) => true;
}
