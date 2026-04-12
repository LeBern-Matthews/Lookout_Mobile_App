import 'package:flutter/material.dart';
import '../components/country_selector.dart'; // Add this import
import 'package:provider/provider.dart';
import '../components/theme_button.dart';
import '../themes/theme_provider.dart';
import '../themes/light_mode.dart';
import '../themes/dark_mode.dart';
import '../services/country_provider.dart';
import '../services/custom_contacts_provider.dart';
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

// ── Country selection section ──────────────────────────────────────

              SizedBox(height: 30),
              Consumer<CountryProvider>(
                builder: (context, countryProvider, _) {
                  final selectedCountry = countryProvider.country;
                  //final isLight =Theme.of(context).brightness == Brightness.light;
                  final borderColor = Theme.of(context).colorScheme.primary;
                  final cardColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
                      /*
                  final expansionLightColor = const Color.fromARGB(255,210,207,202,);
                  final expansionDarkColor = const Color.fromRGBO(35,32,33,1,);
                  final expansionBg = isLight
                      ? expansionLightColor
                      : expansionDarkColor;
                      */
                  final scaffoldBg = Theme.of(context).listTileTheme.tileColor;

                  //final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
                  //final scaffoldBg = Colors.red;
                  return ExpansionTile(
                    //shape control
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    //padding control
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    //color control
                    backgroundColor: scaffoldBg,
                    //collapsedBackgroundColor: scaffoldBg,
                    
                    controller: _countryController,
                    title: const Text("Country"),
                    subtitle: Text(selectedCountry != "Country" 
                        ? '${countryFlags[selectedCountry] ?? '🌍'} $selectedCountry' 
                        : selectedCountry),
                    trailing: const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 40,
                    ),
                    children: [
                      Container(
                        color: scaffoldBg,
                        child: Column(
                          children: countryOptions().map((country) {
                            final isSelected = selectedCountry == country;

                            return SizedBox(
                              width: double.infinity,
                              child: Card(
                                elevation: 1,
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
                                  vertical: 6,
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
                                    await Future.delayed(
                                      const Duration(milliseconds: 250),
                                    );
                                    _countryController.collapse();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    child: Text(
                                      '${countryFlags[country] ?? '🌍'} $country',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // ── Contacts section ──────────────────────────────────────
              const SizedBox(height: 10),
              Divider(
                color: const Color.fromARGB(255, 188, 177, 177),
                thickness: 1.5,
              ),
              const SizedBox(height: 20),
              const Text(
                'Contacts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Customise how your saved contacts are displayed.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Consumer<CustomContactsProvider>(
                builder: (context, contactsP, _) {
                  return SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: const Text(
                      'Show Contact Categories',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Display a category label under each custom contact\'s name.',
                    ),
                    value: contactsP.showCategories,
                    onChanged: (val) =>
                        contactsP.setShowCategories(val),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
