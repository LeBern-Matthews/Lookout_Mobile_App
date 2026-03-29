import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomContact {
  final String name;
  final String phone;
  final String category; // optional — empty string means no category

  const CustomContact({
    required this.name,
    required this.phone,
    this.category = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'category': category,
      };

  factory CustomContact.fromJson(Map<String, dynamic> json) => CustomContact(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        category: json['category'] as String? ?? '',
      );
}

class CustomContactsProvider with ChangeNotifier {
  static const _prefsKey = 'custom_contacts';
  static const _catKey = 'show_contact_categories';

  List<CustomContact> _contacts = [];
  bool _showCategories = false;

  List<CustomContact> get contacts => List.unmodifiable(_contacts);
  bool get showCategories => _showCategories;

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      _contacts = decoded
          .map((e) => CustomContact.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _showCategories = prefs.getBool(_catKey) ?? false;
    notifyListeners();
  }

  Future<void> setShowCategories(bool value) async {
    _showCategories = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_catKey, value);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_contacts.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> addContact({
    required String name,
    required String phone,
    String category = '',
  }) async {
    _contacts.add(CustomContact(name: name, phone: phone, category: category));
    notifyListeners();
    await _save();
  }

  Future<void> removeContact(int index) async {
    if (index < 0 || index >= _contacts.length) return;
    _contacts.removeAt(index);
    notifyListeners();
    await _save();
  }

  Future<void> editContact({
    required int index,
    required String name,
    required String phone,
    String category = '',
  }) async {
    if (index < 0 || index >= _contacts.length) return;
    _contacts[index] = CustomContact(name: name, phone: phone, category: category);
    notifyListeners();
    await _save();
  }
}
