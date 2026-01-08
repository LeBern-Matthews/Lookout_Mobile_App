import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CountryProvider with ChangeNotifier {
  String _country = "Country"; // the _ makes it aprivate field
  List<String> _policeNumbers = ['911'];
  List<String> _ambulanceNumbers = ['911'];
  List<String> _fireNumbers = ['911'];

  String get country => _country;
  List<String> get policeNumbers => List.unmodifiable(_policeNumbers);
  List<String> get ambulanceNumbers => List.unmodifiable(_ambulanceNumbers);
  List<String> get fireNumbers => List.unmodifiable(_fireNumbers);

  String get primaryPolice => _policeNumbers.isNotEmpty ? _policeNumbers.first : '';
  String get primaryAmbulance => _ambulanceNumbers.isNotEmpty ? _ambulanceNumbers.first : '';
  String get primaryFire => _fireNumbers.isNotEmpty ? _fireNumbers.first : '';

  // Primamry getters
  bool get policeHasMultiple => _policeNumbers.length > 1;
  bool get ambulanceHasMultiple => _ambulanceNumbers.length > 1;
  bool get fireHasMultiple => _fireNumbers.length > 1;

  void setCountry(String country) {
    _country = country;
    notifyListeners();
  }
  
  // Function that changes all inputs into a list (Normalising the inputs)
  List<String> _normalizePhoneField(dynamic field) {
    if (field == null) {
    
    return <String>[];}
    if (field is String) return [field];
    if (field is List) {
      return field.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    // fallback
    return [field.toString()];
  }

  Future<void> loadJsonData(String country) async {
    try {
      final String response = await rootBundle.loadString('lib/assets/country_data.json');
      final Map<String, dynamic> data = jsonDecode(response) as Map<String, dynamic>;
      final info = data[country] as Map<String, dynamic>?;

      if (info != null) {
        _policeNumbers = _normalizePhoneField(info['police']);
        _ambulanceNumbers = _normalizePhoneField(info['ambulance']);
        _fireNumbers = _normalizePhoneField(info['fire_dept']);
      } else {
        // fallback to defaults or empty lists
        _policeNumbers = ['Not applicable'];
        _ambulanceNumbers = ['Not applicable'];
        _fireNumbers = ['Not applicable'];
      }

      notifyListeners();
    } catch (e, st) {
      print('Error loading country data: $e\n$st');
      // do not crash; leave defaults or set Not available
      _policeNumbers = ['Not available'];
      _ambulanceNumbers = ['Not available'];
      _fireNumbers = ['Not available'];
      notifyListeners();
    }
  }
}