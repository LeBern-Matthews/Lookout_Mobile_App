import 'package:flutter/material.dart';
import '../components/country_selector.dart'; // Add this import
import 'package:provider/provider.dart';
import '../components/themeButton.dart';
import '../themes/theme_provider.dart';
import '../themes/light_mode.dart';
import '../themes/dark_mode.dart';
import '../services/country_provider.dart';
//import '../services/determine_country_info.dart';
import '../components/appbar.dart'; // code for custom AppBar

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  //final String _selectedCountry = "Select a country";
  String _selectedTheme = "Change the theme of your app.";

  final ExpansibleController _themeController = ExpansibleController();
  final ExpansibleController _countryController = ExpansibleController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Settings"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              const Text(
                "Theme",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(_selectedTheme, style: TextStyle(fontSize: 14 ),),
              SizedBox(height: 20),
              Row(
                children: [

                  ThemeButton(        // Light theme button
                    label: 'Light',
                    icon: Icons.light_mode,
                    onPressed: () {
                      setState(() {
                        _selectedTheme = 'Light';
                      });
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).setTheme(lightmode);
                      _themeController.collapse();
                    },
                  ),

                  const SizedBox(width: 10),

                  ThemeButton(       // Dark theme button
                    label: 'Dark',
                    icon: Icons.dark_mode,
                    onPressed: () {
                      setState(() {
                        _selectedTheme = 'Dark';
                      });
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).setTheme(darkmode);
                      _themeController.collapse();
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(
                color: const Color.fromARGB(255, 188, 177, 177),
                thickness: 1.5,
              ),

              SizedBox(height: 30),
              ExpansionTile(
                collapsedBackgroundColor: Colors.red[100],
                controller: _countryController,
                title: const Text("Country"),
                subtitle: Text(context.watch<CountryProvider>().country),
                trailing: const Icon(Icons.arrow_drop_down_rounded),
                children: countryOptions().map((country) {
                  return ListTile(
                    title: Text(country),
                    onTap: () async {
                      Provider.of<CountryProvider>(
                        context,
                        listen: false,
                      ).setCountry(country);
                      await Provider.of<CountryProvider>(
                        context,
                        listen: false,
                      ).loadJsonData(country);
                      _countryController.collapse();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
