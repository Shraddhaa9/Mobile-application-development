import 'package:flutter/material.dart';
import 'package:mp5/components/weather_api.dart';
import 'package:mp5/Model/settings_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsModel().initPrefs();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
      debugShowCheckedModeBanner: false, // Set this to false
    );
  }
}
