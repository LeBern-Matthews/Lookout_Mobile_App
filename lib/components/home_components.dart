import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'calling_button.dart';

// ─── Shared card wrapper ────────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  final Widget child;
  final Color bg;
  final List<BoxShadow> shadows;

  const AppCard({super.key, required this.child, required this.bg, required this.shadows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

// ─── Circular gauge ─────────────────────────────────────────────────────────

class CircularGauge extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final Color onSurface;

  const CircularGauge({
    super.key,
    required this.progress,
    required this.color,
    required this.size,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: GaugePainter(progress: progress, color: color, onSurface: onSurface),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'prepared',
                style: TextStyle(
                  fontSize: 12,
                  color: onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color onSurface;

  GaugePainter({required this.progress, required this.color, required this.onSurface});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final bgPaint = Paint()
      ..color = onSurface.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GaugePainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Emergency row ───────────────────────────────────────────────────────────

class EmergencyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final Color iconColor;
  final String callee;

  const EmergencyRow({
    super.key,
    required this.icon,
    required this.label,
    required this.number,
    required this.iconColor,
    required this.callee,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              Text(
                number.isEmpty ? 'Not available' : number,
                style: TextStyle(
                    fontSize: 14, color: onSurface.withValues(alpha: 0.65)),
              ),
            ],
          ),
        ),
        CallingButton(phoneNumber: number, callee: callee),
      ],
    );
  }
}

// ─── Quick action card ───────────────────────────────────────────────────────

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Color bg;
  final List<BoxShadow> shadows;
  final Color onSurface;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.bg,
    required this.shadows,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: shadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 12, color: onSurface.withValues(alpha: 0.45))),
          ],
        ),
      ),
    );
  }
}

// ─── Animations ──────────────────────────────────────────────────────────────

class PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const PulsingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 26,
  });

  @override
  State<PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Icon(
              widget.icon,
              color: widget.color,
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}
