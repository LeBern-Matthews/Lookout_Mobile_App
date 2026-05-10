import 'package:firebase_analytics/firebase_analytics.dart';

/// Centralized analytics service for tracking user metrics.
///
/// Usage:
///   AnalyticsService.instance.logOnboardingComplete(country: 'Jamaica');
///   AnalyticsService.instance.logPageView('home');
///
/// All events are sent to Firebase Analytics and appear in the
/// Firebase Console under Events (real-time or next day).
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Provides a [NavigatorObserver] for automatic screen tracking.
  /// Add this to your MaterialApp's navigatorObservers list.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ── Screen / Page Tracking ────────────────────────────────────────────────

  /// Log a screen view. Call this when the user navigates to a new page.
  Future<void> logPageView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ── Onboarding Events ────────────────────────────────────────────────────

  /// Log when a user completes onboarding.
  Future<void> logOnboardingComplete({
    required String country,
    required String householdSize,
    required int membersCount,
    required String homeType,
    required String coastalProximity,
    required String hurricaneExperience,
  }) async {
    await _analytics.logEvent(
      name: 'onboarding_complete',
      parameters: {
        'country': country,
        'household_size': householdSize,
        'members_count': membersCount,
        'home_type': homeType,
        'coastal_proximity': coastalProximity,
        'hurricane_experience': hurricaneExperience,
      },
    );
  }

  /// Log which onboarding step the user is on (for funnel analysis).
  Future<void> logOnboardingStep(int step, String stepName) async {
    await _analytics.logEvent(
      name: 'onboarding_step',
      parameters: {
        'step_number': step,
        'step_name': stepName,
      },
    );
  }

  /// Log when GPS country detection is used / accepted / rejected.
  Future<void> logCountryDetection({
    required String detectedCountry,
    required bool accepted,
  }) async {
    await _analytics.logEvent(
      name: 'country_detection',
      parameters: {
        'detected_country': detectedCountry,
        'accepted': accepted ? 1 : 0,
      },
    );
  }

  // ── Core App Events ──────────────────────────────────────────────────────

  /// Log when a user changes their country (from Settings).
  Future<void> logCountryChanged(String country) async {
    await _analytics.logEvent(
      name: 'country_changed',
      parameters: {'country': country},
    );
  }

  /// Log checklist item toggled.
  Future<void> logChecklistToggle({
    required String itemName,
    required bool completed,
  }) async {
    // Firebase Analytics parameter values must be <= 100 characters.
    final safeItemName =
        itemName.length > 100 ? itemName.substring(0, 100) : itemName;
    await _analytics.logEvent(
      name: 'checklist_toggle',
      parameters: {
        'item_name': safeItemName,
        'completed': completed ? 1 : 0,
      },
    );
  }

  /// Log when an emergency number is called.
  Future<void> logEmergencyCall(String service) async {
    await _analytics.logEvent(
      name: 'emergency_call',
      parameters: {'service': service},
    );
  }

  /// Log bottom navigation tab switches.
  Future<void> logTabSwitch(int tabIndex, String tabName) async {
    await _analytics.logEvent(
      name: 'tab_switch',
      parameters: {
        'tab_index': tabIndex,
        'tab_name': tabName,
      },
    );
  }

  /// Log when a custom contact is created.
  Future<void> logCustomContactCreated({required bool hasCategory}) async {
    await _analytics.logEvent(
      name: 'custom_contact_created',
      parameters: {'has_category': hasCategory ? 1 : 0},
    );
  }

  /// Log the overall completion rate of the checklist.
  Future<void> logChecklistCompletionRate(double progress) async {
    await _analytics.logEvent(
      name: 'checklist_completion_rate',
      parameters: {'progress_percentage': (progress * 100).toInt()},
    );
  }

  // ── User Properties ──────────────────────────────────────────────────────

  /// Set the user's country as a user property for segmentation.
  Future<void> setUserCountry(String country) async {
    await _analytics.setUserProperty(name: 'user_country', value: country);
  }

  /// Set the user's household size as a user property.
  Future<void> setHouseholdSize(String size) async {
    await _analytics.setUserProperty(name: 'household_size', value: size);
  }
}
