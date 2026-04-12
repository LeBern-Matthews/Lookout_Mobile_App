import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/checklist_provider.dart';
import '../services/country_provider.dart';
import '../components/home_components.dart';
import '../components/country_selector.dart';

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
    final cardBg = isLight ? Colors.white : const Color.fromARGB(255, 24, 24, 24);
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
            AppCard(
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
                    builder: (_, __) => CircularGauge(
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
            AppCard(
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
                    child: PulsingIcon(icon: Icons.arrow_circle_right_rounded,
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
            AppCard(
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
                        : '${countryFlags[countryP.country] ?? '🌍'} ${countryP.country}',
                    style: TextStyle(
                        fontSize: 12, color: onSurface.withValues(alpha: 0.45)),
                  ),
                  Divider(height: 20, color: onSurface.withValues(alpha: 0.1)),
                  EmergencyRow(
                    icon: Icons.local_police_rounded,
                    label: 'Police',
                    number: countryP.primaryPolice,
                    iconColor: const Color(0xFF1F74DF),
                    callee: 'Police',
                  ),
                  const SizedBox(height: 12),
                  EmergencyRow(
                    icon: Icons.local_hospital_rounded,
                    label: 'Ambulance',
                    number: countryP.primaryAmbulance,
                    iconColor: Colors.red,
                    callee: 'Ambulance',
                  ),
                  const SizedBox(height: 12),
                  EmergencyRow(
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
                  child: QuickAction(
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
                  child: QuickAction(
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