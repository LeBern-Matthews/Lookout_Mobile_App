import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/country_provider.dart';
import '../services/custom_contacts_provider.dart';
import '../components/appbar.dart';
import '../components/emergency_components.dart';
import '../components/country_selector.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // solid, non-translucent color
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
              SheetField(
                controller: _nameCtrl,
                label: 'Name',
                icon: Icons.person_outline_rounded,
                inputType: TextInputType.name,
              ),
              const SizedBox(height: 12),
              SheetField(
                controller: _phoneCtrl,
                label: 'Phone number',
                icon: Icons.phone_outlined,
                inputType: TextInputType.phone,
              ),
              if (showCategories) ...[
                const SizedBox(height: 12),
                SheetField(
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
            SectionLabel(
              label: 'NATIONAL EMERGENCY NUMBERS',
              onSurface: onSurface,
            ),
            const SizedBox(height: 8),
            EmergencyCard(
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
                            : '${countryFlags[countryP.country] ?? '🌍'} ${countryP.country}',
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20, color: onSurface.withValues(alpha: 0.1)),

                  // Police rows
                  ServiceSection(
                    icon: Icons.local_police_rounded,
                    label: 'Police',
                    numbers: countryP.policeNumbers,
                    iconColor: const Color(0xFF1F74DF),
                    onCall: _call,
                    onSurface: onSurface,
                  ),

                  ServiceDivider(onSurface: onSurface),

                  // Ambulance rows
                  ServiceSection(
                    icon: Icons.local_hospital_rounded,
                    label: 'Ambulance',
                    numbers: countryP.ambulanceNumbers,
                    iconColor: Colors.red,
                    onCall: _call,
                    onSurface: onSurface,
                  ),

                  ServiceDivider(onSurface: onSurface),

                  // Fire rows
                  ServiceSection(
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
                      SectionLabel(
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
              EmergencyCard(
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
              EmergencyCard(
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
                            child: const JigglingTrashIcon(
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
                            child: CustomContactRow(
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
