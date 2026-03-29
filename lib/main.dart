import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/country_provider.dart';
import 'services/checklist_provider.dart';
import 'services/custom_contacts_provider.dart';
import 'pages/emergency_contacts.dart';
import 'pages/essential_checklist_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';
import 'themes/theme_provider.dart';
import 'services/has_internet.dart';
import 'components/connectivity_popup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  startInternetMonitoring();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CountryProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => CustomContactsProvider()),
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
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomePage(onNavigate: _navigateTo),
      const EssentialChecklistPage(),
      const EmergencyContactsPage(),
      const SettingsPage(),
    ];
    // Load checklist items + restore saved state as soon as the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChecklistProvider>().loadItems();
      context.read<CustomContactsProvider>().loadContacts();
    });
  }

  void _navigateTo(int index) {
    setState(() => currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentPage,
            children: pages,
          ),
          const ConnectivityPopup(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        //indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.primary,
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "", tooltip: "Home"),
          NavigationDestination(icon: Icon(Icons.checklist_sharp), label: "", tooltip: "Essential items"),
          NavigationDestination(icon: Icon(Icons.contact_emergency_rounded), label: "", tooltip: "Emergency contacts"),
          NavigationDestination(icon: Icon(Icons.settings), label: "", tooltip: "Settings"),
        ],
        onDestinationSelected: _navigateTo,
        selectedIndex: currentPage,
      ),
    );
  }
}