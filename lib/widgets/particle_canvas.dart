import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScientificParticleCanvas extends StatefulWidget {
  final Widget? child;
  final bool animate;

  const ScientificParticleCanvas({
    super.key,
    this.child,
    this.animate = true,
  });

  @override
  State<ScientificParticleCanvas> createState() => _ScientificParticleCanvasState();
}

class _ScientificParticleCanvasState extends State<ScientificParticleCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    for (int i = 0; i < 48; i++) {
      _particles.add(
        Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 2.5 + 1.2,
          speed: _random.nextDouble() * 0.4 + 0.1,
          angle: _random.nextDouble() * 2 * math.pi,
          opacity: _random.nextDouble() * 0.35 + 0.15,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.animate)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              );
            },
          )
        else
          CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress: 0.0,
            ),
            size: Size.infinite,
          ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double radius;
  double speed;
  double angle;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.angle,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = AppColors.primaryContainer.withValues(alpha: 0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final List<Offset> positions = [];

    for (final p in particles) {
      final double currentX = (p.x + math.cos(p.angle) * p.speed * progress) % 1.0;
      final double currentY = (p.y + math.sin(p.angle) * p.speed * progress) % 1.0;
      final pos = Offset(currentX * size.width, currentY * size.height);
      positions.add(pos);

      dotPaint.color = AppColors.primaryContainer.withValues(alpha: p.opacity * 0.6);
      canvas.drawCircle(pos, p.radius, dotPaint);
    }

    // Connect close particles with subtle scientific nodes
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final dist = (positions[i] - positions[j]).distance;
        if (dist < 70) {
          linePaint.color = AppColors.primaryContainer.withValues(
            alpha: (1.0 - dist / 70) * 0.08,
          );
          canvas.drawLine(positions[i], positions[j], linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
