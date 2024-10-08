import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel {
  SharedPreferences? _prefs;

  // Singleton pattern to access the model globally
  static final SettingsModel _instance = SettingsModel._internal();
  factory SettingsModel() {
    return _instance;
  }
  SettingsModel._internal();

  // Initialize SharedPreferences
  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Wind speed unit preferences
  String get windSpeedUnit => _prefs?.getString('windSpeedUnit') ?? 'km/h';
  set windSpeedUnit(String value) => _prefs?.setString('windSpeedUnit', value);

  // Getter for temperature unit with a default value
  String get temperatureUnit {
    return _prefs?.getString('temperatureUnit') ??
        'Celsius'; // Default to Celsius
  }

  // Getter for last selected location with a default value
  String get lastLocation {
    return _prefs?.getString('lastLocation') ??
        'Default Location'; // Default location
  }

  // Example of a boolean preference getter
  bool get isDarkModeEnabled {
    return _prefs?.getBool('isDarkModeEnabled') ?? false; // Default to false
  }

  // Setters remain unchanged, to allow changing the settings
  Future<bool> setTemperatureUnit(String unit) async {
    return await _prefs?.setString('temperatureUnit', unit) ?? false;
  }

  Future<bool> setLastLocation(String location) async {
    return await _prefs?.setString('lastLocation', location) ?? false;
  }

  Future<bool> setIsDarkModeEnabled(bool isEnabled) async {
    return await _prefs?.setBool('isDarkModeEnabled', isEnabled) ?? false;
  }

  // You can add more getters and setters as needed
}
