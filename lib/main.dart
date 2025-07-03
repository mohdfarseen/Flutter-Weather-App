import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/login_screen.dart';
import 'package:weatherapp/user_provider.dart';
import 'package:weatherapp/weather_screen.dart'; // We'll need this for authenticated state

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const WeatherApp(),
    ),
  );
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
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isAuthenticated) {
            return WeatherScreen(toggleTheme: toggleTheme);
          } else {
            return LoginScreen(toggleTheme: toggleTheme);
          }
        },
      ),
    );
  }
}
