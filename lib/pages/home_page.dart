import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/checklist_provider.dart';
import '../services/country_provider.dart';
import '../components/calling_button.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;
  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnimation;
  double _lastProgress = 0.0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _animateTo(double newProgress) {
    if ((newProgress - _lastProgress).abs() > 0.001) {
      _progressAnimation = Tween<double>(
        begin: _lastProgress,
        end: newProgress,
      ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
      _animController.forward(from: 0);
      _lastProgress = newProgress;
    }
  }

  String _readinessLabel(double p) {
    if (p == 0) return "Let's get started!";
    if (p <= 0.25) return "Just getting started";
    if (p <= 0.50) return "Making progress!";
    if (p <= 0.75) return "Looking good!";
    if (p < 1.0) return "Almost there!";
    return "Fully prepared! 🎉";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final checklist = context.watch<ChecklistProvider>();
    final countryP = context.watch<CountryProvider>();

    _animateTo(checklist.progress);

    final isLight = Theme.of(context).brightness == Brightness.light;
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isLight ? Colors.white : const Color(0xFF1A1A2E);
    final cardShadow = isLight
        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 3))]
        : [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 3))];

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, color: primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'LOOKOUT',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Readiness gauge ──────────────────────────────────────────
            _AppCard(
              bg: cardBg,
              shadows: cardShadow,
              child: Column(
                children: [
                  Text(
                    'READINESS SCORE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (_, __) => _CircularGauge(
                      progress: _progressAnimation.value,
                      color: checklist.colour,
                      size: 170,
                      onSurface: onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _readinessLabel(checklist.progress),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: checklist.colour,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${checklist.checkedCount} of ${checklist.totalCount} items complete',
                    style: TextStyle(
                      fontSize: 13,
                      color: onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Next step ────────────────────────────────────────────────
            _AppCard(
              bg: cardBg,
              shadows: cardShadow,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_circle_right_rounded,
                        color: primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: checklist.nextUncheckedItem != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NEXT STEP',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.3,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                checklist.nextUncheckedItem!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: onSurface,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ALL DONE!',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.3,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                "You're fully prepared! 🎉",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigate?.call(1),
                    child: const Text('View →'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Emergency numbers ────────────────────────────────────────
            _AppCard(
              bg: cardBg,
              shadows: cardShadow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency_rounded,
                          color: Colors.red.shade400, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'EMERGENCY NUMBERS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    countryP.country == 'Country'
                        ? 'Set your country in Settings'
                        : countryP.country,
                    style: TextStyle(
                        fontSize: 12, color: onSurface.withValues(alpha: 0.45)),
                  ),
                  Divider(height: 20, color: onSurface.withValues(alpha: 0.1)),
                  _EmergencyRow(
                    icon: Icons.local_police_rounded,
                    label: 'Police',
                    number: countryP.primaryPolice,
                    iconColor: const Color(0xFF1F74DF),
                    callee: 'Police',
                  ),
                  const SizedBox(height: 12),
                  _EmergencyRow(
                    icon: Icons.local_hospital_rounded,
                    label: 'Ambulance',
                    number: countryP.primaryAmbulance,
                    iconColor: Colors.red,
                    callee: 'Ambulance',
                  ),
                  const SizedBox(height: 12),
                  _EmergencyRow(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Fire Dept.',
                    number: countryP.primaryFire,
                    iconColor: Colors.orange.shade700,
                    callee: 'Fire',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Quick actions ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.checklist_sharp,
                    label: 'Checklist',
                    subtitle: '${checklist.checkedCount}/${checklist.totalCount} done',
                    color: primary,
                    onTap: () => widget.onNavigate?.call(1),
                    bg: cardBg,
                    shadows: cardShadow,
                    onSurface: onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.contact_emergency_rounded,
                    label: 'Contacts',
                    subtitle: 'Emergency numbers',
                    color: Colors.red.shade400,
                    onTap: () => widget.onNavigate?.call(2),
                    bg: cardBg,
                    shadows: cardShadow,
                    onSurface: onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared card wrapper ────────────────────────────────────────────────────

class _AppCard extends StatelessWidget {
  final Widget child;
  final Color bg;
  final List<BoxShadow> shadows;

  const _AppCard({required this.child, required this.bg, required this.shadows});

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

class _CircularGauge extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final Color onSurface;

  const _CircularGauge({
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
            painter: _GaugePainter(progress: progress, color: color, onSurface: onSurface),
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

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color onSurface;

  _GaugePainter({required this.progress, required this.color, required this.onSurface});

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
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Emergency row ───────────────────────────────────────────────────────────

class _EmergencyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final Color iconColor;
  final String callee;

  const _EmergencyRow({
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Color bg;
  final List<BoxShadow> shadows;
  final Color onSurface;

  const _QuickAction({
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