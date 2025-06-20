import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  String city = "London";
  final String apiKey = '0808abb18b81ea0130261ab7324a7a59';

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    final urlCurrent =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    final urlForecast =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(urlCurrent));
      final forecastResponse = await http.get(Uri.parse(urlForecast));

      if (response.statusCode == 200 && forecastResponse.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          forecastData = json.decode(forecastResponse.body)['list'];
        });
      } else {
        print("Error fetching weather data.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  String getWeatherImage(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("sun")) return 'assets/sunny.jpg';
    if (condition.contains("cloud")) return 'assets/cloudy.jpg';
    if (condition.contains("rain")) return 'assets/rainy.jpg';
    if (condition.contains("snow")) return 'assets/snow.jpg';
    return 'assets/default.jpg';
  }

  String getWeatherEmoji(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("sun")) return '☀️';
    if (condition.contains("cloud")) return '☁️';
    if (condition.contains("rain")) return '🌧';
    if (condition.contains("snow")) return '❄️';
    return '🌡️';
  }

  Widget weatherDetails() {
    if (weatherData == null) return const CircularProgressIndicator();

    final condition = weatherData!['weather'][0]['main'].toString().toLowerCase();
    final image = getWeatherImage(condition);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Column(
        children: [
          Text(
            '${weatherData!['name']}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${weatherData!['main']['temp']}°C',
            style: const TextStyle(fontSize: 40),
          ),
          Text('${weatherData!['weather'][0]['main']}'),
          Text('Humidity: ${weatherData!['main']['humidity']}%'),
        ],
      ),
    );
  }

  Widget forecastDetails() {
    if (forecastData == null) return const SizedBox();

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await fetchWeather();
        },
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            final data = forecastData![index * 8];
            final date = DateTime.parse(data['dt_txt']);
            final condition = data['weather'][0]['main'].toString();
            final emoji = getWeatherEmoji(condition);

            return Container(
              height: 90,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Text(
                  emoji,
                  style: const TextStyle(fontSize: 30),
                ),
                title: Text(
                  '${date.day}/${date.month}',
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${data['main']['temp'].toStringAsFixed(1)}°C'),
                    Text(condition),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter city",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      city = _controller.text;
                      fetchWeather();
                    });
                  },
                ),
              ),
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
