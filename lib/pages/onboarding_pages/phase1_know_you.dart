import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 1 · Know You — Screens 1, 2, 3
// ─────────────────────────────────────────────────────────────────────────────

/// Screen 1 — Welcome splash
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIcon;
  late Animation<double> _fadeTitle;
  late Animation<double> _fadeSub;
  late Animation<Offset> _slideTitle;
  late Animation<Offset> _slideSub;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fadeIcon = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _fadeTitle = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));
    _slideTitle = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));
    _fadeSub = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _slideSub = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          FadeTransition(
            opacity: _fadeIcon,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [primary, primary.withValues(alpha: 0.6)],
                ),
                boxShadow: [BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: const Icon(Icons.shield_rounded, size: 52, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          SlideTransition(
            position: _slideTitle,
            child: FadeTransition(
              opacity: _fadeTitle,
              child: Column(children: [
                Text('Welcome to', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: onSurface.withValues(alpha: 0.6))),
                const SizedBox(height: 6),
                Text('LOOKOUT', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: 6, color: primary)),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _slideSub,
            child: FadeTransition(
              opacity: _fadeSub,
              child: Text('Stay prepared, stay safe.\nLet\'s personalise your experience.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5, color: onSurface.withValues(alpha: 0.6))),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Screen 2 — Household Members (multi-select with drill-downs)
// ─────────────────────────────────────────────────────────────────────────────

class HouseholdMembersScreen extends StatefulWidget {
  final Set<String> selectedMembers;
  final List<String> selectedChildAges;
  final List<String> selectedPetTypes;
  final String medicalNeeds;
  final ValueChanged<Set<String>> onMembersChanged;
  final ValueChanged<List<String>> onChildAgesChanged;
  final ValueChanged<List<String>> onPetTypesChanged;
  final ValueChanged<String> onMedicalNeedsChanged;

  const HouseholdMembersScreen({
    super.key,
    required this.selectedMembers, required this.selectedChildAges,
    required this.selectedPetTypes, required this.medicalNeeds,
    required this.onMembersChanged, required this.onChildAgesChanged,
    required this.onPetTypesChanged, required this.onMedicalNeedsChanged,
  });

  @override
  State<HouseholdMembersScreen> createState() => _HouseholdMembersScreenState();
}

class _HouseholdMembersScreenState extends State<HouseholdMembersScreen> {
  late final TextEditingController _medicalCtrl;

  static const _members = [
    {'key': 'adults', 'label': 'Adults', 'icon': Icons.person},
    {'key': 'children', 'label': 'Children / Infants', 'icon': Icons.child_care},
    {'key': 'elderly', 'label': 'Seniors', 'icon': Icons.elderly},
    {'key': 'pets', 'label': 'Pets', 'icon': Icons.pets},
    {'key': 'medical', 'label': 'Medical Needs', 'icon': Icons.medical_services},
  ];
  static const _childAges = ['0–2 yrs', '3–5 yrs', '6–12 yrs', '13–17 yrs'];
  static const _petTypes = ['Dog', 'Cat', 'Bird', 'Other'];

  @override
  void initState() { super.initState(); _medicalCtrl = TextEditingController(text: widget.medicalNeeds); }
  @override
  void dispose() { _medicalCtrl.dispose(); super.dispose(); }

  void _toggle(String key) {
    final s = Set<String>.from(widget.selectedMembers);
    s.contains(key) ? s.remove(key) : s.add(key);
    widget.onMembersChanged(s);
  }

  void _toggleChild(String v) {
    final l = List<String>.from(widget.selectedChildAges);
    l.contains(v) ? l.remove(v) : l.add(v);
    widget.onChildAgesChanged(l);
  }

  void _togglePet(String v) {
    final l = List<String>.from(widget.selectedPetTypes);
    l.contains(v) ? l.remove(v) : l.add(v);
    widget.onPetTypesChanged(l);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? Colors.white : const Color.fromARGB(255, 24, 24, 24);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        onboardingHeader(context, 'Who are you preparing for?', 'Select all that apply'),
        const SizedBox(height: 20),
        Wrap(spacing: 10, runSpacing: 10, children: _members.map((o) {
          final k = o['key'] as String; final sel = widget.selectedMembers.contains(k);
          return FilterChip(
            selected: sel, showCheckmark: true, checkmarkColor: Colors.white,
            avatar: Icon(o['icon'] as IconData, size: 18, color: sel ? Colors.white : onSurface.withValues(alpha: 0.6)),
            label: Text(o['label'] as String),
            labelStyle: TextStyle(color: sel ? Colors.white : onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400),
            selectedColor: primary, backgroundColor: cardBg,
            side: BorderSide(color: sel ? primary : onSurface.withValues(alpha: 0.15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            onSelected: (_) => _toggle(k),
          );
        }).toList()),

        if (widget.selectedMembers.contains('children')) ...[
          const SizedBox(height: 24),
          _chipGroup(context, 'Children\'s age ranges', _childAges, widget.selectedChildAges, _toggleChild, primary, onSurface, cardBg),
        ],
        if (widget.selectedMembers.contains('pets')) ...[
          const SizedBox(height: 24),
          _chipGroup(context, 'Types of pets', _petTypes, widget.selectedPetTypes, _togglePet, primary, onSurface, cardBg),
        ],
        if (widget.selectedMembers.contains('medical')) ...[
          const SizedBox(height: 24),
          Text('Describe medical needs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          TextField(
            controller: _medicalCtrl, onChanged: widget.onMedicalNeedsChanged, maxLines: 2,
            decoration: InputDecoration(
              hintText: 'e.g. insulin, oxygen, wheelchair access...',
              hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.35)),
              filled: true, fillColor: cardBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: onSurface.withValues(alpha: 0.15))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: onSurface.withValues(alpha: 0.15))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary, width: 2)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _chipGroup(BuildContext ctx, String title, List<String> opts, List<String> sel, ValueChanged<String> onTap, Color primary, Color onSurface, Color cardBg) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface.withValues(alpha: 0.7))),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: opts.map((o) {
        final s = sel.contains(o);
        return ChoiceChip(
          selected: s, showCheckmark: false, label: Text(o),
          labelStyle: TextStyle(color: s ? Colors.white : onSurface, fontWeight: s ? FontWeight.w600 : FontWeight.w400, fontSize: 13),
          selectedColor: primary, backgroundColor: cardBg,
          side: BorderSide(color: s ? primary : onSurface.withValues(alpha: 0.15)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onSelected: (_) => onTap(o),
        );
      }).toList()),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Screen 3 — Household Size (single-select)
// ─────────────────────────────────────────────────────────────────────────────

class HouseholdSizeScreen extends StatelessWidget {
  final String selectedSize;
  final ValueChanged<String> onSizeChanged;
  const HouseholdSizeScreen({super.key, required this.selectedSize, required this.onSizeChanged});

  static const _opts = [
    {'key': '1', 'label': 'Just me', 'icon': Icons.person, 'desc': '1 person'},
    {'key': '2-3', 'label': '2 – 3', 'icon': Icons.people, 'desc': 'Small household'},
    {'key': '4-6', 'label': '4 – 6', 'icon': Icons.groups, 'desc': 'Medium household'},
    {'key': '7+', 'label': '7 +', 'icon': Icons.groups_3, 'desc': 'Large household'},
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
        onboardingHeader(context, 'How many people are\nin your household?', 'This helps us scale your supply recommendations.'),
        const SizedBox(height: 24),
        ..._opts.map((o) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SelectionCard(
            icon: o['icon'] as IconData, title: o['label'] as String,
            subtitle: o['desc'] as String, selected: selectedSize == o['key'],
            primary: primary, onSurface: onSurface, cardBg: cardBg,
            onTap: () => onSizeChanged(o['key'] as String),
          ),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────────────────────

Widget onboardingHeader(BuildContext context, String title, String subtitle) {
  final onSurface = Theme.of(context).colorScheme.onSurface;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: onSurface, height: 1.3)),
    const SizedBox(height: 6),
    Text(subtitle, style: TextStyle(fontSize: 14, color: onSurface.withValues(alpha: 0.55), height: 1.4)),
  ]);
}

class SelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final Color primary;
  final Color onSurface;
  final Color cardBg;
  final VoidCallback onTap;

  const SelectionCard({super.key,
    required this.icon, required this.title, required this.subtitle,
    required this.selected, required this.primary, required this.onSurface,
    required this.cardBg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? primary.withValues(alpha: 0.12) : cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200), curve: Curves.easeInOut,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? primary : onSurface.withValues(alpha: 0.1), width: selected ? 2 : 1),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: selected ? primary.withValues(alpha: 0.2) : onSurface.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: selected ? primary : onSurface.withValues(alpha: 0.5), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: selected ? primary : onSurface)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 13, color: onSurface.withValues(alpha: 0.5))),
            ])),
            if (selected) Icon(Icons.check_circle_rounded, color: primary, size: 24),
          ]),
        ),
      ),
    );
  }
}
