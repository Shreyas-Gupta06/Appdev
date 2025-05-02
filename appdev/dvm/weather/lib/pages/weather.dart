import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart'; // Add this package
import '../models.dart';

class Weather extends StatefulWidget {
  final City city;

  const Weather({super.key, required this.city});

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();

    fetchWeather();
  }

  @override
  void didUpdateWidget(covariant Weather oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != oldWidget.city) {
      fetchWeather();
    }
  }

  Future<void> fetchWeather() async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${widget.city.lat}&lon=${widget.city.lon}&appid=818f4d62d5d9effa00161901cf700f2d&units=metric',
    );

    try {
      print(
        '🔍 Fetching weather data for ${widget.city.name}, lat=${widget.city.lat}, lon=${widget.city.lon}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          weatherData = data;
          isLoading = false;
          hasError = false;
        });

        // Update the City object with fetched weather data
        widget.city.temperature = data['main']['temp'];
        widget.city.weatherCondition = data['weather'][0]['main'];
        widget.city.weatherIcon = data['weather'][0]['icon'];
        widget.city.humidity = data['main']['humidity'];
        widget.city.windSpeed = data['wind']['speed'];
        widget.city.lastUpdated = DateTime.now();

        // Save or update the city in global list and prefs
        await addOrUpdateCity(widget.city);
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      // Check for internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // No internet connection
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No Internet Connection')));

        setState(() {
          isLoading = false;
          hasError = false; // Show saved data instead of an error
        });
      } else {
        // Other errors
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Failed to fetch weather: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: fetchWeather, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (weatherData == null) {
      return const Center(
        child: Text(
          'No weather data available.',
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final temp = widget.city.temperature;
    final humidity = widget.city.humidity;
    final windSpeed = widget.city.windSpeed;
    final condition = widget.city.weatherCondition;
    final icon = widget.city.weatherIcon;
    final updatedTime = widget.city.lastUpdated;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            widget.city.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (icon != null)
            Image.network(
              'http://openweathermap.org/img/wn/$icon@2x.png',
              width: 100,
              height: 100,
            ),
          Text('$temp°C', style: const TextStyle(fontSize: 40)),
          Text(condition ?? 'Unknown', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Icon(Icons.opacity, size: 30),
                  const Text('Humidity'),
                  Text('$humidity%', style: const TextStyle(fontSize: 18)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.air, size: 30),
                  const Text('Wind Speed'),
                  Text('$windSpeed m/s', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Last updated: ${updatedTime?.hour}:${updatedTime?.minute}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
