import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../services/country_provider.dart';

class CallingButton extends StatefulWidget {
  final String phoneNumber;
  final String callee;

  const CallingButton({
    super.key,
    required this.phoneNumber,
    required this.callee,
  });

  @override
  State<CallingButton> createState() => _CallingButtonState();
}

class _CallingButtonState extends State<CallingButton> {

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // show a user-friendly message when dialing fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot call $phoneNumber')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountryProvider>();

    List<String> numbers;
    if (widget.callee == 'Police') {
      numbers = provider.policeNumbers;
    } else if (widget.callee == 'Ambulance') {
      numbers = provider.ambulanceNumbers;
    } else {
      numbers = provider.fireNumbers;
    }

    // fallback to widget.phoneNumber if provider has nothing
    if (numbers.isEmpty && widget.phoneNumber.isNotEmpty) {
      numbers = [widget.phoneNumber];
    }

    if (numbers.isEmpty) {
      return IconButton(
        icon: Icon(Icons.call),
        tooltip: '${widget.callee}: Not available',
        onPressed: null,
      );
    }

    if (numbers.length == 1) {
      final num = numbers.first;
      return IconButton(
        icon: Icon(Icons.call),
        tooltip: 'Call ${widget.callee}',
        onPressed: () => _makePhoneCall(context, num),
      );
    }

    // multiple numbers: show popup menu to choose which to call
    return PopupMenuButton<String>(
      tooltip: 'Call ${widget.callee}',
      icon: Icon(Icons.call),
      onSelected: (number) => _makePhoneCall(context, number),
      itemBuilder: (ctx) => numbers
          .map((n) => PopupMenuItem<String>(value: n, child: Text(n)))
          .toList(),
    );
  }
}
