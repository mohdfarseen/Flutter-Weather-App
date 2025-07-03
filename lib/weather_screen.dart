import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weatherapp/user_provider.dart';
import 'package:weatherapp/auth_service.dart'; // For logout

class WeatherScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const WeatherScreen({required this.toggleTheme, super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? weatherData;
  List<dynamic>? forecastData;
  String city = "London"; // Default city
  final String apiKey = '0808abb18b81ea0130261ab7324a7a59'; // Replace with your actual API key
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Fetch weather for the default or last searched city
    // Consider saving last searched city in shared_preferences for persistence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isAuthenticated) {
        // You could personalize the default city based on user preferences later
      }
      fetchWeather();
    });
  }

  Future<void> fetchWeather() async {
    if (city.isEmpty) {
      // Optionally show a message to enter a city
      return;
    }
    final urlCurrent =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final urlForecast =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(urlCurrent));
      final forecastResponse = await http.get(Uri.parse(urlForecast));

      if (mounted) { // Check if the widget is still in the tree
        if (response.statusCode == 200 && forecastResponse.statusCode == 200) {
          setState(() {
            weatherData = json.decode(response.body);
            forecastData = json.decode(forecastResponse.body)['list'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching weather for $city. Please check the city name.')),
          );
          print("Error fetching weather data. Status codes: ${response.statusCode}, ${forecastResponse.statusCode}");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
      print("Error: $e");
    }
  }

  String getWeatherImage(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("sun") || condition.contains("clear")) return 'assets/sunny.jpg';
    if (condition.contains("cloud")) return 'assets/cloudy.jpg';
    if (condition.contains("rain") || condition.contains("drizzle")) return 'assets/rainy.jpg';
    if (condition.contains("snow") || condition.contains("sleet")) return 'assets/snow.jpg';
    return 'assets/default.jpg';
  }

  String getWeatherEmoji(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("sun") || condition.contains("clear")) return '☀️';
    if (condition.contains("cloud")) return '☁️';
    if (condition.contains("rain") || condition.contains("drizzle")) return '🌧';
    if (condition.contains("snow") || condition.contains("sleet")) return '❄️';
    if (condition.contains("thunderstorm")) return '⛈️';
    if (condition.contains("mist") || condition.contains("fog") || condition.contains("haze")) return '🌫️';
    return '🌡️';
  }

  Widget weatherDetails() {
    if (weatherData == null) return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Center(child: Text("Search for a city to see weather details.", textAlign: TextAlign.center,)),
    );

    final condition = weatherData!['weather'][0]['main'].toString();
    final image = getWeatherImage(condition);
    final temp = weatherData!['main']['temp'];
    final humidity = weatherData!['main']['humidity'];
    final windSpeed = weatherData!['wind']['speed'];


    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${weatherData!['name']}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${temp.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.w200),
            textAlign: TextAlign.center,
          ),
          Text(
            condition,
            style: const TextStyle(fontSize: 22, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _detailItem(Icons.water_drop_outlined, "Humidity", "$humidity%"),
              _detailItem(Icons.air, "Wind", "${windSpeed}m/s"),
            ],
          )
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }


  Widget forecastDetails() {
    if (forecastData == null) return const SizedBox.shrink(); // Use shrink if no data

    // Filter to get one forecast per day (approx. 24 hours apart)
    // OpenWeatherMap free tier returns data every 3 hours.
    List<dynamic> dailyForecasts = [];
    if (forecastData != null && forecastData!.isNotEmpty) {
      dailyForecasts.add(forecastData![0]); // Add the first one (closest to now)
      for (int i = 1; i < forecastData!.length; i++) {
        DateTime currentDate = DateTime.parse(forecastData![i]['dt_txt']);
        DateTime previousDate = DateTime.parse(dailyForecasts.last['dt_txt']);
        if (currentDate.day != previousDate.day) {
           if (dailyForecasts.length < 5) { // Limit to 5 days
            dailyForecasts.add(forecastData![i]);
           } else {
             break;
           }
        }
      }
    }


    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
            child: Text("5-Day Forecast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchWeather();
              },
              child: ListView.builder(
                itemCount: dailyForecasts.length,
                itemBuilder: (context, index) {
                  final data = dailyForecasts[index];
                  final date = DateTime.parse(data['dt_txt']);
                  final condition = data['weather'][0]['main'].toString();
                  final emoji = getWeatherEmoji(condition);
                  final temp = data['main']['temp'].toStringAsFixed(1);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Text(
                        emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                      title: Text(
                        '${_formatDate(date)}', // More readable date
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(condition),
                      trailing: Text(
                        '${temp}°C',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // e.g., "Mon, Jul 29"
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(user != null ? 'Hi, ${user.username}' : 'Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
          if (userProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text('Logout'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (confirmLogout == true) {
                  await _authService.logoutUser(); // Perform any backend logout if necessary
                  // Ensure context is still valid if operations are async before this point.
                  if (!mounted) return;
                  userProvider.logout(); // Clears user from provider
                  // Navigation to LoginScreen is handled by Consumer in main.dart
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter city name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        city = _controller.text;
                        weatherData = null; // Clear previous data for loading indicator
                        forecastData = null;
                      });
                      fetchWeather();
                      _controller.clear(); // Clear text field after search
                      FocusScope.of(context).unfocus(); // Dismiss keyboard
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                 if (value.isNotEmpty) {
                    setState(() {
                      city = value;
                      weatherData = null;
                      forecastData = null;
                    });
                    fetchWeather();
                    _controller.clear();
                    FocusScope.of(context).unfocus();
                  }
              },
            ),
            const SizedBox(height: 20),
            weatherDetails(),
            const SizedBox(height: 20),
            forecastDetails(),
          ],
        ),
      ),
    );
  }
}
