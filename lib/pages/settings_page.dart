import 'package:flutter/material.dart';
import '../components/country_selector.dart'; // Add this import
import 'package:provider/provider.dart';
import '../components/theme_button.dart';
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
              Text(_selectedTheme, style: TextStyle(fontSize: 14)),
              SizedBox(height: 20),
              Row(
                children: [
                  themeButton(
                    // Light theme button
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

                  themeButton(
                    // Dark theme button
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
              Consumer<CountryProvider>(
                builder: (context, countryProvider, _) {
                  final selectedCountry = countryProvider.country;
                  final isLight =
                      Theme.of(context).brightness == Brightness.light;
                  final borderColor = const Color.fromARGB(255, 255, 157, 20);
                  final cardColor = isLight
                      ? const Color.fromARGB(255, 255, 236, 209)
                      : const Color.fromARGB(255, 63, 43, 16);
                  return ExpansionTile(
                    controller: _countryController,
                    title: const Text("Country"),
                    subtitle: Text(selectedCountry),
                    trailing: const Icon(Icons.arrow_drop_down_rounded, size: 40,),
                    children: countryOptions().map((country) {
                      final isSelected = selectedCountry == country;

                      return SizedBox(
                        width: double.infinity,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? borderColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          color: isSelected ? cardColor : null,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 4,
                          ),
                          child: InkWell(
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Text(
                                country,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
