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

  /// Loads items from the bundled JSON file and restores saved states.
  Future<void> loadItems() async {
    if (_isLoaded) return;

    final String content =
        await rootBundle.loadString('lib/assets/emergencyinfo.json');

    final List<dynamic> jsonList = json.decode(content);

    final prefs = await SharedPreferences.getInstance();
    
    for (int i = 0; i < jsonList.length; i++) {
      final Map<String, dynamic> itemJson = jsonList[i];
      final bool checked = prefs.getBool('checklist_item_$i') ?? false;
      
      _itemsList.add(ChecklistItem(
        title: itemJson['title'] as String,
        weight: itemJson['weight'] as int,
        isChecked: checked,
      ));
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// Toggles the checked state of an item and persists the change.
  Future<void> toggleItem(int index) async {
    if (index < 0 || index >= _itemsList.length) return;
    _itemsList[index].isChecked = !_itemsList[index].isChecked;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checklist_item_$index', _itemsList[index].isChecked);
    notifyListeners();
  }
}
