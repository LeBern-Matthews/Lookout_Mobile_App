import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistItem {
  final String title;
  final int weight;
  bool isChecked;

  ChecklistItem({
    required this.title,
    required this.weight,
    this.isChecked = false,
  });
}

/// Centralised checklist state with SharedPreferences persistence.
/// Keeps backward compatible UI getters but uses weights for progress.
///
/// Now household-aware: items are dynamically adjusted based on
/// onboarding data (household size, members, medical needs).
class ChecklistProvider with ChangeNotifier {
  final List<ChecklistItem> _itemsList = [];
  bool _isLoaded = false;

  List<String> get items => _itemsList.map((i) => i.title).toList();
  List<bool> get isChecked => _itemsList.map((i) => i.isChecked).toList();
  List<int> get weights => _itemsList.map((i) => i.weight).toList();
  bool get isLoaded => _isLoaded;

  int get totalCount => _itemsList.length;
  int get checkedCount => _itemsList.where((i) => i.isChecked).length;

  double get progress {
    if (_itemsList.isEmpty) return 0.0;
    int totalWeight = _itemsList.fold(0, (sum, item) => sum + item.weight);
    int checkedWeight = _itemsList.where((i) => i.isChecked).fold(0, (sum, item) => sum + item.weight);
    return checkedWeight / totalWeight;
  }

  Color get colour {
    final p = progress * 100;
    if (p <= 25) return Colors.red;
    if (p <= 35) return Colors.orange;
    if (p <= 60) return Colors.amber.shade700;
    if (p <= 79) return Colors.green;
    return Colors.green.shade800;
  }

  /// Returns the first unchecked item title, or null if all are done.
  String? get nextUncheckedItem {
    for (var item in _itemsList) {
      if (!item.isChecked) return item.title;
    }
    return null;
  }

  /// Generates a stable persistence key from an item title.
  /// Uses a simple hash so that checked state survives list reordering
  /// when items are dynamically added/removed based on household profile.
  String _persistKey(String title) {
    // Use a short stable prefix of the title to create a readable key
    final normalized = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final short = normalized.length > 40 ? normalized.substring(0, 40) : normalized;
    return 'cl_$short';
  }

  /// Quantity label based on household size tier.
  String _scaleQty(String perPerson, String householdSize) {
    switch (householdSize) {
      case '1':
        return perPerson;
      case '2-3':
        // Scale the number in the perPerson string
        if (perPerson.contains('1 gallon')) {
          return '2–3 gallons';
        }
        return '2–3 people supply';
      case '4-6':
        if (perPerson.contains('1 gallon')) {
          return '4–6 gallons';
        }
        return '4–6 people supply';
      case '7+':
        if (perPerson.contains('1 gallon')) {
          return '7+ gallons';
        }
        return '7+ people supply';
      default:
        return perPerson; // no size selected — keep the default
    }
  }

  /// Loads items from the bundled JSON file and adjusts them based on
  /// the user's household profile from onboarding.
  ///
  /// [householdSize] — '1', '2-3', '4-6', '7+' or empty
  /// [householdMembers] — set of 'adults', 'children', 'elderly', 'pets', 'medical'
  /// [medicalNeeds] — free-text describing specific medical needs
  Future<void> loadItems({
    String householdSize = '',
    Set<String> householdMembers = const {},
    String medicalNeeds = '',
  }) async {
    if (_isLoaded) return;

    final String content =
        await rootBundle.loadString('lib/assets/emergencyinfo.json');

    final List<dynamic> jsonList = json.decode(content);
    final prefs = await SharedPreferences.getInstance();

    final List<ChecklistItem> processed = [];

    for (int i = 0; i < jsonList.length; i++) {
      final Map<String, dynamic> itemJson = jsonList[i];
      String title = itemJson['title'] as String;
      int weight = itemJson['weight'] as int;
      final conditional = itemJson['conditional'] as String?;
      final scalable = itemJson['scalable'] as bool? ?? false;
      final template = itemJson['template'] as String?;
      final perPerson = itemJson['perPerson'] as String?;

      // ── Conditional items: skip if the condition isn't met ──
      if (conditional == 'pets' && !householdMembers.contains('pets')) {
        continue;
      }

      // ── Scalable items: replace {qty} with household-scaled value ──
      if (scalable && template != null && perPerson != null && householdSize.isNotEmpty) {
        final qty = _scaleQty(perPerson, householdSize);
        title = template.replaceAll('{qty}', qty);
      }

      // ── Medical: append user's specifics to the prescription item ──
      if (title.startsWith('Prescription medications') &&
          householdMembers.contains('medical') &&
          medicalNeeds.isNotEmpty) {
        title = 'Prescription medications ($medicalNeeds): A supply for at least a week';
      }

      final key = _persistKey(title);
      final checked = prefs.getBool(key) ?? false;

      processed.add(ChecklistItem(
        title: title,
        weight: weight,
        isChecked: checked,
      ));
    }

    // ── Inject children-specific item if children are in household ──
    if (householdMembers.contains('children')) {
      const childTitle = 'Baby formula, bottles, and diapers';
      final key = _persistKey(childTitle);
      final checked = prefs.getBool(key) ?? false;

      // Insert after First-Aid kit (index 2 in the base list, but account for removals)
      int insertAt = processed.length; // fallback: end
      for (int i = 0; i < processed.length; i++) {
        if (processed[i].title.startsWith('First-Aid kit')) {
          insertAt = i + 1;
          break;
        }
      }

      processed.insert(insertAt, ChecklistItem(
        title: childTitle,
        weight: 9,
        isChecked: checked,
      ));
    }

    _itemsList.addAll(processed);
    _isLoaded = true;
    notifyListeners();
  }

  /// Toggles the checked state of an item and persists the change.
  Future<void> toggleItem(int index) async {
    if (index < 0 || index >= _itemsList.length) return;
    _itemsList[index].isChecked = !_itemsList[index].isChecked;
    final prefs = await SharedPreferences.getInstance();
    final key = _persistKey(_itemsList[index].title);
    await prefs.setBool(key, _itemsList[index].isChecked);
    notifyListeners();
  }
}
