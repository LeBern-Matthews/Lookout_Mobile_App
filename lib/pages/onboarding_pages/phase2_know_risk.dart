import 'package:flutter/material.dart';
import '../../components/country_selector.dart';
import '../../services/country_provider.dart';
import '../../services/location_service.dart';
import 'package:provider/provider.dart';
import 'phase1_know_you.dart'; // SelectionCard, onboardingHeader

// ─────────────────────────────────────────────────────────────────────────────
// Phase 2 · Know Your Risk — Screens 4, 5, 6, 7
// ─────────────────────────────────────────────────────────────────────────────

/// Screen 4 — Country selector with GPS auto-detection
class CountryScreen extends StatefulWidget {
  final String selectedCountry;
  final ValueChanged<String> onCountryChanged;
  const CountryScreen({super.key, required this.selectedCountry, required this.onCountryChanged});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen>
    with SingleTickerProviderStateMixin {
  /// `null` = still detecting, empty string = detection failed, non-empty = detected
  String? _detectedCountry;
  bool _isDetecting = true;
  bool _bannerDismissed = false;

  late AnimationController _bannerCtrl;
  late Animation<double> _bannerFade;
  late Animation<Offset> _bannerSlide;

  @override
  void initState() {
    super.initState();

    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bannerFade = CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOut);
    _bannerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOutCubic));

    _detectCountry();
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectCountry() async {
    final country = await LocationService.detectCountry();
    if (!mounted) return;
    setState(() {
      _detectedCountry = country ?? '';
      _isDetecting = false;
    });
    if (country != null && country.isNotEmpty) {
      _bannerCtrl.forward();
    }
  }

  void _acceptDetected() {
    final country = _detectedCountry!;
    widget.onCountryChanged(country);
    final countryp = Provider.of<CountryProvider>(context, listen: false);
    countryp.setCountry(country);
    countryp.loadJsonData(country);
    setState(() => _bannerDismissed = true);
  }

  void _dismissBanner() {
    _bannerCtrl.reverse().then((_) {
      if (mounted) setState(() => _bannerDismissed = true);
    });
  }

  void _selectCountry(String c) {
    widget.onCountryChanged(c);
    final countryp = Provider.of<CountryProvider>(context, listen: false);
    countryp.setCountry(c);
    countryp.loadJsonData(c);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : const Color.fromARGB(255, 24, 24, 24);
    final countries = countryOptions();

    final showBanner = !_bannerDismissed &&
        _detectedCountry != null &&
        _detectedCountry!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        onboardingHeader(context, 'Where are you located?',
            'We\'ll use this to show you the correct emergency numbers.'),
        const SizedBox(height: 16),

        // ── Loading indicator while detecting ──
        if (_isDetecting)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Detecting your location…',
                  style: TextStyle(
                    fontSize: 13,
                    color: onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        // ── Detected country suggestion banner ──
        if (showBanner)
          SlideTransition(
            position: _bannerSlide,
            child: FadeTransition(
              opacity: _bannerFade,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withValues(alpha: 0.12),
                      primary.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 14, color: onSurface, height: 1.4),
                              children: [
                                const TextSpan(text: 'We\'ve detected that you\'re in '),
                                TextSpan(
                                  text: '${countryFlags[_detectedCountry] ?? '🌍'} $_detectedCountry',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _acceptDetected,
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Use this country'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _dismissBanner,
                          style: TextButton.styleFrom(
                            foregroundColor: onSurface.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: const Text('Dismiss', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Or select from the list below. Country can be changed later in Settings.',
                      style: TextStyle(
                        fontSize: 11,
                        color: onSurface.withValues(alpha: 0.45),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ── Country list ──
        ...countries.map((c) {
          final sel = widget.selectedCountry == c;
          final flag = countryFlags[c] ?? '🌍';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: sel ? primary.withValues(alpha: 0.12) : cardBg,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _selectCountry(c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? primary : onSurface.withValues(alpha: 0.1),
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Text(flag, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Expanded(child: Text(c, style: TextStyle(
                      fontSize: 15, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      color: sel ? primary : onSurface,
                    ))),
                    if (sel) Icon(Icons.check_circle_rounded, color: primary, size: 22),
                  ]),
                ),
              ),
            ),
          );
        }),
      ]),
    );
  }
}

/// Screen 5 — Home Type (single-select 2×2 grid)
class HomeTypeScreen extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  const HomeTypeScreen({super.key, required this.selectedType, required this.onTypeChanged});

  static const _opts = [
    {'key': 'Apartment', 'icon': Icons.apartment, 'desc': 'Multi-storey building'},
    {'key': 'House', 'icon': Icons.home, 'desc': 'Standalone house'},
    {'key': 'Mobile Home', 'icon': Icons.rv_hookup, 'desc': 'Mobile / manufactured'},
    {'key': 'Other', 'icon': Icons.other_houses, 'desc': 'Other dwelling type'},
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : const Color.fromARGB(255, 24, 24, 24);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        onboardingHeader(context, 'What type of home\ndo you live in?',
            'Different home types face different risks during storms.'),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: _opts.map((o) {
            final key = o['key'] as String;
            final sel = selectedType == key;
            return _GridCard(
              icon: o['icon'] as IconData, label: key,
              desc: o['desc'] as String, selected: sel,
              primary: primary, onSurface: onSurface, cardBg: cardBg,
              onTap: () => onTypeChanged(key),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

/// Screen 6 — Coastal Proximity (single-select)
class CoastalScreen extends StatelessWidget {
  final String selectedProximity;
  final ValueChanged<String> onProximityChanged;
  const CoastalScreen({super.key, required this.selectedProximity, required this.onProximityChanged});

  static const _opts = [
    {'key': 'Very close', 'label': 'Yes, very close', 'icon': Icons.waves, 'desc': 'Less than 1 mile from the coast'},
    {'key': 'Somewhat close', 'label': 'Somewhat close', 'icon': Icons.water, 'desc': '1 – 5 miles from the coast'},
    {'key': 'Inland', 'label': 'No, inland', 'icon': Icons.landscape, 'desc': 'More than 5 miles inland'},
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : const Color.fromARGB(255, 24, 24, 24);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        onboardingHeader(context, 'How close are you\nto the coast?',
            'Coastal areas face higher storm surge and flooding risk.'),
        const SizedBox(height: 24),
        ..._opts.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SelectionCard(
            icon: o['icon'] as IconData, title: o['label'] as String,
            subtitle: o['desc'] as String, selected: selectedProximity == o['key'],
            primary: primary, onSurface: onSurface, cardBg: cardBg,
            onTap: () => onProximityChanged(o['key'] as String),
          ),
        )),
      ]),
    );
  }
}

/// Screen 7 — Hurricane Experience (single-select)
class HurricaneExperienceScreen extends StatelessWidget {
  final String selectedExperience;
  final ValueChanged<String> onExperienceChanged;
  const HurricaneExperienceScreen({super.key, required this.selectedExperience, required this.onExperienceChanged});

  static const _opts = [
    {'key': 'None', 'label': 'No experience', 'icon': Icons.help_outline, 'desc': 'This would be my first hurricane'},
    {'key': 'Some', 'label': 'One or two', 'icon': Icons.thunderstorm, 'desc': 'I\'ve been through a few storms'},
    {'key': 'Experienced', 'label': 'Experienced', 'icon': Icons.shield, 'desc': 'I deal with hurricanes yearly'},
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : const Color.fromARGB(255, 24, 24, 24);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        onboardingHeader(context, 'How experienced are you\nwith hurricanes?',
            'We\'ll tailor tips based on your experience level.'),
        const SizedBox(height: 24),
        ..._opts.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SelectionCard(
            icon: o['icon'] as IconData, title: o['label'] as String,
            subtitle: o['desc'] as String, selected: selectedExperience == o['key'],
            primary: primary, onSurface: onSurface, cardBg: cardBg,
            onTap: () => onExperienceChanged(o['key'] as String),
          ),
        )),
      ]),
    );
  }
}

// ─── Grid card used by Home Type screen ──────────────────────────────────────

class _GridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool selected;
  final Color primary;
  final Color onSurface;
  final Color cardBg;
  final VoidCallback onTap;

  const _GridCard({
    required this.icon, required this.label, required this.desc,
    required this.selected, required this.primary, required this.onSurface,
    required this.cardBg, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? primary.withValues(alpha: 0.12) : cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? primary : onSurface.withValues(alpha: 0.1), width: selected ? 2 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: selected ? primary.withValues(alpha: 0.2) : onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: selected ? primary : onSurface.withValues(alpha: 0.5), size: 24),
              ),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? primary : onSurface)),
              const SizedBox(height: 2),
              Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: onSurface.withValues(alpha: 0.5))),
              if (selected) ...[const SizedBox(height: 4), Icon(Icons.check_circle_rounded, color: primary, size: 18)],
            ],
          ),
        ),
      ),
    );
  }
}
