import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/country_provider.dart';
import '../services/custom_contacts_provider.dart';
import '../components/appbar.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────────────────────────────────────

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  // Controllers for the "add contact" bottom sheet
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      messenger.showSnackBar(SnackBar(content: Text('Cannot call $number')));
    }
  }

  void _showContactSheet(
    BuildContext context,
    bool showCategories, [
    int? editIndex,
  ]) {
    if (editIndex != null) {
      final contact = context
          .read<CustomContactsProvider>()
          .contacts[editIndex];
      _nameCtrl.text = contact.name;
      _phoneCtrl.text = contact.phone;
      _categoryCtrl.text = contact.category;
    } else {
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _categoryCtrl.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editIndex != null ? 'Edit Contact' : 'Add Contact',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              _SheetField(
                controller: _nameCtrl,
                label: 'Name',
                icon: Icons.person_outline_rounded,
                inputType: TextInputType.name,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _phoneCtrl,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                inputType: TextInputType.phone,
              ),
              if (showCategories) ...[
                const SizedBox(height: 12),
                _SheetField(
                  controller: _categoryCtrl,
                  label: 'Category (optional)',
                  icon: Icons.label_outline_rounded,
                  inputType: TextInputType.text,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: Icon(
                    editIndex != null ? Icons.save_rounded : Icons.add_rounded,
                  ),
                  label: Text(
                    editIndex != null ? 'Save Changes' : 'Add Contact',
                  ),
                  onPressed: () {
                    final name = _nameCtrl.text.trim();
                    final phone = _phoneCtrl.text.trim();
                    if (name.isEmpty || phone.isEmpty) return;

                    if (editIndex != null) {
                      context.read<CustomContactsProvider>().editContact(
                        index: editIndex,
                        name: name,
                        phone: phone,
                        category: _categoryCtrl.text.trim(),
                      );
                    } else {
                      context.read<CustomContactsProvider>().addContact(
                        name: name,
                        phone: phone,
                        category: _categoryCtrl.text.trim(),
                      );
                    }
                    Navigator.pop(sheetCtx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final countryP = context.watch<CountryProvider>();
    final contactsP = context.watch<CustomContactsProvider>();

    final isLight = Theme.of(context).brightness == Brightness.light;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    final cardBg = isLight ? Colors.white : const Color.fromARGB(255, 24, 24, 24);
    final cardShadow = isLight
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ];

    // Read the "show categories" setting from SharedPreferences via the provider
    final showCategories = contactsP.showCategories;

    return Scaffold(
      appBar: CustomAppBar(title: 'Emergency Contacts'),
      /*
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactSheet(context, showCategories),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Contact'),
      ),*/
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── National numbers card ──────────────────────────────────
            _SectionLabel(
              label: 'NATIONAL EMERGENCY NUMBERS',
              onSurface: onSurface,
            ),
            const SizedBox(height: 8),
            _Card(
              bg: cardBg,
              shadows: cardShadow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country subtitle
                  Row(
                    children: [
                      Icon(
                        Icons.public_rounded,
                        size: 14,
                        color: onSurface.withValues(alpha: 0.45),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        countryP.country == 'Country'
                            ? 'Set your country in Settings'
                            : countryP.country,
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20, color: onSurface.withValues(alpha: 0.1)),

                  // Police rows
                  _ServiceSection(
                    icon: Icons.local_police_rounded,
                    label: 'Police',
                    numbers: countryP.policeNumbers,
                    iconColor: const Color(0xFF1F74DF),
                    onCall: _call,
                    onSurface: onSurface,
                  ),

                  _ServiceDivider(onSurface: onSurface),

                  // Ambulance rows
                  _ServiceSection(
                    icon: Icons.local_hospital_rounded,
                    label: 'Ambulance',
                    numbers: countryP.ambulanceNumbers,
                    iconColor: Colors.red,
                    onCall: _call,
                    onSurface: onSurface,
                  ),

                  _ServiceDivider(onSurface: onSurface),

                  // Fire rows
                  _ServiceSection(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Fire Dept.',
                    numbers: countryP.fireNumbers,
                    iconColor: Colors.orange.shade700,
                    onCall: _call,
                    onSurface: onSurface,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Custom contacts section ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                        label: 'MY CONTACTS',
                        onSurface: onSurface,
                      ),
                      if (contactsP.contacts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Swipe left to delete a contact',
                            style: TextStyle(
                              fontSize: 11,
                              color: onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add'),
                  onPressed: () => _showContactSheet(context, showCategories),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (contactsP.contacts.isEmpty)
              _Card(
                bg: cardBg,
                shadows: cardShadow,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 40,
                          color: onSurface.withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No custom contacts yet',
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.45),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap "Add" to save a number here',
                          style: TextStyle(
                            color: onSurface.withValues(alpha: 0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              _Card(
                bg: cardBg,
                shadows: cardShadow,
                child: Column(
                  children: List.generate(contactsP.contacts.length, (i) {
                    final contact = contactsP.contacts[i];
                    final isLast = i == contactsP.contacts.length - 1;
                    return Column(
                      children: [
                        Dismissible(
                          key: ValueKey('${contact.name}-${contact.phone}-$i'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.red,
                            ),
                          ),
                          onDismissed: (_) => context
                              .read<CustomContactsProvider>()
                              .removeContact(i),
                          child: InkWell(
                            onTap: () =>
                                _showContactSheet(context, showCategories, i),
                            borderRadius: BorderRadius.circular(10),
                            child: _CustomContactRow(
                              contact: contact,
                              showCategory: showCategories,
                              onCall: _call,
                              onSurface: onSurface,
                              primary: primary,
                            ),
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            color: onSurface.withValues(alpha: 0.08),
                          ),
                      ],
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color onSurface;
  const _SectionLabel({required this.label, required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color bg;
  final List<BoxShadow> shadows;
  const _Card({required this.child, required this.bg, required this.shadows});

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

class _ServiceDivider extends StatelessWidget {
  final Color onSurface;
  const _ServiceDivider({required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 20, color: onSurface.withValues(alpha: 0.08));
  }
}

/// Shows the service name + icon, then one call row per number.
class _ServiceSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> numbers;
  final Color iconColor;
  final Future<void> Function(String) onCall;
  final Color onSurface;

  const _ServiceSection({
    required this.icon,
    required this.label,
    required this.numbers,
    required this.iconColor,
    required this.onCall,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveNumbers = numbers.isEmpty
        ? <String>['Not available']
        : numbers;
    final bool unavailable =
        numbers.isEmpty ||
        (numbers.length == 1 && numbers.first == 'Not available');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service header row (icon + label)
        Row(
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
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            if (effectiveNumbers.length > 1)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${effectiveNumbers.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // One row per number
        ...effectiveNumbers.map(
          (number) => Padding(
            padding: const EdgeInsets.only(top: 10, left: 4),
            child: Row(
              children: [
                const SizedBox(width: 38), // aligns with label text
                Expanded(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 15,
                      color: unavailable
                          ? onSurface.withValues(alpha: 0.35)
                          : onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ),
                if (!unavailable)
                  IconButton(
                    icon: const Icon(Icons.call_rounded),
                    color: iconColor,
                    tooltip: 'Call $num',
                    onPressed: () => onCall(number),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A single row for a custom contact.
class _CustomContactRow extends StatelessWidget {
  final CustomContact contact;
  final bool showCategory;
  final Future<void> Function(String) onCall;
  final Color onSurface;
  final Color primary;

  const _CustomContactRow({
    required this.contact,
    required this.showCategory,
    required this.onCall,
    required this.onSurface,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person_rounded, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (showCategory && contact.category.isNotEmpty)
                  Text(
                    contact.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Text(
                  contact.phone,
                  style: TextStyle(
                    fontSize: 13,
                    color: onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded),
            color: primary,
            tooltip: 'Call ${contact.name}',
            onPressed: () => onCall(contact.phone),
          ),
        ],
      ),
    );
  }
}

/// A styled text field for the bottom sheet.
class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType inputType;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
