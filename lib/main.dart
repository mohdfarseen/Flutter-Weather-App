import 'package:flutter/material.dart';
import 'package:weatherapp/weather_screen.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ✅ Hide the debug banner
      title: 'Weather App',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: WeatherScreen(toggleTheme: toggleTheme),
    );
  }
}
