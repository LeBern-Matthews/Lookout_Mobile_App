import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../../services/user_preferences_provider.dart';
import 'phase1_know_you.dart';
import 'phase2_know_risk.dart';
import 'phase3_stay_connected.dart';
import '../../main.dart'; // RootPage

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Flow — 9-screen wizard using PageView
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _currentPage = 0;
  static const _totalPages = 9;

  // Phase boundaries: 0-2 = Phase 1, 3-6 = Phase 2, 7-8 = Phase 3
  int get _currentPhase {
    if (_currentPage <= 2) return 0;
    if (_currentPage <= 6) return 1;
    return 2;
  }

  static const _phaseLabels = ['Know You', 'Know Your Risk', 'Stay Connected'];
  static const _phaseSizes = [3, 4, 2]; // pages per phase

  int get _pageInPhase {
    if (_currentPage <= 2) return _currentPage;
    if (_currentPage <= 6) return _currentPage - 3;
    return _currentPage - 7;
  }

  // ── Local state mirroring provider (for responsive UI) ──
  Set<String> _members = {};
  List<String> _childAges = [];
  List<String> _petTypes = [];
  String _medicalNeeds = '';
  String _householdSize = '';
  String _country = '';
  String _homeType = '';
  String _coastal = '';
  String _hurricane = '';
  List<String> _alertChannels = [];
  String _alertFreq = '';

  bool get _isLastPage => _currentPage == _totalPages - 1;
  bool get _isFirstPage => _currentPage == 0;

  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      setState(() => _currentPage++);
    }
  }

  void _back() {
    if (!_isFirstPage) {
      setState(() => _currentPage--);
    }
  }

  Future<void> _finish() async {
    final prefs = context.read<UserPreferencesProvider>();
    prefs.setHouseholdMembers(_members);
    prefs.setChildAges(_childAges);
    prefs.setPetTypes(_petTypes);
    prefs.setMedicalNeeds(_medicalNeeds);
    prefs.setHouseholdSize(_householdSize);
    prefs.setCountry(_country);
    prefs.setHomeType(_homeType);
    prefs.setCoastalProximity(_coastal);
    prefs.setHurricaneExperience(_hurricane);
    prefs.setAlertChannels(_alertChannels);
    prefs.setAlertFrequency(_alertFreq);
    await prefs.markOnboardingComplete();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RootPage()),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0: return const WelcomeScreen();
      case 1: return HouseholdMembersScreen(
        selectedMembers: _members, selectedChildAges: _childAges,
        selectedPetTypes: _petTypes, medicalNeeds: _medicalNeeds,
        onMembersChanged: (v) => setState(() => _members = v),
        onChildAgesChanged: (v) => setState(() => _childAges = v),
        onPetTypesChanged: (v) => setState(() => _petTypes = v),
        onMedicalNeedsChanged: (v) => setState(() => _medicalNeeds = v),
      );
      case 2: return HouseholdSizeScreen(
        selectedSize: _householdSize,
        onSizeChanged: (v) => setState(() => _householdSize = v),
      );
      case 3: return CountryScreen(
        selectedCountry: _country,
        onCountryChanged: (v) => setState(() => _country = v),
      );
      case 4: return HomeTypeScreen(
        selectedType: _homeType,
        onTypeChanged: (v) => setState(() => _homeType = v),
      );
      case 5: return CoastalScreen(
        selectedProximity: _coastal,
        onProximityChanged: (v) => setState(() => _coastal = v),
      );
      case 6: return HurricaneExperienceScreen(
        selectedExperience: _hurricane,
        onExperienceChanged: (v) => setState(() => _hurricane = v),
      );
      case 7: return AlertPreferencesScreen(
        selectedChannels: _alertChannels, selectedFrequency: _alertFreq,
        onChannelsChanged: (v) => setState(() => _alertChannels = v),
        onFrequencyChanged: (v) => setState(() => _alertFreq = v),
      );
      case 8: return const EmergencyContactScreen();
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Phase indicator + step count ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(children: [
                // 3 phase pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i == _currentPhase;
                    final done = i < _currentPhase;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: active
                              ? primary
                              : done
                                  ? primary.withValues(alpha: 0.4)
                                  : onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                // Phase label + step count
                if (_currentPage > 0) // hide on welcome
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                      _phaseLabels[_currentPhase],
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                          letterSpacing: 1, color: primary),
                    ),
                    Text(
                      'Step ${_pageInPhase + 1} of ${_phaseSizes[_currentPhase]}',
                      style: TextStyle(fontSize: 12, color: onSurface.withValues(alpha: 0.45)),
                    ),
                  ]),
              ]),
            ),

            const SizedBox(height: 8),

            // ── Page content ──
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, primaryAnim, secondaryAnim) {
                  return SharedAxisTransition(
                    animation: primaryAnim,
                    secondaryAnimation: secondaryAnim,
                    transitionType: SharedAxisTransitionType.horizontal,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentPage),
                  child: _buildPage(_currentPage),
                ),
              ),
            ),

            // ── Bottom bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: surface,
                border: Border(top: BorderSide(color: onSurface.withValues(alpha: 0.08))),
              ),
              child: Row(children: [
                // Back button
                if (!_isFirstPage)
                  TextButton.icon(
                    onPressed: _back,
                    icon: Icon(Icons.arrow_back_rounded, size: 18, color: onSurface.withValues(alpha: 0.6)),
                    label: Text('Back', style: TextStyle(color: onSurface.withValues(alpha: 0.6))),
                  )
                else
                  const SizedBox(width: 80),

                const Spacer(),

                // Next / Finish button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      elevation: 0,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        _isFirstPage ? 'Let\'s go' : _isLastPage ? 'Finish' : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      if (!_isLastPage) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ]),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
