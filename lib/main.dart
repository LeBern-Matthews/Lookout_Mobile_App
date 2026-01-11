import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/country_provider.dart';
import 'services/progress_provider.dart';
import 'pages/emergency_contacts.dart';
import 'pages/essential_checklist_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'pages/map_page.dart';
import 'themes/theme_provider.dart';
import 'services/has_internet.dart';
import 'components/connectivity_popup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Start internet monitoring as early as possible
  startInternetMonitoring();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      themeMode: ThemeMode.system,
      // Reduce animation duration from 300ms to 150ms
      themeAnimationDuration: const Duration(milliseconds: 0),
      themeAnimationCurve: Curves.easeInOut,
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int currentPage = 0;

  final List<Widget> pages = [
    const HomePage(),
    const EssentialChecklistPage(),
    const EmergencyContactsPage(),
    const SettingsPage(),
    const MapPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentPage, // Show the current page
            children: pages, // Keep all pages in memory
          ),
          const ConnectivityPopup(),
        ],
      ),
      
      bottomNavigationBar: NavigationBar(

        shadowColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.primary,
        height: 60,
        
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "", tooltip: "Home"),
          NavigationDestination(icon: Icon(Icons.checklist_sharp), label: "", tooltip: "Essential items"),
          NavigationDestination(icon: Icon(Icons.contact_emergency_rounded), label: "", tooltip: "Emergency contacts",),
          NavigationDestination(icon: Icon(Icons.settings), label: "", tooltip: "Settings"),
          NavigationDestination(icon: Icon(Icons.map), label: "", tooltip: "Map"),
        ],
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index; // Update the current page index
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}