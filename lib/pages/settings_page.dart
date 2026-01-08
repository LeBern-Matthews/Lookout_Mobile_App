import 'package:flutter/material.dart';
import '../components/country_selector.dart'; // Add this import
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../themes/light_mode.dart';
import '../themes/dark_mode.dart';
import '../services/country_provider.dart';
//import '../services/determine_country_info.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
 //final String _selectedCountry = "Select a country";
  String _selectedTheme ="Change the app theme";

  final ExpansibleController _themeController = ExpansibleController();
  final ExpansibleController _countryController = ExpansibleController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            ExpansionTile(
              controller: _themeController,
              title: const Text("Theme"),
              subtitle:  Text(_selectedTheme),
              trailing: const Icon(Icons.arrow_drop_down_rounded),
              children: [
                ListTile(
                  title: const Text("Light"),
                  leading: const Icon(Icons.light_mode),
                  onTap: () {
                    setState(() {
                      _selectedTheme = "Light";
                    });
                    Provider.of<ThemeProvider>(context, listen: false).setTheme(lightmode);
                    _themeController.collapse();
                  },
                ),
                ListTile(
                  title: const Text("Dark"),
                  leading: const Icon(Icons.dark_mode),
                  onTap: () {
                    setState(() {
                      _selectedTheme = "Dark";
                    });
                    Provider.of<ThemeProvider>(context, listen: false).setTheme(darkmode);
                    _themeController.collapse();
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            ExpansionTile(
              controller: _countryController,
              title: const Text("Country"),
              subtitle: Text(context.watch<CountryProvider>().country),
              trailing: const Icon(Icons.arrow_drop_down_rounded),
              children: countryOptions().map((country) {
                return ListTile(
                  title: Text(country),
                  onTap: () async {
                    Provider.of<CountryProvider>(context, listen: false).setCountry(country);
                    await Provider.of<CountryProvider>(context, listen: false).loadJsonData(country);
                    _countryController.collapse();
                  },
                );
              }).toList(),
            ),
          ],
          
        ),
        
      ),
    );
  }
}