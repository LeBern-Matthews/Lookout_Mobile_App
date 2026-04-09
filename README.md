# LookOut App
A mobile app built with Dart and the Flutter framework for hurricane and emergency preparedness.


## Table of contents
[Features](#features)

[Instructions](#instructions)

[Usage](#usage)

[Architecture](#architecture)

[Dependencies](#dependencies)

## Features
### 1. Home Page
- Displays a **"Prepared-o-meter"** progress bar that tracks your overall readiness based on a **weighted** system of checked-off supplies, prioritizing critical items.
- Quick-access shortcuts to navigate directly to the Checklist and Contacts pages.
- Connectivity popup that alerts you when your internet connection drops or is restored.

### 2. Checklist Page
- A detailed list of essential supplies for emergencies.
- Items are **weighted** by importance to give an accurate preparedness score.
- Interactive checkboxes to track the items you have prepared.
- Progress is **persisted** across app sessions using SharedPreferences.

### 3. Emergency Contacts Page
- Displays emergency contacts (police, ambulance, fire department) for your selected country.
- Supports adding and managing **custom contacts** that persist across sessions.
- Tap a number to call directly using the device dialer.

### 4. Settings Page
- **Theme Selection** — toggle between Dark and Light mode.
- **Country Selection** — manually set your country for emergency contact lookups.

### 5. Navigation Bar
- A bottom navigation bar for switching between all four pages.
- Smooth **shared-axis page transitions** powered by the `animations` package.

### 6. Map (Coming Soon)
- A map view showing the locations of nearby hospitals, clinics, and emergency centers is planned for a future release.

## Instructions
1. Download and set up the [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to launch the app on a connected device or emulator

## Usage
1. Open the app on your phone or an emulator.

2. Use the **Settings** page to select your country if you are not connected to the internet.

3. Navigate through the app using the bottom navigation bar:
    - **Home** — View your preparedness progress
    - **Checklist** — Check off your essential emergency supplies
    - **Contacts** — View and call emergency contacts for your country, or add custom ones
    - **Settings** — Change your theme and select your country

## Architecture

The app uses the **Provider** pattern for state management across four main providers:

- `ThemeProvider` — manages light/dark theme state
- `CountryProvider` — manages the selected country for emergency contacts
- `ChecklistProvider` — manages checklist items and persists state with SharedPreferences
- `CustomContactsProvider` — manages user-added custom contacts and persists them with SharedPreferences

Page transitions are handled by `PageTransitionSwitcher` with a `SharedAxisTransition` (horizontal) from the `animations` package.

## Dependencies

1. [provider](https://pub.dev/packages/provider) — State management
2. [shared_preferences](https://pub.dev/packages/shared_preferences) — Persistent local storage for checklist and custom contacts
3. [internet_connection_checker](https://pub.dev/packages/internet_connection_checker) — Monitors internet connectivity
4. [url_launcher](https://pub.dev/packages/url_launcher) — Opens phone dialer for emergency contact calls
5. [animations](https://pub.dev/packages/animations) — Smooth page transition animations
6. [location](https://pub.dev/packages/location) — Device location access (for future map feature)
7. [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) — Google Maps integration (planned for upcoming map feature)
