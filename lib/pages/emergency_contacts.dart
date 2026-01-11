import 'package:flutter/material.dart';
import 'package:lookout/components/calling_button.dart';
import 'package:provider/provider.dart';
import '../services/country_provider.dart';


class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {

  @override
  Widget build(BuildContext context) {
  final country = context.watch<CountryProvider>().country;

  final provider = context.watch<CountryProvider>();
  final policeNum = provider.primaryPolice;
  final ambulanceNum = provider.primaryAmbulance;
  final fireNum = provider.primaryFire;

  

  return Scaffold(
    appBar: AppBar(title: Text("Emergency contacts"),
      centerTitle: false,
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left:20, top: 20),
          child: Text(" For $country",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Divider( color: const Color.fromARGB(255, 188, 177, 177), thickness: 1, indent: 20, endIndent: 20,),
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.only(left:20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Row(
                children: [
                  
                  Text("Police Department: ${policeNum.isNotEmpty ? policeNum : 'Not available'}", style: TextStyle(fontSize: 20)),
                  Spacer(),
                  CallingButton(phoneNumber: policeNum, callee: "Police"),
                ],
              ),
              SizedBox(height: 60),
              Row(
                children: [
                  Text("Ambulance: ${ambulanceNum.isNotEmpty ? ambulanceNum : 'Not available'}", style: TextStyle(fontSize: 20)),
                  Spacer(),
                  CallingButton(phoneNumber: fireNum, callee: "Ambulance"),
                ],
              ),
          
            SizedBox(height: 60),
              Row(
                children: [
                  Text("Fire Department: ${fireNum.isNotEmpty ? fireNum : 'Not available'}", style: TextStyle(fontSize: 20)),
                  Spacer(),
                  CallingButton(phoneNumber: ambulanceNum, callee: "Fire")
                ],
              ),
              SizedBox(height: 60),
            ],
          )
          ),

    ],),
  );
}
}