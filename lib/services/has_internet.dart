import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class CheckInternet extends StatelessWidget {
  const CheckInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Internal subscription used by the monitoring helper.
StreamSubscription<InternetConnectionStatus>? _internetSubscription;

/// Start listening for internet status changes.
/// Call this once during app startup (for example, before `runApp`).
void startInternetMonitoring() {
  // Avoid attaching multiple listeners if already started
  print("Hello");
  if (_internetSubscription != null) return;

  final checker = InternetConnectionChecker();
  _internetSubscription = checker.onStatusChange.listen(
    (InternetConnectionStatus status) {
      if (status == InternetConnectionStatus.connected) {
        debugPrint('Connected to the internet');
      } else {
        debugPrint('Disconnected from the internet');
      }
    },
  );
}

/// Stop listening to internet status updates and free resources.
void stopInternetMonitoring() {
  _internetSubscription?.cancel();
  _internetSubscription = null;
}