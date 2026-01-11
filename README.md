# LookOut App
A mobile app built with Dart and the Flutter framework for hurricane preparedness


## Table of contents
[Features](#features)

[Instructions](#instructions)

[Usage](#usage)

[Functions](#functions)

## Features
### 1. Home Page:
- Displays a "Prepared-o-meter" to track your readiness.
- A weather update section to provide real-time weather alerts (future implementation).
- A map that shows the location of the nearest hospitals, clinics, and emergency centers
### 2. Checklist Page
- A detailed list of essential supplies for emergencies.
- Interactive checkboxes to track the items you have prepared.
- The progress bar updates as you check off items.

### 3. Emergency Contact Page
- Automatically fetches and displays emergency contacts (police, ambulance, fire department) based on your location.
- Supports multiple contacts for each service.

### 4. Settings Page
- Theme Selection (Dark and Light)
- Country selection for when the device is not connected to the internet

### 5. Navigation Bar
- An intuitive navigation bar allows easy switching between pages.
- Specify which page is currently on

## Instructions
1. Download and set up the Flutter SDK
2. Clone this repository and run the app
   
## Usage
1. Open the mobile app on your phone or an emulator
   
2. The app will detect your public IP and automatically determine your country using an IP geolocation service(future impementation)
   
3. Navigate through the app using the buttons in the navigation bar
    - Home Button: View your preparedness progress and weather updates
    - Checklist Button: Access and interact with the checklist of essential supplies
    - Contacts Button: View emergency contact information for your country
    -Settings Button: Change your theme and select your country


## Functions

`main()`
- The main function that initializes and runs the application
- Sets up the window title, size, and icon
- Makes the window non-resizable and centers it on screen

`layout()`
- Creates the entire layout of the application
- Sets up four main frames: home, checklist, contacts, and settings
- Configures the navigation bar and theme settings

`getcountry(IP: str)`
- Takes a public IP address as input
- Returns location information including country name, latitude, and longitude
- Uses the apiip.net service for geolocation

`emergency_contacts(Country_name: str)`
- Retrieves emergency contact information for a specific country
- Returns a dictionary containing police, ambulance, and fire department numbers
- Sources data from country_data.json

`has_internet_connection()`
- Checks if the device has an active internet connection
- Returns True if connected, False otherwise
- Tests connection by attempting to reach Google's DNS (8.8.8.8)

`weather_status(location_info: dict)`
- Gets current weather information based on latitude and longitude
- Returns weather conditions, temperature, and description
- Uses OpenWeatherMap API for weather data

`getIP()`
- Gets the device's public IP address
- Returns the IP address as a string
- Uses the public_ip library

`weather_stuff()`
- Combines multiple functions to get complete weather information
- Updates global variables for weather display
- Handles both online and offline scenarios using cached data

Additional Functions:

`get_essentials()`
- Returns a list of essential items for hurricane preparedness
- Reads from essetial_items.txt file

`country_options()`
- Returns a list of supported countries
- Used for the location dropdown menu

`check_month(number: str)`
- Converts numeric month to month name
- Used for formatting dates in weather updates

`center_window(window)`
- Centers the application window on the screen

## Dependencies

1. Internet_connection_checker [check it out here](https://pub.dev/packages/internet_connection_checker)
2. Url_launcher [check it out here](https://pub.dev/packages/url_launcher)
3. Google_maps_flutter [check it out here](https://pub.dev/packages/google_maps_flutter) currently in testing for the map feature
