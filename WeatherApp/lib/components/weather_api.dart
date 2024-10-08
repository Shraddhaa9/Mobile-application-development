import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mp5/Model/weather_model.dart';
import 'package:mp5/Model/settings_model.dart';
import 'weather_alert.dart';
import 'weather_details_page.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  WeatherModel? _weather;
  List<WeatherAlert>? _alerts;
  final settingsModel = SettingsModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🌐 Weather App 🌐',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Enter City Name'),
              ),
            ),
            ElevatedButton(
              onPressed: () => _fetchWeather(),
              child: const Text('Get Weather'),
            ),
            if (_weather != null) ...[
              _buildWeatherTable(),
              ElevatedButton(
                onPressed: () {
                  if (_weather != null) {
                    _navigateToDetailsPage(_weather!.toJson());
                  } else {
                    print('Weather data is not available.');
                  }
                },
                child: const Text('View Details'),
              )
            ],
            if (_alerts != null && _alerts!.isNotEmpty) ...[
              _buildAlerts(),
            ],
            // Temperature Unit Dropdown with label
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Temperature: "), // Label for the dropdown
                DropdownButton<String>(
                  value: settingsModel
                      .temperatureUnit, // Use as a property, not a method
                  onChanged: (String? newValue) {
                    if (newValue != null &&
                        newValue != settingsModel.temperatureUnit) {
                      setState(() {
                        settingsModel.setTemperatureUnit(
                            newValue); // Update the temperature unit
                      });
                    }
                  },
                  items: <String>['Celsius', 'Fahrenheit']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Wind Speed Unit Dropdown with label
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Wind Speed: "), // Label for the dropdown
                DropdownButton<String>(
                  value: settingsModel
                      .windSpeedUnit, // Use class name for static member access
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        settingsModel.windSpeedUnit =
                            newValue; // Use class name for static setter
                      });
                    }
                  },
                  items: <String>[
                    'km/h',
                    'mph'
                  ] // Options for the user to choose from
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _weather != null
          ? FloatingActionButton(
              onPressed: () {
                if (_weather != null) {
                  _navigateToDetailsPage(_weather!.toJson());
                } else {
                  print('Weather data is not available.');
                }
              },
              child: const Icon(Icons.details),
            )
          : null,
    );
  }

  Widget buildGradientBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue.shade300, // Lighter shade at the top
            Colors.blue.shade900, // Darker shade at the bottom
          ],
        ),
      ),
      child: child,
    );
  }

  Widget _buildWeatherTable() {
    return buildGradientBackground(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
              .withOpacity(0.85), // Slight transparency to show the gradient
        ),
        child: Table(
          border: TableBorder.all(color: Colors.blue.shade200, width: 2),
          children: [
            _buildTableRow('Weather', '', _getWeatherEmoji(),
                fontSize: 48.0, color: Colors.orange),
            _buildTableRow(
                'Temperature',
                '${_weather!.temperature.toStringAsFixed(2)} °${settingsModel.temperatureUnit[0]}',
                '',
                fontSize: 32.0,
                color: Colors.orange),
            _buildTableRow('Description', _weather!.description, '',
                fontSize: 24.0, color: Colors.blue),
            _buildTableRow('Latitude', _weather!.lat.toString(), ''),
            _buildTableRow('Longitude', _weather!.lon.toString(), ''),
            _buildTableRow('Pressure', _weather!.pressure.toString(), ''),
            _buildTableRow('Humidity', _weather!.humidity.toString(), ''),
            _buildTableRow(
                'Wind Speed',
                '${_weather!.windSpeed.toStringAsFixed(2)} ${settingsModel.windSpeedUnit}',
                '',
                fontSize: 24.0,
                color: Colors.blue),
            _buildTableRow(
                'Alerts Description', _weather!.alertsDescription, ''),
            _buildTableRow('Country', _weather!.timezone, ''),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alerts:'),
        for (var alert in _alerts!) ...[
          ListTile(
            title: Text(alert.event),
            subtitle: Text(alert.description),
          ),
        ],
      ],
    );
  }

  TableRow _buildTableRow(String label, String value, String emoji,
      {double fontSize = 16.0, Color? color}) {
    return TableRow(
      children: [
        _buildTableCell(label),
        emoji.isEmpty
            ? _buildTableCell(value)
            : _buildEmojiCell(emoji, fontSize, color),
      ],
    );
  }

  Widget _buildEmojiCell(String emoji, double fontSize, Color? color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        emoji,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: fontSize, color: color ?? Colors.orange),
      ),
    );
  }

  Widget _buildTableCell(String text, {Color textColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getWeatherEmoji() {
    String icon = _weather!.icon;
    String suffix = icon.substring(icon.length - 1);

    switch (icon.substring(0, 2)) {
      case '01':
        return suffix == 'd' ? '☀️' : '🌙';
      case '02':
        return suffix == 'd' ? '⛅' : '☁️';
      case '03':
      case '04':
        return '☁️';
      case '09':
      case '10':
        return '🌧️';
      case '11':
        return '⛈️';
      case '13':
        return '❄️';
      case '50':
        return '🌫️';
      default:
        return '';
    }
  }

  Future<void> _fetchWeather() async {
    const apiKey = 'b1ba5bbbb0a0001e742f15d4ee320ed5';
    final city = _cityController.text;

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?q=$city&APPID=$apiKey'),
      );

      if (response.statusCode == 200) {
        final weatherJson = json.decode(response.body);
        setState(() {
          _weather = WeatherModel.fromJson(weatherJson, settingsModel);
        });
        _navigateToDetailsPage(weatherJson);
      } else {
        print('Failed to fetch weather: ${response.statusCode}');
        _showErrorSnackBar('Failed to fetch weather. Please try again.');
      }
    } catch (error) {
      print('Error: $error');
      _showErrorSnackBar('An error occurred. Please try again.');
    }
  }

  void _navigateToDetailsPage(Map<String, dynamic> weatherDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WeatherDetailsPage(weatherDetails: weatherDetails),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
