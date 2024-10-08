import 'package:flutter/foundation.dart';
import 'package:mp5/Model/settings_model.dart';

class WeatherModel {
  double _rawTemperature; // Raw temperature in Kelvin
  double _temperature; // Store temperature in Celsius
  final String description;
  final String icon;
  final double lat;
  final double lon;
  final int pressure;
  final int humidity;
  double _windSpeed;
  final String alertsDescription;
  final String timezone;
  final SettingsModel settingsModel; // Dependency on SettingsModel

  WeatherModel({
    required double temperature,
    required this.description,
    required this.icon,
    required this.lat,
    required this.lon,
    required this.pressure,
    required this.humidity,
    required double windSpeed,
    required this.alertsDescription,
    required this.timezone,
    required this.settingsModel,
  })  : _windSpeed = windSpeed,
        _rawTemperature = temperature,
        _temperature = temperature -
            273.15; // Initialize Celsius temperature at construction

  double get temperature {
    double tempInCelsius = _kelvinToCelsius(_rawTemperature);
    return settingsModel.temperatureUnit == 'Fahrenheit'
        ? _celsiusToFahrenheit(tempInCelsius)
        : tempInCelsius;
  }

  // Convert Kelvin to Celsius
  double _kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }

  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  void updateTemperature(double newTemp) {
    _temperature = newTemp;
  }

  // Convert wind speed based on user preference
  double get windSpeed {
    return settingsModel.windSpeedUnit == 'mph'
        ? _metersPerSecondToMilesPerHour(_windSpeed)
        : _metersPerSecondToKilometersPerHour(_windSpeed);
  }

  double _metersPerSecondToKilometersPerHour(double mps) {
    return mps * 3.6;
  }

  double _metersPerSecondToMilesPerHour(double mps) {
    return mps * 2.237;
  }

  factory WeatherModel.fromJson(
      Map<String, dynamic> json, SettingsModel settingsModel) {
    try {
      return WeatherModel(
        temperature: (json['main']['temp'] is int)
            ? (json['main']['temp'] as int).toDouble()
            : json['main']['temp'] as double? ?? 0.0,
        description: json['weather'][0]['description'] as String? ?? '',
        icon: json['weather'][0]['icon'] as String? ?? '',
        lat: json['coord']['lat'] as double? ?? 0.0,
        lon: json['coord']['lon'] as double? ?? 0.0,
        pressure: json['main']['pressure'] as int? ?? 0,
        humidity: json['main']['humidity'] as int? ?? 0,
        windSpeed: json['wind']['speed'] as double? ?? 0.0,
        alertsDescription: json['weather'][0]['main'] as String? ?? '',
        timezone: json['sys']['country'] as String? ?? '',
        settingsModel: settingsModel,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing weather data: $e');
      }
      return WeatherModel(
        temperature: 0.0,
        description: '',
        icon: '',
        lat: 0.0,
        lon: 0.0,
        pressure: 0,
        humidity: 0,
        windSpeed: 0.0,
        alertsDescription: '',
        timezone: '',
        settingsModel: settingsModel,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': _temperature,
      'description': description,
      'icon': icon,
      'lat': lat,
      'lon': lon,
      'pressure': pressure,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'alertsDescription': alertsDescription,
      'timezone': timezone,
    };
  }
}
