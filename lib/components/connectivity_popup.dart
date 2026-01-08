import 'dart:async';

import 'package:flutter/material.dart';
import '../services/has_internet.dart';

class ConnectivityPopup extends StatefulWidget {
  const ConnectivityPopup({super.key});

  @override
  State<ConnectivityPopup> createState() => _ConnectivityPopupState();
}

class _ConnectivityPopupState extends State<ConnectivityPopup> with TickerProviderStateMixin {
  static const double _expandedHeight = 140.0;
  static const double _compactHeight = 36.0;
  static const double _hiddenHeight = 0.0;
  static const Duration _animationDuration = Duration(milliseconds: 300);

  bool _expanded = false;
  Timer? _shrinkTimer;

  @override
  void initState() {
    super.initState();
    isOnline.addListener(_onConnectivityChanged);
  }

  @override
  void dispose() {
    isOnline.removeListener(_onConnectivityChanged);
    _shrinkTimer?.cancel();
    super.dispose();
  }

  void _onConnectivityChanged() {
    final online = isOnline.value;
    if (!online) {
      // Went offline: show expanded popup and schedule shrinking
      setState(() {
        _expanded = true;
      });
      _shrinkTimer?.cancel();
      _shrinkTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _expanded = false; // shrink to compact
          });
        }
      });
    } else {
      // Came back online: hide immediately
      _shrinkTimer?.cancel();
      setState(() {
        _expanded = false;
      });
    }
  }

  double _currentHeight() {
    if (isOnline.value) return _hiddenHeight;
    return _expanded ? _expandedHeight : _compactHeight;
  }

  @override
  Widget build(BuildContext context) {
    // The app's bottom navigation bar has height 60 in your app.
    ///const double bottomNavHeight = 60.0;

    return IgnorePointer(
      ignoring: true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            height: _currentHeight(),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isOnline.value ? 0.0 : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_expanded) ...[
                      const Text(
                        'You are currently offline',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Some features may be limited. Check your connection and try again.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ] else ...[
                      const Center(
                        child: Text(
                          'You are offline',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}