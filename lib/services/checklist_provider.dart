import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

/// Centralised checklist state with SharedPreferences persistence.
/// Replaces the old ProgressProvider + local checklist state.
class ChecklistProvider with ChangeNotifier {
  final List<String> _items = [];
  final List<bool> _isChecked = [];
  bool _isLoaded = false;

  List<String> get items => List.unmodifiable(_items);
  List<bool> get isChecked => List.unmodifiable(_isChecked);
  bool get isLoaded => _isLoaded;

  int get totalCount => _items.length;
  int get checkedCount => _isChecked.where((c) => c).length;

  double get progress =>
      _items.isEmpty ? 0.0 : checkedCount / _items.length;

  Color get colour {
    final p = progress * 100;
    if (p <= 25) return Colors.red;
    if (p <= 35) return Colors.orange;
    if (p <= 60) return Colors.amber.shade700;
    if (p <= 79) return Colors.green;
    return Colors.green.shade800;
  }

  /// Returns the first unchecked item label, or null if all are done.
  String? get nextUncheckedItem {
    for (int i = 0; i < _items.length; i++) {
      if (!_isChecked[i]) return _items[i];
    }
    return null;
  }

  /// Loads items from the bundled text file and restores saved states.
  Future<void> loadItems() async {
    if (_isLoaded) return;

    final String content =
        await rootBundle.loadString('lib/assets/emergencyinfo.txt');

    final List<String> lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    _items.addAll(lines);

    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < lines.length; i++) {
      _isChecked.add(prefs.getBool('checklist_item_$i') ?? false);
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// Toggles the checked state of an item and persists the change.
  Future<void> toggleItem(int index) async {
    if (index < 0 || index >= _isChecked.length) return;
    _isChecked[index] = !_isChecked[index];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checklist_item_$index', _isChecked[index]);
    notifyListeners();
  }
}
