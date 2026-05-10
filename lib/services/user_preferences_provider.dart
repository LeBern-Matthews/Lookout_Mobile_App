import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages all user-preference data captured during onboarding.
/// Persists every field to SharedPreferences so it survives restarts.
class UserPreferencesProvider with ChangeNotifier {
  // ── Keys ──────────────────────────────────────────────────────────────────
  static const _kCompleted = 'hasCompletedOnboarding';
  static const _kMembers = 'onb_household_members';
  static const _kChildAges = 'onb_child_ages';
  static const _kPetTypes = 'onb_pet_types';
  static const _kMedicalNeeds = 'onb_medical_needs';
  static const _kHouseholdSize = 'onb_household_size';
  static const _kCountry = 'onb_country';
  static const _kHomeType = 'onb_home_type';
  static const _kCoastal = 'onb_coastal_proximity';
  static const _kHurricane = 'onb_hurricane_experience';
  static const _kAlertChannel = 'onb_alert_channels';
  static const _kAlertFreq = 'onb_alert_frequency';

  // ── State ─────────────────────────────────────────────────────────────────
  bool _hasCompletedOnboarding = false;

  Set<String> _householdMembers = {};
  List<String> _childAges = [];
  List<String> _petTypes = [];
  String _medicalNeeds = '';
  String _householdSize = '';
  String _country = '';
  String _homeType = '';
  String _coastalProximity = '';
  String _hurricaneExperience = '';
  List<String> _alertChannels = [];
  String _alertFrequency = '';

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  Set<String> get householdMembers => Set.unmodifiable(_householdMembers);
  List<String> get childAges => List.unmodifiable(_childAges);
  List<String> get petTypes => List.unmodifiable(_petTypes);
  String get medicalNeeds => _medicalNeeds;
  String get householdSize => _householdSize;
  String get country => _country;
  String get homeType => _homeType;
  String get coastalProximity => _coastalProximity;
  String get hurricaneExperience => _hurricaneExperience;
  List<String> get alertChannels => List.unmodifiable(_alertChannels);
  String get alertFrequency => _alertFrequency;

  // ── Setters (notify + persist) ────────────────────────────────────────────

  void setHouseholdMembers(Set<String> value) {
    _householdMembers = value;
    notifyListeners();
  }

  void setChildAges(List<String> value) {
    _childAges = value;
    notifyListeners();
  }

  void setPetTypes(List<String> value) {
    _petTypes = value;
    notifyListeners();
  }

  void setMedicalNeeds(String value) {
    _medicalNeeds = value;
    notifyListeners();
  }

  void setHouseholdSize(String value) {
    _householdSize = value;
    notifyListeners();
  }

  void setCountry(String value) {
    _country = value;
    notifyListeners();
  }

  void setHomeType(String value) {
    _homeType = value;
    notifyListeners();
  }

  void setCoastalProximity(String value) {
    _coastalProximity = value;
    notifyListeners();
  }

  void setHurricaneExperience(String value) {
    _hurricaneExperience = value;
    notifyListeners();
  }

  void setAlertChannels(List<String> value) {
    _alertChannels = value;
    notifyListeners();
  }

  void setAlertFrequency(String value) {
    _alertFrequency = value;
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _hasCompletedOnboarding = prefs.getBool(_kCompleted) ?? false;

    final membersRaw = prefs.getStringList(_kMembers);
    _householdMembers = membersRaw?.toSet() ?? {};

    _childAges = prefs.getStringList(_kChildAges) ?? [];
    _petTypes = prefs.getStringList(_kPetTypes) ?? [];
    _medicalNeeds = prefs.getString(_kMedicalNeeds) ?? '';
    _householdSize = prefs.getString(_kHouseholdSize) ?? '';
    _country = prefs.getString(_kCountry) ?? '';
    _homeType = prefs.getString(_kHomeType) ?? '';
    _coastalProximity = prefs.getString(_kCoastal) ?? '';
    _hurricaneExperience = prefs.getString(_kHurricane) ?? '';

    _alertChannels = prefs.getStringList(_kAlertChannel) ?? [];
    _alertFrequency = prefs.getString(_kAlertFreq) ?? '';

    notifyListeners();
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_kMembers, _householdMembers.toList());
    await prefs.setStringList(_kChildAges, _childAges);
    await prefs.setStringList(_kPetTypes, _petTypes);
    await prefs.setString(_kMedicalNeeds, _medicalNeeds);
    await prefs.setString(_kHouseholdSize, _householdSize);
    await prefs.setString(_kCountry, _country);
    await prefs.setString(_kHomeType, _homeType);
    await prefs.setString(_kCoastal, _coastalProximity);
    await prefs.setString(_kHurricane, _hurricaneExperience);
    await prefs.setStringList(_kAlertChannel, _alertChannels);
    await prefs.setString(_kAlertFreq, _alertFrequency);
  }

  Future<void> markOnboardingComplete() async {
    _hasCompletedOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCompleted, true);
    await saveToPrefs();
    notifyListeners();
  }
}
