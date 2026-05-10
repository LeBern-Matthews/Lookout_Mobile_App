import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/custom_contacts_provider.dart';
import 'phase1_know_you.dart'; // onboardingHeader, SelectionCard

// ─────────────────────────────────────────────────────────────────────────────
// Phase 3 · Stay Connected — Screens 8, 9
// ─────────────────────────────────────────────────────────────────────────────

/// Screen 8 — Alert Preferences (channel multi-select + frequency single-select)
class AlertPreferencesScreen extends StatelessWidget {
  final List<String> selectedChannels;
  final String selectedFrequency;
  final ValueChanged<List<String>> onChannelsChanged;
  final ValueChanged<String> onFrequencyChanged;

  const AlertPreferencesScreen({
    super.key,
    required this.selectedChannels,
    required this.selectedFrequency,
    required this.onChannelsChanged,
    required this.onFrequencyChanged,
  });

  static const _channels = [
    {'key': 'Push notifications', 'icon': Icons.notifications_active},
    {'key': 'SMS', 'icon': Icons.sms},
    {'key': 'Email', 'icon': Icons.email},
    {'key': 'Radio / TV', 'icon': Icons.radio},
  ];

  static const _frequencies = [
    {'key': 'All alerts', 'label': 'All alerts', 'icon': Icons.campaign, 'desc': 'Get every alert as it happens'},
    {'key': 'Critical only', 'label': 'Critical only', 'icon': Icons.warning_amber, 'desc': 'Only life-threatening alerts'},
    {'key': 'Daily summary', 'label': 'Daily summary', 'icon': Icons.today, 'desc': 'One digest per day'},
  ];

  void _toggleChannel(String key) {
    final updated = List<String>.from(selectedChannels);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    onChannelsChanged(updated);
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
        onboardingHeader(context, 'How would you like\nto receive alerts?',
            'Choose your preferred channels and frequency.'),
        const SizedBox(height: 24),

        // Channel chips
        Text('Alert Channels', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: _channels.map((c) {
          final key = c['key'] as String;
          final sel = selectedChannels.contains(key);
          return FilterChip(
            selected: sel, showCheckmark: true, checkmarkColor: Colors.white,
            avatar: Icon(c['icon'] as IconData, size: 18, color: sel ? Colors.white : onSurface.withValues(alpha: 0.6)),
            label: Text(key),
            labelStyle: TextStyle(color: sel ? Colors.white : onSurface, fontWeight: sel ? FontWeight.w600 : FontWeight.w400),
            selectedColor: primary, backgroundColor: cardBg,
            side: BorderSide(color: sel ? primary : onSurface.withValues(alpha: 0.15)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            onSelected: (_) => _toggleChannel(key),
          );
        }).toList()),

        const SizedBox(height: 28),

        // Frequency
        Text('Alert Frequency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 10),
        ..._frequencies.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SelectionCard(
            icon: f['icon'] as IconData, title: f['label'] as String,
            subtitle: f['desc'] as String, selected: selectedFrequency == f['key'],
            primary: primary, onSurface: onSurface, cardBg: cardBg,
            onTap: () => onFrequencyChanged(f['key'] as String),
          ),
        )),
      ]),
    );
  }
}

/// Screen 9 — Emergency Contact form (with skip option)
class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _contactAdded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _addContact() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    await Provider.of<CustomContactsProvider>(context, listen: false)
        .addContact(name: name, phone: phone, category: 'Emergency');

    setState(() => _contactAdded = true);
    _nameCtrl.clear();
    _phoneCtrl.clear();
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
        onboardingHeader(context, 'Add an emergency contact',
            'Someone to reach in a crisis. You can skip this and add contacts later.'),
        const SizedBox(height: 24),

        if (_contactAdded)
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Contact added! You can add more or finish setup.',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w500))),
            ]),
          ),

        // Name field
        Text('Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: _inputDeco('e.g. Mom, Partner, Neighbour', onSurface, cardBg, primary),
        ),
        const SizedBox(height: 20),

        // Phone field
        Text('Phone number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface.withValues(alpha: 0.7))),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: _inputDeco('e.g. +1 876 555 1234', onSurface, cardBg, primary),
        ),
        const SizedBox(height: 24),

        // Add button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _addContact,
            icon: const Icon(Icons.person_add_rounded, size: 20),
            label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    );
  }

  InputDecoration _inputDeco(String hint, Color onSurface, Color cardBg, Color primary) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.35)),
      filled: true, fillColor: cardBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: onSurface.withValues(alpha: 0.15))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: onSurface.withValues(alpha: 0.15))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primary, width: 2)),
    );
  }
}
