import 'dart:math';
import 'package:flutter/material.dart';

/// GB Confetti Animation Widget
///
/// Displays an animated confetti celebration effect.
/// Perfect for milestone achievements, successful actions, and celebrations.
///
/// Example usage:
/// ```dart
/// // Show confetti
/// GBConfetti.show(context);
///
/// // Show with custom configuration
/// GBConfetti.show(
///   context,
///   particleCount: 100,
///   duration: Duration(seconds: 3),
/// );
/// ```
class GBConfetti {
  /// Show confetti animation as an overlay
  static void show(
    BuildContext context, {
    int particleCount = 50,
    Duration duration = const Duration(seconds: 2),
    List<Color>? colors,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => GBConfettiWidget(
        particleCount: particleCount,
        duration: duration,
        colors: colors,
      ),
    );

    overlay.insert(overlayEntry);

    // Remove overlay after animation completes
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }
}

/// Confetti Widget
class GBConfettiWidget extends StatefulWidget {
  final int particleCount;
  final Duration duration;
  final List<Color>? colors;

  const GBConfettiWidget({
    Key? key,
    required this.particleCount,
    required this.duration,
    this.colors,
  }) : super(key: key);

  @override
  State<GBConfettiWidget> createState() => _GBConfettiWidgetState();
}

class _GBConfettiWidgetState extends State<GBConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _particles = List.generate(
      widget.particleCount,
      (index) => ConfettiParticle(
        colors: widget.colors ??
            [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.orange,
              Colors.purple,
              Colors.pink,
              Colors.cyan,
            ],
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

/// Confetti Particle Model
class ConfettiParticle {
  late final double x;
  late final double y;
  late final double velocityX;
  late final double velocityY;
  late final Color color;
  late final double size;
  late final double rotationSpeed;
  late double rotation;

  ConfettiParticle({required List<Color> colors}) {
    final random = Random();

    // Start from top center, spread horizontally
    x = 0.5 + (random.nextDouble() - 0.5) * 0.3; // Center ±15%
    y = 0.0; // Start from top

    // Velocity - spread outward and downward
    velocityX = (random.nextDouble() - 0.5) * 2.0; // -1.0 to 1.0
    velocityY = random.nextDouble() * 0.5 + 0.3; // 0.3 to 0.8 (downward)

    color = colors[random.nextInt(colors.length)];
    size = random.nextDouble() * 8 + 4; // 4-12px
    rotationSpeed = (random.nextDouble() - 0.5) * 4; // Rotation speed
    rotation = random.nextDouble() * 2 * pi;
  }

  void update(double progress) {
    rotation += rotationSpeed * 0.1;
  }
}

/// Confetti Painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(progress);

      // Calculate position based on progress
      final x = particle.x * size.width +
          (particle.velocityX * size.width * progress);
      final y = particle.y * size.height +
          (particle.velocityY * size.height * progress);

      // Fade out near the end
      final opacity = progress < 0.7 ? 1.0 : (1.0 - (progress - 0.7) / 0.3);

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Save canvas state
      canvas.save();

      // Translate to particle position
      canvas.translate(x, y);

      // Rotate
      canvas.rotate(particle.rotation);

      // Draw confetti shape (rectangle)
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size / 2,
      );
      canvas.drawRect(rect, paint);

      // Restore canvas state
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Confetti Controller for manual control
class GBConfettiController {
  OverlayEntry? _overlayEntry;

  void show(
    BuildContext context, {
    int particleCount = 50,
    Duration duration = const Duration(seconds: 2),
    List<Color>? colors,
  }) {
    // Remove existing confetti if any
    hide();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => GBConfettiWidget(
        particleCount: particleCount,
        duration: duration,
        colors: colors,
      ),
    );

    overlay.insert(_overlayEntry!);

    // Auto-remove after duration
    Future.delayed(duration, () {
      hide();
    });
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void dispose() {
    hide();
  }
}
